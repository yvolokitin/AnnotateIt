import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

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

  /// No description provided for @emptyProject_title.
  ///
  /// In en, this message translates to:
  /// **'Start your first project'**
  String get emptyProject_title;

  /// No description provided for @emptyProject_description.
  ///
  /// In en, this message translates to:
  /// **'Create a project to begin organizing datasets, annotating media, and applying AI to your vision tasks — all in one streamlined workspace designed to accelerate your computer vision pipeline.'**
  String get emptyProject_description;

  /// No description provided for @emptyProject_createNew.
  ///
  /// In en, this message translates to:
  /// **'Create New Project'**
  String get emptyProject_createNew;

  /// No description provided for @emptyProject_importDataset.
  ///
  /// In en, this message translates to:
  /// **'Create Project from Dataset import'**
  String get emptyProject_importDataset;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

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

  /// No description provided for @dialogFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get dialogFinish;

  /// No description provided for @dialogCloseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogCloseTooltip;

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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
