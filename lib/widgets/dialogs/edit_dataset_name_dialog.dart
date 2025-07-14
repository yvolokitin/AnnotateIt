import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../models/dataset.dart';
import '../../data/dataset_database.dart';
import '../../data/project_database.dart';

class EditDatasetNameDialog extends StatefulWidget {
  final Dataset dataset;
  final void Function(Dataset updatedDataset)? onDatasetNameUpdated;

  const EditDatasetNameDialog({
    super.key,
    required this.dataset,
    this.onDatasetNameUpdated,
  });

  @override
  EditDatasetNameDialogState createState() => EditDatasetNameDialogState();
}

class EditDatasetNameDialogState extends State<EditDatasetNameDialog> {
  late TextEditingController _controller;
  String datasetName = "";
  
  @override
  void initState() {
    super.initState();
    datasetName = widget.dataset.name;
    _controller = TextEditingController(text: datasetName);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (datasetName.isNotEmpty) {
      final updated = widget.dataset.copyWith(name: datasetName.trim());
      await DatasetDatabase.instance.updateDataset(updated);
      await ProjectDatabase.instance.updateProjectLastUpdated(updated.projectId);
      widget.onDatasetNameUpdated?.call(updated);
      if (!mounted) return;
      Navigator.pop(context, updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orangeAccent, width: 1),
      ),
      title: Row(
        children: [
          Icon(
            Icons.edit_note_outlined,
            size: (screenWidth > 1200) ? 34 : 26,
            color: Colors.orangeAccent,
          ),
          const SizedBox(width: 12),
          Text(
            l10n.editDatasetTitle,
            style: TextStyle(
              color: Colors.orangeAccent,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
              fontSize: (screenWidth > 1200) ? 26 : 20,
            ),
          ),
        ],
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Colors.orangeAccent),
          Padding(
            padding: EdgeInsets.all(screenWidth > 1200 ? 25.0 : 12.0),
            child: Text(
              l10n.editDatasetDescription,
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.normal,
                fontSize: (screenWidth > 1200) ? 24 : 20,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(screenWidth > 1200 ? 25.0 : 12.0),
            child: TextField(
                controller: _controller,
                onChanged: (value) => setState(() {
                  datasetName = value;
                }),
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Colors.white54,
                    fontFamily: 'CascadiaCode',
                    fontWeight: FontWeight.normal,
                    fontSize: screenWidth > 1200 ? 22 : 18,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orangeAccent, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orangeAccent, width: 1),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (screenWidth > 1200) ? 22 : 18,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.normal,
                ),
              ),
          ),
        ],
      ),

      actions: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.buttonClose,
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'CascadiaCode',
                  fontSize: (screenWidth > 1200) ? 22 : 20,
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.orangeAccent, width: 2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.buttonSave,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.bold,
                      fontSize: (screenWidth > 1200) ? 22 : 20,
                    ),
                  ),
                ],
              ),
            ),
          ]
        ),
      ],
    );
  }
}
