import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/app_localizations.dart';
import 'theme.dart';
import 'widgets.dart';

/// Selectable catalog / search result row.
class CatalogRow extends StatelessWidget {
  const CatalogRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.leading,
  });

  final String title;
  final String subtitle;
  final Widget trailing;
  final Widget? leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.isLight ? c.insetBorder : c.border),
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 10)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ts(14, weight: w600, color: c.textBody),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ts(10, weight: w500, color: c.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// A logged entry in a day's history, with delete.
class LoggedRow extends StatelessWidget {
  const LoggedRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.kcalLabel,
    required this.onDelete,
    required this.deleteTooltip,
    this.leading,
    this.kcalColor,
  });

  final String title;
  final String subtitle;
  final String kcalLabel;
  final Color? kcalColor;
  final Widget? leading;
  final VoidCallback onDelete;
  final String deleteTooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final kc = kcalColor ?? c.text;
    return NfInset(
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ts(12, weight: w700, color: c.textBody),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ts(9.5, color: c.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kcalColor == null ? c.subtle : kc.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kcalColor == null ? c.border : kc.withValues(alpha: 0.15)),
            ),
            child: Text(
              kcalLabel,
              style: ts(12, weight: w700, color: kc),
            ),
          ),
          IconButton(
            tooltip: deleteTooltip,
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
            icon: Icon(LucideIcons.trash2, size: 18, color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

/// "Add" button that flashes "Added" for a moment after a tap.
class FlashAddButton extends StatefulWidget {
  const FlashAddButton({super.key, required this.onAdd, this.color = NfColors.indigo, this.foreground = Colors.white});

  final Future<bool> Function() onAdd;
  final Color color;
  final Color foreground;

  @override
  State<FlashAddButton> createState() => _FlashAddButtonState();
}

class _FlashAddButtonState extends State<FlashAddButton> {
  var _added = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _tap() async {
    setState(() => _added = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _added = false);
    });
    final ok = await widget.onAdd();
    if (!ok && mounted) setState(() => _added = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final bg = _added
        ? NfColors.emerald.withValues(alpha: 0.15)
        : (c.isLight && widget.color == NfColors.indigo ? c.primary : widget.color);
    final fg = _added ? c.emeraldText : widget.foreground;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _added ? null : _tap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: _added ? Border.all(color: NfColors.emerald.withValues(alpha: 0.3)) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_added ? LucideIcons.check : LucideIcons.plus, size: 14, color: fg),
              const SizedBox(width: 6),
              Text(
                _added ? t.commonAdded : t.commonAdd,
                style: ts(12, weight: w700, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid of small labeled values (kcal / P / C / F).
class MacroGrid extends StatelessWidget {
  const MacroGrid({super.key, required this.items, this.inset = true});

  final List<(String label, String value, Color labelColor)> items;
  final bool inset;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final row = Row(
      children: [
        for (final (label, value, color) in items)
          Expanded(
            child: Column(
              children: [
                Text(
                  label,
                  style: ts(10, weight: w600, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: ts(12, weight: w700, color: c.text),
                ),
              ],
            ),
          ),
      ],
    );
    return inset ? NfInset(padding: const EdgeInsets.all(8), radius: 12, child: row) : row;
  }
}

/// Header row for an "Online results" section (globe + label + spinner).
class OnlineResultsLabel extends StatelessWidget {
  const OnlineResultsLabel({super.key, required this.searching, this.spinnerColor});
  final bool searching;
  final Color? spinnerColor;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(LucideIcons.globe, size: 12, color: c.textMuted),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context).foodOnlineResults.toUpperCase(),
            style: ts(10, mono: true, color: c.textMuted, letterSpacing: 0.8),
          ),
          if (searching) ...[const SizedBox(width: 6), Spinner(size: 11, color: spinnerColor)],
        ],
      ),
    );
  }
}

/// Bottom sheet frame used by the portion / duration adjusters.
Future<T?> showAdjustSheet<T>(BuildContext context, Widget Function(BuildContext) builder) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (ctx) {
    final c = ctx.nf;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: c.isLight ? c.cardBorder : c.borderStrong, width: c.cardBorderWidth),
          ),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.paddingOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: c.borderStrong, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            builder(ctx),
          ],
        ),
      ),
    );
  },
);
