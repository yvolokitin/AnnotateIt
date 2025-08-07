import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../models/project.dart';
import '../../models/label.dart';
import '../../data/labels_database.dart';
import '../../data/annotation_database.dart';
import '../../session/user_session.dart';
import '../app_snackbar.dart';
import 'alert_error_dialog.dart';

class RemoveAllLabelsDialog extends StatefulWidget {
  final Project project;
  final Function(List<Label>) onLabelsRemoved;

  const RemoveAllLabelsDialog({
    super.key,
    required this.project,
    required this.onLabelsRemoved,
  });

  static Future<void> show({
    required BuildContext context,
    required Project project,
    required Function(List<Label>) onLabelsRemoved,
  }) {
    return showDialog(
      context: context,
      builder: (context) => RemoveAllLabelsDialog(
        project: project,
        onLabelsRemoved: onLabelsRemoved,
      ),
    );
  }

  @override
  State<RemoveAllLabelsDialog> createState() => _RemoveAllLabelsDialogState();
}

class _RemoveAllLabelsDialogState extends State<RemoveAllLabelsDialog> {
  bool _isRemoving = false;

  Future<void> _removeAllLabels() async {
    final shouldDeleteAnnotations = UserSession.instance.getUser().labelsDeleteAnnotations;
    
    setState(() {
      _isRemoving = true;
    });

    try {
      // If configured to delete annotations when labels are removed
      if (shouldDeleteAnnotations) {
        // Delete annotations for each label in the project
        for (final label in widget.project.labels!) {
          await AnnotationDatabase.instance.deleteAnnotationsByLabelId(label.id);
        }
      }
      
      // Delete all labels for this project
      await LabelsDatabase.instance.deleteLabelsForProject(widget.project.id!);
      
      // Update the UI with an empty list of labels
      widget.onLabelsRemoved(<Label>[]);
      
      // Show success message
      if (mounted) {
        Navigator.pop(context);
        AppSnackbar.show(
          context,
          'All labels have been removed from the project.',
          backgroundColor: Colors.orange,
          textColor: Colors.black,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        AlertErrorDialog.show(
          context,
          'Failed to remove labels',
          'An error occurred while removing labels: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 700;
    final shouldDeleteAnnotations = UserSession.instance.getUser().labelsDeleteAnnotations;

    return AlertDialog(
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      titlePadding: const EdgeInsets.only(left: 16, top: 16, right: 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.delete_sweep_outlined,
                size: 32,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 12),
              Text(
                'Remove All Labels',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.bold,
                  fontSize: isLargeScreen ? 24 : 20,
                ),
              ),
            ],
          ),
          if (!_isRemoving)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              tooltip: l10n.buttonClose,
              onPressed: () => Navigator.pop(context),
            ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: Colors.redAccent),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _isRemoving
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 40),
                          const CircularProgressIndicator(
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Removing all labels...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'CascadiaCode',
                              fontSize: isLargeScreen ? 22 : 18,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Are you sure you want to remove all labels from this project?',
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'CascadiaCode',
                              fontSize: isLargeScreen ? 22 : 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (shouldDeleteAnnotations)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.redAccent),
                              ),
                              child: Text(
                                'Warning: All annotations associated with these labels will also be deleted.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'CascadiaCode',
                                  fontWeight: FontWeight.bold,
                                  fontSize: isLargeScreen ? 20 : 16,
                                ),
                              ),
                            )
                          else
                            Text(
                              'All annotations will be marked as Unknown and will need to be re-labeled.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontFamily: 'CascadiaCode',
                                fontStyle: FontStyle.italic,
                                fontSize: isLargeScreen ? 20 : 16,
                              ),
                            ),
                        ],
                      ),
              ),
              const Divider(color: Colors.redAccent),
            ],
          ),
        ),
      ),
      actions: _isRemoving
          ? null
          : [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white70, width: 2),
                  ),
                ),
                child: Text(
                  l10n.buttonCancel,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'CascadiaCode',
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 22 : 18,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _removeAllLabels,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.redAccent, width: 2),
                  ),
                ),
                child: Text(
                  'Remove All',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'CascadiaCode',
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 22 : 18,
                  ),
                ),
              ),
            ],
    );
  }
}