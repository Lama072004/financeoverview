import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/prefs.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/session.dart';
import '../widgets/forms.dart';

class ChangeCredentialScreen extends ConsumerStatefulWidget {
  const ChangeCredentialScreen({super.key});

  @override
  ConsumerState<ChangeCredentialScreen> createState() => _ChangeCredentialScreenState();
}

class _ChangeCredentialScreenState extends ConsumerState<ChangeCredentialScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _repeat = TextEditingController();
  late CredentialType _type = ref.read(sessionProvider).header!.credentialType;
  bool _busy = false;
  String? _currentError;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    setState(() => _currentError = null);
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final session = ref.read(sessionProvider.notifier);
    if (!await session.verifyCredential(_current.text)) {
      setState(() {
        _busy = false;
        _currentError = l.unlockWrong;
      });
      return;
    }
    await session.changeCredential(_next.text, _type);
    if (!mounted) return;
    showSnack(context, l.credentialChanged);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currentType = ref.watch(sessionProvider).header!.credentialType;
    final pin = _type == CredentialType.pin;

    InputDecoration deco(String label, {String? error}) => InputDecoration(labelText: label, errorText: error);
    final keyboard = pin ? TextInputType.number : TextInputType.visiblePassword;
    final formatters = pin ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)] : null;

    return Scaffold(
      appBar: AppBar(title: Text(l.changeCredential)),
      body: Form(
        key: _form,
        child: ListView(
          padding: formPadding,
          children: [
            TextFormField(
              controller: _current,
              obscureText: true,
              autofocus: true,
              keyboardType: currentType == CredentialType.pin ? TextInputType.number : TextInputType.visiblePassword,
              decoration: deco(l.currentCredential, error: _currentError),
              validator: (v) => (v ?? '').isEmpty ? l.requiredField : null,
            ),
            const SizedBox(height: 24),
            SegmentedButton<CredentialType>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: CredentialType.pin, label: Text(l.credentialPin)),
                ButtonSegment(value: CredentialType.password, label: Text(l.credentialPassword)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                _next.clear();
                _repeat.clear();
              }),
            ),
            fieldGap,
            TextFormField(
              controller: _next,
              obscureText: true,
              keyboardType: keyboard,
              inputFormatters: formatters,
              decoration: deco(pin ? l.setupCreatePin : l.setupCreatePassword).copyWith(
                helperText: pin ? l.credentialPinHint : l.credentialPasswordHint,
              ),
              validator: (v) {
                final s = v ?? '';
                if (pin) return s.length < 4 || !RegExp(r'^\d+$').hasMatch(s) ? l.pinTooShort : null;
                return s.length < 6 ? l.passwordTooShort : null;
              },
            ),
            fieldGap,
            TextFormField(
              controller: _repeat,
              obscureText: true,
              keyboardType: keyboard,
              inputFormatters: formatters,
              decoration: deco(pin ? l.setupConfirmPin : l.setupConfirmPassword),
              validator: (v) => v != _next.text ? l.credentialsMismatch : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}
