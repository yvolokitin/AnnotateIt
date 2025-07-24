import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../../widgets/app_snackbar.dart';
import '../../widgets/dialogs/alert_error_dialog.dart';

import '../../session/user_session.dart';
import '../../models/project.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../utils/dataset_exporters/dataset_export_utils.dart';

class ExportProjectDialog extends StatefulWidget {
  final Project project;

  const ExportProjectDialog({
    super.key,
    required this.project,
  });

  @override
  ExportProjectDialogState createState() => ExportProjectDialogState();
}

class ExportProjectDialogState extends State<ExportProjectDialog> {
  String selectedDatasetType = 'COCO';
  bool exportLabels = true;
  bool exportAnnotations = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1600;
    final isTablet = screenWidth >= 900 && screenWidth < 1600;
    
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dialogPadding = isLargeScreen
            ? const EdgeInsets.all(60)
            : isTablet
                ? const EdgeInsets.all(24)
                : const EdgeInsets.all(12);

        final dialogWidth = constraints.maxWidth * (isLargeScreen ? 0.9 : 1.0);
        final dialogHeight = constraints.maxHeight * (isLargeScreen ? 0.9 : 1.0);

        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.grey[850],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Padding(
              padding: dialogPadding,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth > 1400 ? 40 : 10),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [                              
                                  Icon(
                                    Icons.upload_file,
                                    size: isLargeScreen ? 34 : 30,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Export Project as Dataset',
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 26 : 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'CascadiaCode',
                                      color: Colors.white,
                                    ),
                                  ),
                                ]
                              ),
                              const SizedBox(height: 4),
                              if (screenWidth > 445)...[
                                Row(
                                  children: [                              
                                    Text(
                                      'Export "${widget.project.name}" as a dataset',
                                      style: TextStyle(
                                        fontSize: isLargeScreen ? 22 : (screenWidth > 660) ? 18 : 12,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: 'CascadiaCode',
                                        color: Colors.white24,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: screenWidth > 1200 ? 12 : (screenWidth > 650) ? 6 : 2),
                        const Divider(color: Colors.white70),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth > 1200 ? 15 : 4),
                            child: _buildExportOptions(),
                          ),
                        ),

                        SizedBox(height: screenWidth > 1200 ? 12 : (screenWidth > 650) ? 6 : 2),
                        _buildBottomButtons(),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      tooltip: l10n.buttonClose,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExportOptions() {
    double screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dataset Type',
          style: TextStyle(
            fontSize: screenWidth > 1200 ? 22 : 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'CascadiaCode',
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        // Dataset Type Selection
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildDatasetTypeCard('COCO', 'Common Objects in Context', Icons.photo_library),
            _buildDatasetTypeCard('YOLO', 'You Only Look Once', Icons.view_in_ar),
            _buildDatasetTypeCard('Datumaro', 'Universal Dataset Format', Icons.data_object),
          ],
        ),
        
        const SizedBox(height: 32),
        
        // Export Options
        Text(
          'Export Options',
          style: TextStyle(
            fontSize: screenWidth > 1200 ? 22 : 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'CascadiaCode',
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        // Export Labels Toggle
        SwitchListTile(
          title: Text(
            'Export All Labels',
            style: TextStyle(
              fontSize: screenWidth > 1200 ? 20 : 16,
              fontFamily: 'CascadiaCode',
              color: Colors.white,
            ),
          ),
          value: exportLabels,
          onChanged: (value) {
            setState(() {
              exportLabels = value;
            });
          },
          activeColor: Colors.red,
        ),
        
        // Export Annotations Toggle
        SwitchListTile(
          title: Text(
            'Export All Annotations',
            style: TextStyle(
              fontSize: screenWidth > 1200 ? 20 : 16,
              fontFamily: 'CascadiaCode',
              color: Colors.white,
            ),
          ),
          value: exportAnnotations,
          onChanged: (value) {
            setState(() {
              exportAnnotations = value;
            });
          },
          activeColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildDatasetTypeCard(String type, String description, IconData icon) {
    final isSelected = selectedDatasetType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          selectedDatasetType = type;
        });
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withOpacity(0.2) : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.red : Colors.white70,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'CascadiaCode',
                    color: isSelected ? Colors.red : Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'CascadiaCode',
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.buttonCancel,
            style: TextStyle(
              color: Colors.white54,
              fontFamily: 'CascadiaCode',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _handleExport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[850],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.red, width: 2),
            ),
          ),
          child: Text(
            'Export',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  void _handleExport() async {
    try {
      final currentUser = UserSession.instance.getUser();
      final exportFolder = currentUser.datasetExportFolder;
      
      // Create a filename for the export
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${widget.project.name.replaceAll(' ', '_')}_${selectedDatasetType.toLowerCase()}_$timestamp.zip';
      final exportPath = path.join(exportFolder, filename);
      
      // Show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Use the DatasetExportUtils to export the project
      final result = await DatasetExportUtils.exportProject(
        project: widget.project,
        datasetType: selectedDatasetType,
        exportPath: exportPath,
        exportLabels: exportLabels,
        exportAnnotations: exportAnnotations,
      );
      
      // Close the loading indicator
      Navigator.of(context).pop();
      
      // Show success message and return
      AppSnackbar.show(
        context,
        'Project exported successfully to $result',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      
      Navigator.of(context).pop('refresh');
    } catch (e, stack) {
      debugPrint('Error while exporting project: $e\n$stack');
      
      // Close the loading indicator if it's showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      AlertErrorDialog.show(
        context,
        'Export Failed',
        'Something went wrong while exporting your project. Please try again or contact support.',
        tips: e.toString(),
      );
    }
  }
}