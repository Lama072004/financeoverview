import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../state/session.dart';
import '../nav.dart';
import '../projection/projection_screen.dart';
import '../report/report_screen.dart';
import '../review/review_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'account_types_screen.dart';
import 'backup_screen.dart';
import 'categories_screen.dart';
import 'guide_screen.dart';
import 'investments_screen.dart';
import 'purchase_screen.dart';
import 'recurring_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fin = context.fin;

    Widget item(IconData icon, Color color, String title, String subtitle, Widget page) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: IconBadge(icon: icon, color: color),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.chevron_right_rounded, color: fin.muted),
          onTap: () => push(context, page),
        );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 20,
        title: Text(l.navMore, style: context.text.headlineSmall),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        children: [
          ListCard(children: [
            item(Icons.insights_rounded, fin.chartColor(4), l.reviewTitle, l.moreReviewSub, const ReviewScreen()),
            item(Icons.trending_up_rounded, fin.chartColor(8), l.projectionTitle, l.moreProjectionSub,
                const ProjectionScreen()),
            item(Icons.picture_as_pdf_rounded, fin.chartColor(1), l.reportTitle, l.moreReportSub, const ReportScreen()),
          ]),
          const SizedBox(height: 14),
          ListCard(children: [
            item(Icons.event_repeat_rounded, fin.chartColor(0), l.recurringTitle, l.moreRecurringSub, const RecurringScreen()),
            item(Icons.candlestick_chart_rounded, fin.chartColor(2), l.investmentsTitle, l.moreInvestmentsSub,
                const InvestmentsScreen()),
            item(Icons.calculate_rounded, fin.chartColor(1), l.purchaseTitle, l.morePurchaseSub, const PurchaseScreen()),
          ]),
          const SizedBox(height: 14),
          ListCard(children: [
            item(Icons.category_rounded, fin.chartColor(3), l.categoriesTitle, l.moreCategoriesSub, const CategoriesScreen()),
            item(Icons.tune_rounded, fin.chartColor(5), l.accountTypesTitle, l.moreAccountTypesSub,
                const AccountTypesScreen()),
          ]),
          const SizedBox(height: 14),
          ListCard(children: [
            item(Icons.settings_rounded, fin.chartColor(9), l.settingsTitle, l.moreSettingsSub, const SettingsScreen()),
            item(Icons.shield_moon_rounded, fin.chartColor(7), l.backupTitle, l.moreBackupSub, const BackupScreen()),
            item(Icons.menu_book_rounded, fin.chartColor(6), l.guideTitle, l.moreGuideSub, const GuideScreen()),
          ]),
          const SizedBox(height: 14),
          ListCard(children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: IconBadge(icon: Icons.lock_rounded, color: context.colors.primary),
              title: Text(l.lockNow),
              onTap: () => ref.read(sessionProvider.notifier).lock(),
            ),
          ]),
          const SizedBox(height: 24),
          Center(child: Text(l.aboutOffline, style: context.text.bodySmall, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
