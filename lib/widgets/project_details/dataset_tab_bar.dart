import 'package:flutter/material.dart';
import '../../models/dataset.dart';
import '../../gen_l10n/app_localizations.dart';

class DatasetTabBar extends StatelessWidget {
  final List<Dataset> datasets;
  final TabController controller;
  final String? defaultDatasetId;
  final void Function(Dataset, String) onMenuAction;

  const DatasetTabBar({
    required this.datasets,
    required this.controller,
    required this.defaultDatasetId,
    required this.onMenuAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      indicatorColor: Colors.redAccent,
      labelStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.normal, fontFamily: 'CascadiaCode',),
      unselectedLabelColor: Colors.white60,
      tabs: List.generate(datasets.length, (i) {
        final dataset = datasets[i];
        final isSelected = controller.index == i;
        final isDefault = dataset.id == defaultDatasetId;
        final isAddTab = dataset.id == 'add_new_tab';

        final l10n = AppLocalizations.of(context)!;
        final screenWidth = MediaQuery.of(context).size.width;
        return Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dataset.name,
                style: TextStyle(
                  fontFamily: 'CascadiaCode',
                  fontSize: screenWidth > 1200 ? 22 : 18,
                  fontWeight: isDefault ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (!isAddTab && isSelected)
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    onMenuAction(dataset, value);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: Colors.white24,
                      width: 1,
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'rename',
                      child: Text(
                        l10n.rename,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontFamily: 'CascadiaCode',
                          fontSize: screenWidth > 1200 ? 22 : 18,
                        ),
                      ),
                    ),
                    if (!isDefault)
                      PopupMenuItem(
                        value: 'set_default',
                        child: Text(
                          l10n.setAsDefault,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: 'CascadiaCode',
                            fontSize: screenWidth > 1200 ? 22 : 18,
                          ),
                        ),
                      ),
                    if (!isDefault)
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          l10n.delete,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: 'CascadiaCode',
                            fontSize: screenWidth > 1200 ? 22 : 18,
                          ),
                        ),
                      ),
                  ],
                  icon: const Icon(Icons.more_vert, size: 18),
                ),
            ],
          ),
        );
      }),
    );
  }
}
