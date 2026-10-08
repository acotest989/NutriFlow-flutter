import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/catalog_items.dart';
import '../../../models/log_entry.dart';
import '../../../services/ai_service.dart';
import '../../../state/app_controller.dart';
import '../../../state/providers.dart';
import '../../../state/settings_controller.dart';
import '../../entry_widgets.dart';
import '../../errors.dart';
import '../../theme.dart';
import '../../widgets.dart';

/// Snap-a-Meal (AI photo estimate) + barcode scanner. [active] is false while
/// another tab is showing, so the camera is released.
class ScanTab extends StatelessWidget {
  const ScanTab({super.key, required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) =>
      Column(children: spaced([const _PhotoAnalyzer(), _BarcodeScanner(active: active)], 24));
}

// ===================== Snap a Meal =====================

class _PhotoAnalyzer extends ConsumerStatefulWidget {
  const _PhotoAnalyzer();

  @override
  ConsumerState<_PhotoAnalyzer> createState() => _PhotoAnalyzerState();
}

class _PhotoAnalyzerState extends ConsumerState<_PhotoAnalyzer> {
  final _picker = ImagePicker();
  Uint8List? _preview;
  var _analyzing = false;
  String? _error;
  PhotoEstimate? _result;
  var _logged = false;
  var _runId = 0;

  final _name = TextEditingController();
  final _cal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _cal, _protein, _carbs, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  void _reset() => setState(() {
    _runId++; // drop any in-flight analysis
    _preview = null;
    _result = null;
    _error = null;
    _analyzing = false;
    _logged = false;
  });

  Future<void> _pick(ImageSource source) async {
    final t = AppLocalizations.of(context);
    setState(() {
      _error = null;
      _result = null;
      _logged = false;
    });
    XFile? file;
    try {
      // The picker scales + re-encodes, keeping the upload small.
      file = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 70);
    } on PlatformException catch (e) {
      debugPrint('Image picker failed: $e');
      if (mounted) setState(() => _error = t.photoErrCamera);
      return;
    }
    if (file == null || !mounted) return; // cancelled

    try {
      final bytes = await file.readAsBytes();
      await _analyze(bytes, _mimeOf(file));
    } catch (e) {
      if (mounted) setState(() => _error = t.photoErrRead);
    }
  }

