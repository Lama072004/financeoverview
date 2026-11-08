import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/actions.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'dashboard_cards.dart';

/// Reorder, show/hide and resize the dashboard cards.
class CustomizeDashboardScreen extends ConsumerWidget {
  const CustomizeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cards = ref.watch(appDataProvider.select((d) => d.dashboard));
    final actions = ref.read(actionsProvider);

    void replace(int index, DashboardCardConfig next) => actions.setDashboard([...cards]..[index] = next);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.customizeDashboard),
        actions: [
          IconButton(
            tooltip: l.resetLayout,
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: actions.resetDashboard,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: InfoNote(l.customizeHint)),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              buildDefaultDragHandles: false,
              itemCount: cards.length,
              onReorder: (from, to) {
                final next = [...cards];
                final item = next.removeAt(from);
                next.insert(to > from ? to - 1 : to, item);
                actions.setDashboard(next);
              },
              proxyDecorator: (child, _, _) => Material(color: Colors.transparent, child: child),
              itemBuilder: (context, i) {
                final c = cards[i];
                return Padding(
                  key: ValueKey(c.type),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.fromLTRB(8, 10, 14, 10),
                    child: Opacity(
                      opacity: c.visible ? 1 : 0.5,
                      child: Row(
                        children: [
                          ReorderableDragStartListener(
                            index: i,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(Icons.drag_indicator_rounded, color: context.fin.muted),
                            ),
                          ),
                          IconBadge(icon: cardIcon(c.type), color: context.colors.primary, size: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cardTitle(l, c.type), style: context.text.titleSmall),
                                const SizedBox(height: 6),
                                SegmentedButton<CardSize>(
                                  showSelectedIcon: false,
                                  segments: [
                                    ButtonSegment(value: CardSize.compact, label: Text(l.sizeCompact)),
                                    ButtonSegment(value: CardSize.large, label: Text(l.sizeLarge)),
                                  ],
                                  selected: {c.size},
                                  onSelectionChanged: (s) => replace(i, c.copyWith(size: s.first)),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(c.visible ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                            onPressed: () => replace(i, c.copyWith(visible: !c.visible)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
