import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Row of dots showing how many digits were entered.
class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.length, required this.filled, this.error = false});

  final int length;
  final int filled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: error ? fin.negative : (i < filled ? context.colors.primary : Colors.transparent),
              border: Border.all(color: error ? fin.negative : context.colors.primary.withValues(alpha: 0.55), width: 1.6),
            ),
          ),
      ],
    );
  }
}

/// Numeric keypad. [extra] fills the bottom-left slot (e.g. biometrics).
class PinPad extends StatelessWidget {
  const PinPad({super.key, required this.onDigit, required this.onBackspace, this.extra, this.enabled = true});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final Widget? extra;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    Widget key(String digit) => _PadKey(
          enabled: enabled,
          onTap: () {
            HapticFeedback.selectionClick();
            onDigit(digit);
          },
          child: Text(digit, style: money(context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w600))),
        );

    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final r in rows) Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: r.map(key).toList()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 84, height: 84, child: Center(child: extra)),
            key('0'),
            _PadKey(
              enabled: enabled,
              onTap: onBackspace,
              background: false,
              child: Icon(Icons.backspace_outlined, color: context.fin.muted),
            ),
          ],
        ),
      ],
    );
  }
}

class _PadKey extends StatelessWidget {
  const _PadKey({required this.child, required this.onTap, required this.enabled, this.background = true});

  final Widget child;
  final VoidCallback onTap;
  final bool enabled;
  final bool background;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: background ? context.colors.surface : Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: SizedBox(width: 72, height: 72, child: Center(child: child)),
        ),
      ),
    );
  }
}
