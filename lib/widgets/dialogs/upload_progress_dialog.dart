import 'package:flutter/material.dart';

/// A dialog that shows the progress of file uploads.
/// It can be minimized to a snackbar and restored from the snackbar.
/// 
/// The dialog shows:
/// - Overall upload progress
/// - Current file index and total files
/// - List of files being uploaded with individual progress
/// - Cancellation status when upload is being cancelled
/// 
/// When the user presses the cancel button, the dialog shows a cancellation
/// status and disables the cancel button to prevent multiple cancellation requests.
/// The upload process will detect the cancellation and stop the upload.
/// 
/// The dialog also informs the user that leaving the page will cancel the upload.
class UploadProgressDialog extends StatefulWidget {
  /// The list of files being uploaded
  final List<UploadFileInfo> files;
  
  /// Whether the dialog is minimized to a snackbar
  final bool isMinimized;
  
  /// Callback when the dialog is minimized
  final VoidCallback onMinimize;
  
  /// Callback when the dialog is restored from the snackbar
  final VoidCallback onRestore;
  
  /// Callback when the upload is canceled
  final VoidCallback onCancel;

  const UploadProgressDialog({
    Key? key,
    required this.files,
    required this.isMinimized,
    required this.onMinimize,
    required this.onRestore,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<UploadProgressDialog> createState() => _UploadProgressDialogState();
}

class _UploadProgressDialogState extends State<UploadProgressDialog> {
  @override
  Widget build(BuildContext context) {
    if (widget.isMinimized) {
      return _buildSnackbar(context);
    } else {
      return _buildDialog(context);
    }
  }

  Widget _buildDialog(BuildContext context) {
    // Filter out the cancellation indicator for counting actual files
    final actualFiles = widget.files.where((file) => !file.isCancelling).toList();
    final totalFiles = actualFiles.length;
    
    // Count files that are fully uploaded (progress = 1.0)
    final completedFiles = actualFiles.where((file) => file.progress >= 1.0).length;
    
    // Calculate the current file index (files with any progress)
    final currentFileIndex = actualFiles.where((file) => file.progress > 0).length;
    
    // Calculate overall progress
    final overallProgress = totalFiles > 0 ? completedFiles / totalFiles : 0.0;
    
    // Check if cancellation is in progress
    final isCancelling = widget.files.any((file) => file.isCancelling);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isCancelling ? 'Cancelling Upload...' : 'Uploading Files',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isCancelling ? Colors.orange : null,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.minimize),
                      tooltip: 'Minimize',
                      onPressed: widget.onMinimize,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Cancel',
                      onPressed: isCancelling ? null : widget.onCancel,
                      color: isCancelling ? Colors.grey : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Overall Progress: ${(overallProgress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: overallProgress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCancelling ? Colors.orange : Colors.blue
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Files: $currentFileIndex/$totalFiles',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Note: Leaving this page will cancel the upload',
              style: TextStyle(
                color: Colors.orange[800],
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
            if (isCancelling)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Cancelling upload in progress...',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.files.length,
                  itemBuilder: (context, index) {
                    final file = widget.files[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  file.filename,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: file.isCancelling ? Colors.orange : null,
                                    fontStyle: file.isCancelling ? FontStyle.italic : null,
                                    fontWeight: file.isCancelling ? FontWeight.bold : null,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (file.progress >= 1.0 && !file.isCancelling)
                                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                            ],
                          ),
                          if (!file.isCancelling) ...[
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: file.progress,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                file.progress >= 1.0 ? Colors.green : Colors.blue,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnackbar(BuildContext context) {
    // Filter out the cancellation indicator for counting actual files
    final actualFiles = widget.files.where((file) => !file.isCancelling).toList();
    final totalFiles = actualFiles.length;
    
    // Count files that are fully uploaded (progress = 1.0)
    final completedFiles = actualFiles.where((file) => file.progress >= 1.0).length;
    
    // Calculate the current file index (files with any progress)
    final currentFileIndex = actualFiles.where((file) => file.progress > 0).length;
    
    // Calculate overall progress
    final overallProgress = totalFiles > 0 ? completedFiles / totalFiles : 0.0;
    
    // Check if cancellation is in progress
    final isCancelling = widget.files.any((file) => file.isCancelling);
    
    return GestureDetector(
      onTap: widget.onRestore,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCancelling ? Colors.orange[800] : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        // Wrap with a SizedBox to provide a bounded width constraint
        child: SizedBox(
          width: 300, // Fixed width for the snackbar
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCancelling ? Icons.cancel : Icons.upload_file, 
                color: Colors.white
              ),
              const SizedBox(width: 12),
              Flexible( // Use Flexible instead of Expanded
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isCancelling 
                        ? 'Cancelling upload...' 
                        : 'Uploading: $currentFileIndex/$totalFiles files',
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: overallProgress,
                      backgroundColor: Colors.grey[600],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCancelling ? Colors.red : Colors.blue
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Leaving will cancel upload',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.open_in_full, color: Colors.white),
                tooltip: 'Expand',
                onPressed: widget.onRestore,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Information about a file being uploaded
/// 
/// This class stores information about a file being uploaded, including:
/// - The filename
/// - The progress of the upload (0.0 to 1.0)
/// - Whether the upload is being cancelled
/// 
/// Files with progress = 1.0 are considered fully uploaded.
/// Files with isCancelling = true are used to indicate that cancellation is in progress.
class UploadFileInfo {
  /// The filename
  final String filename;
  
  /// The progress of the upload (0.0 to 1.0)
  final double progress;
  
  /// Whether this file upload is being cancelled
  /// 
  /// This is used to indicate that cancellation is in progress.
  /// Files with this flag are displayed differently in the UI.
  final bool isCancelling;

  UploadFileInfo({
    required this.filename,
    required this.progress,
    this.isCancelling = false,
  });
}

/// A widget that manages the upload progress dialog and snackbar
/// 
/// This widget:
/// - Displays a dialog showing upload progress
/// - Allows the dialog to be minimized to a snackbar
/// - Handles cancellation of uploads
/// - Provides methods to update file progress and clear files
/// 
/// When the user presses the cancel button, the manager:
/// 1. Calls the onCancelUpload callback to notify the parent
/// 2. Adds a visual indicator that cancellation is in progress
/// 3. Keeps the dialog visible until the upload process detects cancellation
/// 4. The upload process will then clear the dialog after a short delay
/// 
/// The dialog also informs the user that leaving the page will cancel the upload.
/// This is handled by the parent components through the ProjectDetailsPage._confirmNavigationDuringUpload method.
class UploadProgressManager extends StatefulWidget {
  /// The child widget
  final Widget child;
  
  /// Callback when the upload is canceled
  /// 
  /// This is called when the user presses the cancel button.
  /// The parent should set a flag to indicate that cancellation is requested,
  /// which will be checked by the upload process.
  final VoidCallback? onCancelUpload;

  const UploadProgressManager({
    Key? key,
    required this.child,
    this.onCancelUpload,
  }) : super(key: key);

  @override
  State<UploadProgressManager> createState() => UploadProgressManagerState();
}

class UploadProgressManagerState extends State<UploadProgressManager> {
  final List<UploadFileInfo> _files = [];
  bool _isMinimized = false;
  bool _isVisible = false;
  
  /// Add or update a file in the upload progress dialog
  /// 
  /// This method is called by the parent component to update the progress of a file.
  /// It:
  /// - Finds the file if it already exists, or adds a new file
  /// - Updates the progress of the file
  /// - Shows the dialog if it's not visible
  /// 
  /// @param filename The name of the file being uploaded
  /// @param index The current index (1-based) of the file in the upload process
  /// @param total The total number of files being uploaded
  void updateFileProgress(String filename, int index, int total) {
    setState(() {
      // Find the file if it already exists
      final existingFileIndex = _files.indexWhere((file) => file.filename == filename);
      
      // Calculate progress
      final progress = index / total;
      
      if (existingFileIndex >= 0) {
        // Update existing file
        _files[existingFileIndex] = UploadFileInfo(
          filename: filename,
          progress: progress,
        );
      } else {
        // Add new file
        _files.add(UploadFileInfo(
          filename: filename,
          progress: progress,
        ));
      }
      
      // Show the dialog if it's not visible
      if (!_isVisible) {
        _isVisible = true;
        _isMinimized = false;
      }
    });
  }
  
  /// Clear all files and hide the dialog
  /// 
  /// This method is called:
  /// - After a successful upload (with a delay)
  /// - When the upload process detects cancellation (with a delay)
  /// - When an upload error occurs
  /// 
  /// It clears the list of files and hides the dialog.
  void clearFiles() {
    setState(() {
      _files.clear();
      _isVisible = false;
    });
  }
  
  /// Cancel the upload
  /// 
  /// This method is called when the user presses the cancel button.
  /// It:
  /// 1. Calls the onCancelUpload callback to notify the parent component
  /// 2. Adds a visual indicator that cancellation is in progress
  /// 3. Keeps the dialog visible until the upload process detects cancellation
  /// 
  /// The upload process will check for cancellation and stop the upload.
  /// After a short delay to show the cancellation status, the upload process
  /// will call clearFiles to hide the dialog.
  /// 
  /// This approach ensures that:
  /// - The user gets immediate visual feedback that cancellation is in progress
  /// - The dialog doesn't disappear and reappear during cancellation
  /// - The upload process has time to detect and handle the cancellation
  void cancelUpload() {
    // Call the cancel callback but don't clear files immediately
    // This allows the dialog to stay visible until the upload process actually stops
    widget.onCancelUpload?.call();
    
    // Mark all files as cancelled by setting a cancelled flag in the UI
    setState(() {
      // Add a visual indicator that cancellation is in progress
      if (_files.isNotEmpty) {
        _files.add(UploadFileInfo(
          filename: "Cancelling upload...",
          progress: 0.0,
          isCancelling: true
        ));
      }
    });
    
    // Don't clear files here - let the upload process handle that
    // clearFiles will be called by the upload process when it detects cancellation
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isVisible)
          Positioned(
            bottom: 16,
            right: 16,
            child: _isMinimized
                ? UploadProgressDialog(
                    files: _files,
                    isMinimized: true,
                    onMinimize: () {},
                    onRestore: () {
                      setState(() {
                        _isMinimized = false;
                      });
                    },
                    onCancel: cancelUpload,
                  )
                : UploadProgressDialog(
                    files: _files,
                    isMinimized: false,
                    onMinimize: () {
                      setState(() {
                        _isMinimized = true;
                      });
                    },
                    onRestore: () {},
                    onCancel: cancelUpload,
                  ),
          ),
      ],
    );
  }
}