import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'theme.dart';

/// Text style shorthand matching the web's Tailwind sizes (px ≈ logical px).
TextStyle ts(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color? color,
  bool mono = false,
  double? height,
  double? letterSpacing,
  FontStyle? style,
}) => TextStyle(
  fontSize: size,
  fontWeight: weight,
  color: color,
  fontFamily: mono ? fontMono : fontSans,
  height: height,
  letterSpacing: letterSpacing,
  fontStyle: style,
);

const w500 = FontWeight.w500;
const w600 = FontWeight.w600;
const w700 = FontWeight.w700;
const w800 = FontWeight.w800;
const w900 = FontWeight.w900;

/// Rounded surface card (bg-[#141923] rounded-3xl border border-white/5).
class NfCard extends StatelessWidget {
  const NfCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 24,
    this.gradient,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? c.card) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? c.cardBorder, width: c.cardBorderWidth),
        boxShadow: c.cardShadow,
      ),
      child: child,
    );
  }
}

/// Inner well inside a card (bg-[#0B0E14] border-white/5).
class NfInset extends StatelessWidget {
  const NfInset({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 16,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.inset,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? c.insetBorder),
      ),
      child: child,
    );
  }
}

enum NfButtonVariant { primary, green, emerald, secondary, ghost, danger, amber, white }

class NfButton extends StatelessWidget {
  const NfButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.variant = NfButtonVariant.primary,
    this.expand = false,
    this.small = false,
    this.gradient = false,
    this.leading,
  });

  final String label;
  final IconData? icon;
  final Widget? leading;
  final VoidCallback? onPressed;
  final bool loading;
  final NfButtonVariant variant;
  final bool expand;
  final bool small;

  /// Indigo / emerald gradient fill (AI Coach buttons).
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final disabled = onPressed == null || loading;

    late Color bg;
    late Color fg;
    Color? border;
    Gradient? grad;
    switch (variant) {
      case NfButtonVariant.primary:
        bg = c.primary;
        fg = c.onPrimary;
        if (gradient && !c.isLight) grad = const LinearGradient(colors: [NfColors.indigo, NfColors.indigoLight]);
      case NfButtonVariant.green:
        bg = NfColors.green;
        fg = const Color(0xFF0B0E14);
      case NfButtonVariant.emerald:
        bg = NfColors.emerald;
        fg = Colors.white;
        if (gradient) grad = const LinearGradient(colors: [NfColors.emerald, NfColors.emeraldSoft]);
      case NfButtonVariant.secondary:
        bg = c.inset;
        fg = c.textSecondary;
        border = c.borderStrong;
      case NfButtonVariant.ghost:
        bg = c.subtle;
        fg = c.textSecondary;
      case NfButtonVariant.danger:
        bg = const Color(0xFFE11D48);
        fg = Colors.white;
      case NfButtonVariant.amber:
        bg = NfColors.amberDark;
        fg = Colors.white;
      case NfButtonVariant.white:
        bg = Colors.white;
        fg = const Color(0xFF1F2937);
        if (c.isLight) border = c.border;
    }

    // Filled buttons go flat grey when disabled (disabled:bg-white/5); the
    // loading state keeps its color so the spinner reads as progress.
    final flatDisabled =
        onPressed == null && !loading && variant != NfButtonVariant.secondary && variant != NfButtonVariant.ghost;
    if (flatDisabled) {
      bg = c.subtle;
      fg = c.textMuted;
      grad = null;
    }

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox.square(
            dimension: small ? 14 : 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else if (leading != null)
          leading!
        else if (icon != null)
          Icon(icon, size: small ? 14 : 16, color: fg),
        if (loading || icon != null || leading != null) SizedBox(width: small ? 6 : 8),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: ts(small ? 12 : 14, weight: w700, color: fg),
          ),
        ),
      ],
    );

    return Opacity(
      opacity: loading ? 0.85 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: grad == null ? bg : null,
            gradient: grad,
            borderRadius: BorderRadius.circular(12),
            border: border == null ? null : Border.all(color: border, width: c.isLight ? 1.5 : 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: disabled
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onPressed!();
                  },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: small ? 12 : 16, vertical: small ? 8 : 11),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small icon-only square button (header actions).
