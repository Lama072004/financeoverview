import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'data/reminder_service.dart';
import 'data/vault/secret_store.dart';
import 'data/vault/vault_repository.dart';
import 'state/reminders.dart';
import 'state/session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final support = await getApplicationSupportDirectory();
  final vault = VaultRepository(
    directory: Directory('${support.path}${Platform.pathSeparator}vault'),
    secrets: DeviceSecretStore(),
  );

  final reminders = await LocalReminderService.create();

  runApp(
    ProviderScope(
      overrides: [
        vaultRepositoryProvider.overrideWithValue(vault),
        reminderServiceProvider.overrideWithValue(reminders ?? ReminderService()),
      ],
      child: const FinanceApp(),
    ),
  );
}
