import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reminder_service.dart';
import '../l10n/gen/app_localizations.dart';

/// Replaced in main() by the notification plugin.
final reminderServiceProvider = Provider<ReminderService>((ref) => ReminderService());

ReminderTexts reminderTexts(AppLocalizations l) =>
    ReminderTexts(channel: l.reminderChannel, title: l.reminderNotificationTitle, body: l.reminderNotificationBody);