  static String _mimeOf(XFile f) {
    final m = f.mimeType;
    if (m != null && m.startsWith('image/')) return m;
    final p = f.path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.webp')) return 'image/webp';
    if (p.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }

  Future<void> _analyze(Uint8List bytes, String mime) async {
    final t = AppLocalizations.of(context);
    final run = ++_runId;
    setState(() {
      _preview = bytes;
      _analyzing = true;
    });
    try {
      final r = await ref.read(aiServiceProvider).analyzePhoto(bytes, mime, ref.read(settingsProvider).language);
      if (!mounted || run != _runId) return;
      _name.text = r.name;
      _cal.text = fmtNum(r.calories);
      _protein.text = fmtNum(r.protein);
      _carbs.text = fmtNum(r.carbs);
      _fat.text = fmtNum(r.fat);
      setState(() => _result = r);
    } catch (e) {
      if (mounted && run == _runId) setState(() => _error = aiErrorText(t, e, t.photoErrAnalyze));
    } finally {
      if (mounted && run == _runId) setState(() => _analyzing = false);
    }
  }

  Future<void> _log() async {
    double v(TextEditingController c) => (parseNum(c.text) ?? 0).clamp(0, double.infinity).toDouble();
    final name = _name.text.trim().isEmpty ? 'Meal' : _name.text.trim();
    final ok = await ref
        .read(appProvider.notifier)
        .addEntry(
          NewEntry(
            date: ref.read(appProvider).currentDate,
            type: EntryType.meal,
            name: '$name (Photo)',
            calories: v(_cal).roundToDouble(),
            protein: v(_protein),
            carbs: v(_carbs),
            fat: v(_fat),
            quantity: 1,
          ),
        );
    if (!ok || !mounted) return;
    setState(() => _logged = true);
    Timer(const Duration(milliseconds: 1300), () {
      if (mounted) _reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final r = _result;
    final noFood = r != null && r.noFood;

    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: t.photoTitle, icon: LucideIcons.camera),
          const SizedBox(height: 4),
          Text(t.photoDesc, style: ts(12, color: c.textSecondary, height: 1.4)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: c.inset,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.insetBorder),
              ),
              child: _preview != null ? _previewBox(t) : _idleBox(t, c),
            ),
          ),
          if (_error != null) ...[const SizedBox(height: 16), MessageBox(_error!, kind: MessageKind.warning)],
          if (noFood && !_logged) ...[
            const SizedBox(height: 16),
            MessageBox(
              t.photoNoFood,
              kind: MessageKind.warning,
              trailing: GestureDetector(
                onTap: _reset,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.rotateCcw, size: 14, color: c.accent),
                    const SizedBox(width: 4),
                    Text(
                      t.photoRetry,
                      style: ts(12, weight: w600, color: c.accent),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_logged) ...[const SizedBox(height: 16), MessageBox(t.photoLoggedDiary, kind: MessageKind.success)],
          if (r != null && !noFood && !_logged) ...[const SizedBox(height: 16), _reviewCard(t, c, r)],
        ],
      ),
    );
  }

  Widget _idleBox(AppLocalizations t, NfColors c) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
    child: Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: c.card,
            shape: BoxShape.circle,
            border: Border.all(color: c.border),
          ),
          child: Icon(LucideIcons.camera, size: 24, color: c.accent),
        ),
        const SizedBox(height: 12),
        Text(
          t.photoIdleTitle,
          style: ts(14, weight: w600, color: c.textBody),
        ),
        const SizedBox(height: 4),
        Text(
          t.photoIdleDesc,
          style: ts(12, color: c.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            NfButton(
              label: t.photoTakePhoto,
              icon: LucideIcons.camera,
              small: true,
              onPressed: () => _pick(ImageSource.camera),
            ),
            NfButton(
              label: t.photoUpload,
              icon: LucideIcons.imagePlus,
              small: true,
              variant: NfButtonVariant.secondary,
              onPressed: () => _pick(ImageSource.gallery),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _previewBox(AppLocalizations t) => AspectRatio(
    aspectRatio: 16 / 9,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(_preview!, fit: BoxFit.cover, semanticLabel: t.photoPreviewAlt),
        if (!_logged)
          Positioned(
            top: 12,
            right: 12,
            child: _CircleButton(icon: LucideIcons.x, tooltip: t.photoRemovePhoto, onTap: _reset),
          ),
        if (_analyzing)
          Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spinner(size: 24),
                const SizedBox(height: 8),
                Text(t.photoAnalyzing, style: ts(12, color: const Color(0xFFE2E8F0))),
              ],
            ),
          ),
      ],
    ),
  );

  Widget _reviewCard(AppLocalizations t, NfColors c, PhotoEstimate r) {
    Widget field(String label, Color color, TextEditingController ctl) => Expanded(
      child: NfInset(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
        radius: 12,
        child: Column(
          children: [
            Text(
              label,
              style: ts(9, weight: w600, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            NfTextField(
              controller: ctl,
              borderless: true,
              mono: true,
              fontSize: 12,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: NfTextField.decimalFormatters,
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NfColors.indigo.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.isLight ? c.accent : NfColors.indigo.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Pill(
                t.photoAiEstimate.toUpperCase(),
                icon: LucideIcons.sparkles,
                size: 9,
                color: c.accent,
                background: NfColors.indigo.withValues(alpha: 0.2),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  t.photoReviewAdjust,
                  style: ts(10, color: c.textMuted),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          NfTextField(controller: _name, hint: t.photoMealNamePlaceholder, fontWeight: w600, dense: true),
          if (r.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final it in r.items)
                  Pill(
                    it,
                    icon: LucideIcons.utensils,
                    size: 10,
                    weight: FontWeight.w400,
                    color: c.isLight ? c.textBody : const Color(0xFFCBD5E1),
                    background: c.inset,
                    borderColor: c.border,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              field(t.photoCalories, c.accent, _cal),
              const SizedBox(width: 8),
              field(t.photoProteinG, NfColors.orange, _protein),
              const SizedBox(width: 8),
              field(t.photoCarbsG, NfColors.sky, _carbs),
              const SizedBox(width: 8),
              field(t.photoFatG, NfColors.yellow, _fat),
            ],
          ),
          if (r.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              r.note,
              style: ts(10, color: c.textSecondary, style: FontStyle.italic, height: 1.4),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: NfButton(
                  label: t.photoTryAnother,
                  icon: LucideIcons.rotateCcw,
                  variant: NfButtonVariant.secondary,
                  small: true,
                  expand: true,
                  onPressed: _reset,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NfButton(
                  label: t.photoLogMeal,
                  icon: LucideIcons.check,
                  small: true,
                  expand: true,
                  onPressed: _log,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===================== Barcode scanner =====================

class _BarcodeScanner extends ConsumerStatefulWidget {
  const _BarcodeScanner({required this.active});
  final bool active;

  @override
  ConsumerState<_BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends ConsumerState<_BarcodeScanner> with SingleTickerProviderStateMixin {
  final _barcode = TextEditingController();
  MobileScannerController? _camera;
  var _handled = false; // first detection wins; ignore the rest of the burst
  var _searching = false;
  var _flash = false;
  FoodItem? _result;
  String? _error;
  String? _status;

  late final AnimationController _laser;

  @override
  void initState() {
    super.initState();
    _laser = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _barcode.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant _BarcodeScanner old) {
    super.didUpdateWidget(old);
    if (!widget.active && _camera != null) _stopCamera(); // left the tab
  }

  @override
  void dispose() {
    _camera?.dispose();
    _laser.dispose();
    _barcode.dispose();
    super.dispose();
  }

  void _startCamera() {
    final t = AppLocalizations.of(context);
    setState(() {
      _error = null;
      _result = null;
      _handled = false;
      _status = t.scannerStatusPoint;
      _camera = MobileScannerController(
        formats: const [
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
          BarcodeFormat.code128,
        ],
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
    });
    _laser.repeat(reverse: true);
  }

  void _stopCamera() {
    final cam = _camera;
    _laser.stop();
    setState(() {
      _camera = null;
      _status = null;
    });
    cam?.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final value = capture.barcodes
        .map((b) => b.rawValue?.trim() ?? '')
        .firstWhere((v) => v.isNotEmpty, orElse: () => '');
    if (value.isEmpty) return;
    _handled = true;
    HapticFeedback.mediumImpact();
    _barcode.text = value;
    _stopCamera();
    _lookup(value);
  }

  Future<void> _lookup(String code) async {
    final t = AppLocalizations.of(context);
    if (code.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _error = null;
      _result = null;
      _flash = true;
    });
    Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _flash = false);
    });
    try {
      final food = await ref.read(foodDbProvider).lookupBarcode(code, ref.read(settingsProvider).language);
      if (mounted) setState(() => _result = food);
    } catch (e) {
      if (mounted) setState(() => _error = aiErrorText(t, e, t.scannerErrLookup));
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _log() async {
    final r = _result;
    if (r == null) return;
    final ok = await ref
        .read(appProvider.notifier)
        .addEntry(
          NewEntry(
            date: ref.read(appProvider).currentDate,
            type: EntryType.meal,
            name: '${r.name} (Scanned)',
            calories: r.calories,
            protein: r.protein,
            carbs: r.carbs,
            fat: r.fat,
            quantity: r.servingSize,
          ),
        );
    if (!ok || !mounted) return;
    setState(() => _result = null);
    _barcode.clear();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final r = _result;

    return NfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: t.scannerTitle, icon: LucideIcons.scan),
          const SizedBox(height: 4),
          Text(t.scannerDescSupported, style: ts(12, color: c.textSecondary, height: 1.4)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: c.inset,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.insetBorder),
              ),
              child: Stack(
                children: [
                  _camera != null ? _cameraView(t) : _idle(t, c),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: _flash ? 0.8 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const ColoredBox(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_status != null) ...[
            const SizedBox(height: 12),
            NfInset(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              radius: 8,
              child: Text(
                _status!,
                style: ts(12, color: c.textSecondary, style: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (_error != null) ...[const SizedBox(height: 12), MessageBox(_error!, kind: MessageKind.warning)],
          const SizedBox(height: 16),
          _DashedTop(color: c.border),
          const SizedBox(height: 16),
          FieldLabel(t.scannerManualLabel),
          Row(
            children: [
              Expanded(
                child: NfTextField(
                  controller: _barcode,
                  hint: t.scannerPlaceholder,
                  mono: true,
                  dense: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: NfTextField.integerFormatters,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _lookup,
                ),
              ),
              const SizedBox(width: 8),
              NfButton(
                label: t.scannerLookup,
                icon: LucideIcons.search,
                small: true,
                loading: _searching,
                onPressed: _searching || _barcode.text.trim().isEmpty ? null : () => _lookup(_barcode.text),
              ),
            ],
          ),
          if (r != null) ...[const SizedBox(height: 16), _resultCard(t, c, r)],
        ],
      ),
    );
  }

  Widget _idle(AppLocalizations t, NfColors c) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
    child: Center(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: c.card,
              shape: BoxShape.circle,
              border: Border.all(color: c.border),
            ),
            child: Icon(LucideIcons.camera, size: 24, color: c.accent),
          ),
          const SizedBox(height: 12),
          Text(
            t.scannerReadyTitle,
            style: ts(14, weight: w600, color: c.textBody),
          ),
          const SizedBox(height: 4),
          Text(
            t.scannerReadyDesc,
            style: ts(12, color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          NfButton(label: t.scannerUseCamera, icon: LucideIcons.camera, small: true, onPressed: _startCamera),
        ],
      ),
    ),
  );

  Widget _cameraView(AppLocalizations t) => AspectRatio(
    aspectRatio: 4 / 3,
    child: Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _camera,
          onDetect: _onDetect,
          errorBuilder: (context, error) {
            // Permission denied / no camera: fall back to manual entry.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _camera == null) return;
              _stopCamera();
              setState(() => _error = t.scannerErrCamera);
            });
            return const SizedBox.shrink();
          },
        ),
        IgnorePointer(
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NfColors.indigo.withValues(alpha: 0.5), width: 2),
            ),
          ),
        ),
        // Animated scan line.
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _laser,
            builder: (_, _) => Align(
              alignment: Alignment(0, -0.7 + 1.4 * Curves.easeInOut.transform(_laser.value)),
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: NfColors.indigoLight,
                  boxShadow: [BoxShadow(color: NfColors.indigo.withValues(alpha: 0.8), blurRadius: 10)],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('● ${t.scannerLiveViewport}', style: ts(10, mono: true, color: NfColors.indigoLight)),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: _CircleButton(icon: LucideIcons.x, tooltip: t.scannerStopCamera, onTap: _stopCamera),
        ),
      ],
    ),
  );

  Widget _resultCard(AppLocalizations t, NfColors c, FoodItem r) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: NfColors.indigo.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: c.isLight ? c.accent : NfColors.indigo.withValues(alpha: 0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Pill(
                    t.scannerMatchScanned.toUpperCase(),
                    size: 9,
                    color: c.accent,
                    background: NfColors.indigo.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    r.name,
                    style: ts(14, weight: w700, color: c.text),
                  ),
                  Text(
                    t.scannerServingQty(fmtNum(r.servingSize), r.servingUnit),
                    style: ts(10, color: c.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            NfInset(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              radius: 12,
              child: Text(
                '${fmtNum(r.calories)} kcal',
                style: ts(16, weight: w700, color: c.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MacroGrid(
          items: [
            (t.scannerProtein, '${fmtNum(r.protein)}g', NfColors.orange),
            (t.scannerCarbs, '${fmtNum(r.carbs)}g', NfColors.sky),
            (t.scannerFats, '${fmtNum(r.fat)}g', NfColors.yellow),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: NfButton(
                label: t.scannerClear,
                variant: NfButtonVariant.secondary,
                small: true,
                expand: true,
                onPressed: () => setState(() => _result = null),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NfButton(
                label: t.scannerLogToLog,
                icon: LucideIcons.check,
                small: true,
                expand: true,
                onPressed: _log,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.black.withValues(alpha: 0.6),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    ),
  );
}

class _DashedTop extends StatelessWidget {
  const _DashedTop({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, box) => Row(
      children: List.generate(
        (box.maxWidth / 8).floor(),
        (_) => Expanded(
          child: Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 2), color: color),
        ),
      ),
    ),
  );
}
