import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vap/gen_l10n/app_localizations.dart';
import 'package:vap/models/project.dart';
import 'package:vap/data/labels_database.dart';
import 'package:vap/utils/project_utils.dart';

class DeleteProjectDialog extends StatefulWidget {
  final Project project;
  final VoidCallback onConfirmed;
  final void Function(bool deleteFromDisk, bool dontAskAgain)? onOptionsSelected;

  const DeleteProjectDialog({
    super.key,
    required this.project,
    required this.onConfirmed,
    this.onOptionsSelected,
  });

  @override
  State<DeleteProjectDialog> createState() => _DeleteProjectDialogState();
}

class _DeleteProjectDialogState extends State<DeleteProjectDialog> {
  bool _deleteFromDisk = false;
  bool _dontAskAgain = false;
  bool _isDeleting = false;
  int _labelCount = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);

    await deleteProjectSafe(widget.project, deleteFromDisk: _deleteFromDisk);

    if (mounted) {
      widget.onOptionsSelected?.call(_deleteFromDisk, _dontAskAgain);
      widget.onConfirmed();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isFullscreen = isMobile || isTablet;

    final creationDate = DateFormat.yMMMd().format(widget.project.creationDate);

    return WillPopScope(
      onWillPop: () async => !_isDeleting,
      child: AlertDialog(
        insetPadding: isFullscreen ? EdgeInsets.zero : const EdgeInsets.all(40),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delete Project'),
            const SizedBox(height: 8),
            const Divider(thickness: 1, color: Colors.white),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isFullscreen ? double.infinity : 800,
            maxHeight: isFullscreen ? double.infinity : 500,
          ),
          child: _isDeleting
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(height: 40),
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Deleting project...', style: TextStyle(color: Colors.white70)),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to permanently delete the project "${widget.project.name}"?',
                      style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 32, color: Colors.white38),
                        const SizedBox(width: 25),
                        Expanded(
                          child: Text(
                            'Project was created at $creationDate\nNumber of Labels: $_labelCount',
                            style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: _deleteFromDisk,
                      onChanged: (val) => setState(() => _deleteFromDisk = val ?? false),
                      title: const Text(
                        'Also delete all files from disk',
                        style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.redAccent,
                    ),
                    CheckboxListTile(
                      value: _dontAskAgain,
                      onChanged: (val) => setState(() => _dontAskAgain = val ?? false),
                      title: const Text(
                        "Don't ask me again",
                        style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.grey,
                    ),
                  ],
                ),
        ),
        actions: _isDeleting
            ? []
            : [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.white70, width: 2),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.redAccent, width: 2),
                    ),
                  ),
                  onPressed: _handleDelete,
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
      ),
    );
  }
}
