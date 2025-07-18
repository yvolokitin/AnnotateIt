// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get buttonKeep => 'Keep';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonHelp => 'Help';

  @override
  String get buttonEdit => 'Edit';

  @override
  String get buttonNext => 'Next';

  @override
  String get buttonBack => 'Back';

  @override
  String get buttonApply => 'Apply';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonImport => 'Import';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonFinish => 'Finish';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonDuplicate => 'Duplicate';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonDiscard => 'Discard';

  @override
  String get buttonFeedbackShort => 'Fdbck';

  @override
  String get buttonImportLabels => 'Import Labels';

  @override
  String get buttonExportLabels => 'Export Labels';

  @override
  String get buttonNextConfirmTask => 'Next: Confirm Task';

  @override
  String get buttonCreateProject => 'Create Project';

  @override
  String get aboutTitle => 'About Annot@It';

  @override
  String get aboutDescription =>
      'Annot@It is an annotation application designed to streamline the annotation process for computer vision projects. Whether you\'re working on image classification, object detection, segmentation, or other vision tasks, Annot@It provides the flexibility and precision needed for high-quality data labeling.';

  @override
  String get aboutFeaturesTitle => 'Key Features:';

  @override
  String get aboutFeatures =>
      '- Multiple Project Types: Create and manage projects tailored for different computer vision tasks.\n- Data Upload & Management: Easily upload and organize your datasets for seamless annotation.\n- Advanced Annotation Tools – Use bounding boxes, polygons, keypoints, and segmentation masks.\n- Export & Integration – Export labeled data in various formats compatible with AI/ML frameworks.';

  @override
  String get aboutCallToAction =>
      'Start your annotation journey today and build high-quality datasets for your computer vision models!';

  @override
  String get userProfileName => 'Captain Annotator';

  @override
  String get userProfileFeedbackButton => 'Feedback';

  @override
  String get userProfileEditProfileButton => 'Edit Profile';

  @override
  String get userProfileProjects => 'Projects';

  @override
  String get userProfileLabels => 'Labels';

  @override
  String get userProfileMedia => 'Media';

  @override
  String get userProfileOverview => 'Overview';

  @override
  String get userProfileAnnotations => 'Annotations';

  @override
  String get settingsGeneralTitle => 'General Settings';

  @override
  String get settingsProjectCreationTitle => 'Project Creation';

  @override
  String get settingsProjectCreationConfirmNoLabels =>
      'Always ask to confirm when create a project with no labels';

  @override
  String get settingsProjectCreationConfirmNoLabelsNote =>
      'You’ll be warned if you try to create a project without any labels defined.';

  @override
  String get settingsDatasetViewTitle => 'Dataset View';

  @override
  String get settingsDatasetViewDuplicateWithAnnotations =>
      'Duplicate (make a copy) image always with annotations';

  @override
  String get settingsDatasetViewDuplicateWithAnnotationsNote =>
      'When duplicating, annotations will be included unless you change settings.';

  @override
  String get settingsDatasetViewDeleteFromOS =>
      'When delete image from Dataset, always delete it from OS / file system';

  @override
  String get settingsDatasetViewDeleteFromOSNote =>
      'Deletes the file from disk too, not just from the dataset.';

  @override
  String get settingsAnnotationTitle => 'Annotation Settings';

  @override
  String get settingsAnnotationOpacity => 'Annotation opacity';

  @override
  String get settingsAnnotationAutoSave =>
      'Always Save or Submit annotation when move to the next image';

  @override
  String get settingsThemeTitle => 'Theme selection';

  @override
  String get settingsLanguageTitle => 'Country / Language';

  @override
  String get colorPickerTitle => 'Pick a color';

  @override
  String get colorPickerBasicColors => 'Basic Colors';

  @override
  String get loadingProjects => 'Loading projects...';

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
  String get emptyProjectTitle => 'Start your first project';

  @override
  String get emptyProjectDescription =>
      'Create a project to begin organizing datasets, annotating media, and applying AI to your vision tasks — all in one streamlined workspace designed to accelerate your computer vision pipeline.';

  @override
  String get emptyProjectCreateNew => 'Create New Project';

  @override
  String get emptyProjectCreateNewShort => 'New Project';

  @override
  String get emptyProjectImportDataset => 'Create Project from Dataset import';

  @override
  String get emptyProjectImportDatasetShort => 'Import Dataset';

  @override
  String get dialogBack => '<- Back';

  @override
  String get dialogNext => 'Next ->';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get setAsDefault => 'Set as Default';

  @override
  String paginationPageFromTotal(int current, int total) {
    return 'Page $current from $total';
  }

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
  String get menuCreateNewProject => 'Create new project';

  @override
  String get menuCreateFromDataset => 'Create from Dataset';

  @override
  String get menuImportDataset => 'Create project from Dataset Import';

  @override
  String get menuSortLastUpdated => 'Last updated';

  @override
  String get menuSortNewestOldest => 'Newest-Oldest';

  @override
  String get menuSortOldestNewest => 'Oldest-Newest';

  @override
  String get menuSortType => 'Project Type';

  @override
  String get menuSortAz => 'A-Z';

  @override
  String get menuSortZa => 'Z-A';

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
  String get removeFilesFromDatasetInProgress => 'Deleting files...';

  @override
  String get removeFilesFromDataset => 'Remove files from Dataset?';

  @override
  String removeFilesFromDatasetConfirm(Object amount) {
    return 'Are you sure you want to delete the following file(s) (\'$amount\')?\n\nAll corresponding annotations will be removed as well.';
  }

  @override
  String get removeFilesFailedTitle => 'Deletion Failed';

  @override
  String get removeFilesFailedMessage => 'Some files could not be deleted';

  @override
  String get removeFilesFailedTips =>
      'Please check file permissions and try again';

  @override
  String get duplicateImage => 'Duplicate Image';

  @override
  String get duplicateWithAnnotations => 'Duplicate image with annotations';

  @override
  String get duplicateWithAnnotationsHint =>
      'A copy of the image will be created along with all annotation data.';

  @override
  String get duplicateImageOnly => 'Duplicate image only';

  @override
  String get duplicateImageOnlyHint =>
      'Only the image will be copied, without annotations.';

  @override
  String get saveDuplicateChoiceAsDefault =>
      'Save this reply as default answer and do not ask again\n(You can change this in Account -> Application settings -> Dataset navigation)';

  @override
  String get editProjectTitle => 'Edit project name';

  @override
  String get editProjectDescription =>
      'Please, choose a clear, descriptive project name (3 - 86 characters). It\'s recommended to avoid special characters.';

  @override
  String get changeProjectTypeTitle => 'Change project type';

  @override
  String get deleteProjectTitle => 'Delete Project';

  @override
  String get deleteProjectInProgress => 'Deleting project...';

  @override
  String get deleteProjectOptionDeleteFromDisk =>
      'Also delete all files from disk';

  @override
  String get deleteProjectOptionDontAskAgain => 'Don\'t ask me again';

  @override
  String deleteProjectConfirm(Object projectName) {
    return 'Are you sure you want to delete the project \"$projectName\"?';
  }

  @override
  String deleteProjectInfoLine(Object creationDate, Object labelCount) {
    return 'Project was created at $creationDate\nNumber of Labels: $labelCount';
  }

  @override
  String get deleteDatasetTitle => 'Delete Dataset';

  @override
  String get deleteDatasetInProgress => 'Deleting dataset... Please wait.';

  @override
  String deleteDatasetConfirm(Object datasetName) {
    return 'Are you sure you want to delete \"$datasetName\"?';
  }

  @override
  String deleteDatasetInfoLine(
    Object creationDate,
    Object mediaCount,
    Object annotationCount,
  ) {
    return 'This dataset was created on $creationDate and contains $mediaCount media items and $annotationCount annotations.';
  }

  @override
  String get editDatasetTitle => 'Rename Dataset';

  @override
  String get editDatasetDescription => 'Enter a new name for this dataset:';

  @override
  String get noMediaDialogUploadPrompt => 'You have to upload images or videos';

  @override
  String get noMediaDialogUploadPromptShort => 'Upload media';

  @override
  String get noMediaDialogSupportedImageTypesTitle => 'Supported images types:';

  @override
  String get noMediaDialogSupportedImageTypesList =>
      'jpg, jpeg, png, bmp, jfif, webp';

  @override
  String get noMediaDialogSupportedVideoFormatsLink =>
      'Click here to see which video formats are supported on your platform';

  @override
  String get noMediaDialogSupportedVideoFormatsTitle =>
      'Supported Video Formats';

  @override
  String get noMediaDialogSupportedVideoFormatsList =>
      'Commonly Supported Formats:\n\n- MP4: Android, iOS, Web, Desktop\n- MOV: Android, iOS, macOS\n- M4V: Android, iOS, macOS\n- WEBM: Android, Web (browser-dependent)\n- MKV: Android (partial), Windows\n- AVI: Android/Windows only (partial)';

  @override
  String get noMediaDialogSupportedVideoFormatsWarning =>
      'Support may vary depending on the platform and video codec.\nSome formats may not work in browsers or on iOS.';

  @override
  String get toolbarNavigation => 'Navigation';

  @override
  String get toolbarBbox => 'Bounding Box';

  @override
  String get toolbarSegmentation => 'Segmentation';

  @override
  String get toolbarResetZoom => 'Reset Zoom';

  @override
  String get toolbarToggleGrid => 'Toggle Grid';

  @override
  String get toolbarAnnotationSettings => 'Annotation Settings';

  @override
  String get toolbarToggleAnnotationNames => 'Toggle Annotation Names';

  @override
  String get toolbarRotateLeft => 'Rotate Left (Coming Soon)';

  @override
  String get toolbarRotateRight => 'Rotate Right (Coming Soon)';

  @override
  String get toolbarHelp => 'Help';

  @override
  String get dialogOpacityTitle => 'Annotation Fill Opacity';

  @override
  String get dialogHelpTitle => 'Annotator Toolbar Help';

  @override
  String get dialogHelpContent =>
      '• **Navigation** – Use to select and move around the canvas.\n• **Bounding Box** – (Visible in Detection projects) Draw rectangular bounding boxes.\n• **Segmentation** – (Visible in Segmentation projects) Use SAM-based segmentation tools.\n• **Reset Zoom** – Resets the zoom level to fit the image on screen.\n• **Toggle Grid** – Show or hide the dataset thumbnail grid.\n• **Opacity Settings** – Adjust the fill opacity of annotations.\n• **Toggle Annotation Names** – Show or hide text labels on annotations.\n• **Rotate Left / Right** – (Coming Soon) Rotate the image view.';

  @override
  String get dialogHelpTips =>
      'Tip: Use Navigation mode to select and edit annotations.\nMore shortcuts and features coming soon!';

  @override
  String get dialogOpacityExplanation =>
      'Adjust the opacity level to make the content more or less transparent.';

  @override
  String get deleteAnnotationTitle => 'Delete Annotation';

  @override
  String get deleteAnnotationMessage => 'Are you sure you want to delete';

  @override
  String get unnamedAnnotation => 'this annotation';

  @override
  String get accountStorage_importFolderTitle => 'Datasets import Folder';

  @override
  String get accountStorage_thumbnailsFolderTitle => 'Thumbnails Folder';

  @override
  String get accountStorage_exportFolderTitle => 'Datasets export Folder';

  @override
  String get accountStorage_folderTooltip => 'Choose folder';

  @override
  String get accountStorage_helpTitle => 'Storage Help';

  @override
  String get accountStorage_helpMessage =>
      'You can change the folder where imported datasets, exported ZIP archives, and thumbnails are stored.\nTap the \"Folder\" icon next to the path field to select or change the directory.\n\nThis folder will be used as the default location for:\n- Imported dataset files (e.g., COCO, YOLO, VOC, Datumaro, etc.)\n- Exported dataset Zip archives\n- Project thumbnails\n\nMake sure the selected folder is writable and has enough space.\nOn Android or iOS, you may need to grant storage permissions.\nRecommended folders vary by platform — see below platform-specific tips.';

  @override
  String get accountStorage_helpTips =>
      'Recommended folders by platform:\n\nWindows:\n  C:\\Users\\<you>\\AppData\\Roaming\\AnnotateIt\\datasets\n\nLinux / Ubuntu:\n  /home/<you>/.annotateit/datasets\n\nmacOS:\n  /Users/<you>/Library/Application Support/AnnotateIt/datasets\n\nAndroid:\n  /storage/emulated/0/AnnotateIt/datasets\n\niOS:\n  <App sandbox path>/Documents/AnnotateIt/datasets\n';

  @override
  String get changeProjectTypeStepOneSubtitle =>
      'Please select a new project type from the list below';

  @override
  String get changeProjectTypeStepTwoSubtitle => 'Please confirm your choice';

  @override
  String get changeProjectTypeWarningTitle =>
      'Warning: You are about to change the project type.';

  @override
  String get changeProjectTypeConversionIntro =>
      'All existing annotations will be converted as follows:';

  @override
  String get changeProjectTypeConversionDetails =>
      '- Bounding boxes (Detection) -> converted to rectangular polygons.\n- Polygons (Segmentation) -> converted to tight-fitting bounding boxes.\n\nNote: These conversions may reduce precision, especially when converting polygons to boxes, as detailed shape information will be lost.\n\n- Detection / Segmentation → Classification:\n  Images will be classified based on the most frequent label in the annotations:\n     -> If image has 5 objects labeled \"Dog\" and 10 labeled \"Cat\", it will be classified as \"Cat\".\n     -> If the counts are equal, the first label found will be used.\n\n- Classification -> Detection / Segmentation:\n  No annotations will be transferred. You will need to re-annotate all media items manually, as classification projects do not contain region-level data.';

  @override
  String get changeProjectTypeErrorTitle => 'Migration Failed';

  @override
  String get changeProjectTypeErrorMessage =>
      'An error occurred while changing the project type. The changes could not be applied.';

  @override
  String get changeProjectTypeErrorTips =>
      'Please check if the project has valid annotations and try again. If the problem persists, restart the app or contact support.';

  @override
  String get projectHelpTitle => 'How Projects Work';

  @override
  String get projectHelpMessage =>
      'Projects allow you to organize datasets, media files, and annotations in one place. You can create new projects for different tasks like detection, classification, or segmentation.';

  @override
  String get projectHelpTips =>
      'Tip: You can import datasets in COCO, YOLO, VOC, Labelme and Datumaro format to create a project automatically.';

  @override
  String get datasetDialogTitle => 'Import Dataset to Create Project';

  @override
  String get datasetDialogProcessing => 'Processing...';

  @override
  String datasetDialogProcessingProgress(Object percent) {
    return 'Processing... $percent%';
  }

  @override
  String get datasetDialogModeIsolate => 'Isolate Mode Enabled';

  @override
  String get datasetDialogModeNormal => 'Normal Mode';

  @override
  String get datasetDialogNoDatasetLoaded => 'No dataset loaded.';

  @override
  String get datasetDialogImportFailedTitle => 'Import Failed';

  @override
  String get datasetDialogImportFailedMessage =>
      'The ZIP file could not be processed. It may be corrupted, incomplete, or not a valid dataset archive.';

  @override
  String get datasetDialogImportFailedTips =>
      'Try re-exporting or re-zipping your dataset.\nEnsure it is in COCO, YOLO, VOC, or supported format.\n\nError: ';

  @override
  String get datasetDialogNoProjectTypeTitle => 'No Project Type Selected';

  @override
  String get datasetDialogNoProjectTypeMessage =>
      'Please select a Project Type based on the detected annotation types in your dataset.';

  @override
  String get datasetDialogNoProjectTypeTips =>
      'Check your dataset format and ensure annotations follow a supported structure like COCO, YOLO, VOC or Datumaro.';

  @override
  String get datasetDialogProcessingDatasetTitle => 'Processing Dataset';

  @override
  String get datasetDialogProcessingDatasetMessage =>
      'We are currently extracting your ZIP archive, analyzing its contents, and detecting the dataset format and annotation type. This may take a few seconds to a few minutes depending on the dataset size and structure. Please do not close this window or navigate away during the process.';

  @override
  String get datasetDialogProcessingDatasetTips =>
      'Large archives with many images or annotation files can take longer to process.';

  @override
  String get datasetDialogCreatingProjectTitle => 'Creating Project';

  @override
  String get datasetDialogCreatingProjectMessage =>
      'We are setting up your project, initializing its metadata, and saving all configurations. This includes assigning labels, creating datasets, and linking associated media files. Please wait a moment and avoid closing this window until the process is complete.';

  @override
  String get datasetDialogCreatingProjectTips =>
      'Projects with many labels or media files might take slightly longer.';

  @override
  String get datasetDialogAnalyzingDatasetTitle => 'Analyzing Dataset';

  @override
  String get datasetDialogAnalyzingDatasetMessage =>
      'We are currently analyzing your dataset archive. This includes extracting files, detecting dataset structure, identifying annotation formats, and collecting media and label information. Please wait until the process is complete. Closing the window or navigating away may interrupt the operation.';

  @override
  String get datasetDialogAnalyzingDatasetTips =>
      'Large datasets with many files or complex annotations may take extra time.';

  @override
  String get datasetDialogFilePickErrorTitle => 'File Selection Error';

  @override
  String get datasetDialogFilePickErrorMessage =>
      'Failed to select the file. Please try again.';

  @override
  String get datasetDialogGenericErrorTips =>
      'Please check your file and try again. If the problem persists, contact support.';

  @override
  String get thumbnailGenerationTitle => 'Error';

  @override
  String get thumbnailGenerationFailed => 'Failed to generate thumbnail';

  @override
  String get thumbnailGenerationTryAgainLater => 'Please try again later';

  @override
  String get thumbnailGenerationInProgress => 'Generating thumbnail...';

  @override
  String get menuImageDetails => 'Details';

  @override
  String get menuImageDuplicate => 'Duplicate';

  @override
  String get menuImageSetAsIcon => 'Set as Icon';

  @override
  String get menuImageDelete => 'Delete';

  @override
  String get noLabelsTitle => 'You have no Labels in the Project';

  @override
  String get noLabelsExplain1 =>
      'You can\'t annotate without labels because labels give meaning to what you\'re marking';

  @override
  String get noLabelsExplain2 =>
      'You can add labels manually or import them from a JSON file.';

  @override
  String get noLabelsExplain3 =>
      'An annotation without a label is just an empty box.';

  @override
  String get noLabelsExplain4 =>
      'Labels define the categories or classes you\'re annotating in your dataset.';

  @override
  String get noLabelsExplain5 =>
      'Whether you\'re tagging objects in images, classifying, or segmenting regions,';

  @override
  String get noLabelsExplain6 =>
      'labels are essential for organizing your annotations clearly and consistently.';

  @override
  String get importLabelsPreviewTitle => 'Import Labels Preview';

  @override
  String get importLabelsFailedTitle => 'Label Import Failed';

  @override
  String get importLabelsNoLabelsTitle => 'No labels found in this project';

  @override
  String get importLabelsJsonParseError => 'JSON parsing failed.\n';

  @override
  String get importLabelsJsonParseTips =>
      'Make sure the file is valid JSON. You can validate it at https://jsonlint.com/';

  @override
  String importLabelsJsonNotList(Object type) {
    return 'Expected a list of labels (array), but got: $type.';
  }

  @override
  String get importLabelsJsonNotListTips =>
      'Your JSON file must start with [ and contain multiple label objects. Each label should include name, color, and labelOrder fields.';

  @override
  String importLabelsJsonItemNotMap(Object type) {
    return 'One of the entries in the list is not a valid object: $type';
  }

  @override
  String get importLabelsJsonItemNotMapTips =>
      'Each item in the list must be a valid object with fields: name, color, and labelOrder.';

  @override
  String get importLabelsJsonLabelParseError =>
      'Failed to parse one of the labels.\n';

  @override
  String get importLabelsJsonLabelParseTips =>
      'Check that each label has required fields like name and color, and values are correct types.';

  @override
  String get importLabelsUnexpectedError =>
      'Failed to parse one of the labels.\n';

  @override
  String get importLabelsUnexpectedErrorTip =>
      'Please make sure your file is readable and formatted correctly.';
}
