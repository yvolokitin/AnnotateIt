import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../models/project.dart';
import '../../data/project_database.dart';
import '../../utils/theme.dart';
import '../shared/edit_name_dialog.dart';

class EditProjectNameDialog extends StatelessWidget {
  final Project project;
  final String Function(String)? onProjectNameUpdated;

  const EditProjectNameDialog({
    super.key,
    required this.project,
    this.onProjectNameUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EditNameDialog(
      currentName: project.name,
      title: l10n.editProjectTitle,
      description: l10n.editProjectDescription,
      saveLabel: l10n.buttonSave,
      closeLabel: l10n.buttonClose,
      accentColor: Theme.of(context).colorScheme.info,
      onSave: (newName) async {
        await ProjectDatabase.instance.updateProjectName(project.id!, newName);
        onProjectNameUpdated?.call(newName);
      },
    );
  }
}