class NfIconButton extends StatelessWidget {
  const NfIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
    this.size = 18,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final btn = Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: c.subtle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.borderStrong, width: c.isLight ? 1.5 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(icon, size: size, color: color ?? c.textSecondary),
          ),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

class NfTextField extends StatelessWidget {
  const NfTextField({
    super.key,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.suffixText,
    this.keyboardType,
    this.obscure = false,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.focusColor = NfColors.indigo,
    this.mono = false,
    this.textAlign = TextAlign.start,
    this.dense = false,
    this.autofocus = false,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.fontSize = 14,
    this.fontWeight,
    this.borderless = false,
  });

  final TextEditingController controller;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? suffixText;
  final TextInputType? keyboardType;
  final bool obscure;
  final int maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Color focusColor;
  final bool mono;
  final TextAlign textAlign;
  final bool dense;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final double fontSize;
  final FontWeight? fontWeight;
  final bool borderless;

  /// Decimal input that accepts both "." and "," as the separator.
  static final decimalFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
  static final integerFormatters = [FilteringTextInputFormatter.digitsOnly];

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final radius = BorderRadius.circular(c.isLight ? 8 : 12);
    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLines: obscure ? 1 : maxLines,
      minLines: minLines,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      textAlign: textAlign,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      style: ts(fontSize, color: c.text, mono: mono, weight: fontWeight ?? FontWeight.w400),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: ts(fontSize, color: c.isLight ? c.textFaint : c.textMuted, mono: mono),
        filled: !borderless,
        fillColor: c.isLight ? Colors.white : c.inset,
        contentPadding: borderless
            ? const EdgeInsets.symmetric(vertical: 4)
            : EdgeInsets.symmetric(horizontal: prefixIcon == null ? 12 : 0, vertical: dense ? 9 : 12),
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 16, color: c.textMuted),
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
        suffixIcon:
            suffix ??
            (suffixText == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(suffixText!, style: ts(12, color: c.textMuted)),
                  )),
        suffixIconConstraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        border: borderless ? InputBorder.none : outline(c.borderStrong, c.isLight ? 2 : 1),
        enabledBorder: borderless ? InputBorder.none : outline(c.borderStrong, c.isLight ? 2 : 1),
        focusedBorder: borderless ? InputBorder.none : outline(focusColor, 2),
      ),
    );
  }
}

/// Label above a field (text-xs text-[#94A3B8] mb-1).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(text, style: ts(12, color: context.nf.textSecondary)),
        ),
        ?trailing,
      ],
    ),
  );
}

class SegmentOption<T> {
  const SegmentOption(this.value, this.label, this.icon);
  final T value;
  final String label;
  final IconData icon;
}

/// Pill tab switcher (the web's sub-tabs). [filled] = active tab gets an indigo
/// background (AI Coach); otherwise the active tab is a raised card with
/// [activeColor] text (Meals / Workouts).
class NfSegmented<T> extends StatelessWidget {
  const NfSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.activeColor,
    this.filled = false,
  });

  final List<SegmentOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final Color? activeColor;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: filled ? c.card : c.inset,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: filled ? c.cardBorder : c.insetBorder, width: filled ? c.cardBorderWidth : 1),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(o.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                  decoration: BoxDecoration(
                    color: o.value == selected ? (filled ? c.primary : c.card) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: o.value == selected && !filled ? Border.all(color: c.border) : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(o.icon, size: 14, color: _fg(c, o.value == selected)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          o.label,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: ts(12, weight: w600, color: _fg(c, o.value == selected)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _fg(NfColors c, bool active) {
    if (!active) return c.textSecondary;
    if (filled) return c.onPrimary;
    return activeColor ?? c.accent;
  }
}

/// Small rounded label (kcal pills, "15 Items Loaded", grade chips...).
class Pill extends StatelessWidget {
  const Pill(
    this.text, {
    super.key,
    this.color,
    this.background,
    this.borderColor,
    this.mono = false,
    this.size = 10,
    this.weight = w700,
    this.icon,
    this.padding,
  });

  final String text;
  final Color? color;
  final Color? background;
  final Color? borderColor;
  final bool mono;
  final double size;
  final FontWeight weight;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final fg = color ?? c.textSecondary;
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background ?? c.subtle,
        borderRadius: BorderRadius.circular(999),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: size + 2, color: fg), const SizedBox(width: 4)],
          Text(
            text,
            style: ts(size, weight: weight, color: fg, mono: mono),
          ),
        ],
      ),
    );
  }
}

