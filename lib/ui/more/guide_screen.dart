import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Short manual, adapted from the spreadsheet's "Anleitung" sheet.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sections = [
      (Icons.rocket_launch_rounded, l.guideSetupTitle, [l.guideSetup1, l.guideSetup2, l.guideSetup3]),
      (Icons.update_rounded, l.guideRegularTitle, [l.guideRegular1, l.guideRegular2, l.guideRegular3]),
      (Icons.space_dashboard_rounded, l.guideDashboardTitle, [l.guideDashboard1]),
      (Icons.insights_rounded, l.guideAnalysisTitle, [l.guideAnalysis1, l.guideAnalysis2, l.guideAnalysis3]),
      (Icons.shield_moon_rounded, l.guideSafetyTitle, [l.guideSafety1, l.guideSafety2, l.guideSafety3]),
      (Icons.lightbulb_outline_rounded, l.guideNotesTitle, [l.guideNote1, l.guideNote2, l.guideNote3, l.guideNote4]),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.guideTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          for (final (icon, title, items) in sections) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconBadge(icon: icon, color: context.colors.primary, size: 36),
                      const SizedBox(width: 12),
                      Expanded(child: Text(title, style: context.text.titleMedium)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < items.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text('${i + 1}.', style: context.text.labelLarge?.copyWith(color: context.fin.muted)),
                          ),
                          Expanded(child: Text(items[i], style: context.text.bodyMedium)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
