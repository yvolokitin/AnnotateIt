// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get buttonKeep => 'Behouden';

  @override
  String get buttonSave => 'Opslaan';

  @override
  String get buttonHelp => 'Help';

  @override
  String get buttonEdit => 'Bewerken';

  @override
  String get buttonNext => 'Volgende';

  @override
  String get buttonBack => 'Terug';

  @override
  String get buttonApply => 'Toepassen';

  @override
  String get buttonClose => 'Sluiten';

  @override
  String get buttonImport => 'Importeren';

  @override
  String get buttonCancel => 'Annuleren';

  @override
  String get buttonFinish => 'Voltooien';

  @override
  String get buttonDelete => 'Verwijderen';

  @override
  String get buttonDuplicate => 'Dupliceren';

  @override
  String get buttonConfirm => 'Bevestigen';

  @override
  String get buttonDiscard => 'Weggooien';

  @override
  String get buttonFeedbackShort => 'Fdbck';

  @override
  String get buttonImportLabels => 'Labels Importeren';

  @override
  String get buttonExportLabels => 'Labels Exporteren';

  @override
  String get buttonNextConfirmTask => 'Volgende: Taak Bevestigen';

  @override
  String get buttonCreateProject => 'Project Aanmaken';

  @override
  String get aboutTitle => 'Over Annot@It';

  @override
  String get aboutDescription =>
      'Annot@It is een annotatie-applicatie ontworpen om het annotatieproces voor computervisieprojecten te stroomlijnen. Of je nu werkt aan beeldclassificatie, objectdetectie, segmentatie of andere visietaken, Annot@It biedt de flexibiliteit en precisie die nodig zijn voor hoogwaardige gegevenslabeling.';

  @override
  String get aboutFeaturesTitle => 'Belangrijkste functies:';

  @override
  String get aboutFeatures =>
      '- Meerdere projecttypen: Maak en beheer projecten op maat voor verschillende computervisietaken.\n- Gegevens uploaden & beheren: Upload en organiseer eenvoudig je datasets voor naadloze annotatie.\n- Geavanceerde annotatiehulpmiddelen: Gebruik begrenzingsvakken, polygonen, sleutelpunten en segmentatiemaskers.\n- Exporteren & integratie: Exporteer gelabelde gegevens in verschillende formaten die compatibel zijn met AI/ML-frameworks.';

  @override
  String get aboutCallToAction =>
      'Begin vandaag nog met je annotatiereis en bouw hoogwaardige datasets voor je computervisiemodellen!';

  @override
  String get accountUser => 'Gebruiker';

  @override
  String get accountProfile => 'Profiel';

  @override
  String get accountStorage => 'Opslag';

  @override
  String get accountDeviceStorage => 'Apparaatopslag';

  @override
  String get accountSettings => 'Instellingen';

  @override
  String get accountApplicationSettings => 'Applicatie-instellingen';

  @override
  String get accountLoadingMessage => 'Gebruikersgegevens laden...';

  @override
  String get accountErrorLoadingUser =>
      'Het laden van gebruikersgegevens is mislukt';

  @override
  String get accountRetry => 'Opnieuw proberen';

  @override
  String get userProfileName => 'Kapitein Annotator';

  @override
  String get userProfileFeedbackButton => 'Feedback';

  @override
  String get userProfileEditProfileButton => 'Profiel Bewerken';

  @override
  String get userProfileProjects => 'Projecten';

  @override
  String get userProfileLabels => 'Labels';

  @override
  String get userProfileMedia => 'Media';

  @override
  String get userProfileOverview => 'Overzicht';

  @override
  String get userProfileAnnotations => 'Annotaties';

  @override
  String get settingsGeneralTitle => 'Algemene Instellingen';

  @override
  String get settingsProjectCreationTitle => 'Project Aanmaken';

  @override
  String get settingsProjectCreationConfirmNoLabels =>
      'Altijd vragen om te bevestigen bij het maken van een project zonder labels';

  @override
  String get settingsProjectCreationConfirmNoLabelsNote =>
      'Je wordt gewaarschuwd als je probeert een project aan te maken zonder gedefinieerde labels.';

  @override
  String get settingsLabelsCreationDeletionTitle =>
      'Labels Aanmaken / Verwijderen';

  @override
  String get settingsLabelsDeletionWithAnnotations =>
      'Annotaties verwijderen wanneer label wordt verwijderd';

  @override
  String get settingsLabelsDeletionWithAnnotationsNote =>
      'Wanneer ingeschakeld, zal het verwijderen van een label automatisch alle annotaties verwijderen die aan dat label zijn toegewezen in alle media-items.';

  @override
  String get settingsLabelsSetDefaultLabel =>
      'Eerste label als standaard instellen';

  @override
  String get settingsLabelsSetDefaultLabelNote =>
      'Wanneer ingeschakeld, wordt het eerste label dat je in een project maakt automatisch gemarkeerd als het standaardlabel. Je kunt de standaard later op elk moment wijzigen.';

  @override
  String get settingsDatasetViewTitle => 'Dataset Weergave';

  @override
  String get settingsDatasetViewDuplicateWithAnnotations =>
      'Afbeelding altijd met annotaties dupliceren (kopiëren)';

  @override
  String get settingsDatasetViewDuplicateWithAnnotationsNote =>
      'Bij dupliceren worden annotaties meegenomen, tenzij je de instellingen wijzigt';

  @override
  String get settingsDatasetViewDeleteFromOS =>
      'Bij het verwijderen van een afbeelding uit de Dataset, deze altijd verwijderen uit het besturingssysteem / bestandssysteem';

  @override
  String get settingsDatasetViewDeleteFromOSNote =>
      'Verwijdert het bestand ook van de schijf, niet alleen uit de dataset';

  @override
  String get settingsAnnotationTitle => 'Annotatie-instellingen';

  @override
  String get settingsAnnotationOpacity => 'Annotatie-transparantie';

  @override
  String get settingsAnnotationAutoSave =>
      'Annotatie altijd opslaan of verzenden bij het overgaan naar de volgende afbeelding';

  @override
  String get settingsThemeTitle => 'Themaselectie';

  @override
  String get settingsLanguageTitle => 'Land / Taal';

  @override
  String get colorPickerTitle => 'Kies een kleur';

  @override
  String get colorPickerBasicColors => 'Basiskleuren';

  @override
  String get loadingProjects => 'Projecten laden...';

  @override
  String get importDataset => 'Dataset importeren';

  @override
  String get uploadMedia => 'Media uploaden';

  @override
  String get createProjectTitle => 'Nieuw Project Aanmaken';

  @override
  String get createProjectStepOneSubtitle =>
      'Voer je nieuwe projectnaam in en selecteer het Projecttype';

  @override
  String get createProjectStepTwoSubtitle =>
      'Maak labels aan voor een Nieuw project';

  @override
  String get emptyProjectTitle => 'Begin je eerste project';

  @override
  String get emptyProjectDescription =>
      'Maak een project aan om datasets te organiseren, media te annoteren en AI toe te passen op je visietaken — allemaal in één gestroomlijnde werkruimte ontworpen om je computervisie-pipeline te versnellen.';

  @override
  String get emptyProjectCreateNew => 'Nieuw Project Aanmaken';

  @override
  String get emptyProjectCreateNewShort => 'Nieuw Project';

  @override
  String get emptyProjectImportDataset =>
      'Project aanmaken vanuit Dataset-import';

  @override
  String get emptyProjectImportDatasetShort => 'Dataset Importeren';

  @override
  String get dialogBack => '<- Terug';

  @override
  String get dialogNext => 'Volgende ->';

  @override
  String get rename => 'Hernoemen';

  @override
  String get delete => 'Verwijderen';

  @override
  String get setAsDefault => 'Als Standaard Instellen';

  @override
  String paginationPageFromTotal(int current, int total) {
    return 'Pagina $current van $total';
  }

  @override
  String get taskTypeRequiredTitle => 'Taaktype Vereist';

  @override
  String taskTypeRequiredMessage(Object tab) {
    return 'Je moet een taaktype selecteren voordat je verder kunt gaan. Het huidige tabblad \'$tab\' heeft geen taaktype geselecteerd. Elk project moet gekoppeld zijn aan een taak (bijv. objectdetectie, classificatie of segmentatie) zodat het systeem weet hoe je gegevens te verwerken.';
  }

  @override
  String taskTypeRequiredTips(Object tab) {
    return 'Klik op een van de beschikbare taaktype-opties onder het tabblad \'$tab\'. Als je niet zeker weet welke taak je moet kiezen, beweeg dan met de muis over het informatiepictogram naast elk type om een korte beschrijving te zien.';
  }

  @override
  String get menuProjects => 'Projecten';

  @override
  String get menuAccount => 'Account';

  @override
  String get menuLearn => 'Leren';

  @override
  String get menuAbout => 'Over';

  @override
  String get menuCreateNewProject => 'Nieuw project aanmaken';

  @override
  String get menuCreateFromDataset => 'Aanmaken vanuit Dataset';

  @override
  String get menuImportDataset => 'Project aanmaken vanuit Dataset-import';

  @override
  String get menuSortLastUpdated => 'Laatst Bijgewerkt';

  @override
  String get menuSortNewestOldest => 'Nieuwste-Oudste';

  @override
  String get menuSortOldestNewest => 'Oudste-Nieuwste';

  @override
  String get menuSortType => 'Projecttype';

  @override
  String get menuSortAz => 'A-Z';

  @override
  String get menuSortZa => 'Z-A';

  @override
  String get projectNameLabel => 'Projectnaam';

  @override
  String get tabDetection => 'Detectie';

  @override
  String get tabClassification => 'Classificatie';

  @override
  String get tabSegmentation => 'Segmentatie';

  @override
  String get labelRequiredTitle => 'Minstens Één Label Vereist';

  @override
  String get labelRequiredMessage =>
      'Je moet minstens één label aanmaken om verder te gaan. Labels zijn essentieel voor het definiëren van de annotatiecategorieën die tijdens de datasetvoorbereiding zullen worden gebruikt.';

  @override
  String get labelRequiredTips =>
      'Tip: Klik op de rode knop met de tekst Label Aanmaken nadat je een labelnaam hebt ingevoerd om je eerste label toe te voegen.';

  @override
  String get createLabelButton => 'Label Aanmaken';

  @override
  String get labelNameHint => 'Voer hier een nieuwe Labelnaam in';

  @override
  String get createdLabelsTitle => 'Aangemaakte Labels';

  @override
  String get labelEmptyTitle => 'Labelnaam kan niet leeg zijn!';

  @override
  String get labelEmptyMessage =>
      'Voer een labelnaam in. Labels helpen bij het identificeren van objecten of categorieën in je project. Het wordt aanbevolen om korte, duidelijke en beschrijvende namen te gebruiken, zoals \"Auto\", \"Persoon\" of \"Boom\". Vermijd speciale tekens of spaties.';

  @override
  String get labelEmptyTips =>
      'Tips voor Labelnaamgeving:\n• Gebruik korte en beschrijvende namen\n• Houd je aan letters, cijfers, onderstreepjes (bijv. kat, verkeersbord, achtergrond)\n• Vermijd spaties en symbolen (bijv. Persoon 1 → persoon_1)';

  @override
  String get labelDuplicateTitle => 'Dubbele Labelnaam';

  @override
  String labelDuplicateMessage(Object label) {
    return 'Het label \'$label\' bestaat al in dit project. Elk label moet een unieke naam hebben om verwarring tijdens annotatie en training te voorkomen.';
  }

  @override
  String get labelDuplicateTips =>
      'Waarom unieke labels?\n• Het hergebruiken van dezelfde naam kan problemen veroorzaken tijdens dataset-export en modeltraining.\n• Unieke labelnamen helpen bij het behouden van duidelijke, gestructureerde annotaties.\n\nTip: Probeer een variatie of nummer toe te voegen om te onderscheiden (bijv. \'Auto\', \'Auto_2\').';

  @override
  String get binaryLimitTitle => 'Binaire Classificatielimiet';

  @override
  String get binaryLimitMessage =>
      'Je kunt niet meer dan twee labels aanmaken voor een Binair Classificatieproject.\n\nBinaire Classificatie is ontworpen om onderscheid te maken tussen precies twee klassen, zoals \'Ja\' vs \'Nee\', of \'Spam\' vs \'Geen Spam\'.';

  @override
  String get binaryLimitTips =>
      'Heb je meer dan twee labels nodig?\nOverweeg om je projecttype te wijzigen naar Multi-Class Classificatie of een andere geschikte taak om drie of meer categorieën te ondersteunen.';

  @override
  String get noteBinaryClassification =>
      'Dit projecttype staat precies 2 labels toe. Binaire Classificatie wordt gebruikt wanneer je model onderscheid moet maken tussen twee mogelijke klassen, zoals \"Ja\" vs \"Nee\", of \"Hond\" vs \"Geen Hond\". Maak alsjeblieft slechts twee verschillende labels aan.';

  @override
  String get noteMultiClassClassification =>
      'Dit projecttype ondersteunt meerdere labels. Multi-Class Classificatie is geschikt wanneer je model moet kiezen uit drie of meer categorieën, zoals \"Kat\", \"Hond\", \"Konijn\". Je kunt zoveel labels toevoegen als nodig.';

  @override
  String get noteDetectionOrSegmentation =>
      'Dit projecttype ondersteunt meerdere labels. Voor Objectdetectie of Segmentatie vertegenwoordigt elk label typisch een verschillende klasse van object (bijv. \"Auto\", \"Voetganger\", \"Fiets\"). Je kunt zoveel labels aanmaken als nodig voor je dataset.';

  @override
  String get noteDefault =>
      'Je kunt één of meer labels aanmaken afhankelijk van je projecttype. Elk label helpt bij het definiëren van een categorie die je model zal leren herkennen. Raadpleeg de documentatie voor best practices.';

  @override
  String get discardDatasetImportTitle => 'Dataset-import Weggooien?';

  @override
  String get discardDatasetImportMessage =>
      'Je hebt al een dataset geëxtraheerd. Nu annuleren zal de geëxtraheerde bestanden en gedetecteerde datasetdetails verwijderen. Weet je zeker dat je wilt doorgaan?';

  @override
  String get projectTypeHelpTitle => 'Hulp bij Projecttypeselectie';

  @override
  String get projectTypeWhyDisabledTitle =>
      'Waarom zijn sommige projecttypen uitgeschakeld?';

  @override
  String get projectTypeWhyDisabledBody =>
      'Wanneer je een dataset importeert, analyseert het systeem de geleverde annotaties en probeert automatisch het meest geschikte projecttype voor je te detecteren.\n\nBijvoorbeeld, als je dataset begrenzingsvak-annotaties bevat, zal het voorgestelde projecttype \"Detectie\" zijn. Als het maskers bevat, zal \"Segmentatie\" worden voorgesteld, enzovoort.\n\nOm je gegevens te beschermen, zijn standaard alleen compatibele projecttypen ingeschakeld.';

  @override
  String get projectTypeAllowChangeTitle =>
      'Wat gebeurt er als ik projecttypewijziging inschakelen?';

  @override
  String get projectTypeAllowChangeBody =>
      'Als je \"Projecttypewijziging Toestaan\" inschakelt, kun je handmatig ELK projecttype selecteren, zelfs als het niet overeenkomt met de gedetecteerde annotaties.\n\n⚠️ WAARSCHUWING: Alle bestaande annotaties van de import zullen worden verwijderd bij het overschakelen naar een incompatibel projecttype.\nJe zult alle media-items opnieuw moeten annoteren of een dataset moeten importeren die geschikt is voor het nieuw geselecteerde projecttype.';

  @override
  String get projectTypeWhenUseTitle => 'Wanneer moet ik deze optie gebruiken?';

  @override
  String get projectTypeWhenUseBody =>
      'Je zou deze optie alleen moeten inschakelen als:\n\n- Je per ongeluk de verkeerde dataset hebt geïmporteerd.\n- Je een nieuw annotatieproject wilt starten met een ander type.\n- Je datasetstructuur is veranderd na import.\n\nAls je niet zeker bent, raden we sterk aan om de standaardselectie te behouden om gegevensverlies te voorkomen.';

  @override
  String get allLabels => 'Alle Labels';

  @override
  String get setAsProjectIcon => 'Als Projecticoon Instellen';

  @override
  String setAsProjectIconConfirm(Object filePath) {
    return 'Wil je \'$filePath\' gebruiken als icoon voor dit project?\n\nDit zal elk eerder ingesteld icoon vervangen.';
  }

  @override
  String get removeFilesFromDatasetInProgress => 'Bestanden verwijderen...';

  @override
  String get removeFilesFromDataset => 'Bestanden verwijderen uit Dataset?';

  @override
  String removeFilesFromDatasetConfirm(Object amount) {
    return 'Weet je zeker dat je de volgende bestanden wilt verwijderen (\'$amount\')?\n\nAlle bijbehorende annotaties zullen ook worden verwijderd.';
  }

  @override
  String get removeFilesFailedTitle => 'Verwijderen Mislukt';

  @override
  String get removeFilesFailedMessage =>
      'Sommige bestanden konden niet worden verwijderd';

  @override
  String get removeFilesFailedTips =>
      'Controleer bestandsrechten en probeer het opnieuw';

  @override
  String get duplicateImage => 'Afbeelding Dupliceren';

  @override
  String get duplicateWithAnnotations => 'Afbeelding dupliceren met annotaties';

  @override
  String get duplicateWithAnnotationsHint =>
      'Er wordt een kopie van de afbeelding gemaakt samen met alle annotatiegegevens.';

  @override
  String get duplicateImageOnly => 'Alleen afbeelding dupliceren';

  @override
  String get duplicateImageOnlyHint =>
      'Alleen de afbeelding wordt gekopieerd, zonder annotaties.';

  @override
  String get saveDuplicateChoiceAsDefault =>
      'Dit antwoord opslaan als standaardantwoord en niet meer vragen\n(Je kunt dit wijzigen in Account -> Applicatie-instellingen -> Dataset-navigatie)';

  @override
  String get editProjectTitle => 'Projectnaam bewerken';

  @override
  String get editProjectDescription =>
      'Kies een duidelijke, beschrijvende projectnaam (3 - 86 tekens). Het wordt aanbevolen om speciale tekens te vermijden.';

  @override
  String get deleteProjectTitle => 'Project Verwijderen';

  @override
  String get deleteProjectInProgress => 'Project verwijderen...';

  @override
  String get deleteProjectOptionDeleteFromDisk =>
      'Ook alle bestanden van schijf verwijderen';

  @override
  String get deleteProjectOptionDontAskAgain => 'Vraag me niet opnieuw';

  @override
  String deleteProjectConfirm(Object projectName) {
    return 'Weet je zeker dat je het project \"$projectName\" wilt verwijderen?';
  }

  @override
  String deleteProjectInfoLine(Object creationDate, Object labelCount) {
    return 'Project werd aangemaakt op $creationDate\nAantal Labels: $labelCount';
  }

  @override
  String get deleteDatasetTitle => 'Dataset Verwijderen';

  @override
  String get deleteDatasetInProgress => 'Dataset verwijderen... Even geduld.';

  @override
  String deleteDatasetConfirm(Object datasetName) {
    return 'Weet je zeker dat je \"$datasetName\" wilt verwijderen?';
  }

  @override
  String deleteDatasetInfoLine(
    Object creationDate,
    Object mediaCount,
    Object annotationCount,
  ) {
    return 'Deze dataset werd aangemaakt op $creationDate en bevat $mediaCount media-items en $annotationCount annotaties.';
  }

  @override
  String get editDatasetTitle => 'Dataset Hernoemen';

  @override
  String get editDatasetDescription =>
      'Voer een nieuwe naam in voor deze dataset:';

  @override
  String get noMediaDialogUploadPrompt =>
      'Je moet afbeeldingen of video\'s uploaden';

  @override
  String get noMediaDialogUploadPromptShort => 'Media uploaden';

  @override
  String get noMediaDialogSupportedImageTypesTitle =>
      'Ondersteunde afbeeldingstypen:';

  @override
  String get noMediaDialogSupportedImageTypesList =>
      'jpg, jpeg, png, bmp, jfif, webp';

  @override
  String get noMediaDialogSupportedVideoFormatsLink =>
      'Klik hier om te zien welke videoformaten worden ondersteund op jouw platform';

  @override
  String get noMediaDialogSupportedVideoFormatsTitle =>
      'Ondersteunde Videoformaten';

  @override
  String get noMediaDialogSupportedVideoFormatsList =>
      'Veelvoorkomende Ondersteunde Formaten:\n\n- MP4: Android, iOS, Web, Desktop\n- MOV: Android, iOS, macOS\n- M4V: Android, iOS, macOS\n- WEBM: Android, Web (browserafhankelijk)\n- MKV: Android (gedeeltelijk), Windows\n- AVI: Alleen Android/Windows (gedeeltelijk)';

  @override
  String get noMediaDialogSupportedVideoFormatsWarning =>
      'Ondersteuning kan variëren afhankelijk van het platform en de videocodec.\nSommige formaten werken mogelijk niet in browsers of op iOS.';

  @override
  String get annotatorTopToolbarBackTooltip => 'Terug naar Project';

  @override
  String get annotatorTopToolbarSelectDefaultLabel => 'Standaardlabel';

  @override
  String get toolbarNavigation => 'Navigatie';

  @override
  String get toolbarBbox => 'Begrenzingsvak Tekenen';

  @override
  String get toolbarPolygon => 'Polygoon Tekenen';

  @override
  String get toolbarSAM => 'Segment Anything Model';

  @override
  String get toolbarResetZoom => 'Zoom Resetten';

  @override
  String get toolbarToggleGrid => 'Raster Schakelen';

  @override
  String get toolbarAnnotationSettings => 'Annotatie-instellingen';

  @override
  String get toolbarToggleAnnotationNames => 'Annotatienamen Schakelen';

  @override
  String get toolbarRotateLeft => 'Linksom Draaien (Binnenkort Beschikbaar)';

  @override
  String get toolbarRotateRight => 'Rechtsom Draaien (Binnenkort Beschikbaar)';

  @override
  String get toolbarHelp => 'Help';

  @override
  String get dialogOpacityTitle => 'Annotatie Vulling Transparantie';

  @override
  String get dialogHelpTitle => 'Annotator Werkbalk Help';

  @override
  String get dialogHelpContent =>
      '• Navigatie – Gebruik om te selecteren en rond het canvas te bewegen.\n• Begrenzingsvak – (Zichtbaar in Detectieprojecten) Teken rechthoekige begrenzingsvakken.\n• Zoom Resetten – Reset het zoomniveau om de afbeelding op het scherm te passen.\n• Raster Schakelen – Toon of verberg het dataset-miniatuurrooster.\n• Instellingen – Pas de vultransparantie van annotaties, de annotatiegrens en de grootte van hoeken aan.\n• Annotatienamen Schakelen – Toon of verberg tekstlabels op annotaties.';

  @override
  String get dialogHelpTips =>
      'Tip: Gebruik de Navigatiemodus om annotaties te selecteren en te bewerken.\nMeer sneltoetsen en functies komen binnenkort!';

  @override
  String get dialogOpacityExplanation =>
      'Pas het transparantieniveau aan om de inhoud meer of minder doorzichtig te maken.';

  @override
  String get deleteAnnotationTitle => 'Annotatie Verwijderen';

  @override
  String get deleteAnnotationMessage => 'Weet je zeker dat je wilt verwijderen';

  @override
  String get unnamedAnnotation => 'deze annotatie';

  @override
  String get accountStorage_importFolderTitle => 'Datasets importmap';

  @override
  String get accountStorage_thumbnailsFolderTitle => 'Miniatuurmap';

  @override
  String get accountStorage_exportFolderTitle => 'Datasets exportmap';

  @override
  String get accountStorage_folderTooltip => 'Map kiezen';

  @override
  String get accountStorage_helpTitle => 'Opslaghulp';

  @override
  String get accountStorage_helpMessage =>
      'Je kunt de map wijzigen waar geïmporteerde datasets, geëxporteerde ZIP-archieven en miniaturen worden opgeslagen.\nTik op het \"Map\"-pictogram naast het padveld om de directory te selecteren of te wijzigen.\n\nDeze map zal worden gebruikt als standaardlocatie voor:\n- Geïmporteerde datasetbestanden (bijv. COCO, YOLO, VOC, Datumaro, etc.)\n- Geëxporteerde dataset Zip-archieven\n- Projectminiaturen\n\nZorg ervoor dat de geselecteerde map beschrijfbaar is en voldoende ruimte heeft.\nOp Android of iOS moet je mogelijk opslagrechten verlenen.\nAanbevolen mappen variëren per platform — zie hieronder platformspecifieke tips.';

  @override
  String get accountStorage_helpTips =>
      'Aanbevolen mappen per platform:\n\nWindows:\n  C:\\Users\\<jij>\\AppData\\Roaming\\AnnotateIt\\datasets\n\nLinux / Ubuntu:\n  /home/<jij>/.annotateit/datasets\n\nmacOS:\n  /Users/<jij>/Library/Application Support/AnnotateIt/datasets\n\nAndroid:\n  /storage/emulated/0/AnnotateIt/datasets\n\niOS:\n  <App sandbox pad>/Documents/AnnotateIt/datasets\n';

  @override
  String get accountStorage_copySuccess => 'Pad gekopieerd naar klembord';

  @override
  String get accountStorage_openError => 'Map bestaat niet:\n';

  @override
  String get accountStorage_pathEmpty => 'Pad is leeg';

  @override
  String get accountStorage_openFailed => 'Kan map niet openen:\n';

  @override
  String get changeProjectTypeTitle => 'Projecttype wijzigen';

  @override
  String get changeProjectTypeMigrating => 'Projecttype migreren...';

  @override
  String get changeProjectTypeStepOneSubtitle =>
      'Selecteer een nieuw projecttype uit de onderstaande lijst';

  @override
  String get changeProjectTypeStepTwoSubtitle => 'Bevestig je keuze';

  @override
  String get changeProjectTypeWarningTitle =>
      'Waarschuwing: Je staat op het punt het projecttype te wijzigen.';

  @override
  String get changeProjectTypeConversionIntro =>
      'Alle bestaande annotaties zullen als volgt worden geconverteerd:';

  @override
  String get changeProjectTypeConversionDetails =>
      '- Begrenzingsvakken (Detectie) -> omgezet naar rechthoekige polygonen.\n- Polygonen (Segmentatie) -> omgezet naar strak passende begrenzingsvakken.\n\nOpmerking: Deze conversies kunnen de precisie verminderen, vooral bij het converteren van polygonen naar vakken, aangezien gedetailleerde vorminformatie verloren gaat.\n\n- Detectie / Segmentatie → Classificatie:\n  Afbeeldingen worden geclassificeerd op basis van het meest voorkomende label in de annotaties:\n     -> Als een afbeelding 5 objecten heeft gelabeld als \"Hond\" en 10 als \"Kat\", zal het worden geclassificeerd als \"Kat\".\n     -> Als de aantallen gelijk zijn, zal het eerste gevonden label worden gebruikt.\n\n- Classificatie -> Detectie / Segmentatie:\n  Er worden geen annotaties overgedragen. Je zult alle media-items handmatig opnieuw moeten annoteren, aangezien classificatieprojecten geen gegevens op regioniveau bevatten.';

  @override
  String get changeProjectTypeErrorTitle => 'Migratie Mislukt';

  @override
  String get changeProjectTypeErrorMessage =>
      'Er is een fout opgetreden bij het wijzigen van het projecttype. De wijzigingen konden niet worden toegepast.';

  @override
  String get changeProjectTypeErrorTips =>
      'Controleer of het project geldige annotaties heeft en probeer het opnieuw. Als het probleem aanhoudt, herstart de app of neem contact op met ondersteuning.';

  @override
  String get exportProjectAsDataset => 'Project Exporteren als Dataset';

  @override
  String get projectHelpTitle => 'Hoe Projecten Werken';

  @override
  String get projectHelpMessage =>
      'Met projecten kun je datasets, mediabestanden en annotaties op één plek organiseren. Je kunt nieuwe projecten maken voor verschillende taken zoals detectie, classificatie of segmentatie.';

  @override
  String get projectHelpTips =>
      'Tip: Je kunt datasets in COCO-, YOLO-, VOC-, Labelme- en Datumaro-formaat importeren om automatisch een project te maken.';

  @override
  String get datasetDialogTitle => 'Dataset Importeren om Project te Maken';

  @override
  String get datasetDialogProcessing => 'Verwerken...';

  @override
  String datasetDialogProcessingProgress(Object percent) {
    return 'Verwerken... $percent%';
  }

  @override
  String get datasetDialogModeIsolate => 'Isolatiemodus Ingeschakeld';

  @override
  String get datasetDialogModeNormal => 'Normale Modus';

  @override
  String get datasetDialogNoDatasetLoaded => 'Geen dataset geladen.';

  @override
  String get datasetDialogSelectZipFile => 'Selecteer uw Dataset ZIP-bestand';

  @override
  String get datasetDialogChooseFile => 'Kies een bestand';

  @override
  String get datasetDialogSupportedFormats => 'Ondersteunde Dataset formaten:';

  @override
  String get datasetDialogSupportedFormatsList1 => 'COCO, YOLO, VOC, Datumaro,';

  @override
  String get datasetDialogSupportedFormatsList2 =>
      'LabelMe, CVAT, of alleen media (.zip)';

  @override
  String get dialogImageDetailsTitle => 'Bestandsdetails';

  @override
  String get datasetDialogImportFailedTitle => 'Import Mislukt';

  @override
  String get datasetDialogImportFailedMessage =>
      'Het ZIP-bestand kon niet worden verwerkt. Het is mogelijk beschadigd, onvolledig of geen geldig dataset-archief.';

  @override
  String get datasetDialogImportFailedTips =>
      'Probeer je dataset opnieuw te exporteren of te zippen.\nZorg ervoor dat het in COCO-, YOLO-, VOC- of ondersteund formaat is.\n\nFout: ';

  @override
  String get datasetDialogNoProjectTypeTitle => 'Geen Projecttype Geselecteerd';

  @override
  String get datasetDialogNoProjectTypeMessage =>
      'Selecteer een Projecttype op basis van de gedetecteerde annotatietypen in je dataset.';

  @override
  String get datasetDialogNoProjectTypeTips =>
      'Controleer je datasetformaat en zorg ervoor dat annotaties een ondersteunde structuur volgen zoals COCO, YOLO, VOC of Datumaro.';

  @override
  String get datasetDialogProcessingDatasetTitle => 'Dataset Verwerken';

  @override
  String get datasetDialogProcessingDatasetMessage =>
      'We zijn momenteel bezig met het uitpakken van je ZIP-archief, het analyseren van de inhoud en het detecteren van het datasetformaat en annotatietype. Dit kan enkele seconden tot enkele minuten duren, afhankelijk van de grootte en structuur van de dataset. Sluit dit venster niet en navigeer niet weg tijdens het proces.';

  @override
  String get datasetDialogProcessingDatasetTips =>
      'Grote archieven met veel afbeeldingen of annotatiebestanden kunnen langer duren om te verwerken.';

  @override
  String get datasetDialogCreatingProjectTitle => 'Project Aanmaken';

  @override
  String get datasetDialogCreatingProjectMessage =>
      'We zijn bezig met het opzetten van je project, het initialiseren van de metadata en het opslaan van alle configuraties. Dit omvat het toewijzen van labels, het aanmaken van datasets en het koppelen van bijbehorende mediabestanden. Wacht even en vermijd het sluiten van dit venster totdat het proces is voltooid.';

  @override
  String get datasetDialogCreatingProjectTips =>
      'Projecten met veel labels of mediabestanden kunnen iets langer duren.';

  @override
  String get datasetDialogAnalyzingDatasetTitle => 'Dataset Analyseren';

  @override
  String get datasetDialogAnalyzingDatasetMessage =>
      'We zijn momenteel bezig met het analyseren van je dataset-archief. Dit omvat het uitpakken van bestanden, het detecteren van de datasetstructuur, het identificeren van annotatieformaten en het verzamelen van media- en labelinformatie. Wacht tot het proces is voltooid. Het sluiten van het venster of wegnavigeren kan de operatie onderbreken.';

  @override
  String get datasetDialogAnalyzingDatasetTips =>
      'Grote datasets met veel bestanden of complexe annotaties kunnen extra tijd kosten.';

  @override
  String get datasetDialogFilePickErrorTitle => 'Bestandsselectiefout';

  @override
  String get datasetDialogFilePickErrorMessage =>
      'Kon het bestand niet selecteren. Probeer het opnieuw.';

  @override
  String get datasetDialogGenericErrorTips =>
      'Controleer je bestand en probeer het opnieuw. Als het probleem aanhoudt, neem contact op met ondersteuning.';

  @override
  String get thumbnailGenerationTitle => 'Fout';

  @override
  String get thumbnailGenerationFailed => 'Kon miniatuur niet genereren';

  @override
  String get thumbnailGenerationTryAgainLater => 'Probeer het later opnieuw';

  @override
  String get thumbnailGenerationInProgress => 'Miniatuur genereren...';

  @override
  String get menuImageAnnotate => 'Annoteren';

  @override
  String get menuImageDetails => 'Details';

  @override
  String get menuImageDuplicate => 'Dupliceren';

  @override
  String get menuImageSetAsIcon => 'Als Icoon';

  @override
  String get menuImageDelete => 'Verwijderen';

  @override
  String get noLabelsTitle => 'Je hebt geen Labels in het Project';

  @override
  String get noLabelsExplain1 =>
      'Je kunt niet annoteren zonder labels omdat labels betekenis geven aan wat je markeert';

  @override
  String get noLabelsExplain2 =>
      'Je kunt handmatig labels toevoegen of ze importeren uit een JSON-bestand.';

  @override
  String get noLabelsExplain3 =>
      'Een annotatie zonder label is slechts een lege doos.';

  @override
  String get noLabelsExplain4 =>
      'Labels definiëren de categorieën of klassen die je annoteert in je dataset.';

  @override
  String get noLabelsExplain5 =>
      'Of je nu objecten in afbeeldingen tagt, classificeert of regio\'s segmenteert,';

  @override
  String get noLabelsExplain6 =>
      'labels zijn essentieel voor het duidelijk en consistent organiseren van je annotaties.';

  @override
  String get importLabelsPreviewTitle => 'Labelimport Voorbeeld';

  @override
  String get importLabelsFailedTitle => 'Labelimport Mislukt';

  @override
  String get importLabelsNoLabelsTitle => 'Geen labels gevonden in dit project';

  @override
  String get importLabelsJsonParseError => 'JSON-parsing mislukt.\n';

  @override
  String get importLabelsJsonParseTips =>
      'Zorg ervoor dat het bestand geldige JSON is. Je kunt het valideren op https://jsonlint.com/';

  @override
  String importLabelsJsonNotList(Object type) {
    return 'Een lijst van labels (array) werd verwacht, maar kreeg: $type.';
  }

  @override
  String get importLabelsJsonNotListTips =>
      'Je JSON-bestand moet beginnen met [ en meerdere labelobjecten bevatten. Elk label moet naam-, kleur- en labelVolgorde-velden bevatten.';

  @override
  String importLabelsJsonItemNotMap(Object type) {
    return 'Een van de items in de lijst is geen geldig object: $type';
  }

  @override
  String get importLabelsJsonItemNotMapTips =>
      'Elk item in de lijst moet een geldig object zijn met velden: naam, kleur en labelVolgorde.';

  @override
  String get importLabelsJsonLabelParseError =>
      'Kon een van de labels niet parsen.\n';

  @override
  String get importLabelsJsonLabelParseTips =>
      'Controleer of elk label de vereiste velden heeft zoals naam en kleur, en of de waarden de juiste types zijn.';

  @override
  String get importLabelsUnexpectedError =>
      'Er is een onverwachte fout opgetreden tijdens het importeren van het JSON-bestand.\n';

  @override
  String get importLabelsUnexpectedErrorTip =>
      'Zorg ervoor dat je bestand leesbaar is en correct geformatteerd.';

  @override
  String get importLabelsDatabaseError => 'Kon labels niet opslaan in database';

  @override
  String get importLabelsDatabaseErrorTips =>
      'Controleer je databaseverbinding en probeer het opnieuw. Als het probleem aanhoudt, neem contact op met ondersteuning.';

  @override
  String get importLabelsNameMissingOrEmpty =>
      'Een van de labels heeft geen geldige naam.';

  @override
  String get importLabelsNameMissingOrEmptyTips =>
      'Zorg ervoor dat elk label in de JSON een niet-leeg \'naam\'-veld bevat.';

  @override
  String get menuSortAZ => 'A-Z';

  @override
  String get menuSortZA => 'Z-A';

  @override
  String get menuSortProjectType => 'Projecttype';

  @override
  String get uploadInProgressTitle => 'Upload Bezig';

  @override
  String get uploadInProgressMessage =>
      'Je hebt een actieve upload bezig. Als je nu weggaat, wordt de upload geannuleerd en moet je opnieuw beginnen.\n\nWil je toch weggaan?';

  @override
  String get uploadInProgressStay => 'Blijven';

  @override
  String get uploadInProgressLeave => 'Weggaan';

  @override
  String get fileNotFound => 'Bestand niet gevonden of toegang geweigerd';

  @override
  String get labelEditSave => 'Opslaan';

  @override
  String get labelEditEdit => 'Bewerken';

  @override
  String get labelEditMoveUp => 'Omhoog';

  @override
  String get labelEditMoveDown => 'Omlaag';

  @override
  String get labelEditDefault => 'Default';

  @override
  String get labelEditUndefault => 'Undefault';

  @override
  String get labelEditDelete => 'Verwijderen';

  @override
  String get labelExportLabels => 'Labels Exporteren';

  @override
  String get labelSaveDialogTitle => 'Labels opslaan in JSON-bestand';

  @override
  String get labelSaveDefaultFilename => 'labels.json';

  @override
  String labelDeleteError(Object error) {
    return 'Kon label niet verwijderen: $error';
  }

  @override
  String get labelDeleteErrorTips =>
      'Zorg ervoor dat het label nog bestaat of niet elders wordt gebruikt.';

  @override
  String get datasetStepUploadZip =>
      'Upload een .ZIP bestand met COCO, YOLO, VOC, LabelMe, CVAT, Datumaro of alleen-media formaat';

  @override
  String get datasetStepExtractingZip => 'ZIP uitpakken in lokale opslag ...';

  @override
  String datasetStepExtractedPath(Object path) {
    return 'Dataset uitgepakt in: $path';
  }

  @override
  String datasetStepDetectedTaskType(Object format) {
    return 'Gedetecteerd taaktype: $format';
  }

  @override
  String get datasetStepSelectProjectType => 'Selecteer projecttype';

  @override
  String get datasetStepProgressSelection => 'Dataset Selectie';

  @override
  String get datasetStepProgressExtract => 'ZIP Uitpakken';

  @override
  String get datasetStepProgressOverview => 'Dataset Overzicht';

  @override
  String get datasetStepProgressTaskConfirmation => 'Taakbevestiging';

  @override
  String get datasetStepProgressProjectCreation => 'Project Aanmaken';

  @override
  String get projectTypeDetectionBoundingBox => 'Detectie met begrenzingsvak';

  @override
  String get projectTypeDetectionOriented => 'Georiënteerde detectie';

  @override
  String get projectTypeBinaryClassification => 'Binaire Classificatie';

  @override
  String get projectTypeMultiClassClassification => 'Multi-class Classificatie';

  @override
  String get projectTypeMultiLabelClassification => 'Multi-label Classificatie';

  @override
  String get projectTypeInstanceSegmentation => 'Instantie Segmentatie';

  @override
  String get projectTypeSemanticSegmentation => 'Semantische Segmentatie';

  @override
  String get datasetStepChooseProjectType =>
      'Kies je Projecttype op basis van gedetecteerde annotaties';

  @override
  String get datasetStepAllowProjectTypeChange =>
      'Projecttypewijziging Toestaan';

  @override
  String get projectTypeBinaryClassificationDescription =>
      'Wijs één van twee mogelijke labels toe aan elke invoer (bijv. spam of geen spam, positief of negatief).';

  @override
  String get projectTypeMultiClassClassificationDescription =>
      'Wijs precies één label toe uit een set van wederzijds uitsluitende klassen (bijv. kat, hond of vogel).';

  @override
  String get projectTypeMultiLabelClassificationDescription =>
      'Wijs één of meer labels toe uit een set van klassen — meerdere labels kunnen tegelijkertijd van toepassing zijn (bijv. een afbeelding getagd als zowel \"kat\" als \"hond\")';

  @override
  String get projectTypeDetectionBoundingBoxDescription =>
      'Teken een rechthoek rond een object in een afbeelding.';

  @override
  String get projectTypeDetectionOrientedDescription =>
      'Teken en omsluit een object binnen een minimale rechthoek.';

  @override
  String get projectTypeInstanceSegmentationDescription =>
      'Detecteer en onderscheid elk individueel object op basis van zijn unieke kenmerken.';

  @override
  String get projectTypeSemanticSegmentationDescription =>
      'Detecteer en classificeer alle vergelijkbare objecten als één entiteit.';
}
