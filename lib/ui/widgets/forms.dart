import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';

/// Numeric text field for amounts and percentages.
///
/// iOS number pads have no minus key, so [allowNegative] adds a ± button.
class NumberField extends StatefulWidget {
  const NumberField({
    super.key,
    required this.controller,
    required this.label,
    this.suffix = '€',
    this.hint,
    this.helper,
    this.allowNegative = false,
    this.required = false,
    this.integer = false,
    this.autofocus = false,
    this.onChanged,
    this.textInputAction,
    this.big = false,
  });

  final TextEditingController controller;
  final String label;
  final String? suffix;
  final String? hint;
  final String? helper;
  final bool allowNegative;
  final bool required;
  final bool integer;
  final bool autofocus;
  final ValueChanged<double?>? onChanged;
  final TextInputAction? textInputAction;

  /// Large centered style for the main amount of a form.
  final bool big;

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  void _toggleSign() {
    final t = widget.controller.text.trim();
    widget.controller.text = t.startsWith('-') ? t.substring(1) : (t.isEmpty ? '-' : '-$t');
    widget.controller.selection = TextSelection.collapsed(offset: widget.controller.text.length);
    widget.onChanged?.call(parseAmount(widget.controller.text));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = widget.big
        ? money(context.text.headlineMedium)
        : money(context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600));
    return TextFormField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      style: style,
      textAlign: widget.big ? TextAlign.center : TextAlign.start,
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      keyboardType: TextInputType.numberWithOptions(decimal: !widget.integer, signed: widget.allowNegative),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(widget.allowNegative ? r'[0-9.,\-−]' : r'[0-9.,]'))],
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helper,
        suffixText: widget.suffix,
        prefixIcon: widget.allowNegative
            ? IconButton(
                tooltip: l.toggleSign,
                icon: const Icon(Icons.exposure_rounded),
                onPressed: _toggleSign,
              )
            : null,
      ),
      onChanged: (v) => widget.onChanged?.call(parseAmount(v)),
      validator: (v) {
        final text = v?.trim() ?? '';
        if (text.isEmpty || text == '-') return widget.required ? l.requiredField : null;
        final parsed = parseAmount(text);
        if (parsed == null) return l.invalidNumber;
        if (widget.integer && parsed != parsed.roundToDouble()) return l.invalidNumber;
        return null;
      },
    );
  }
}

/// Tappable field that opens a date picker.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.allowClear = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool allowClear;

  @override
  Widget build(BuildContext context) {
    final fmt = Fmt.of(context);
    final l = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: allowClear && value != null
              ? IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => onChanged(null))
              : const Icon(Icons.calendar_today_rounded, size: 20),
        ),
        child: Text(
          value == null ? l.notSet : fmt.date(value!),
          style: context.text.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: value == null ? context.fin.muted : null,
          ),
        ),
      ),
    );
  }
}

class PickerOption<T> {
  const PickerOption({required this.value, required this.label, this.subtitle, this.leading});

  final T value;
  final String label;
  final String? subtitle;
  final Widget? leading;
}

/// Field showing the selected option; opens a bottom sheet to choose.
class PickerField<T> extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<PickerOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = options.where((o) => o.value == value).firstOrNull;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showOptionSheet<T>(context, title: label, options: options, selected: value);
        if (picked != null) onChanged(picked.value);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        child: Row(
          children: [
            if (selected?.leading != null) ...[selected!.leading!, const SizedBox(width: 10)],
            Expanded(
              child: Text(
                selected?.label ?? '',
                style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps the chosen option so that `null` can be a valid choice.
class Picked<T> {
  const Picked(this.value);
  final T value;
}

Future<Picked<T>?> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<PickerOption<T>> options,
  T? selected,
}) {
  return showModalBottomSheet<Picked<T>>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(title, style: context.text.titleLarge),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  for (final o in options)
                    ListTile(
                      leading: o.leading,
                      title: Text(o.label),
                      subtitle: o.subtitle == null ? null : Text(o.subtitle!),
                      trailing: o.value == selected
                          ? Icon(Icons.check_circle_rounded, color: context.colors.primary)
                          : null,
                      onTap: () => Navigator.pop(context, Picked(o.value)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  String? confirmLabel,
  bool destructive = true,
}) async {
  final l = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
        TextButton(
          style: destructive ? TextButton.styleFrom(foregroundColor: context.fin.negative) : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel ?? l.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Standard padding for form screens.
const formPadding = EdgeInsets.fromLTRB(20, 8, 20, 32);

/// Vertical gap between form fields.
const fieldGap = SizedBox(height: 14);
