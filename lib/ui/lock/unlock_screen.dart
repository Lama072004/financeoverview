import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/prefs.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';
import '../widgets/app_mark.dart';
import 'biometrics.dart';
import 'pin_pad.dart';
import 'reset_dialog.dart';

class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  String _input = '';
  String? _error;
  bool _busy = false;
  bool _obscure = true;
  Timer? _ticker;
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_lockedUntil != null) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometrics(auto: true));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _passwordController.dispose();
    super.dispose();
  }

  DateTime? get _lockedUntil {
    final until = ref.read(sessionProvider).header?.lockedUntil;
    return until != null && until.isAfter(DateTime.now()) ? until : null;
  }

  Future<void> _tryBiometrics({bool auto = false}) async {
    final prefs = ref.read(prefsProvider);
    if (!prefs.biometricsEnabled || _busy || _lockedUntil != null) return;
    final l = AppLocalizations.of(context);
    final session = ref.read(sessionProvider.notifier);
    final ok = await session.withoutAutoLock(
      () => ref.read(biometricServiceProvider).authenticate(l.biometricReason),
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final opened = await session.unlockWithBiometricKey();
    if (mounted && !opened) setState(() => _busy = false);
  }

  Future<void> _submit(String credential) async {
    if (credential.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(sessionProvider.notifier).unlock(credential);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    switch (result) {
      case UnlockSuccess():
        return;
      case UnlockWrong():
        HapticFeedback.heavyImpact();
        setState(() => _error = l.unlockWrong);
      case UnlockLockedOut():
        HapticFeedback.heavyImpact();
        setState(() => _error = null);
    }
    setState(() {
      _busy = false;
      _input = '';
      _passwordController.clear();
    });
  }

  String _remaining(DateTime until) {
    final l = AppLocalizations.of(context);
    final s = until.difference(DateTime.now()).inSeconds + 1;
    return s >= 60 ? l.minutesShort((s / 60).ceil()) : l.secondsShort(s);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final header = ref.watch(sessionProvider).header!;
    final prefs = header.prefs;
    final isPin = header.credentialType == CredentialType.pin;
    final lockedUntil = _lockedUntil;
    final bioKind = ref.watch(biometricAvailabilityProvider).value;
    final showBio = prefs.biometricsEnabled && bioKind != null;

    final status = lockedUntil != null
        ? l.unlockLockedOut(_remaining(lockedUntil))
        : (_busy ? l.unlocking : (_error ?? (isPin ? l.unlockEnterPin : l.unlockEnterPassword)));
    final statusColor = (lockedUntil != null || _error != null) ? context.fin.negative : context.fin.muted;

    final bioButton = showBio
        ? IconButton(
            iconSize: 30,
            tooltip: l.unlockWithBiometric(biometricLabel(l, bioKind)),
            onPressed: _busy ? null : _tryBiometrics,
            icon: Icon(bioKind == BiometricKind.face ? Icons.face_rounded : Icons.fingerprint_rounded),
          )
        : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 56),
            const AppMark(size: 52),
            const SizedBox(height: 20),
            Text(l.appTitle, style: context.text.titleLarge),
            const SizedBox(height: 8),
            Text(status, style: context.text.bodyMedium?.copyWith(color: statusColor), textAlign: TextAlign.center),
            const SizedBox(height: 28),
            if (isPin) ...[
              PinDots(length: header.pinLength, filled: _input.length, error: _error != null && _input.isEmpty),
              const Spacer(),
              PinPad(
                enabled: !_busy && lockedUntil == null,
                extra: bioButton,
                onBackspace: () => setState(() {
                  if (_input.isNotEmpty) _input = _input.substring(0, _input.length - 1);
                }),
                onDigit: (d) {
                  if (_input.length >= header.pinLength) return;
                  setState(() {
                    _input += d;
                    _error = null;
                  });
                  if (_input.length == header.pinLength) _submit(_input);
                },
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _passwordController,
                  autofocus: !prefs.biometricsEnabled,
                  obscureText: _obscure,
                  enabled: !_busy && lockedUntil == null,
                  enableSuggestions: false,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: _submit,
                  decoration: InputDecoration(
                    labelText: l.credentialPassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    if (bioButton != null) ...[bioButton, const SizedBox(width: 8)],
                    Expanded(
                      child: FilledButton(
                        onPressed: _busy || lockedUntil != null ? null : () => _submit(_passwordController.text),
                        child: Text(l.next),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
            const SizedBox(height: 8),
            TextButton(onPressed: () => showForgotDialog(context, ref), child: Text(l.forgotCredential)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
