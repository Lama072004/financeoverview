import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/prefs.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/auto_backup.dart';
import '../../state/reminders.dart';
import '../../state/session.dart';
import '../accounts/accounts_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../entry/snapshot_editor.dart';
import '../history/history_screen.dart';
import '../more/more_screen.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import 'quick_add_sheet.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  late final _reminders = ref.read(reminderServiceProvider);
  (ReminderPrefs, String)? _scheduled;

  @override
  void initState() {
    super.initState();
    _reminders.captureRequested.addListener(_openCapture);
    ref.listenManual(sessionProvider.select((s) => s.status), (_, _) => _openCapture());
    ref.listenManual(prefsProvider.select((p) => p.reminder), (_, _) => _syncReminders());
    WidgetsBinding.instance.addPostFrameCallback((_) => _openCapture());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Also after a language change: the notification texts follow the app.
    _syncReminders();
  }

  @override
  void dispose() {
    _reminders.captureRequested.removeListener(_openCapture);
    super.dispose();
  }

  /// Reschedules the reminders when their settings or the language changed.
  void _syncReminders() {
    final l = AppLocalizations.of(context);
    final prefs = ref.read(prefsProvider).reminder;
    final key = (prefs, l.localeName);
    if (_scheduled == key || (_scheduled == null && !prefs.enabled)) return;
    _scheduled = key;
    _reminders.schedule(prefs, reminderTexts(l)).catchError((Object e) => debugPrint('reminders: $e'));
  }

  /// A tapped reminder opens the balance entry – once the app is unlocked.
  void _openCapture() {
    if (!mounted || !_reminders.captureRequested.value) return;
    if (ref.read(sessionProvider).status != SessionStatus.unlocked) return;
    _reminders.captureRequested.value = false;
    ref.read(homeTabProvider.notifier).select(Tabs.home);
    push(context, const SnapshotEditor());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final index = ref.watch(homeTabProvider);
    final select = ref.read(homeTabProvider.notifier).select;
    // Keeps the automatic backup listening for changes while the app runs.
    ref.listen(autoBackupProvider, (_, _) {});

    return PopScope(
      canPop: index == Tabs.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) select(Tabs.home);
      },
      child: Scaffold(
        body: IndexedStack(
          index: index,
          children: const [DashboardScreen(), AccountsScreen(), HistoryScreen(), MoreScreen()],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: l.quickAddTitle,
          onPressed: () => showQuickAdd(context),
          child: const Icon(Icons.add_rounded, size: 32),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          elevation: Theme.of(context).brightness == Brightness.light ? 6 : 0,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          child: Row(
            children: [
              _NavItem(icon: Icons.space_dashboard_rounded, label: l.navHome, selected: index == 0, onTap: () => select(0)),
              _NavItem(icon: Icons.account_balance_rounded, label: l.navAccounts, selected: index == 1, onTap: () => select(1)),
              const SizedBox(width: 72),
              _NavItem(icon: Icons.history_rounded, label: l.navHistory, selected: index == 2, onTap: () => select(2)),
              _NavItem(icon: Icons.grid_view_rounded, label: l.navMore, selected: index == 3, onTap: () => select(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.colors.primary : context.fin.muted;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        child: InkResponse(
          onTap: onTap,
          radius: 36,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? context.colors.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(icon, color: selected ? context.colors.onPrimaryContainer : color, size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: context.text.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
