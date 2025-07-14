import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

class ProjectsTopBar extends StatelessWidget {
  final bool sortDetection, sortClassification, sortSegmentation;

  final VoidCallback onSearchPressed;
  final Function(String) onSortSelected;
  final VoidCallback onCreateProject;
  final VoidCallback onCreateFromDataset;
  final VoidCallback onCreateFromExport;

  final VoidCallback onSortDetection;
  final VoidCallback onSortClassification;
  final VoidCallback onSortSegmentation;

  const ProjectsTopBar({
    super.key,
    required this.sortDetection,
    required this.sortClassification,
    required this.sortSegmentation,
    required this.onSearchPressed,
    required this.onSortSelected,
    required this.onCreateProject,
    required this.onCreateFromDataset,
    required this.onCreateFromExport,

    required this.onSortDetection,
    required this.onSortClassification,
    required this.onSortSegmentation,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth > 1200) ? 16 : (screenWidth>=700) ? 6 : 2,
        vertical: (screenWidth > 1200) ? 22 : (screenWidth>=700) ? 12 : 4,
      ),
      child: Row(
        children: [
          SizedBox(width: screenWidth>=700 ? 10 : 0),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onSortDetection,
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: sortDetection ? Colors.grey[850] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.crop_free_rounded,
                  color: sortDetection ? Colors.white : Colors.white70,
                  size: 30,
                ),
              ),
            ),
          ),

          SizedBox(width: screenWidth>=700 ? 10 : 0),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onSortClassification,
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: sortClassification ? Colors.grey[850] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.category_outlined,
                  color: sortClassification ? Colors.white : Colors.white70,
                  size: 30,
                ),
              ),
            ),
          ),

          SizedBox(width: screenWidth>=700 ? 10 : 0),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onSortSegmentation,
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: sortSegmentation ? Colors.grey[850] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.extension_outlined,
                  color: sortSegmentation ? Colors.white : Colors.white70,
                  size: 30,
                ),
              ),
            ),
          ),

          if (screenWidth>=700)...[
            const Spacer(),
            const SizedBox(width: 20),
            PopupMenuButton<String>(
              icon: const Icon(Icons.swap_vert, color: Colors.white70),
              onSelected: onSortSelected,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.white70, width: 1),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(value: "Last updated", child: Text(l10n.menuSortLastUpdated, style: TextStyle(fontFamily: 'CascadiaCode', fontWeight: FontWeight.normal))),
                PopupMenuItem(value: "Newest-Oldest", child: Text(l10n.menuSortNewestOldest, style: TextStyle(fontFamily: 'CascadiaCode', fontWeight: FontWeight.normal))),
                PopupMenuItem(value: "Oldest-Newest", child: Text(l10n.menuSortOldestNewest, style: TextStyle(fontFamily: 'CascadiaCode', fontWeight: FontWeight.normal))),
                PopupMenuItem(value: "Project Type", child: Text(l10n.menuSortType, style: TextStyle(fontFamily: 'CascadiaCode', fontWeight: FontWeight.normal))),
                PopupMenuItem(value: "A-Z", child: Text(l10n.menuSortAz, style: TextStyle(fontFamily: 'CascadiaCode', fontWeight: FontWeight.normal))),
                PopupMenuItem(value: "Z-A", child: Text(l10n.menuSortZa, style: TextStyle(fontFamily: 'CascadiaCode', fontWeight: FontWeight.normal))),
              ],
            ),
            const SizedBox(width: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.3 * 255).toInt()),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onCreateProject,
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      child: Text(
                        l10n.menuCreateNewProject,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'CascadiaCode',
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 7),
                  PopupMenuButton<int>(
                    color: const Color(0xFF2E2E2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.white70, width: 1),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    offset: const Offset(-10, 47),
                    onSelected: (value) {
                      if (value == 0) { onCreateProject(); }
                      else { onCreateFromDataset(); }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Text(
                          l10n.menuCreateNewProject,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'CascadiaCode',
                            fontWeight: FontWeight.normal
                          ),
                        ),
                      ),
                      PopupMenuItem<int>(
                        value: 1,
                        child: Text(
                          l10n.menuCreateFromDataset,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'CascadiaCode',
                            fontWeight: FontWeight.normal
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
          ],
        ],
      ),
    );
  }
}
