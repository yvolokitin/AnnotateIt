import 'dart:io';
import 'package:flutter/material.dart';

import '../../models/media_item.dart';
import '../../gen_l10n/app_localizations.dart';

import '../../utils/image_utils.dart';

class SetImageIconDialog extends StatefulWidget {
  final MediaItem media;
  final String projectId;
  final void Function(String? thumbnailPath) onConfirmed;

  const SetImageIconDialog({
    super.key,
    required this.media,
    required this.projectId,
    required this.onConfirmed,
  });

  @override
  State<SetImageIconDialog> createState() => _SetImageIconDialogState();
}

class _SetImageIconDialogState extends State<SetImageIconDialog> {
  bool _isGenerating = false;
  bool _hasError = false;

  Future<void> _generateAndSetThumbnail() async {
    setState(() {
      _isGenerating = true;
      _hasError = false;
    });

    try {
      final thumbnailFile = await generateThumbnailFromImage(
        File(widget.media.filePath),
        widget.projectId,
      );

      if (thumbnailFile != null) {
        widget.onConfirmed(thumbnailFile.path);
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() => _hasError = true);
      }
    } catch (e) {
      setState(() => _hasError = true);
      debugPrint('Thumbnail generation failed: $e');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 700;
    final fileName = widget.media.filePath.split('/').last;

    return AlertDialog(
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.blueAccent, width: 1),
      ),
      titlePadding: const EdgeInsets.only(left: 16, top: 16, right: 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _hasError ? Icons.error_outline : Icons.image_outlined,
                size: 32,
                color: _hasError ? Colors.orange : Colors.blueAccent,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.setAsProjectIcon,
                style: TextStyle(
                  color: _hasError ? Colors.orange : Colors.blueAccent,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.bold,
                  fontSize: isLargeScreen ? 24 : 20,
                ),
              ),
            ],
          ),
          if (!_isGenerating)
            IconButton(
              icon: Icon(Icons.close, color: _hasError ? Colors.orange : Colors.blueAccent),
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
              Divider(color: _hasError ? Colors.orange : Colors.blueAccent),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _isGenerating
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 40),
                          const CircularProgressIndicator(
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.thumbnailGenerationInProgress,
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
                            _hasError ? l10n.thumbnailGenerationFailed : l10n.setAsProjectIconConfirm(widget.media.filePath),
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'CascadiaCode',
                              fontSize: isLargeScreen ? 22 : 18,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.image, 
                                size: 24, 
                                color: _hasError ? Colors.orange : Colors.white38,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  fileName,
                                  style: TextStyle(
                                    color: _hasError ? Colors.orange : Colors.white54,
                                    fontFamily: 'CascadiaCode',
                                    fontSize: isLargeScreen ? 20 : 16,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (_hasError) ...[
                            const SizedBox(height: 20),
                            Text(
                              l10n.thumbnailGenerationTryAgainLater,
                              style: TextStyle(
                                color: Colors.orange,
                                fontFamily: 'CascadiaCode',
                                fontSize: isLargeScreen ? 20 : 16,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              Divider(color: _hasError ? Colors.orange : Colors.blueAccent),
            ],
          ),
        ),
      ),
      actions: _isGenerating
          ? null
          : [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _hasError ? Colors.orange : Colors.white70, 
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _hasError ? l10n.buttonClose : l10n.buttonCancel,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'CascadiaCode',
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 22 : 18,
                  ),
                ),
              ),
              if (!_hasError)
                ElevatedButton(
                  onPressed: _generateAndSetThumbnail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                  ),
                  child: Text(
                    l10n.setAsProjectIcon,
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
