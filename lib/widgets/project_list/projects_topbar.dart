import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../utils/theme.dart';

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

  Widget _filterChip({
    required bool active,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 42,
          height: 42,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: active
                ? AppColors.accent.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? AppColors.accent.withOpacity(0.4)
                  : Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: active ? AppColors.accent : Colors.white.withOpacity(0.5),
            size: 22,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth > 1200) ? 20 : (screenWidth >= 700) ? 10 : 6,
        vertical: (screenWidth > 1200) ? 18 : (screenWidth >= 700) ? 12 : 6,
      ),
      child: Row(
        children: [
          SizedBox(width: screenWidth >= 700 ? 8 : 0),
          _filterChip(
            active: sortDetection,
            icon: Icons.crop_free_rounded,
            onTap: onSortDetection,
          ),
          SizedBox(width: screenWidth >= 700 ? 4 : 0),
          _filterChip(
            active: sortClassification,
            icon: Icons.category_outlined,
            onTap: onSortClassification,
          ),
          _filterChip(
            active: sortSegmentation,
            icon: Icons.extension_outlined,
            onTap: onSortSegmentation,
          ),

          if (screenWidth > 300) ...[
            const Spacer(),
          ],

          PopupMenuButton<String>(
            icon: Icon(Icons.swap_vert, color: Colors.white.withOpacity(0.5)),
            onSelected: onSortSelected,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            color: AppColors.darkCard,
            itemBuilder: (context) => [
              PopupMenuItem(value: "Custom order", child: Text(l10n.menuSortCustomOrder, style: const TextStyle(fontWeight: FontWeight.w400))),
              PopupMenuItem(value: "Last updated", child: Text(l10n.menuSortLastUpdated, style: const TextStyle(fontWeight: FontWeight.w400))),
              PopupMenuItem(value: "Newest-Oldest", child: Text(l10n.menuSortNewestOldest, style: const TextStyle(fontWeight: FontWeight.w400))),
              PopupMenuItem(value: "Oldest-Newest", child: Text(l10n.menuSortOldestNewest, style: const TextStyle(fontWeight: FontWeight.w400))),
              PopupMenuItem(value: "Project Type", child: Text(l10n.menuSortProjectType, style: const TextStyle(fontWeight: FontWeight.w400))),
              PopupMenuItem(value: "A-Z", child: Text(l10n.menuSortAZ, style: const TextStyle(fontWeight: FontWeight.w400))),
              PopupMenuItem(value: "Z-A", child: Text(l10n.menuSortZA, style: const TextStyle(fontWeight: FontWeight.w400))),
            ],
          ),

          SizedBox(width: screenWidth >= 700 ? 16 : 8),

          // Create button with gradient
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentOrange],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onCreateProject,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth < 500 ? 12 : 18,
                      vertical: screenWidth < 500 ? 6 : 8,
                    ),
                    child: Tooltip(
                      message: l10n.menuCreateNewProject,
                      waitDuration: const Duration(milliseconds: 500),
                      child: (screenWidth < 500)
                          ? const Icon(Icons.add_rounded, color: Colors.white, size: 20)
                          : Text(
                              l10n.menuCreateNewProject,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth >= 700 ? 16 : 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: screenWidth < 500 ? 20 : 26,
                  color: Colors.white.withOpacity(0.3),
                ),
                PopupMenuButton<int>(
                  color: AppColors.darkCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                  ),
                  icon: screenWidth < 500
                      ? null
                      : const Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
                  child: (screenWidth < 500)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 18),
                        )
                      : null,
                  offset: const Offset(-10, 47),
                  onSelected: (value) {
                    if (value == 0) {
                      onCreateProject();
                    } else {
                      onCreateFromDataset();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<int>(
                      value: 0,
                      child: Text(
                        l10n.menuCreateNewProject,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth >= 700 ? 16 : 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Text(
                        l10n.menuCreateFromDataset,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth >= 700 ? 16 : 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: screenWidth > 1200 ? 16 : 4),
        ],
      ),
    );
  }
}
