import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../gen_l10n/app_localizations.dart';

import '../../models/project.dart';
import '../../utils/project_utils.dart';

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
  bool _deleteFromDisk = true;
  bool _dontAskAgain = false;
  bool _isDeleting = false;
  int _labelCount = 0;
  String _currentStep = '';
  double _progress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _labelCount = widget.project.labels!.length;
  }

  Future<void> _handleDelete() async {
    setState(() {
      _isDeleting = true;
      _currentStep = 'Starting deletion...';
      _progress = 0.0;
      _errorMessage = null;
    });

    try {
      await deleteProjectSafe(
        widget.project,
        deleteFromDisk: _deleteFromDisk,
        onProgress: (step, progress) {
          if (mounted) {
            setState(() {
              _currentStep = step;
              _progress = progress;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _errorMessage = error;
            });
          }
        },
      );

      if (mounted) {
        widget.onOptionsSelected?.call(_deleteFromDisk, _dontAskAgain);
        widget.onConfirmed();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Critical error: $e';
          _currentStep = 'Deletion failed!';
          _progress = 1.0;
        });
        
        // Show error dialog and allow user to close
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isDeleting = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final creationDate = DateFormat.yMMMd().format(widget.project.creationDate);

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
                l10n.deleteProjectTitle,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth>700 ? 24 : 20,
                ),
              ),
            ],
          ),
          if (!_isDeleting)
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
                child: _isDeleting
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          // Progress bar
                          LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.grey[700],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                            minHeight: 8,
                          ),
                          const SizedBox(height: 20),
                          // Current step
                          Text(
                            _currentStep,
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'CascadiaCode',
                              fontSize: screenWidth>700 ? 20 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          // Progress percentage
                          Text(
                            '${(_progress * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.white54,
                              fontFamily: 'CascadiaCode',
                              fontSize: screenWidth>700 ? 18 : 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Error messages
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontFamily: 'CascadiaCode',
                                        fontSize: screenWidth>700 ? 16 : 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          // Show close button if deletion failed
                          if (_progress >= 1.0 && _errorMessage != null)
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(color: Colors.redAccent, width: 1),
                                ),
                              ),
                              child: Text(
                                'Close',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'CascadiaCode',
                                  fontSize: screenWidth>700 ? 16 : 14,
                                ),
                              ),
                            ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.deleteProjectConfirm(widget.project.name),
                            style: TextStyle(
                              fontFamily: 'CascadiaCode',
                              fontWeight: FontWeight.normal,
                              color: Colors.white70,
                              fontSize: screenWidth>700 ? 22 : 18,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline,
                                  size: 32, color: Colors.white38),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  l10n.deleteProjectInfoLine(
                                      creationDate, _labelCount),
                                  style: TextStyle(
                                    fontFamily: 'CascadiaCode',
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white54,
                                    fontSize: screenWidth>700 ? 22 : 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          CheckboxListTile(
                            value: _deleteFromDisk,
                            onChanged: (val) =>
                                setState(() => _deleteFromDisk = val ?? false),
                            title: Text(
                              l10n.deleteProjectOptionDeleteFromDisk,
                              style: TextStyle(
                                fontFamily: 'CascadiaCode',
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                fontSize: screenWidth>700 ? 22 : 18,
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.redAccent,
                          ),
                          CheckboxListTile(
                            value: _dontAskAgain,
                            onChanged: (val) =>
                                setState(() => _dontAskAgain = val ?? false),
                            title: Text(
                              l10n.deleteProjectOptionDontAskAgain,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'CascadiaCode',
                                fontWeight: FontWeight.normal,
                                fontSize: screenWidth>700 ? 22 : 18,
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.grey,
                          ),
                        ],
                      ),
              ),
              const Divider(color: Colors.redAccent),
            ],
          ),
        ),
      ),
      actions: _isDeleting
          ? null
          : [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25, vertical: 15),
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
                    fontSize: screenWidth>700 ? 22 : 18,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _handleDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.redAccent, width: 2),
                  ),
                ),
                child: Text(
                  l10n.buttonDelete,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'CascadiaCode',
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth>700 ? 22 : 18,
                  ),
                ),
              ),
            ],
    );
  }
}
