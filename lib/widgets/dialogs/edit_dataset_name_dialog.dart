import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../models/dataset.dart';
import '../../data/dataset_database.dart';
import '../../data/project_database.dart';
import '../../utils/theme.dart';
import '../shared/edit_name_dialog.dart';

class EditDatasetNameDialog extends StatelessWidget {
  final Dataset dataset;
  final void Function(Dataset updatedDataset)? onDatasetNameUpdated;

  const EditDatasetNameDialog({
    super.key,
    required this.dataset,
    this.onDatasetNameUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EditNameDialog(
      currentName: dataset.name,
      title: l10n.editDatasetTitle,
      description: l10n.editDatasetDescription,
      saveLabel: l10n.buttonSave,
      closeLabel: l10n.buttonClose,
      accentColor: AppColors.accentOrange,
      onSave: (newName) async {
        final updated = dataset.copyWith(name: newName);
        await DatasetDatabase.instance.updateDataset(updated);
        await ProjectDatabase.instance.updateProjectLastUpdated(updated.projectId);
        onDatasetNameUpdated?.call(updated);
      },
    );
  }
}
