import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

class EmptyProjectPlaceholder extends StatelessWidget {
  final VoidCallback onCreateNewProject;
  final VoidCallback onImportFromDataset;

  const EmptyProjectPlaceholder({
    Key? key,
    required this.onCreateNewProject,
    required this.onImportFromDataset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    print ('Screen width: $screenWidth, isMobile: $isMobile');
    return Card(
      color: Colors.grey.shade800,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 350,
        width: double.infinity,
        child: Row(
          children: [
            // Left: Image (only for larger screens)
            if (!isMobile)
              Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/empty_project_placeholder.jpg',
                    fit: BoxFit.cover,
                    height: 350,
                    width: 350,
                  ),
                ),
              ),

            // Right: Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.emptyProject_title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.emptyProject_description,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: onCreateNewProject,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: Text(
                            l10n.emptyProject_createNew,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: onImportFromDataset,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: Colors.white54),
                          ),
                          icon: const Icon(Icons.file_upload, color: Colors.white),
                          label: Text(
                            l10n.emptyProject_importDataset,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
