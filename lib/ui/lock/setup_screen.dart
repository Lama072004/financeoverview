import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/defaults.dart';
import '../../data/prefs.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/app_mark.dart';
import 'biometrics.dart';
import 'pin_pad.dart';

enum _Step { welcome, enter, confirm, biometric, working }

/// First start: choose PIN or password, optionally biometrics, create vault.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  static const minPin = 4;
  static const maxPin = 8;
  static const minPassword = 6;

  _Step _step = _Step.welcome;
  CredentialType _type = CredentialType.pin;
  String _first = '';
  String _input = '';
  String? _error;
  bool _obscure = true;
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _choose(CredentialType type) => setState(() {
        _type = type;
        _step = _Step.enter;
        _input = '';
        _first = '';
        _error = null;
        _passwordController.clear();
      });

  void _submitFirst() {
    final l = AppLocalizations.of(context);
    final value = _type == CredentialType.pin ? _input : _passwordController.text;
    if (_type == CredentialType.pin && value.length < minPin) {
      setState(() => _error = l.pinTooShort);
      return;
    }
    if (_type == CredentialType.password && value.length < minPassword) {
      setState(() => _error = l.passwordTooShort);
      return;
    }
    setState(() {
      _first = value;
      _input = '';
      _passwordController.clear();
      _error = null;
      _step = _Step.confirm;
    });
  }

  Future<void> _submitConfirm() async {
    final value = _type == CredentialType.pin ? _input : _passwordController.text;
    if (value != _first) {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = AppLocalizations.of(context).credentialsMismatch;
        _input = '';
        _first = '';
        _passwordController.clear();
        _step = _Step.enter;
      });
      return;
    }
    final kind = await ref.read(biometricAvailabilityProvider.future);
    if (!mounted) return;
    if (kind != null) {
      setState(() => _step = _Step.biometric);
    } else {
      await _finish(biometrics: false);
    }
  }

  Future<void> _finish({required bool biometrics}) async {
    final german = Localizations.localeOf(context).languageCode == 'de';
    setState(() => _step = _Step.working);
    final session = ref.read(sessionProvider.notifier);
    await session.setup(
      credential: _first,
      type: _type,
      prefs: const AppPrefs(),
      initialData: initialAppData(german: german),
    );
    if (biometrics) await session.setBiometrics(true);
  }

  Future<void> _enableBiometrics() async {
    final l = AppLocalizations.of(context);
    final session = ref.read(sessionProvider.notifier);
    final ok = await session.withoutAutoLock(
      () => ref.read(biometricServiceProvider).authenticate(l.biometricReason),
    );
    await _finish(biometrics: ok);
  }

  void _onDigit(String d) {
    if (_input.length >= maxPin) return;
    setState(() {
      _input += d;
      _error = null;
    });
    if (_step == _Step.confirm && _input.length == _first.length) {
      _submitConfirm();
    } else if (_step == _Step.enter && _input.length == maxPin) {
      _submitFirst();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step != _Step.welcome && _step != _Step.working) {
          setState(() {
            _step = _Step.welcome;
            _error = null;
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: KeyedSubtree(
              key: ValueKey(_step),
              child: switch (_step) {
                _Step.welcome => _welcome(l),
                _Step.enter || _Step.confirm => _credential(l),
                _Step.biometric => _biometric(l),
                _Step.working => _working(l),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _welcome(AppLocalizations l) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      children: [
        const Align(alignment: Alignment.centerLeft, child: AppMark(size: 64)),
        const SizedBox(height: 28),
        Text(l.setupWelcomeTitle, style: context.text.headlineMedium),
        const SizedBox(height: 10),
        Text(l.setupWelcomeBody, style: context.text.bodyLarge?.copyWith(color: context.fin.muted)),
        const SizedBox(height: 32),
        Text(l.setupChooseMethod, style: context.text.titleMedium),
        const SizedBox(height: 12),
        _MethodTile(
          icon: Icons.dialpad_rounded,
          title: l.credentialPin,
          subtitle: l.credentialPinHint,
          onTap: () => _choose(CredentialType.pin),
        ),
        const SizedBox(height: 12),
        _MethodTile(
          icon: Icons.password_rounded,
          title: l.credentialPassword,
          subtitle: l.credentialPasswordHint,
          onTap: () => _choose(CredentialType.password),
        ),
        const SizedBox(height: 24),
        InfoNote(l.setupForgetWarning, icon: Icons.shield_outlined),
      ],
    );
  }

  Widget _credential(AppLocalizations l) {
    final confirming = _step == _Step.confirm;
    final isPin = _type == CredentialType.pin;
    final title = isPin
        ? (confirming ? l.setupConfirmPin : l.setupCreatePin)
        : (confirming ? l.setupConfirmPassword : l.setupCreatePassword);
    final header = Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => setState(() {
              _step = _Step.welcome;
              _error = null;
            }),
          ),
        ),
        const SizedBox(height: 8),
        const AppMark(size: 44),
        const SizedBox(height: 20),
        Text(title, style: context.text.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(
          _error ?? (isPin ? l.credentialPinHint : l.credentialPasswordHint),
          style: context.text.bodyMedium?.copyWith(color: _error != null ? context.fin.negative : context.fin.muted),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (!isPin) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          header,
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: TextField(
              controller: _passwordController,
              autofocus: true,
              obscureText: _obscure,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => confirming ? _submitConfirm() : _submitFirst(),
              decoration: InputDecoration(
                labelText: l.credentialPassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilledButton(
              onPressed: confirming ? _submitConfirm : _submitFirst,
              child: Text(l.next),
            ),
          ),
        ],
      );
    }

    final dots = confirming ? _first.length : (_input.length < minPin ? minPin : _input.length);
    return Column(
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(8, 8, 8, 0), child: header),
        const SizedBox(height: 28),
        PinDots(length: dots, filled: _input.length, error: _error != null && _input.isEmpty),
        const Spacer(),
        PinPad(
          onDigit: _onDigit,
          onBackspace: () => setState(() {
            if (_input.isNotEmpty) _input = _input.substring(0, _input.length - 1);
          }),
          extra: !confirming && _input.length >= minPin
              ? IconButton.filled(
                  onPressed: _submitFirst,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  tooltip: l.next,
                )
              : null,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _biometric(AppLocalizations l) {
    final kind = ref.watch(biometricAvailabilityProvider).value;
    final method = biometricLabel(l, kind);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconBadge(
              icon: kind == BiometricKind.face ? Icons.face_rounded : Icons.fingerprint_rounded,
              color: context.colors.primary,
              size: 72,
            ),
          ),
          const SizedBox(height: 28),
          Text(l.setupBiometricTitle(method), style: context.text.headlineSmall),
          const SizedBox(height: 10),
          Text(l.setupBiometricBody, style: context.text.bodyLarge?.copyWith(color: context.fin.muted)),
          const Spacer(),
          FilledButton(onPressed: _enableBiometrics, child: Text(l.enableBiometric)),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: () => _finish(biometrics: false), child: Text(l.notNow)),
        ],
      ),
    );
  }

  Widget _working(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppMark(size: 56),
          const SizedBox(height: 24),
          const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)),
          const SizedBox(height: 16),
          Text(l.setupFinishing, style: context.text.bodyMedium?.copyWith(color: context.fin.muted)),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconBadge(icon: icon, color: context.colors.primary, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleMedium),
                Text(subtitle, style: context.text.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.fin.muted),
        ],
      ),
    );
  }
}
