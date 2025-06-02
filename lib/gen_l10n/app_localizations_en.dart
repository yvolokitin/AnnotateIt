// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get keep => 'Keep';

  @override
  String get discard => 'Discard';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get importDataset => 'Import dataset';

  @override
  String get uploadMedia => 'Upload media';

  @override
  String get createProjectTitle => 'Create a New Project';

  @override
  String get createProjectStepOneSubtitle =>
      'Please, enter your new project name and select Project type';

  @override
  String get createProjectStepTwoSubtitle =>
      'Please, create labels for a New project';

  @override
  String get emptyProject_title => 'Start your first project';

  @override
  String get emptyProject_description =>
      'Create a project to begin organizing datasets, annotating media, and applying AI to your vision tasks — all in one streamlined workspace designed to accelerate your computer vision pipeline.';

  @override
  String get emptyProject_createNew => 'Create New Project';

  @override
  String get emptyProject_importDataset => 'Create Project from Dataset import';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogBack => '<- Back';

  @override
  String get dialogNext => 'Next ->';

  @override
  String get dialogFinish => 'Finish';

  @override
  String get dialogCloseTooltip => 'Close';

  @override
  String get taskTypeRequiredTitle => 'Task Type Required';

  @override
  String taskTypeRequiredMessage(Object tab) {
    return 'You need to select a task type before continuing. The current tab \'$tab\' has no task type selected. Each project must be associated with a task (e.g., object detection, classification, or segmentation) so the system knows how to process your data.';
  }

  @override
  String taskTypeRequiredTips(Object tab) {
    return 'Click one of the available task type options below the \'$tab\' tab. If you\'re unsure which task to choose, hover over the info icon next to each type to see a brief description.';
  }

  @override
  String get menuProjects => 'Projects';

  @override
  String get menuAccount => 'Account';

  @override
  String get menuLearn => 'Learn';

  @override
  String get menuAbout => 'About';

  @override
  String get projectNameLabel => 'Project Name';

  @override
  String get tabDetection => 'Detection';

  @override
  String get tabClassification => 'Classification';

  @override
  String get tabSegmentation => 'Segmentation';

  @override
  String get labelRequiredTitle => 'At Least One Label Required';

  @override
  String get labelRequiredMessage =>
      'You must create at least one label to proceed. Labels are essential for defining the annotation categories that will be used during dataset preparation.';

  @override
  String get labelRequiredTips =>
      'Tip: Click the red button labeled Create Label after entering a label name to add your first label.';

  @override
  String get createLabelButton => 'Create Label';

  @override
  String get labelNameHint => 'Enter a new Label name here';

  @override
  String get createdLabelsTitle => 'Created Labels';

  @override
  String get labelEmptyTitle => 'Label name cannot be empty!';

  @override
  String get labelEmptyMessage =>
      'Please enter a label name. Labels help identify the objects or categories in your project. It is recommended to use short, clear, and descriptive names, such as \"Car\", \"Person\", or \"Tree\". Avoid special characters or spaces.';

  @override
  String get labelEmptyTips =>
      'Tips for Label Naming:\n• Use short and descriptive names\n• Stick to letters, digits, underscores (e.g., cat, road_sign, background)\n• Avoid spaces and symbols (e.g., Person 1 → person_1)';

  @override
  String get labelDuplicateTitle => 'Duplicate Label Name';

  @override
  String labelDuplicateMessage(Object label) {
    return 'The label \'$label\' already exists in this project. Each label must have a unique name to avoid confusion during annotation and training.';
  }

  @override
  String get labelDuplicateTips =>
      'Why unique labels?\n• Reusing the same name can cause issues during dataset export and model training.\n• Unique label names help maintain clear, structured annotations.\n\nTip: Try adding a variation or number to differentiate (e.g., \'Car\', \'Car_2\').';

  @override
  String get binaryLimitTitle => 'Binary Classification Limit';

  @override
  String get binaryLimitMessage =>
      'You cannot create more than two labels for a Binary Classification project.\n\nBinary Classification is designed to distinguish between exactly two classes, such as \'Yes\' vs \'No\', or \'Spam\' vs \'Not Spam\'.';

  @override
  String get binaryLimitTips =>
      'Need more than two labels?\nConsider switching your project type to Multi-Class Classification or another suitable task in order to support three or more categories.';

  @override
  String get noteBinaryClassification =>
      'This project type allows exactly 2 labels. Binary Classification is used when your model needs to distinguish between two possible classes, such as \"Yes\" vs \"No\", or \"Dog\" vs \"Not Dog\". Please create only two distinct labels.';

  @override
  String get noteMultiClassClassification =>
      'This project type supports multiple labels. Multi-Class Classification is suitable when your model needs to choose from three or more categories, like \"Cat\", \"Dog\", \"Rabbit\". You can add as many labels as needed.';

  @override
  String get noteDetectionOrSegmentation =>
      'This project type supports multiple labels. For Object Detection or Segmentation, each label typically represents a different class of object (e.g., \"Car\", \"Pedestrian\", \"Bicycle\"). You can create as many labels as required for your dataset.';

  @override
  String get noteDefault =>
      'You can create one or more labels depending on your project type. Each label helps define a category that your model will learn to recognize. Please refer to the documentation for best practices.';

  @override
  String get discardDatasetImportTitle => 'Discard Dataset Import?';

  @override
  String get discardDatasetImportMessage =>
      'You have already extracted a dataset. Cancelling now will delete the extracted files and detected dataset details. Are you sure you want to proceed?';

  @override
  String get projectTypeHelpTitle => 'Project Type Selection Help';

  @override
  String get projectTypeWhyDisabledTitle =>
      'Why are some project types disabled?';

  @override
  String get projectTypeWhyDisabledBody =>
      'When you import a dataset, the system analyzes the provided annotations and tries to detect the most suitable project type for you automatically.\n\nFor example, if your dataset contains bounding box annotations, the suggested project type will be \"Detection\". If it contains masks, \"Segmentation\" will be suggested, and so on.\n\nTo protect your data, only compatible project types are enabled by default.';

  @override
  String get projectTypeAllowChangeTitle =>
      'What happens if I enable project type change?';

  @override
  String get projectTypeAllowChangeBody =>
      'If you toggle \"Allow Project Type Change\", you can manually select ANY project type, even if it does not match the detected annotations.\n\n⚠️ WARNING: All existing annotations from the import will be deleted when switching to an incompatible project type.\nYou will have to re-annotate or import a dataset suitable for the newly selected project type.';

  @override
  String get projectTypeWhenUseTitle => 'When should I use this option?';

  @override
  String get projectTypeWhenUseBody =>
      'You should only enable this option if:\n\n- You accidentally imported the wrong dataset.\n- You want to start a new annotation project with a different type.\n- Your dataset structure changed after import.\n\nIf you are unsure, we strongly recommend keeping the default selection to avoid data loss.';

  @override
  String get allLabels => 'All Labels';

  @override
  String get setAsProjectIcon => 'Set as Project Icon';

  @override
  String setAsProjectIconConfirm(Object filePath) {
    return 'Do you want to use \'$filePath\' as the icon for this project?\n\nThis will replace any previously set icon.';
  }

  @override
  String get removeFilesFromDataset => 'Remove files from Dataset?';

  @override
  String get removeFilesFromDatasetConfirm =>
      'Are you sure you want to delete the following files?\n\nAll corresponding annotations will be removed as well.';
}
