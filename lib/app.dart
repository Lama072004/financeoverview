import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/format.dart';
import 'data/prefs.dart';
import 'l10n/gen/app_localizations.dart';
import 'state/session.dart';
import 'ui/lock/lock_gate.dart';
import 'ui/shell/home_shell.dart';
import 'ui/theme/app_theme.dart';

class FinanceApp extends ConsumerWidget {
  const FinanceApp({super.key, this.home = const HomeShell()});

  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(prefs.darkVariant),
      themeMode: switch (prefs.theme) {
        ThemePref.system => ThemeMode.system,
        ThemePref.light => ThemeMode.light,
        ThemePref.dark => ThemeMode.dark,
      },
      locale: switch (prefs.locale) {
        LocalePref.system => null,
        LocalePref.de => const Locale('de'),
        LocalePref.en => const Locale('en'),
      },
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Unknown system languages fall back to German.
      localeResolutionCallback: (locale, supported) =>
          supported.where((s) => s.languageCode == locale?.languageCode).firstOrNull ?? const Locale('de'),
      builder: (context, child) => Discreet(hidden: prefs.discreet, child: LockGate(child: child!)),
      home: home,
    );
  }
}
