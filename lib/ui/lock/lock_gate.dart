import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';
import '../widgets/app_mark.dart';
import 'reset_dialog.dart';
import 'setup_screen.dart';
import 'unlock_screen.dart';

/// Sits above the app's navigator. Locking only covers the app: its screens
/// stay mounted (hidden, not interactive) so that unfinished input survives a
/// quick switch to another app. After a reset the app tree is dropped.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate> {
  late final AppLifecycleListener _lifecycle;
  bool _obscured = false;

  /// True from the first unlock until the session ends (reset, key missing).
  bool _appMounted = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onInactive: () => setState(() => _obscured = true),
      onHide: () => ref.read(sessionProvider.notifier).onBackground(),
      onShow: () => ref.read(sessionProvider.notifier).onForeground(),
      onResume: () => setState(() => _obscured = false),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider.select((s) => s.status), (_, status) {
      // No keyboard for a hidden text field under the lock screen.
      if (status == SessionStatus.locked) FocusManager.instance.primaryFocus?.unfocus();
    });
    final status = ref.watch(sessionProvider.select((s) => s.status));
    final unlocked = status == SessionStatus.unlocked;
    if (unlocked) {
      _appMounted = true;
    } else if (status != SessionStatus.locked) {
      _appMounted = false;
    }

    final Widget? cover = switch (status) {
      SessionStatus.loading => const _Splash(),
      SessionStatus.needsSetup => const _OwnNavigator(key: ValueKey('setup'), child: SetupScreen()),
      SessionStatus.locked => const _OwnNavigator(key: ValueKey('locked'), child: UnlockScreen()),
      SessionStatus.keyMissing => const _OwnNavigator(key: ValueKey('missing'), child: _KeyMissingScreen()),
      SessionStatus.unlocked => null,
    };

    return Stack(
      children: [
        if (_appMounted)
          Positioned.fill(
            key: const ValueKey('app'),
            child: Offstage(
              offstage: !unlocked,
              child: TickerMode(
                enabled: unlocked,
                child: ExcludeSemantics(excluding: !unlocked, child: widget.child),
              ),
            ),
          ),
        if (cover != null) Positioned.fill(key: const ValueKey('cover'), child: cover),
        // Covers the content in the app switcher.
        if (_obscured && unlocked) const Positioned.fill(key: ValueKey('privacy'), child: _Splash()),
      ],
    );
  }
}

/// Lock screens live outside the app navigator but still need dialogs.
class _OwnNavigator extends StatelessWidget {
  const _OwnNavigator({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => HeroControllerScope.none(
        // The app's navigator (hidden underneath) keeps the shared hero controller.
        child: Navigator(onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => child)),
      );
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const Center(child: AppMark(size: 64)),
    );
  }
}

class _KeyMissingScreen extends ConsumerWidget {
  const _KeyMissingScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Icon(Icons.key_off_rounded, size: 48, color: context.fin.negative),
              const SizedBox(height: 20),
              Text(l.keyMissingTitle, style: context.text.headlineSmall),
              const SizedBox(height: 10),
              Text(l.keyMissingBody, style: context.text.bodyLarge?.copyWith(color: context.fin.muted)),
              const Spacer(),
              FilledButton(onPressed: () => confirmReset(context, ref), child: Text(l.resetApp)),
            ],
          ),
        ),
      ),
    );
  }
}
