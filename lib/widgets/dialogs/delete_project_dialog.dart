import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

import 'package:vap/models/project.dart';
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
    _labelCount = widget.project.labels!.length;
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
            Text(
              l10n.deleteProjectTitle,
              style: const TextStyle(
                fontFamily: 'CascadiaCode',
              ),
            ),
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
                  children: [
                    const SizedBox(height: 40),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      l10n.deleteProjectInProgress,
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'CascadiaCode',
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.deleteProjectConfirm(widget.project.name),
                      style: const TextStyle(
                        fontFamily: 'CascadiaCode',
                        fontWeight: FontWeight.normal,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 32, color: Colors.white38),
                        const SizedBox(width: 25),
                        Expanded(
                          child: Text(
                            l10n.deleteProjectInfoLine(creationDate, _labelCount),
                            style: const TextStyle(
                              fontFamily: 'CascadiaCode',
                              fontWeight: FontWeight.normal,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: _deleteFromDisk,
                      onChanged: (val) => setState(() => _deleteFromDisk = val ?? false),
                      title: Text(
                        l10n.deleteProjectOptionDeleteFromDisk,
                        style: const TextStyle(
                          fontFamily: 'CascadiaCode',
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.redAccent,
                    ),
                    CheckboxListTile(
                      value: _dontAskAgain,
                      onChanged: (val) => setState(() => _dontAskAgain = val ?? false),
                      title: Text(
                        l10n.deleteProjectOptionDontAskAgain,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'CascadiaCode',
                          fontWeight: FontWeight.normal,
                        ),
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
                  child: Text(
                    l10n.buttonCancel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'CascadiaCode',
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
                  child: Text(
                    l10n.buttonDelete,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
      ),
    );
  }
}