/// Gradient flame tile — the NutriFlow brand mark.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 32, this.radius});
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius ?? size * 0.3),
      gradient: const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [NfColors.indigo, NfColors.purple],
      ),
      boxShadow: [
        BoxShadow(color: NfColors.indigo.withValues(alpha: 0.3), blurRadius: size * 0.4, offset: Offset(0, size * 0.1)),
      ],
    ),
    child: Icon(LucideIcons.flame, color: Colors.white, size: size * 0.55),
  );
}

/// "Nutri" + accent "Flow".
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.size = 14});
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Nutri',
            style: ts(size, weight: w900, color: c.text, letterSpacing: -0.3),
          ),
          TextSpan(
            text: 'Flow',
            style: ts(size, weight: w900, color: c.accent, letterSpacing: -0.3),
          ),
        ],
      ),
    );
  }
}

/// Card heading: icon + bold title (+ optional trailing widget).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.titleColor,
    this.trailing,
    this.size = 16,
  });

  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Color? titleColor;
  final Widget? trailing;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    return Row(
      children: [
        if (icon != null) ...[Icon(icon, size: 16, color: iconColor ?? c.accent), const SizedBox(width: 8)],
        Expanded(
          child: Text(
            title,
            style: ts(size, weight: w700, color: titleColor ?? c.text),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

enum MessageKind { error, warning, success, info }

/// Tinted inline message (error / warning / success / info).
class MessageBox extends StatelessWidget {
  const MessageBox(this.text, {super.key, this.kind = MessageKind.error, this.trailing});

  final String text;
  final MessageKind kind;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final (Color fg, Color tint, IconData icon) = switch (kind) {
      MessageKind.error => (c.roseText, NfColors.rose, LucideIcons.circleAlert),
      MessageKind.warning => (c.amberText, NfColors.amber, LucideIcons.circleAlert),
      MessageKind.success => (c.emeraldText, NfColors.emerald, LucideIcons.circleCheck),
      MessageKind.info => (c.accent, NfColors.indigo, LucideIcons.sparkles),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: c.isLight ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.isLight ? fg : tint.withValues(alpha: 0.25), width: c.isLight ? 1.5 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 16, color: fg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: ts(12, color: fg, height: 1.4, weight: c.isLight ? w600 : FontWeight.w400),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class Spinner extends StatelessWidget {
  const Spinner({super.key, this.size = 16, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CircularProgressIndicator(strokeWidth: 2, color: color ?? context.nf.accent),
  );
}

/// Rounded square icon tile (w-10 h-10 rounded-xl bg-color/10).
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.iconSize,
    this.radius = 12,
    this.bordered = false,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double? iconSize;
  final double radius;
  final bool bordered;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(radius),
      border: bordered ? Border.all(color: color.withValues(alpha: 0.2)) : null,
    ),
    child: Icon(icon, size: iconSize ?? size * 0.5, color: color),
  );
}

/// Vertical spacing helper for column children (space-y-*).
List<Widget> spaced(List<Widget> children, double gap) => [
  for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(height: gap), children[i]],
];

/// Parse a user-entered number accepting "," as the decimal separator.
double? parseNum(String s) => double.tryParse(s.trim().replaceAll(',', '.'));
