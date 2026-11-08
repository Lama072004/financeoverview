import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rounded card with the subtle shadow of the design (border in dark mode).
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(20), this.onTap, this.color});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final radius = BorderRadius.circular(22);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? context.colors.surface,
        borderRadius: radius,
        boxShadow: fin.cardShadow,
        border: fin.cardBorder == null ? null : Border.all(color: fin.cardBorder!),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Small uppercase-ish card title with an optional trailing action.
class CardHeader extends StatelessWidget {
  const CardHeader(this.title, {super.key, this.trailing, this.icon});

  final String title;
  final Widget? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: context.fin.muted),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: context.text.labelLarge?.copyWith(color: context.fin.muted, letterSpacing: 0.1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Section title above grouped list cards.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.text.titleMedium)),
          ?trailing,
        ],
      ),
    );
  }
}

/// Amount with tabular figures; coloured by sign when [colored].
class Amount extends StatelessWidget {
  const Amount(
    this.text, {
    super.key,
    this.value,
    this.style,
    this.colored = false,
    this.invert = false,
    this.textAlign,
  });

  final String text;

  /// Used for the sign colour.
  final double? value;
  final TextStyle? style;
  final bool colored;

  /// For debts: an increase is bad.
  final bool invert;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final base = money(style ?? context.text.titleSmall);
    final v = value ?? 0;
    final color = colored ? context.fin.signed(invert ? -v : v, neutral: base.color) : null;
    return Text(
      text,
      style: color == null ? base : base.copyWith(color: color),
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Pill showing a signed change, e.g. "+120 € seit letzter Erfassung".
class DeltaChip extends StatelessWidget {
  const DeltaChip({super.key, required this.text, required this.value, this.label, this.invert = false});

  final String text;
  final double value;
  final String? label;
  final bool invert;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final v = invert ? -value : value;
    final color = fin.signed(v);
    final icon = v > 0.004
        ? Icons.arrow_upward_rounded
        : (v < -0.004 ? Icons.arrow_downward_rounded : Icons.remove_rounded);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 3),
              Text(text, style: money(context.text.labelMedium?.copyWith(color: color))),
            ],
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(label!, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ],
    );
  }
}

/// Rounded square with a tinted icon (categories, accounts, menu items).
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.color, this.size = 40});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, size: size * 0.52, color: readable(context, color)),
    );
  }

  /// Light chart colours get darkened in light mode so icons stay legible.
  static Color readable(BuildContext context, Color c) {
    if (Theme.of(context).brightness == Brightness.dark) return c;
    final hsl = HSLColor.fromColor(c);
    return hsl.lightness > 0.45 ? hsl.withLightness(0.36).toColor() : c;
  }
}

/// Thin rounded progress bar.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.color, this.height = 10});

  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: context.fin.track)),
            FractionallySizedBox(
              widthFactor: v,
              heightFactor: 1,
              alignment: Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height),
                  gradient: LinearGradient(
                    colors: [
                      (color ?? context.fin.accent).withValues(alpha: 0.85),
                      color ?? context.fin.accent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label/value row used in summary cards.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.amount,
    this.colored = false,
    this.emphasize = false,
    this.hint,
  });

  final String label;
  final String value;
  final double? amount;
  final bool colored;
  final bool emphasize;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final labelStyle = emphasize ? context.text.titleSmall : context.text.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                if (hint != null) Text(hint!, style: context.text.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Amount(
            value,
            value: amount,
            colored: colored,
            style: emphasize ? context.text.titleSmall : context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Friendly empty state with an optional call to action.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.body, this.action});

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: context.fin.accent, size: 48),
          const SizedBox(height: 14),
          Text(title, style: context.text.titleMedium),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(body!, style: context.text.bodyMedium?.copyWith(color: context.fin.muted)),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// Hint box with an info icon.
class InfoNote extends StatelessWidget {
  const InfoNote(this.text, {super.key, this.icon = Icons.info_outline_rounded});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.colors.onPrimaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: context.text.bodySmall?.copyWith(color: context.colors.onPrimaryContainer)),
          ),
        ],
      ),
    );
  }
}

/// Grouped list inside a card (settings, menus).
class ListCard extends StatelessWidget {
  const ListCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(const Divider(indent: 20, endIndent: 20));
      items.add(children[i]);
    }
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(children: items),
    );
  }
}
