import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
    Locale('pt'),
    Locale('ru'),
  ];

  /// No description provided for @buttonKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get buttonKeep;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @buttonHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get buttonHelp;

  /// No description provided for @buttonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEdit;

  /// No description provided for @buttonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get buttonNext;

  /// No description provided for @buttonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get buttonBack;

  /// No description provided for @buttonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get buttonApply;

  /// No description provided for @buttonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// No description provided for @buttonImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get buttonImport;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get buttonFinish;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get buttonDuplicate;

  /// No description provided for @buttonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buttonConfirm;

  /// No description provided for @buttonDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get buttonDiscard;

  /// No description provided for @buttonFeedbackShort.
  ///
  /// In en, this message translates to:
  /// **'Fdbck'**
  String get buttonFeedbackShort;

  /// No description provided for @buttonImportLabels.
  ///
  /// In en, this message translates to:
  /// **'Import Labels'**
  String get buttonImportLabels;

  /// No description provided for @buttonExportLabels.
  ///
  /// In en, this message translates to:
  /// **'Export Labels'**
  String get buttonExportLabels;

  /// No description provided for @buttonNextConfirmTask.
  ///
  /// In en, this message translates to:
  /// **'Next: Confirm Task'**
  String get buttonNextConfirmTask;

  /// No description provided for @buttonCreateProject.
  ///
  /// In en, this message translates to:
  /// **'Create Project'**
  String get buttonCreateProject;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Annot@It'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Annot@It is an annotation application designed to streamline the annotation process for computer vision projects. Whether you\'re working on image classification, object detection, segmentation, or other vision tasks, Annot@It provides the flexibility and precision needed for high-quality data labeling.'**
  String get aboutDescription;

  /// No description provided for @aboutFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Key Features:'**
  String get aboutFeaturesTitle;

  /// No description provided for @aboutFeatures.
  ///
  /// In en, this message translates to:
  /// **'- Multiple Project Types: Create and manage projects tailored for different computer vision tasks.\n- Data Upload & Management: Easily upload and organize your datasets for seamless annotation.\n- Advanced Annotation Tools – Use bounding boxes, polygons, keypoints, and segmentation masks.\n- Export & Integration – Export labeled data in various formats compatible with AI/ML frameworks.'**
  String get aboutFeatures;

  /// No description provided for @aboutCallToAction.
  ///
  /// In en, this message translates to:
  /// **'Start your annotation journey today and build high-quality datasets for your computer vision models!'**
  String get aboutCallToAction;

  /// No description provided for @accountUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get accountUser;

  /// No description provided for @accountProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get accountProfile;

  /// No description provided for @accountStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get accountStorage;

  /// No description provided for @accountDeviceStorage.
  ///
  /// In en, this message translates to:
  /// **'Device Storage'**
  String get accountDeviceStorage;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get accountSettings;

  /// No description provided for @accountApplicationSettings.
  ///
  /// In en, this message translates to:
  /// **'Application Settings'**
  String get accountApplicationSettings;

  /// No description provided for @accountLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading user data...'**
  String get accountLoadingMessage;

  /// No description provided for @userProfileName.
  ///
  /// In en, this message translates to:
  /// **'Captain Annotator'**
  String get userProfileName;

  /// No description provided for @userProfileFeedbackButton.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get userProfileFeedbackButton;

  /// No description provided for @userProfileEditProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get userProfileEditProfileButton;

  /// No description provided for @userProfileProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get userProfileProjects;

  /// No description provided for @userProfileLabels.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get userProfileLabels;

  /// No description provided for @userProfileMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get userProfileMedia;

  /// No description provided for @userProfileOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get userProfileOverview;

  /// No description provided for @userProfileAnnotations.
  ///
  /// In en, this message translates to:
  /// **'Annotations'**
  String get userProfileAnnotations;

  /// No description provided for @settingsGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get settingsGeneralTitle;

  /// No description provided for @settingsProjectCreationTitle.
  ///
  /// In en, this message translates to:
  /// **'Project Creation'**
  String get settingsProjectCreationTitle;

  /// No description provided for @settingsProjectCreationConfirmNoLabels.
  ///
  /// In en, this message translates to:
  /// **'Always ask to confirm when create a project with no labels'**
  String get settingsProjectCreationConfirmNoLabels;

  /// No description provided for @settingsProjectCreationConfirmNoLabelsNote.
  ///
  /// In en, this message translates to:
  /// **'You’ll be warned if you try to create a project without any labels defined.'**
  String get settingsProjectCreationConfirmNoLabelsNote;

  /// No description provided for @settingsLabelsCreationDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Labels Creation / Deletion'**
  String get settingsLabelsCreationDeletionTitle;

  /// No description provided for @settingsLabelsDeletionWithAnnotations.
  ///
  /// In en, this message translates to:
  /// **'Delete annotations when label is removed'**
  String get settingsLabelsDeletionWithAnnotations;

  /// No description provided for @settingsLabelsDeletionWithAnnotationsNote.
  ///
  /// In en, this message translates to:
  /// **'When enabled, deleting a label will automatically remove all annotations assigned to that label across all media items.'**
  String get settingsLabelsDeletionWithAnnotationsNote;

  /// No description provided for @settingsLabelsSetDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Set first label as default'**
  String get settingsLabelsSetDefaultLabel;

  /// No description provided for @settingsLabelsSetDefaultLabelNote.
  ///
  /// In en, this message translates to:
  /// **'When enabled, the first label you create in a project will automatically be marked as the default label. You can change the default later at any time.'**
  String get settingsLabelsSetDefaultLabelNote;

  /// No description provided for @settingsDatasetViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Dataset View'**
  String get settingsDatasetViewTitle;

  /// No description provided for @settingsDatasetViewDuplicateWithAnnotations.
  ///
  /// In en, this message translates to:
  /// **'Duplicate (make a copy) image always with annotations'**
  String get settingsDatasetViewDuplicateWithAnnotations;

  /// No description provided for @settingsDatasetViewDuplicateWithAnnotationsNote.
  ///
  /// In en, this message translates to:
  /// **'When duplicating, annotations will be included unless you change settings'**
  String get settingsDatasetViewDuplicateWithAnnotationsNote;

  /// No description provided for @settingsDatasetViewDeleteFromOS.
  ///
  /// In en, this message translates to:
  /// **'When delete image from Dataset, always delete it from OS / file system'**
  String get settingsDatasetViewDeleteFromOS;

  /// No description provided for @settingsDatasetViewDeleteFromOSNote.
  ///
  /// In en, this message translates to:
  /// **'Deletes the file from disk too, not just from the dataset'**
  String get settingsDatasetViewDeleteFromOSNote;

  /// No description provided for @settingsAnnotationTitle.
  ///
  /// In en, this message translates to:
  /// **'Annotation Settings'**
  String get settingsAnnotationTitle;

  /// No description provided for @settingsAnnotationOpacity.
  ///
  /// In en, this message translates to:
  /// **'Annotation opacity'**
  String get settingsAnnotationOpacity;

  /// No description provided for @settingsAnnotationAutoSave.
  ///
  /// In en, this message translates to:
  /// **'Always Save or Submit annotation when move to the next image'**
  String get settingsAnnotationAutoSave;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme selection'**
  String get settingsThemeTitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Country / Language'**
  String get settingsLanguageTitle;

  /// No description provided for @colorPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get colorPickerTitle;

  /// No description provided for @colorPickerBasicColors.
  ///
  /// In en, this message translates to:
  /// **'Basic Colors'**
  String get colorPickerBasicColors;

  /// No description provided for @loadingProjects.
  ///
  /// In en, this message translates to:
  /// **'Loading projects...'**
  String get loadingProjects;

  /// No description provided for @importDataset.
  ///
  /// In en, this message translates to:
  /// **'Import dataset'**
  String get importDataset;

  /// No description provided for @uploadMedia.
  ///
  /// In en, this message translates to:
  /// **'Upload media'**
  String get uploadMedia;

  /// No description provided for @createProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a New Project'**
  String get createProjectTitle;

  /// No description provided for @createProjectStepOneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please, enter your new project name and select Project type'**
  String get createProjectStepOneSubtitle;

  /// No description provided for @createProjectStepTwoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please, create labels for a New project'**
  String get createProjectStepTwoSubtitle;

  /// No description provided for @emptyProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your first project'**
  String get emptyProjectTitle;

  /// No description provided for @emptyProjectDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a project to begin organizing datasets, annotating media, and applying AI to your vision tasks — all in one streamlined workspace designed to accelerate your computer vision pipeline.'**
  String get emptyProjectDescription;

  /// No description provided for @emptyProjectCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create New Project'**
  String get emptyProjectCreateNew;

  /// No description provided for @emptyProjectCreateNewShort.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get emptyProjectCreateNewShort;

  /// No description provided for @emptyProjectImportDataset.
  ///
  /// In en, this message translates to:
  /// **'Create Project from Dataset import'**
  String get emptyProjectImportDataset;

  /// No description provided for @emptyProjectImportDatasetShort.
  ///
  /// In en, this message translates to:
  /// **'Import Dataset'**
  String get emptyProjectImportDatasetShort;

  /// No description provided for @dialogBack.
  ///
  /// In en, this message translates to:
  /// **'<- Back'**
  String get dialogBack;

  /// No description provided for @dialogNext.
  ///
  /// In en, this message translates to:
  /// **'Next ->'**
  String get dialogNext;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefault;

  /// No description provided for @paginationPageFromTotal.
  ///
  /// In en, this message translates to:
  /// **'Page {current} from {total}'**
  String paginationPageFromTotal(int current, int total);

  /// No description provided for @taskTypeRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Type Required'**
  String get taskTypeRequiredTitle;

  /// Error message when task type is not selected
  ///
  /// In en, this message translates to:
  /// **'You need to select a task type before continuing. The current tab \'{tab}\' has no task type selected. Each project must be associated with a task (e.g., object detection, classification, or segmentation) so the system knows how to process your data.'**
  String taskTypeRequiredMessage(Object tab);

  /// Helpful tips for selecting task type
  ///
  /// In en, this message translates to:
  /// **'Click one of the available task type options below the \'{tab}\' tab. If you\'re unsure which task to choose, hover over the info icon next to each type to see a brief description.'**
  String taskTypeRequiredTips(Object tab);

  /// No description provided for @menuProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get menuProjects;

  /// No description provided for @menuAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get menuAccount;

  /// No description provided for @menuLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get menuLearn;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menuAbout;

  /// No description provided for @menuCreateNewProject.
  ///
  /// In en, this message translates to:
  /// **'Create new project'**
  String get menuCreateNewProject;

  /// No description provided for @menuCreateFromDataset.
  ///
  /// In en, this message translates to:
  /// **'Create from Dataset'**
  String get menuCreateFromDataset;

  /// No description provided for @menuImportDataset.
  ///
  /// In en, this message translates to:
  /// **'Create project from Dataset Import'**
  String get menuImportDataset;

  /// No description provided for @menuSortLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get menuSortLastUpdated;

  /// No description provided for @menuSortNewestOldest.
  ///
  /// In en, this message translates to:
  /// **'Newest-Oldest'**
  String get menuSortNewestOldest;

  /// No description provided for @menuSortOldestNewest.
  ///
  /// In en, this message translates to:
  /// **'Oldest-Newest'**
  String get menuSortOldestNewest;

  /// No description provided for @menuSortType.
  ///
  /// In en, this message translates to:
  /// **'Project Type'**
  String get menuSortType;

  /// No description provided for @menuSortAz.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get menuSortAz;

  /// No description provided for @menuSortZa.
  ///
  /// In en, this message translates to:
  /// **'Z-A'**
  String get menuSortZa;

  /// No description provided for @projectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectNameLabel;

  /// No description provided for @tabDetection.
  ///
  /// In en, this message translates to:
  /// **'Detection'**
  String get tabDetection;

  /// No description provided for @tabClassification.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get tabClassification;

  /// No description provided for @tabSegmentation.
  ///
  /// In en, this message translates to:
  /// **'Segmentation'**
  String get tabSegmentation;

  /// No description provided for @labelRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'At Least One Label Required'**
  String get labelRequiredTitle;

  /// No description provided for @labelRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'You must create at least one label to proceed. Labels are essential for defining the annotation categories that will be used during dataset preparation.'**
  String get labelRequiredMessage;

  /// No description provided for @labelRequiredTips.
  ///
  /// In en, this message translates to:
  /// **'Tip: Click the red button labeled Create Label after entering a label name to add your first label.'**
  String get labelRequiredTips;

  /// No description provided for @createLabelButton.
  ///
  /// In en, this message translates to:
  /// **'Create Label'**
  String get createLabelButton;

  /// No description provided for @labelNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a new Label name here'**
  String get labelNameHint;

  /// No description provided for @createdLabelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Created Labels'**
  String get createdLabelsTitle;

  /// No description provided for @labelEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Label name cannot be empty!'**
  String get labelEmptyTitle;

  /// No description provided for @labelEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a label name. Labels help identify the objects or categories in your project. It is recommended to use short, clear, and descriptive names, such as \"Car\", \"Person\", or \"Tree\". Avoid special characters or spaces.'**
  String get labelEmptyMessage;

  /// No description provided for @labelEmptyTips.
  ///
  /// In en, this message translates to:
  /// **'Tips for Label Naming:\n• Use short and descriptive names\n• Stick to letters, digits, underscores (e.g., cat, road_sign, background)\n• Avoid spaces and symbols (e.g., Person 1 → person_1)'**
  String get labelEmptyTips;

  /// No description provided for @labelDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Label Name'**
  String get labelDuplicateTitle;

  /// Error message when label already exists
  ///
  /// In en, this message translates to:
  /// **'The label \'{label}\' already exists in this project. Each label must have a unique name to avoid confusion during annotation and training.'**
  String labelDuplicateMessage(Object label);

  /// No description provided for @labelDuplicateTips.
  ///
  /// In en, this message translates to:
  /// **'Why unique labels?\n• Reusing the same name can cause issues during dataset export and model training.\n• Unique label names help maintain clear, structured annotations.\n\nTip: Try adding a variation or number to differentiate (e.g., \'Car\', \'Car_2\').'**
  String get labelDuplicateTips;

  /// No description provided for @binaryLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Binary Classification Limit'**
  String get binaryLimitTitle;

  /// No description provided for @binaryLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You cannot create more than two labels for a Binary Classification project.\n\nBinary Classification is designed to distinguish between exactly two classes, such as \'Yes\' vs \'No\', or \'Spam\' vs \'Not Spam\'.'**
  String get binaryLimitMessage;

  /// No description provided for @binaryLimitTips.
  ///
  /// In en, this message translates to:
  /// **'Need more than two labels?\nConsider switching your project type to Multi-Class Classification or another suitable task in order to support three or more categories.'**
  String get binaryLimitTips;

  /// No description provided for @noteBinaryClassification.
  ///
  /// In en, this message translates to:
  /// **'This project type allows exactly 2 labels. Binary Classification is used when your model needs to distinguish between two possible classes, such as \"Yes\" vs \"No\", or \"Dog\" vs \"Not Dog\". Please create only two distinct labels.'**
  String get noteBinaryClassification;

  /// No description provided for @noteMultiClassClassification.
  ///
  /// In en, this message translates to:
  /// **'This project type supports multiple labels. Multi-Class Classification is suitable when your model needs to choose from three or more categories, like \"Cat\", \"Dog\", \"Rabbit\". You can add as many labels as needed.'**
  String get noteMultiClassClassification;

  /// No description provided for @noteDetectionOrSegmentation.
  ///
  /// In en, this message translates to:
  /// **'This project type supports multiple labels. For Object Detection or Segmentation, each label typically represents a different class of object (e.g., \"Car\", \"Pedestrian\", \"Bicycle\"). You can create as many labels as required for your dataset.'**
  String get noteDetectionOrSegmentation;

  /// No description provided for @noteDefault.
  ///
  /// In en, this message translates to:
  /// **'You can create one or more labels depending on your project type. Each label helps define a category that your model will learn to recognize. Please refer to the documentation for best practices.'**
  String get noteDefault;

  /// No description provided for @discardDatasetImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard Dataset Import?'**
  String get discardDatasetImportTitle;

  /// No description provided for @discardDatasetImportMessage.
  ///
  /// In en, this message translates to:
  /// **'You have already extracted a dataset. Cancelling now will delete the extracted files and detected dataset details. Are you sure you want to proceed?'**
  String get discardDatasetImportMessage;

  /// No description provided for @projectTypeHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Project Type Selection Help'**
  String get projectTypeHelpTitle;

  /// No description provided for @projectTypeWhyDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Why are some project types disabled?'**
  String get projectTypeWhyDisabledTitle;

  /// No description provided for @projectTypeWhyDisabledBody.
  ///
  /// In en, this message translates to:
  /// **'When you import a dataset, the system analyzes the provided annotations and tries to detect the most suitable project type for you automatically.\n\nFor example, if your dataset contains bounding box annotations, the suggested project type will be \"Detection\". If it contains masks, \"Segmentation\" will be suggested, and so on.\n\nTo protect your data, only compatible project types are enabled by default.'**
  String get projectTypeWhyDisabledBody;

  /// No description provided for @projectTypeAllowChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'What happens if I enable project type change?'**
  String get projectTypeAllowChangeTitle;

  /// No description provided for @projectTypeAllowChangeBody.
  ///
  /// In en, this message translates to:
  /// **'If you toggle \"Allow Project Type Change\", you can manually select ANY project type, even if it does not match the detected annotations.\n\n⚠️ WARNING: All existing annotations from the import will be deleted when switching to an incompatible project type.\nYou will have to re-annotate or import a dataset suitable for the newly selected project type.'**
  String get projectTypeAllowChangeBody;

  /// No description provided for @projectTypeWhenUseTitle.
  ///
  /// In en, this message translates to:
  /// **'When should I use this option?'**
  String get projectTypeWhenUseTitle;

  /// No description provided for @projectTypeWhenUseBody.
  ///
  /// In en, this message translates to:
  /// **'You should only enable this option if:\n\n- You accidentally imported the wrong dataset.\n- You want to start a new annotation project with a different type.\n- Your dataset structure changed after import.\n\nIf you are unsure, we strongly recommend keeping the default selection to avoid data loss.'**
  String get projectTypeWhenUseBody;

  /// No description provided for @allLabels.
  ///
  /// In en, this message translates to:
  /// **'All Labels'**
  String get allLabels;

  /// No description provided for @setAsProjectIcon.
  ///
  /// In en, this message translates to:
  /// **'Set as Project Icon'**
  String get setAsProjectIcon;

  /// No description provided for @setAsProjectIconConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to use \'{filePath}\' as the icon for this project?\n\nThis will replace any previously set icon.'**
  String setAsProjectIconConfirm(Object filePath);

  /// No description provided for @removeFilesFromDatasetInProgress.
  ///
  /// In en, this message translates to:
  /// **'Deleting files...'**
  String get removeFilesFromDatasetInProgress;

  /// No description provided for @removeFilesFromDataset.
  ///
  /// In en, this message translates to:
  /// **'Remove files from Dataset?'**
  String get removeFilesFromDataset;

  /// No description provided for @removeFilesFromDatasetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the following file(s) (\'{amount}\')?\n\nAll corresponding annotations will be removed as well.'**
  String removeFilesFromDatasetConfirm(Object amount);

  /// No description provided for @removeFilesFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Deletion Failed'**
  String get removeFilesFailedTitle;

  /// No description provided for @removeFilesFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Some files could not be deleted'**
  String get removeFilesFailedMessage;

  /// No description provided for @removeFilesFailedTips.
  ///
  /// In en, this message translates to:
  /// **'Please check file permissions and try again'**
  String get removeFilesFailedTips;

  /// No description provided for @duplicateImage.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Image'**
  String get duplicateImage;

  /// No description provided for @duplicateWithAnnotations.
  ///
  /// In en, this message translates to:
  /// **'Duplicate image with annotations'**
  String get duplicateWithAnnotations;

  /// No description provided for @duplicateWithAnnotationsHint.
  ///
  /// In en, this message translates to:
  /// **'A copy of the image will be created along with all annotation data.'**
  String get duplicateWithAnnotationsHint;

  /// No description provided for @duplicateImageOnly.
  ///
  /// In en, this message translates to:
  /// **'Duplicate image only'**
  String get duplicateImageOnly;

  /// No description provided for @duplicateImageOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Only the image will be copied, without annotations.'**
  String get duplicateImageOnlyHint;

  /// No description provided for @saveDuplicateChoiceAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Save this reply as default answer and do not ask again\n(You can change this in Account -> Application settings -> Dataset navigation)'**
  String get saveDuplicateChoiceAsDefault;

  /// No description provided for @editProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit project name'**
  String get editProjectTitle;

  /// No description provided for @editProjectDescription.
  ///
  /// In en, this message translates to:
  /// **'Please, choose a clear, descriptive project name (3 - 86 characters). It\'s recommended to avoid special characters.'**
  String get editProjectDescription;

  /// No description provided for @deleteProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Project'**
  String get deleteProjectTitle;

  /// No description provided for @deleteProjectInProgress.
  ///
  /// In en, this message translates to:
  /// **'Deleting project...'**
  String get deleteProjectInProgress;

  /// No description provided for @deleteProjectOptionDeleteFromDisk.
  ///
  /// In en, this message translates to:
  /// **'Also delete all files from disk'**
  String get deleteProjectOptionDeleteFromDisk;

  /// No description provided for @deleteProjectOptionDontAskAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask me again'**
  String get deleteProjectOptionDontAskAgain;

  /// No description provided for @deleteProjectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the project \"{projectName}\"?'**
  String deleteProjectConfirm(Object projectName);

  /// No description provided for @deleteProjectInfoLine.
  ///
  /// In en, this message translates to:
  /// **'Project was created at {creationDate}\nNumber of Labels: {labelCount}'**
  String deleteProjectInfoLine(Object creationDate, Object labelCount);

  /// No description provided for @deleteDatasetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Dataset'**
  String get deleteDatasetTitle;

  /// No description provided for @deleteDatasetInProgress.
  ///
  /// In en, this message translates to:
  /// **'Deleting dataset... Please wait.'**
  String get deleteDatasetInProgress;

  /// No description provided for @deleteDatasetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{datasetName}\"?'**
  String deleteDatasetConfirm(Object datasetName);

  /// No description provided for @deleteDatasetInfoLine.
  ///
  /// In en, this message translates to:
  /// **'This dataset was created on {creationDate} and contains {mediaCount} media items and {annotationCount} annotations.'**
  String deleteDatasetInfoLine(
    Object creationDate,
    Object mediaCount,
    Object annotationCount,
  );

  /// No description provided for @editDatasetTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Dataset'**
  String get editDatasetTitle;

  /// No description provided for @editDatasetDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter a new name for this dataset:'**
  String get editDatasetDescription;

  /// No description provided for @noMediaDialogUploadPrompt.
  ///
  /// In en, this message translates to:
  /// **'You have to upload images or videos'**
  String get noMediaDialogUploadPrompt;

  /// No description provided for @noMediaDialogUploadPromptShort.
  ///
  /// In en, this message translates to:
  /// **'Upload media'**
  String get noMediaDialogUploadPromptShort;

  /// No description provided for @noMediaDialogSupportedImageTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Supported images types:'**
  String get noMediaDialogSupportedImageTypesTitle;

  /// No description provided for @noMediaDialogSupportedImageTypesList.
  ///
  /// In en, this message translates to:
  /// **'jpg, jpeg, png, bmp, jfif, webp'**
  String get noMediaDialogSupportedImageTypesList;

  /// No description provided for @noMediaDialogSupportedVideoFormatsLink.
  ///
  /// In en, this message translates to:
  /// **'Click here to see which video formats are supported on your platform'**
  String get noMediaDialogSupportedVideoFormatsLink;

  /// No description provided for @noMediaDialogSupportedVideoFormatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Supported Video Formats'**
  String get noMediaDialogSupportedVideoFormatsTitle;

  /// No description provided for @noMediaDialogSupportedVideoFormatsList.
  ///
  /// In en, this message translates to:
  /// **'Commonly Supported Formats:\n\n- MP4: Android, iOS, Web, Desktop\n- MOV: Android, iOS, macOS\n- M4V: Android, iOS, macOS\n- WEBM: Android, Web (browser-dependent)\n- MKV: Android (partial), Windows\n- AVI: Android/Windows only (partial)'**
  String get noMediaDialogSupportedVideoFormatsList;

  /// No description provided for @noMediaDialogSupportedVideoFormatsWarning.
  ///
  /// In en, this message translates to:
  /// **'Support may vary depending on the platform and video codec.\nSome formats may not work in browsers or on iOS.'**
  String get noMediaDialogSupportedVideoFormatsWarning;

  /// No description provided for @annotatorTopToolbarBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back to Project'**
  String get annotatorTopToolbarBackTooltip;

  /// No description provided for @annotatorTopToolbarSelectDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Select default label'**
  String get annotatorTopToolbarSelectDefaultLabel;

  /// No description provided for @toolbarNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get toolbarNavigation;

  /// No description provided for @toolbarBbox.
  ///
  /// In en, this message translates to:
  /// **'Draw Bounding Box'**
  String get toolbarBbox;

  /// No description provided for @toolbarPolygon.
  ///
  /// In en, this message translates to:
  /// **'Draw Polygon'**
  String get toolbarPolygon;

  /// No description provided for @toolbarSAM.
  ///
  /// In en, this message translates to:
  /// **'Segment Anything Model'**
  String get toolbarSAM;

  /// No description provided for @toolbarResetZoom.
  ///
  /// In en, this message translates to:
  /// **'Reset Zoom'**
  String get toolbarResetZoom;

  /// No description provided for @toolbarToggleGrid.
  ///
  /// In en, this message translates to:
  /// **'Toggle Grid'**
  String get toolbarToggleGrid;

  /// No description provided for @toolbarAnnotationSettings.
  ///
  /// In en, this message translates to:
  /// **'Annotation Settings'**
  String get toolbarAnnotationSettings;

  /// No description provided for @toolbarToggleAnnotationNames.
  ///
  /// In en, this message translates to:
  /// **'Toggle Annotation Names'**
  String get toolbarToggleAnnotationNames;

  /// No description provided for @toolbarRotateLeft.
  ///
  /// In en, this message translates to:
  /// **'Rotate Left (Coming Soon)'**
  String get toolbarRotateLeft;

  /// No description provided for @toolbarRotateRight.
  ///
  /// In en, this message translates to:
  /// **'Rotate Right (Coming Soon)'**
  String get toolbarRotateRight;

  /// No description provided for @toolbarHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get toolbarHelp;

  /// No description provided for @dialogOpacityTitle.
  ///
  /// In en, this message translates to:
  /// **'Annotation Fill Opacity'**
  String get dialogOpacityTitle;

  /// No description provided for @dialogHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Annotator Toolbar Help'**
  String get dialogHelpTitle;

  /// No description provided for @dialogHelpContent.
  ///
  /// In en, this message translates to:
  /// **'• Navigation – Use to select and move around the canvas.\n• Bounding Box – (Visible in Detection projects) Draw rectangular bounding boxes.\n• Reset Zoom – Resets the zoom level to fit the image on screen.\n• Toggle Grid – Show or hide the dataset thumbnail grid.\n• Settings – Adjust the fill opacity of annotations, annotations border line and the size of corners.\n• Toggle Annotation Names – Show or hide text labels on annotations.'**
  String get dialogHelpContent;

  /// No description provided for @dialogHelpTips.
  ///
  /// In en, this message translates to:
  /// **'Tip: Use Navigation mode to select and edit annotations.\nMore shortcuts and features coming soon!'**
  String get dialogHelpTips;

  /// No description provided for @dialogOpacityExplanation.
  ///
  /// In en, this message translates to:
  /// **'Adjust the opacity level to make the content more or less transparent.'**
  String get dialogOpacityExplanation;

  /// No description provided for @deleteAnnotationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Annotation'**
  String get deleteAnnotationTitle;

  /// No description provided for @deleteAnnotationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get deleteAnnotationMessage;

  /// No description provided for @unnamedAnnotation.
  ///
  /// In en, this message translates to:
  /// **'this annotation'**
  String get unnamedAnnotation;

  /// No description provided for @accountStorage_importFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Datasets import folder'**
  String get accountStorage_importFolderTitle;

  /// No description provided for @accountStorage_thumbnailsFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Thumbnails folder'**
  String get accountStorage_thumbnailsFolderTitle;

  /// No description provided for @accountStorage_exportFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Datasets export folder'**
  String get accountStorage_exportFolderTitle;

  /// No description provided for @accountStorage_folderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get accountStorage_folderTooltip;

  /// No description provided for @accountStorage_helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage settings'**
  String get accountStorage_helpTitle;

  /// No description provided for @accountStorage_helpMessage.
  ///
  /// In en, this message translates to:
  /// **'You can configure your default folders here.'**
  String get accountStorage_helpMessage;

  /// No description provided for @accountStorage_helpTips.
  ///
  /// In en, this message translates to:
  /// **'Use consistent folder structure to keep things organized.'**
  String get accountStorage_helpTips;

  /// No description provided for @accountStorage_copySuccess.
  ///
  /// In en, this message translates to:
  /// **'Path copied to clipboard'**
  String get accountStorage_copySuccess;

  /// No description provided for @accountStorage_openError.
  ///
  /// In en, this message translates to:
  /// **'Folder does not exist:\n'**
  String get accountStorage_openError;

  /// No description provided for @accountStorage_pathEmpty.
  ///
  /// In en, this message translates to:
  /// **'Path is empty'**
  String get accountStorage_pathEmpty;

  /// No description provided for @accountStorage_openFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open folder:\n'**
  String get accountStorage_openFailed;

  /// No description provided for @changeProjectTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change project type'**
  String get changeProjectTypeTitle;

  /// No description provided for @changeProjectTypeMigrating.
  ///
  /// In en, this message translates to:
  /// **'Migrating project type...'**
  String get changeProjectTypeMigrating;

  /// No description provided for @changeProjectTypeStepOneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please select a new project type from the list below'**
  String get changeProjectTypeStepOneSubtitle;

  /// No description provided for @changeProjectTypeStepTwoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your choice'**
  String get changeProjectTypeStepTwoSubtitle;

  /// No description provided for @changeProjectTypeWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning: You are about to change the project type.'**
  String get changeProjectTypeWarningTitle;

  /// No description provided for @changeProjectTypeConversionIntro.
  ///
  /// In en, this message translates to:
  /// **'All existing annotations will be converted as follows:'**
  String get changeProjectTypeConversionIntro;

  /// No description provided for @changeProjectTypeConversionDetails.
  ///
  /// In en, this message translates to:
  /// **'- Bounding boxes (Detection) -> converted to rectangular polygons.\n- Polygons (Segmentation) -> converted to tight-fitting bounding boxes.\n\nNote: These conversions may reduce precision, especially when converting polygons to boxes, as detailed shape information will be lost.\n\n- Detection / Segmentation → Classification:\n  Images will be classified based on the most frequent label in the annotations:\n     -> If image has 5 objects labeled \"Dog\" and 10 labeled \"Cat\", it will be classified as \"Cat\".\n     -> If the counts are equal, the first label found will be used.\n\n- Classification -> Detection / Segmentation:\n  No annotations will be transferred. You will need to re-annotate all media items manually, as classification projects do not contain region-level data.'**
  String get changeProjectTypeConversionDetails;

  /// No description provided for @changeProjectTypeErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Migration Failed'**
  String get changeProjectTypeErrorTitle;

  /// No description provided for @changeProjectTypeErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while changing the project type. The changes could not be applied.'**
  String get changeProjectTypeErrorMessage;

  /// No description provided for @changeProjectTypeErrorTips.
  ///
  /// In en, this message translates to:
  /// **'Please check if the project has valid annotations and try again. If the problem persists, restart the app or contact support.'**
  String get changeProjectTypeErrorTips;

  /// No description provided for @exportProjectAsDataset.
  ///
  /// In en, this message translates to:
  /// **'Export Project as Dataset'**
  String get exportProjectAsDataset;

  /// No description provided for @projectHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How Projects Work'**
  String get projectHelpTitle;

  /// No description provided for @projectHelpMessage.
  ///
  /// In en, this message translates to:
  /// **'Projects allow you to organize datasets, media files, and annotations in one place. You can create new projects for different tasks like detection, classification, or segmentation.'**
  String get projectHelpMessage;

  /// No description provided for @projectHelpTips.
  ///
  /// In en, this message translates to:
  /// **'Tip: You can import datasets in COCO, YOLO, VOC, Labelme and Datumaro format to create a project automatically.'**
  String get projectHelpTips;

  /// No description provided for @datasetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Dataset to Create Project'**
  String get datasetDialogTitle;

  /// No description provided for @datasetDialogProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get datasetDialogProcessing;

  /// No description provided for @datasetDialogProcessingProgress.
  ///
  /// In en, this message translates to:
  /// **'Processing... {percent}%'**
  String datasetDialogProcessingProgress(Object percent);

  /// No description provided for @datasetDialogModeIsolate.
  ///
  /// In en, this message translates to:
  /// **'Isolate Mode Enabled'**
  String get datasetDialogModeIsolate;

  /// No description provided for @datasetDialogModeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal Mode'**
  String get datasetDialogModeNormal;

  /// No description provided for @datasetDialogNoDatasetLoaded.
  ///
  /// In en, this message translates to:
  /// **'No dataset loaded.'**
  String get datasetDialogNoDatasetLoaded;

  /// No description provided for @datasetDialogImportFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Failed'**
  String get datasetDialogImportFailedTitle;

  /// No description provided for @datasetDialogImportFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'The ZIP file could not be processed. It may be corrupted, incomplete, or not a valid dataset archive.'**
  String get datasetDialogImportFailedMessage;

  /// No description provided for @datasetDialogImportFailedTips.
  ///
  /// In en, this message translates to:
  /// **'Try re-exporting or re-zipping your dataset.\nEnsure it is in COCO, YOLO, VOC, or supported format.\n\nError: '**
  String get datasetDialogImportFailedTips;

  /// No description provided for @datasetDialogNoProjectTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'No Project Type Selected'**
  String get datasetDialogNoProjectTypeTitle;

  /// No description provided for @datasetDialogNoProjectTypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select a Project Type based on the detected annotation types in your dataset.'**
  String get datasetDialogNoProjectTypeMessage;

  /// No description provided for @datasetDialogNoProjectTypeTips.
  ///
  /// In en, this message translates to:
  /// **'Check your dataset format and ensure annotations follow a supported structure like COCO, YOLO, VOC or Datumaro.'**
  String get datasetDialogNoProjectTypeTips;

  /// No description provided for @datasetDialogProcessingDatasetTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing Dataset'**
  String get datasetDialogProcessingDatasetTitle;

  /// No description provided for @datasetDialogProcessingDatasetMessage.
  ///
  /// In en, this message translates to:
  /// **'We are currently extracting your ZIP archive, analyzing its contents, and detecting the dataset format and annotation type. This may take a few seconds to a few minutes depending on the dataset size and structure. Please do not close this window or navigate away during the process.'**
  String get datasetDialogProcessingDatasetMessage;

  /// No description provided for @datasetDialogProcessingDatasetTips.
  ///
  /// In en, this message translates to:
  /// **'Large archives with many images or annotation files can take longer to process.'**
  String get datasetDialogProcessingDatasetTips;

  /// No description provided for @datasetDialogCreatingProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Creating Project'**
  String get datasetDialogCreatingProjectTitle;

  /// No description provided for @datasetDialogCreatingProjectMessage.
  ///
  /// In en, this message translates to:
  /// **'We are setting up your project, initializing its metadata, and saving all configurations. This includes assigning labels, creating datasets, and linking associated media files. Please wait a moment and avoid closing this window until the process is complete.'**
  String get datasetDialogCreatingProjectMessage;

  /// No description provided for @datasetDialogCreatingProjectTips.
  ///
  /// In en, this message translates to:
  /// **'Projects with many labels or media files might take slightly longer.'**
  String get datasetDialogCreatingProjectTips;

  /// No description provided for @datasetDialogAnalyzingDatasetTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Dataset'**
  String get datasetDialogAnalyzingDatasetTitle;

  /// No description provided for @datasetDialogAnalyzingDatasetMessage.
  ///
  /// In en, this message translates to:
  /// **'We are currently analyzing your dataset archive. This includes extracting files, detecting dataset structure, identifying annotation formats, and collecting media and label information. Please wait until the process is complete. Closing the window or navigating away may interrupt the operation.'**
  String get datasetDialogAnalyzingDatasetMessage;

  /// No description provided for @datasetDialogAnalyzingDatasetTips.
  ///
  /// In en, this message translates to:
  /// **'Large datasets with many files or complex annotations may take extra time.'**
  String get datasetDialogAnalyzingDatasetTips;

  /// No description provided for @datasetDialogFilePickErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'File Selection Error'**
  String get datasetDialogFilePickErrorTitle;

  /// No description provided for @datasetDialogFilePickErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to select the file. Please try again.'**
  String get datasetDialogFilePickErrorMessage;

  /// No description provided for @datasetDialogGenericErrorTips.
  ///
  /// In en, this message translates to:
  /// **'Please check your file and try again. If the problem persists, contact support.'**
  String get datasetDialogGenericErrorTips;

  /// No description provided for @thumbnailGenerationTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get thumbnailGenerationTitle;

  /// No description provided for @thumbnailGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate thumbnail'**
  String get thumbnailGenerationFailed;

  /// No description provided for @thumbnailGenerationTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get thumbnailGenerationTryAgainLater;

  /// No description provided for @thumbnailGenerationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Generating thumbnail...'**
  String get thumbnailGenerationInProgress;

  /// No description provided for @menuImageAnnotate.
  ///
  /// In en, this message translates to:
  /// **'Annotate'**
  String get menuImageAnnotate;

  /// No description provided for @menuImageDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get menuImageDetails;

  /// No description provided for @menuImageDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get menuImageDuplicate;

  /// No description provided for @menuImageSetAsIcon.
  ///
  /// In en, this message translates to:
  /// **'Set as Icon'**
  String get menuImageSetAsIcon;

  /// No description provided for @menuImageDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get menuImageDelete;

  /// No description provided for @noLabelsTitle.
  ///
  /// In en, this message translates to:
  /// **'You have no Labels in the Project'**
  String get noLabelsTitle;

  /// No description provided for @noLabelsExplain1.
  ///
  /// In en, this message translates to:
  /// **'You can\'t annotate without labels because labels give meaning to what you\'re marking'**
  String get noLabelsExplain1;

  /// No description provided for @noLabelsExplain2.
  ///
  /// In en, this message translates to:
  /// **'You can add labels manually or import them from a JSON file.'**
  String get noLabelsExplain2;

  /// No description provided for @noLabelsExplain3.
  ///
  /// In en, this message translates to:
  /// **'An annotation without a label is just an empty box.'**
  String get noLabelsExplain3;

  /// No description provided for @noLabelsExplain4.
  ///
  /// In en, this message translates to:
  /// **'Labels define the categories or classes you\'re annotating in your dataset.'**
  String get noLabelsExplain4;

  /// No description provided for @noLabelsExplain5.
  ///
  /// In en, this message translates to:
  /// **'Whether you\'re tagging objects in images, classifying, or segmenting regions,'**
  String get noLabelsExplain5;

  /// No description provided for @noLabelsExplain6.
  ///
  /// In en, this message translates to:
  /// **'labels are essential for organizing your annotations clearly and consistently.'**
  String get noLabelsExplain6;

  /// No description provided for @importLabelsPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Labels Preview'**
  String get importLabelsPreviewTitle;

  /// No description provided for @importLabelsFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Label Import Failed'**
  String get importLabelsFailedTitle;

  /// No description provided for @importLabelsNoLabelsTitle.
  ///
  /// In en, this message translates to:
  /// **'No labels found in this project'**
  String get importLabelsNoLabelsTitle;

  /// No description provided for @importLabelsJsonParseError.
  ///
  /// In en, this message translates to:
  /// **'JSON parsing failed.\n'**
  String get importLabelsJsonParseError;

  /// No description provided for @importLabelsJsonParseTips.
  ///
  /// In en, this message translates to:
  /// **'Make sure the file is valid JSON. You can validate it at https://jsonlint.com/'**
  String get importLabelsJsonParseTips;

  /// No description provided for @importLabelsJsonNotList.
  ///
  /// In en, this message translates to:
  /// **'Expected a list of labels (array), but got: {type}.'**
  String importLabelsJsonNotList(Object type);

  /// No description provided for @importLabelsJsonNotListTips.
  ///
  /// In en, this message translates to:
  /// **'Your JSON file must start with [ and contain multiple label objects. Each label should include name, color, and labelOrder fields.'**
  String get importLabelsJsonNotListTips;

  /// No description provided for @importLabelsJsonItemNotMap.
  ///
  /// In en, this message translates to:
  /// **'One of the entries in the list is not a valid object: {type}'**
  String importLabelsJsonItemNotMap(Object type);

  /// No description provided for @importLabelsJsonItemNotMapTips.
  ///
  /// In en, this message translates to:
  /// **'Each item in the list must be a valid object with fields: name, color, and labelOrder.'**
  String get importLabelsJsonItemNotMapTips;

  /// No description provided for @importLabelsJsonLabelParseError.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse one of the labels.\n'**
  String get importLabelsJsonLabelParseError;

  /// No description provided for @importLabelsJsonLabelParseTips.
  ///
  /// In en, this message translates to:
  /// **'Check that each label has required fields like name and color, and values are correct types.'**
  String get importLabelsJsonLabelParseTips;

  /// No description provided for @importLabelsUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred during JSON file import.\n'**
  String get importLabelsUnexpectedError;

  /// No description provided for @importLabelsUnexpectedErrorTip.
  ///
  /// In en, this message translates to:
  /// **'Please make sure your file is readable and formatted correctly.'**
  String get importLabelsUnexpectedErrorTip;

  /// No description provided for @importLabelsDatabaseError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save labels to database'**
  String get importLabelsDatabaseError;

  /// No description provided for @importLabelsDatabaseErrorTips.
  ///
  /// In en, this message translates to:
  /// **'Please check your database connection and try again. If the problem persists, contact support.'**
  String get importLabelsDatabaseErrorTips;

  /// No description provided for @importLabelsNameMissingOrEmpty.
  ///
  /// In en, this message translates to:
  /// **'One of the labels is missing a valid name.'**
  String get importLabelsNameMissingOrEmpty;

  /// No description provided for @importLabelsNameMissingOrEmptyTips.
  ///
  /// In en, this message translates to:
  /// **'Ensure every label in the JSON includes a non-empty \'name\' field.'**
  String get importLabelsNameMissingOrEmptyTips;

  /// No description provided for @menuSortAZ.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get menuSortAZ;

  /// No description provided for @menuSortZA.
  ///
  /// In en, this message translates to:
  /// **'Z-A'**
  String get menuSortZA;

  /// No description provided for @menuSortProjectType.
  ///
  /// In en, this message translates to:
  /// **'Project Type'**
  String get menuSortProjectType;

  /// No description provided for @uploadInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload in Progress'**
  String get uploadInProgressTitle;

  /// No description provided for @uploadInProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'You have an active upload in progress. If you leave now, the upload will be canceled and you will need to start over.\n\nDo you want to leave anyway?'**
  String get uploadInProgressMessage;

  /// No description provided for @uploadInProgressStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get uploadInProgressStay;

  /// No description provided for @uploadInProgressLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get uploadInProgressLeave;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFound;

  /// No description provided for @labelEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get labelEditSave;

  /// No description provided for @labelEditEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get labelEditEdit;

  /// No description provided for @labelEditMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move Up'**
  String get labelEditMoveUp;

  /// No description provided for @labelEditMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move Down'**
  String get labelEditMoveDown;

  /// No description provided for @labelEditDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get labelEditDelete;

  /// No description provided for @labelExportLabels.
  ///
  /// In en, this message translates to:
  /// **'Export Labels'**
  String get labelExportLabels;

  /// No description provided for @labelSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save labels in JSON file'**
  String get labelSaveDialogTitle;

  /// No description provided for @labelSaveDefaultFilename.
  ///
  /// In en, this message translates to:
  /// **'labels.json'**
  String get labelSaveDefaultFilename;

  /// No description provided for @labelDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete label: {error}'**
  String labelDeleteError(Object error);

  /// No description provided for @labelDeleteErrorTips.
  ///
  /// In en, this message translates to:
  /// **'Make sure the label still exists or is not used elsewhere.'**
  String get labelDeleteErrorTips;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'nl',
    'pt',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
