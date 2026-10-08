import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/app_localizations.dart';
import '../state/app_controller.dart';
import 'errors.dart';
import 'theme.dart';
import 'widgets.dart';

Future<void> showDeleteAccountDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _DeleteAccountDialog());

Future<void> showResetDataDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _ResetDataDialog());

/// Shared modal frame (rounded card, warning tile, close button).
class _ModalFrame extends StatelessWidget {
  const _ModalFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: c.isLight ? c.cardBorder : c.borderStrong, width: c.cardBorderWidth),
            boxShadow: c.cardShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  const _ModalHeader({required this.color, required this.onClose});
  final Color color;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTile(icon: LucideIcons.triangleAlert, color: color, size: 44, radius: 16, bordered: true),
        const Spacer(),
        IconButton(
          onPressed: onClose,
          tooltip: AppLocalizations.of(context).commonClose,
          icon: Icon(LucideIcons.x, size: 20, color: c.textMuted),
        ),
      ],
    );
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog();

  @override
  ConsumerState<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _confirm = TextEditingController();
  var _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _confirm.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  bool get _canDelete => _confirm.text.trim().toUpperCase() == 'DELETE' && !_loading;

  Future<void> _delete() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final nav = Navigator.of(context);
    final err = await ref.read(appProvider.notifier).deleteAccount();
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _error = appErrorText(AppLocalizations.of(context), err);
        _loading = false;
      });
      return;
    }
    nav.pop(); // signed out — the gate shows the auth screen
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final email = ref.watch(appProvider.select((s) => s.user?.email));
    return _ModalFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ModalHeader(color: c.roseText, onClose: _loading ? null : () => Navigator.of(context).pop()),
          const SizedBox(height: 16),
          Text(
            t.modalsDeleteTitle,
            style: ts(18, weight: w900, color: c.text),
          ),
          const SizedBox(height: 8),
          Text(
            t.modalsDeleteBody(email ?? t.modalsDeleteYourAccount),
            style: ts(12, color: c.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              style: ts(12, color: c.textSecondary),
              children: [
                TextSpan(text: '${t.modalsDeleteConfirmPre} '),
                TextSpan(
                  text: 'DELETE',
                  style: ts(12, weight: w700, mono: true, color: c.roseText),
                ),
                TextSpan(text: ' ${t.modalsDeleteConfirmPost}'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          NfTextField(controller: _confirm, hint: 'DELETE', autofocus: true, focusColor: NfColors.rose),
          if (_error != null) ...[const SizedBox(height: 12), MessageBox(_error!)],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: NfButton(
                  label: t.commonCancel,
                  variant: NfButtonVariant.ghost,
                  expand: true,
                  onPressed: _loading ? null : () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NfButton(
                  label: _loading ? t.modalsDeleting : t.modalsDeleteBtn,
                  icon: LucideIcons.trash2,
                  variant: NfButtonVariant.danger,
                  expand: true,
                  loading: _loading,
                  onPressed: _canDelete ? _delete : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResetDataDialog extends ConsumerStatefulWidget {
  const _ResetDataDialog();

  @override
  ConsumerState<_ResetDataDialog> createState() => _ResetDataDialogState();
}

class _ResetDataDialogState extends ConsumerState<_ResetDataDialog> {
  var _loading = false;
  var _done = false;
  String? _error;

  Future<void> _reset() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await ref.read(appProvider.notifier).resetData();
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _error = appErrorText(AppLocalizations.of(context), err);
        _loading = false;
      });
      return;
    }
    setState(() {
      _done = true;
      _loading = false;
    });
    // Brief success state, then close.
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 1100), () {
        if (mounted) Navigator.of(context).pop();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    return _ModalFrame(
      child: _done
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTile(icon: LucideIcons.check, color: c.emeraldText, size: 48, radius: 16, bordered: true),
                const SizedBox(height: 12),
                Text(
                  t.modalsResetDone,
                  style: ts(14, weight: w600, color: c.text),
                ),
                const SizedBox(height: 4),
                Text(t.modalsResetDoneNote, style: ts(12, color: c.textSecondary)),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModalHeader(color: c.amberText, onClose: _loading ? null : () => Navigator.of(context).pop()),
                const SizedBox(height: 16),
                Text(
                  t.modalsResetTitle,
                  style: ts(18, weight: w900, color: c.text),
                ),
                const SizedBox(height: 8),
                Text(t.modalsResetBody, style: ts(12, color: c.textSecondary, height: 1.5)),
                if (_error != null) ...[const SizedBox(height: 12), MessageBox(_error!)],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: NfButton(
                        label: t.commonCancel,
                        variant: NfButtonVariant.ghost,
                        expand: true,
                        onPressed: _loading ? null : () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NfButton(
                        label: _loading ? t.modalsResetting : t.modalsResetBtn,
                        icon: LucideIcons.rotateCcw,
                        variant: NfButtonVariant.amber,
                        expand: true,
                        loading: _loading,
                        onPressed: _loading ? null : _reset,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
