import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_info.dart';
import '../../data/prefs.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/actions.dart';
import '../../state/session.dart';
import '../lock/biometrics.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';
import '../widgets/app_mark.dart';
import 'backup_screen.dart';
import 'change_credential_screen.dart';
import 'reminder_settings.dart';
import 'savings_goal_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(prefsProvider);
    final session = ref.read(sessionProvider.notifier);
    final online = ref.watch(appDataProvider.select((d) => d.onlinePricesEnabled));
    final bio = ref.watch(biometricAvailabilityProvider);
    final bioKind = bio.value;
    final bioLabel = biometricLabel(l, bioKind);

    String lockLabel(int s) => s == 0 ? l.lockImmediately : (s < 60 ? l.secondsShort(s) : l.minutesShort(s ~/ 60));

    Future<void> toggleBiometrics(bool enable) async {
      if (enable) {
        final ok = await session.withoutAutoLock(
          () => ref.read(biometricServiceProvider).authenticate(l.biometricReason),
        );
        if (!ok) return;
      }
      await session.setBiometrics(enable);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          SectionTitle(l.sectionAppearance),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.themeLabel, style: context.text.titleSmall),
                const SizedBox(height: 10),
                SegmentedButton<ThemePref>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: ThemePref.system, label: Text(l.themeSystem), icon: const Icon(Icons.brightness_auto_rounded)),
                    ButtonSegment(value: ThemePref.light, label: Text(l.themeLight), icon: const Icon(Icons.light_mode_rounded)),
                    ButtonSegment(value: ThemePref.dark, label: Text(l.themeDark), icon: const Icon(Icons.dark_mode_rounded)),
                  ],
                  selected: {prefs.theme},
                  onSelectionChanged: (s) => session.updatePrefs((p) => p.copyWith(theme: s.first)),
                ),
                const SizedBox(height: 20),
                Text(l.darkVariantLabel, style: context.text.titleSmall),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DarkOption(
                        selected: prefs.darkVariant == DarkVariant.black,
                        background: Colors.black,
                        card: const Color(0xFF0F1110),
                        title: l.darkBlack,
                        subtitle: l.darkBlackHint,
                        onTap: () => session.updatePrefs((p) => p.copyWith(darkVariant: DarkVariant.black)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DarkOption(
                        selected: prefs.darkVariant == DarkVariant.dim,
                        background: const Color(0xFF151716),
                        card: const Color(0xFF1F2220),
                        title: l.darkDim,
                        subtitle: l.darkDimHint,
                        onTap: () => session.updatePrefs((p) => p.copyWith(darkVariant: DarkVariant.dim)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(l.languageLabel, style: context.text.titleSmall),
                const SizedBox(height: 10),
                SegmentedButton<LocalePref>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: LocalePref.system, label: Text(l.themeSystem)),
                    const ButtonSegment(value: LocalePref.de, label: Text('Deutsch')),
                    const ButtonSegment(value: LocalePref.en, label: Text('English')),
                  ],
                  selected: {prefs.locale},
                  onSelectionChanged: (s) => session.updatePrefs((p) => p.copyWith(locale: s.first)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ListCard(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.visibility_off_rounded),
                title: Text(l.discreetTitle),
                subtitle: Text(l.discreetHint),
                value: prefs.discreet,
                onChanged: (v) => session.updatePrefs((p) => p.copyWith(discreet: v)),
              ),
            ],
          ),
          SectionTitle(l.sectionSecurity),
          ListCard(
            children: [
              ListTile(
                leading: const Icon(Icons.password_rounded),
                title: Text(l.changeCredential),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => push(context, const ChangeCredentialScreen()),
              ),
              SwitchListTile(
                secondary: Icon(bioKind == BiometricKind.face ? Icons.face_rounded : Icons.fingerprint_rounded),
                title: Text(l.biometricUnlock(bioLabel)),
                subtitle: bioKind == null && !bio.isLoading ? Text(l.biometricUnavailable) : null,
                value: prefs.biometricsEnabled && bioKind != null,
                onChanged: bioKind == null ? null : toggleBiometrics,
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(l.lockAfter),
                trailing: Text(lockLabel(prefs.lockTimeoutSeconds), style: context.text.labelLarge),
                onTap: () async {
                  final picked = await showOptionSheet<int>(
                    context,
                    title: l.lockAfter,
                    selected: prefs.lockTimeoutSeconds,
                    options: [for (final s in AppPrefs.lockTimeoutOptions) PickerOption(value: s, label: lockLabel(s))],
                  );
                  if (picked != null) await session.updatePrefs((p) => p.copyWith(lockTimeoutSeconds: picked.value));
                },
              ),
            ],
          ),
          SectionTitle(l.sectionReminder),
          const ReminderSettingsCard(),
          SectionTitle(l.sectionGoal),
          ListCard(
            children: [
              ListTile(
                leading: const Icon(Icons.flag_rounded),
                title: Text(l.cardSavingsGoal),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => push(context, const SavingsGoalScreen()),
              ),
            ],
          ),
          SectionTitle(l.sectionOnline),
          ListCard(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.cloud_sync_rounded),
                title: Text(l.onlinePricesToggle),
                subtitle: Text(l.onlinePricesHint),
                isThreeLine: true,
                value: online,
                onChanged: ref.read(actionsProvider).setOnlinePrices,
              ),
            ],
          ),
          SectionTitle(l.backupTitle),
          ListCard(
            children: [
              ListTile(
                leading: const Icon(Icons.shield_moon_rounded),
                title: Text(l.backupTitle),
                subtitle: Text(l.moreBackupSub),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => push(context, const BackupScreen()),
              ),
            ],
          ),
          SectionTitle(l.sectionAbout),
          AppCard(
            child: Row(
              children: [
                const AppMark(size: 40),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l.appTitle} $appVersion', style: context.text.titleSmall),
                      Text(l.aboutOffline, style: context.text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkOption extends StatelessWidget {
  const _DarkOption({
    required this.selected,
    required this.background,
    required this.card,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final Color background;
  final Color card;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? context.colors.primary : context.colors.outline, width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10)),
              child: Container(decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(6))),
            ),
            const SizedBox(height: 8),
            Text(title, style: context.text.titleSmall),
            Text(subtitle, style: context.text.bodySmall, maxLines: 2),
          ],
        ),
      ),
    );
  }
}
