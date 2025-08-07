// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get buttonKeep => 'Behalten';

  @override
  String get buttonSave => 'Speichern';

  @override
  String get buttonHelp => 'Hilfe';

  @override
  String get buttonEdit => 'Bearbeiten';

  @override
  String get buttonNext => 'Weiter';

  @override
  String get buttonBack => 'Zurück';

  @override
  String get buttonApply => 'Anwenden';

  @override
  String get buttonClose => 'Schließen';

  @override
  String get buttonImport => 'Importieren';

  @override
  String get buttonCancel => 'Abbrechen';

  @override
  String get buttonFinish => 'Fertigstellen';

  @override
  String get buttonDelete => 'Löschen';

  @override
  String get buttonDuplicate => 'Duplizieren';

  @override
  String get buttonConfirm => 'Bestätigen';

  @override
  String get buttonDiscard => 'Verwerfen';

  @override
  String get buttonFeedbackShort => 'Fdbck';

  @override
  String get buttonImportLabels => 'Labels importieren';

  @override
  String get buttonExportLabels => 'Labels exportieren';

  @override
  String get buttonNextConfirmTask => 'Weiter: Aufgabe bestätigen';

  @override
  String get buttonCreateProject => 'Projekt erstellen';

  @override
  String get aboutTitle => 'Über Annot@It';

  @override
  String get aboutDescription =>
      'Annot@It ist eine Annotationsanwendung, die den Annotationsprozess für Computer-Vision-Projekte vereinfacht. Ob Sie an Bildklassifizierung, Objekterkennung, Segmentierung oder anderen Vision-Aufgaben arbeiten, Annot@It bietet die Flexibilität und Präzision, die für hochwertige Datenkennzeichnung erforderlich ist.';

  @override
  String get aboutFeaturesTitle => 'Hauptfunktionen:';

  @override
  String get aboutFeatures =>
      '- Mehrere Projekttypen: Erstellen und verwalten Sie Projekte für verschiedene Computer-Vision-Aufgaben.\n- Daten-Upload & -Verwaltung: Laden Sie Ihre Datensätze einfach hoch und organisieren Sie sie für eine nahtlose Annotation.\n- Erweiterte Annotationswerkzeuge: Verwenden Sie Begrenzungsrahmen, Polygone, Schlüsselpunkte und Segmentierungsmasken.\n- Export & Integration: Exportieren Sie gekennzeichnete Daten in verschiedenen Formaten, die mit KI/ML-Frameworks kompatibel sind.';

  @override
  String get aboutCallToAction =>
      'Beginnen Sie noch heute mit Ihrer Annotationsreise und erstellen Sie hochwertige Datensätze für Ihre Computer-Vision-Modelle!';

  @override
  String get accountUser => 'Benutzer';

  @override
  String get accountProfile => 'Profil';

  @override
  String get accountStorage => 'Speicher';

  @override
  String get accountDeviceStorage => 'Gerätespeicher';

  @override
  String get accountSettings => 'Einstellungen';

  @override
  String get accountApplicationSettings => 'Anwendungseinstellungen';

  @override
  String get accountLoadingMessage => 'Benutzerdaten werden geladen...';

  @override
  String get accountErrorLoadingUser => 'Could not  load user data';

  @override
  String get accountRetry => 'Retry';

  @override
  String get userProfileName => 'Kapitän Annotator';

  @override
  String get userProfileFeedbackButton => 'Feedback';

  @override
  String get userProfileEditProfileButton => 'Profil bearbeiten';

  @override
  String get userProfileProjects => 'Projekte';

  @override
  String get userProfileLabels => 'Labels';

  @override
  String get userProfileMedia => 'Medien';

  @override
  String get userProfileOverview => 'Übersicht';

  @override
  String get userProfileAnnotations => 'Annotationen';

  @override
  String get settingsGeneralTitle => 'Allgemeine Einstellungen';

  @override
  String get settingsProjectCreationTitle => 'Projekterstellung';

  @override
  String get settingsProjectCreationConfirmNoLabels =>
      'Immer nachfragen, wenn ein Projekt ohne Labels erstellt wird';

  @override
  String get settingsProjectCreationConfirmNoLabelsNote =>
      'Sie werden gewarnt, wenn Sie versuchen, ein Projekt ohne definierte Labels zu erstellen.';

  @override
  String get settingsLabelsCreationDeletionTitle =>
      'Label-Erstellung / -Löschung';

  @override
  String get settingsLabelsDeletionWithAnnotations =>
      'Annotationen löschen, wenn Label entfernt wird';

  @override
  String get settingsLabelsDeletionWithAnnotationsNote =>
      'Wenn aktiviert, werden beim Löschen eines Labels automatisch alle diesem Label zugewiesenen Annotationen in allen Medienelementen entfernt.';

  @override
  String get settingsLabelsSetDefaultLabel =>
      'Erstes Label als Standard festlegen';

  @override
  String get settingsLabelsSetDefaultLabelNote =>
      'Wenn aktiviert, wird das erste Label, das Sie in einem Projekt erstellen, automatisch als Standardlabel markiert. Sie können den Standard später jederzeit ändern.';

  @override
  String get settingsDatasetViewTitle => 'Datensatz-Ansicht';

  @override
  String get settingsDatasetViewDuplicateWithAnnotations =>
      'Bild immer mit Annotationen duplizieren (kopieren)';

  @override
  String get settingsDatasetViewDuplicateWithAnnotationsNote =>
      'Beim Duplizieren werden Annotationen eingeschlossen, es sei denn, Sie ändern die Einstellungen';

  @override
  String get settingsDatasetViewDeleteFromOS =>
      'Beim Löschen eines Bildes aus dem Datensatz immer auch aus dem Betriebssystem / Dateisystem löschen';

  @override
  String get settingsDatasetViewDeleteFromOSNote =>
      'Löscht die Datei auch von der Festplatte, nicht nur aus dem Datensatz';

  @override
  String get settingsAnnotationTitle => 'Annotations-Einstellungen';

  @override
  String get settingsAnnotationOpacity => 'Annotations-Transparenz';

  @override
  String get settingsAnnotationAutoSave =>
      'Annotation immer speichern oder übermitteln, wenn zum nächsten Bild gewechselt wird';

  @override
  String get settingsThemeTitle => 'Themenauswahl';

  @override
  String get settingsLanguageTitle => 'Land / Sprache';

  @override
  String get colorPickerTitle => 'Farbe auswählen';

  @override
  String get colorPickerBasicColors => 'Grundfarben';

  @override
  String get loadingProjects => 'Projekte werden geladen...';

  @override
  String get importDataset => 'Datensatz importieren';

  @override
  String get uploadMedia => 'Medien hochladen';

  @override
  String get createProjectTitle => 'Neues Projekt erstellen';

  @override
  String get createProjectStepOneSubtitle =>
      'Bitte geben Sie Ihren neuen Projektnamen ein und wählen Sie den Projekttyp';

  @override
  String get createProjectStepTwoSubtitle =>
      'Bitte erstellen Sie Labels für ein neues Projekt';

  @override
  String get emptyProjectTitle => 'Starten Sie Ihr erstes Projekt';

  @override
  String get emptyProjectDescription =>
      'Erstellen Sie ein Projekt, um Datensätze zu organisieren, Medien zu annotieren und KI auf Ihre Vision-Aufgaben anzuwenden — alles in einem optimierten Arbeitsbereich, der Ihre Computer-Vision-Pipeline beschleunigt.';

  @override
  String get emptyProjectCreateNew => 'Neues Projekt erstellen';

  @override
  String get emptyProjectCreateNewShort => 'Neues Projekt';

  @override
  String get emptyProjectImportDataset =>
      'Projekt aus Datensatz-Import erstellen';

  @override
  String get emptyProjectImportDatasetShort => 'Datensatz importieren';

  @override
  String get dialogBack => '<- Zurück';

  @override
  String get dialogNext => 'Weiter ->';

  @override
  String get rename => 'Umbenennen';

  @override
  String get delete => 'Löschen';

  @override
  String get setAsDefault => 'Als Standard festlegen';

  @override
  String get labelDefault => 'Standard';

  @override
  String get labelUndefault => 'Standard aufheben';

  @override
  String paginationPageFromTotal(int current, int total) {
    return 'Seite $current von $total';
  }

  @override
  String get taskTypeRequiredTitle => 'Aufgabentyp erforderlich';

  @override
  String taskTypeRequiredMessage(Object tab) {
    return 'Sie müssen einen Aufgabentyp auswählen, bevor Sie fortfahren können. Der aktuelle Tab \'$tab\' hat keinen Aufgabentyp ausgewählt. Jedes Projekt muss mit einer Aufgabe (z.B. Objekterkennung, Klassifizierung oder Segmentierung) verknüpft sein, damit das System weiß, wie Ihre Daten zu verarbeiten sind.';
  }

  @override
  String taskTypeRequiredTips(Object tab) {
    return 'Klicken Sie auf eine der verfügbaren Aufgabentyp-Optionen unter dem Tab \'$tab\'. Wenn Sie sich nicht sicher sind, welche Aufgabe Sie wählen sollen, fahren Sie mit der Maus über das Info-Symbol neben jedem Typ, um eine kurze Beschreibung zu sehen.';
  }

  @override
  String get menuProjects => 'Projekte';

  @override
  String get menuAccount => 'Konto';

  @override
  String get menuLearn => 'Lernen';

  @override
  String get menuAbout => 'Über';

  @override
  String get menuCreateNewProject => 'Neues Projekt erstellen';

  @override
  String get menuCreateFromDataset => 'Aus Datensatz erstellen';

  @override
  String get menuImportDataset => 'Projekt aus Datensatz-Import erstellen';

  @override
  String get menuSortLastUpdated => 'Zuletzt aktualisiert';

  @override
  String get menuSortNewestOldest => 'Neueste-Älteste';

  @override
  String get menuSortOldestNewest => 'Älteste-Neueste';

  @override
  String get menuSortType => 'Projekttyp';

  @override
  String get menuSortAz => 'A-Z';

  @override
  String get menuSortZa => 'Z-A';

  @override
  String get projectNameLabel => 'Projektname';

  @override
  String get tabDetection => 'Erkennung';

  @override
  String get tabClassification => 'Klassifizierung';

  @override
  String get tabSegmentation => 'Segmentierung';

  @override
  String get labelRequiredTitle => 'Mindestens ein Label erforderlich';

  @override
  String get labelRequiredMessage =>
      'Sie müssen mindestens ein Label erstellen, um fortzufahren. Labels sind wesentlich für die Definition der Annotationskategorien, die während der Datensatzvorbereitung verwendet werden.';

  @override
  String get labelRequiredTips =>
      'Tipp: Klicken Sie auf die rote Schaltfläche mit der Bezeichnung Label erstellen, nachdem Sie einen Labelnamen eingegeben haben, um Ihr erstes Label hinzuzufügen.';

  @override
  String get createLabelButton => 'Label erstellen';

  @override
  String get labelNameHint => 'Geben Sie hier einen neuen Labelnamen ein';

  @override
  String get createdLabelsTitle => 'Erstellte Labels';

  @override
  String get labelEmptyTitle => 'Labelname darf nicht leer sein!';

  @override
  String get labelEmptyMessage =>
      'Bitte geben Sie einen Labelnamen ein. Labels helfen, die Objekte oder Kategorien in Ihrem Projekt zu identifizieren. Es wird empfohlen, kurze, klare und beschreibende Namen zu verwenden, wie \"Auto\", \"Person\" oder \"Baum\". Vermeiden Sie Sonderzeichen oder Leerzeichen.';

  @override
  String get labelEmptyTips =>
      'Tipps zur Labelbenennung:\n• Verwenden Sie kurze und beschreibende Namen\n• Halten Sie sich an Buchstaben, Ziffern, Unterstriche (z.B. katze, verkehrsschild, hintergrund)\n• Vermeiden Sie Leerzeichen und Symbole (z.B. Person 1 → person_1)';

  @override
  String get labelDuplicateTitle => 'Doppelter Labelname';

  @override
  String labelDuplicateMessage(Object label) {
    return 'Das Label \'$label\' existiert bereits in diesem Projekt. Jedes Label muss einen eindeutigen Namen haben, um Verwirrung während der Annotation und des Trainings zu vermeiden.';
  }

  @override
  String get labelDuplicateTips =>
      'Warum eindeutige Labels?\n• Die Wiederverwendung desselben Namens kann Probleme beim Datensatzexport und Modelltraining verursachen.\n• Eindeutige Labelnamen helfen, klare, strukturierte Annotationen zu erhalten.\n\nTipp: Versuchen Sie, eine Variation oder Nummer hinzuzufügen, um zu unterscheiden (z.B. \'Auto\', \'Auto_2\').';

  @override
  String get binaryLimitTitle => 'Binäre Klassifizierungsbegrenzung';

  @override
  String get binaryLimitMessage =>
      'Sie können nicht mehr als zwei Labels für ein Binäres Klassifizierungsprojekt erstellen.\n\nBinäre Klassifizierung ist darauf ausgelegt, zwischen genau zwei Klassen zu unterscheiden, wie \'Ja\' vs \'Nein\' oder \'Spam\' vs \'Kein Spam\'.';

  @override
  String get binaryLimitTips =>
      'Benötigen Sie mehr als zwei Labels?\nErwägen Sie, Ihren Projekttyp auf Multi-Klassen-Klassifizierung oder eine andere geeignete Aufgabe umzustellen, um drei oder mehr Kategorien zu unterstützen.';

  @override
  String get noteBinaryClassification =>
      'Dieser Projekttyp erlaubt genau 2 Labels. Binäre Klassifizierung wird verwendet, wenn Ihr Modell zwischen zwei möglichen Klassen unterscheiden muss, wie \"Ja\" vs \"Nein\" oder \"Hund\" vs \"Nicht Hund\". Bitte erstellen Sie nur zwei unterschiedliche Labels.';

  @override
  String get noteMultiClassClassification =>
      'Dieser Projekttyp unterstützt mehrere Labels. Multi-Klassen-Klassifizierung ist geeignet, wenn Ihr Modell aus drei oder mehr Kategorien wählen muss, wie \"Katze\", \"Hund\", \"Kaninchen\". Sie können so viele Labels hinzufügen, wie benötigt.';

  @override
  String get noteDetectionOrSegmentation =>
      'Dieser Projekttyp unterstützt mehrere Labels. Für Objekterkennung oder Segmentierung repräsentiert jedes Label typischerweise eine andere Objektklasse (z.B. \"Auto\", \"Fußgänger\", \"Fahrrad\"). Sie können so viele Labels erstellen, wie für Ihren Datensatz erforderlich.';

  @override
  String get noteDefault =>
      'Sie können ein oder mehrere Labels abhängig von Ihrem Projekttyp erstellen. Jedes Label hilft, eine Kategorie zu definieren, die Ihr Modell erkennen lernen wird. Bitte beachten Sie die Dokumentation für bewährte Praktiken.';

  @override
  String get discardDatasetImportTitle => 'Datensatz-Import verwerfen?';

  @override
  String get discardDatasetImportMessage =>
      'Sie haben bereits einen Datensatz extrahiert. Wenn Sie jetzt abbrechen, werden die extrahierten Dateien und erkannten Datensatzdetails gelöscht. Sind Sie sicher, dass Sie fortfahren möchten?';

  @override
  String get projectTypeHelpTitle => 'Hilfe zur Projekttyp-Auswahl';

  @override
  String get projectTypeWhyDisabledTitle =>
      'Warum sind einige Projekttypen deaktiviert?';

  @override
  String get projectTypeWhyDisabledBody =>
      'Wenn Sie einen Datensatz importieren, analysiert das System die bereitgestellten Annotationen und versucht, den am besten geeigneten Projekttyp für Sie automatisch zu erkennen.\n\nZum Beispiel, wenn Ihr Datensatz Begrenzungsrahmen-Annotationen enthält, wird der vorgeschlagene Projekttyp \"Erkennung\" sein. Wenn er Masken enthält, wird \"Segmentierung\" vorgeschlagen, und so weiter.\n\nUm Ihre Daten zu schützen, sind standardmäßig nur kompatible Projekttypen aktiviert.';

  @override
  String get projectTypeAllowChangeTitle =>
      'Was passiert, wenn ich die Projekttyp-Änderung aktiviere?';

  @override
  String get projectTypeAllowChangeBody =>
      'Wenn Sie \"Projekttyp-Änderung erlauben\" aktivieren, können Sie manuell JEDEN Projekttyp auswählen, auch wenn er nicht mit den erkannten Annotationen übereinstimmt.\n\n⚠️ WARNUNG: Alle vorhandenen Annotationen aus dem Import werden beim Wechsel zu einem inkompatiblen Projekttyp gelöscht.\nSie müssen alle Medienelemente neu annotieren oder einen für den neu ausgewählten Projekttyp geeigneten Datensatz importieren.';

  @override
  String get projectTypeWhenUseTitle =>
      'Wann sollte ich diese Option verwenden?';

  @override
  String get projectTypeWhenUseBody =>
      'Sie sollten diese Option nur aktivieren, wenn:\n\n- Sie versehentlich den falschen Datensatz importiert haben.\n- Sie ein neues Annotationsprojekt mit einem anderen Typ starten möchten.\n- Ihre Datensatzstruktur sich nach dem Import geändert hat.\n\nWenn Sie unsicher sind, empfehlen wir dringend, die Standardauswahl beizubehalten, um Datenverlust zu vermeiden.';

  @override
  String get allLabels => 'Alle Labels';

  @override
  String get setAsProjectIcon => 'Als Projektsymbol festlegen';

  @override
  String setAsProjectIconConfirm(Object filePath) {
    return 'Möchten Sie \'$filePath\' als Symbol für dieses Projekt verwenden?\n\nDies ersetzt jedes zuvor festgelegte Symbol.';
  }

  @override
  String get removeFilesFromDatasetInProgress => 'Dateien werden gelöscht...';

  @override
  String get removeFilesFromDataset => 'Dateien aus Datensatz entfernen?';

  @override
  String removeFilesFromDatasetConfirm(Object amount) {
    return 'Sind Sie sicher, dass Sie die folgenden Dateien (\'$amount\') löschen möchten?\n\nAlle entsprechenden Annotationen werden ebenfalls entfernt.';
  }

  @override
  String get removeFilesFailedTitle => 'Löschen fehlgeschlagen';

  @override
  String get removeFilesFailedMessage =>
      'Einige Dateien konnten nicht gelöscht werden';

  @override
  String get removeFilesFailedTips =>
      'Bitte überprüfen Sie die Dateiberechtigungen und versuchen Sie es erneut';

  @override
  String get duplicateImage => 'Bild duplizieren';

  @override
  String get duplicateWithAnnotations => 'Bild mit Annotationen duplizieren';

  @override
  String get duplicateWithAnnotationsHint =>
      'Eine Kopie des Bildes wird zusammen mit allen Annotationsdaten erstellt.';

  @override
  String get duplicateImageOnly => 'Nur Bild duplizieren';

  @override
  String get duplicateImageOnlyHint =>
      'Nur das Bild wird kopiert, ohne Annotationen.';

  @override
  String get saveDuplicateChoiceAsDefault =>
      'Diese Antwort als Standardantwort speichern und nicht mehr fragen\n(Sie können dies in Konto -> Anwendungseinstellungen -> Datensatznavigation ändern)';

  @override
  String get editProjectTitle => 'Projektnamen bearbeiten';

  @override
  String get editProjectDescription =>
      'Bitte wählen Sie einen klaren, beschreibenden Projektnamen (3 - 86 Zeichen). Es wird empfohlen, Sonderzeichen zu vermeiden.';

  @override
  String get deleteProjectTitle => 'Projekt löschen';

  @override
  String get deleteProjectInProgress => 'Projekt wird gelöscht...';

  @override
  String get deleteProjectOptionDeleteFromDisk =>
      'Auch alle Dateien von der Festplatte löschen';

  @override
  String get deleteProjectOptionDontAskAgain => 'Nicht mehr nachfragen';

  @override
  String deleteProjectConfirm(Object projectName) {
    return 'Sind Sie sicher, dass Sie das Projekt \"$projectName\" löschen möchten?';
  }

  @override
  String deleteProjectInfoLine(Object creationDate, Object labelCount) {
    return 'Projekt wurde erstellt am $creationDate\nAnzahl der Labels: $labelCount';
  }

  @override
  String get deleteDatasetTitle => 'Datensatz löschen';

  @override
  String get deleteDatasetInProgress =>
      'Datensatz wird gelöscht... Bitte warten.';

  @override
  String deleteDatasetConfirm(Object datasetName) {
    return 'Sind Sie sicher, dass Sie \"$datasetName\" löschen möchten?';
  }

  @override
  String deleteDatasetInfoLine(
    Object creationDate,
    Object mediaCount,
    Object annotationCount,
  ) {
    return 'Dieser Datensatz wurde am $creationDate erstellt und enthält $mediaCount Medienelemente und $annotationCount Annotationen.';
  }

  @override
  String get editDatasetTitle => 'Datensatz umbenennen';

  @override
  String get editDatasetDescription =>
      'Geben Sie einen neuen Namen für diesen Datensatz ein:';

  @override
  String get noMediaDialogUploadPrompt =>
      'Sie müssen Bilder oder Videos hochladen';

  @override
  String get noMediaDialogUploadPromptShort => 'Medien hochladen';

  @override
  String get noMediaDialogSupportedImageTypesTitle => 'Unterstützte Bildtypen:';

  @override
  String get noMediaDialogSupportedImageTypesList =>
      'jpg, jpeg, png, bmp, jfif, webp';

  @override
  String get noMediaDialogSupportedVideoFormatsLink =>
      'Klicken Sie hier, um zu sehen, welche Videoformate auf Ihrer Plattform unterstützt werden';

  @override
  String get noMediaDialogSupportedVideoFormatsTitle =>
      'Unterstützte Videoformate';

  @override
  String get noMediaDialogSupportedVideoFormatsList =>
      'Häufig unterstützte Formate:\n\n- MP4: Android, iOS, Web, Desktop\n- MOV: Android, iOS, macOS\n- M4V: Android, iOS, macOS\n- WEBM: Android, Web (browserabhängig)\n- MKV: Android (teilweise), Windows\n- AVI: Nur Android/Windows (teilweise)';

  @override
  String get noMediaDialogSupportedVideoFormatsWarning =>
      'Die Unterstützung kann je nach Plattform und Videocodec variieren.\nEinige Formate funktionieren möglicherweise nicht in Browsern oder auf iOS.';

  @override
  String get annotatorTopToolbarBackTooltip => 'Zurück zum Projekt';

  @override
  String get annotatorTopToolbarSelectDefaultLabel => 'Standardlabel';

  @override
  String get toolbarNavigation => 'Navigation';

  @override
  String get toolbarBbox => 'Begrenzungsrahmen zeichnen';

  @override
  String get toolbarPolygon => 'Polygon zeichnen';

  @override
  String get toolbarSAM => 'Segment Anything Model';

  @override
  String get toolbarResetZoom => 'Zoom zurücksetzen';

  @override
  String get toolbarToggleGrid => 'Raster umschalten';

  @override
  String get toolbarAnnotationSettings => 'Annotationseinstellungen';

  @override
  String get toolbarToggleAnnotationNames => 'Annotationsnamen umschalten';

  @override
  String get toolbarRotateLeft => 'Nach links drehen (Demnächst verfügbar)';

  @override
  String get toolbarRotateRight => 'Nach rechts drehen (Demnächst verfügbar)';

  @override
  String get toolbarHelp => 'Hilfe';

  @override
  String get dialogOpacityTitle => 'Annotations-Fülldeckkraft';

  @override
  String get dialogHelpTitle => 'Hilfe zur Annotator-Werkzeugleiste';

  @override
  String get dialogHelpContent =>
      '• Navigation – Verwenden Sie dies, um auf der Leinwand auszuwählen und sich zu bewegen.\n• Begrenzungsrahmen – (Sichtbar in Erkennungsprojekten) Zeichnen Sie rechteckige Begrenzungsrahmen.\n• Zoom zurücksetzen – Setzt die Zoomstufe zurück, um das Bild auf dem Bildschirm anzupassen.\n• Raster umschalten – Zeigen oder verbergen Sie das Datensatz-Miniaturansichtsraster.\n• Einstellungen – Passen Sie die Fülldeckkraft von Annotationen, den Annotationsrahmen und die Größe der Ecken an.\n• Annotationsnamen umschalten – Zeigen oder verbergen Sie Textlabels auf Annotationen.';

  @override
  String get dialogHelpTips =>
      'Tipp: Verwenden Sie den Navigationsmodus, um Annotationen auszuwählen und zu bearbeiten.\nWeitere Shortcuts und Funktionen kommen bald!';

  @override
  String get dialogOpacityExplanation =>
      'Passen Sie die Deckkraftstufe an, um den Inhalt mehr oder weniger transparent zu machen.';

  @override
  String get deleteAnnotationTitle => 'Annotation löschen';

  @override
  String get deleteAnnotationMessage =>
      'Sind Sie sicher, dass Sie löschen möchten';

  @override
  String get unnamedAnnotation => 'diese Annotation';

  @override
  String get accountStorage_importFolderTitle => 'Datensatz-Importordner';

  @override
  String get accountStorage_thumbnailsFolderTitle => 'Miniaturansichtenordner';

  @override
  String get accountStorage_exportFolderTitle => 'Datensatz-Exportordner';

  @override
  String get accountStorage_folderTooltip => 'Ordner auswählen';

  @override
  String get accountStorage_helpTitle => 'Speicherhilfe';

  @override
  String get accountStorage_helpMessage =>
      'Sie können den Ordner ändern, in dem importierte Datensätze, exportierte ZIP-Archive und Miniaturansichten gespeichert werden.\nTippen Sie auf das \"Ordner\"-Symbol neben dem Pfadfeld, um das Verzeichnis auszuwählen oder zu ändern.\n\nDieser Ordner wird als Standardspeicherort verwendet für:\n- Importierte Datensatzdateien (z.B. COCO, YOLO, VOC, Datumaro, etc.)\n- Exportierte Datensatz-Zip-Archive\n- Projekt-Miniaturansichten\n\nStellen Sie sicher, dass der ausgewählte Ordner beschreibbar ist und genügend Platz hat.\nAuf Android oder iOS müssen Sie möglicherweise Speicherberechtigungen gewähren.\nEmpfohlene Ordner variieren je nach Plattform — siehe unten plattformspezifische Tipps.';

  @override
  String get accountStorage_helpTips =>
      'Empfohlene Ordner nach Plattform:\n\nWindows:\n  C:\\Users\\<Sie>\\AppData\\Roaming\\AnnotateIt\\datasets\n\nLinux / Ubuntu:\n  /home/<Sie>/.annotateit/datasets\n\nmacOS:\n  /Users/<Sie>/Library/Application Support/AnnotateIt/datasets\n\nAndroid:\n  /storage/emulated/0/AnnotateIt/datasets\n\niOS:\n  <App-Sandbox-Pfad>/Documents/AnnotateIt/datasets\n';

  @override
  String get accountStorage_copySuccess => 'Pfad in die Zwischenablage kopiert';

  @override
  String get accountStorage_openError => 'Ordner existiert nicht:\n';

  @override
  String get accountStorage_pathEmpty => 'Pfad ist leer';

  @override
  String get accountStorage_openFailed =>
      'Ordner konnte nicht geöffnet werden:\n';

  @override
  String get changeProjectTypeTitle => 'Projekttyp ändern';

  @override
  String get changeProjectTypeMigrating => 'Projekttyp wird migriert...';

  @override
  String get changeProjectTypeStepOneSubtitle =>
      'Bitte wählen Sie einen neuen Projekttyp aus der Liste unten';

  @override
  String get changeProjectTypeStepTwoSubtitle =>
      'Bitte bestätigen Sie Ihre Auswahl';

  @override
  String get changeProjectTypeWarningTitle =>
      'Warnung: Sie sind dabei, den Projekttyp zu ändern.';

  @override
  String get changeProjectTypeConversionIntro =>
      'Alle vorhandenen Annotationen werden wie folgt konvertiert:';

  @override
  String get changeProjectTypeConversionDetails =>
      '- Begrenzungsrahmen (Erkennung) -> in rechteckige Polygone umgewandelt.\n- Polygone (Segmentierung) -> in eng anliegende Begrenzungsrahmen umgewandelt.\n\nHinweis: Diese Konvertierungen können die Präzision reduzieren, besonders beim Umwandeln von Polygonen in Rahmen, da detaillierte Forminformationen verloren gehen.\n\n- Erkennung / Segmentierung → Klassifizierung:\n  Bilder werden basierend auf dem häufigsten Label in den Annotationen klassifiziert:\n     -> Wenn ein Bild 5 Objekte mit dem Label \"Hund\" und 10 mit dem Label \"Katze\" hat, wird es als \"Katze\" klassifiziert.\n     -> Wenn die Anzahl gleich ist, wird das erste gefundene Label verwendet.\n\n- Klassifizierung -> Erkennung / Segmentierung:\n  Es werden keine Annotationen übertragen. Sie müssen alle Medienelemente manuell neu annotieren, da Klassifizierungsprojekte keine Daten auf Regionsebene enthalten.';

  @override
  String get changeProjectTypeErrorTitle => 'Migration fehlgeschlagen';

  @override
  String get changeProjectTypeErrorMessage =>
      'Beim Ändern des Projekttyps ist ein Fehler aufgetreten. Die Änderungen konnten nicht angewendet werden.';

  @override
  String get changeProjectTypeErrorTips =>
      'Bitte überprüfen Sie, ob das Projekt gültige Annotationen hat und versuchen Sie es erneut. Wenn das Problem weiterhin besteht, starten Sie die App neu oder kontaktieren Sie den Support.';

  @override
  String get exportProjectAsDataset => 'Projekt als Datensatz exportieren';

  @override
  String get projectHelpTitle => 'Wie Projekte funktionieren';

  @override
  String get projectHelpMessage =>
      'Projekte ermöglichen es Ihnen, Datensätze, Mediendateien und Annotationen an einem Ort zu organisieren. Sie können neue Projekte für verschiedene Aufgaben wie Erkennung, Klassifizierung oder Segmentierung erstellen.';

  @override
  String get projectHelpTips =>
      'Tipp: Sie können Datensätze im COCO-, YOLO-, VOC-, Labelme- und Datumaro-Format importieren, um automatisch ein Projekt zu erstellen.';

  @override
  String get datasetDialogTitle =>
      'Datensatz importieren, um Projekt zu erstellen';

  @override
  String get datasetDialogProcessing => 'Verarbeitung...';

  @override
  String datasetDialogProcessingProgress(Object percent) {
    return 'Verarbeitung... $percent%';
  }

  @override
  String get datasetDialogModeIsolate => 'Isolationsmodus aktiviert';

  @override
  String get datasetDialogModeNormal => 'Normaler Modus';

  @override
  String get datasetDialogNoDatasetLoaded => 'Kein Datensatz geladen.';

  @override
  String get datasetDialogSelectZipFile =>
      'Wählen Sie Ihre Datensatz-ZIP-Datei';

  @override
  String get datasetDialogChooseFile => 'Datei auswählen';

  @override
  String get datasetDialogSupportedFormats => 'Unterstützte Datensatzformate:';

  @override
  String get datasetDialogSupportedFormatsList1 => 'COCO, YOLO, VOC, Datumaro,';

  @override
  String get datasetDialogSupportedFormatsList2 =>
      'LabelMe, CVAT oder nur Medien (.zip)';

  @override
  String get dialogImageDetailsTitle => 'Dateidetails';

  @override
  String get datasetDialogImportFailedTitle => 'Import fehlgeschlagen';

  @override
  String get datasetDialogImportFailedMessage =>
      'Die ZIP-Datei konnte nicht verarbeitet werden. Sie könnte beschädigt, unvollständig oder kein gültiges Datensatzarchiv sein.';

  @override
  String get datasetDialogImportFailedTips =>
      'Versuchen Sie, Ihren Datensatz erneut zu exportieren oder zu zippen.\nStellen Sie sicher, dass er im COCO-, YOLO-, VOC- oder unterstützten Format vorliegt.\n\nFehler: ';

  @override
  String get datasetDialogNoProjectTypeTitle => 'Kein Projekttyp ausgewählt';

  @override
  String get datasetDialogNoProjectTypeMessage =>
      'Bitte wählen Sie einen Projekttyp basierend auf den erkannten Annotationstypen in Ihrem Datensatz.';

  @override
  String get datasetDialogNoProjectTypeTips =>
      'Überprüfen Sie Ihr Datensatzformat und stellen Sie sicher, dass Annotationen einer unterstützten Struktur wie COCO, YOLO, VOC oder Datumaro folgen.';

  @override
  String get datasetDialogProcessingDatasetTitle =>
      'Datensatz wird verarbeitet';

  @override
  String get datasetDialogProcessingDatasetMessage =>
      'Wir extrahieren derzeit Ihr ZIP-Archiv, analysieren seinen Inhalt und erkennen das Datensatzformat und den Annotationstyp. Dies kann je nach Größe und Struktur des Datensatzes einige Sekunden bis zu einigen Minuten dauern. Bitte schließen Sie dieses Fenster nicht und navigieren Sie während des Prozesses nicht weg.';

  @override
  String get datasetDialogProcessingDatasetTips =>
      'Große Archive mit vielen Bildern oder Annotationsdateien können länger zur Verarbeitung benötigen.';

  @override
  String get datasetDialogCreatingProjectTitle => 'Projekt wird erstellt';

  @override
  String get datasetDialogCreatingProjectMessage =>
      'Wir richten Ihr Projekt ein, initialisieren seine Metadaten und speichern alle Konfigurationen. Dies umfasst das Zuweisen von Labels, das Erstellen von Datensätzen und das Verknüpfen zugehöriger Mediendateien. Bitte warten Sie einen Moment und vermeiden Sie es, dieses Fenster zu schließen, bis der Prozess abgeschlossen ist.';

  @override
  String get datasetDialogCreatingProjectTips =>
      'Projekte mit vielen Labels oder Mediendateien könnten etwas länger dauern.';

  @override
  String get datasetDialogAnalyzingDatasetTitle => 'Datensatz wird analysiert';

  @override
  String get datasetDialogAnalyzingDatasetMessage =>
      'Wir analysieren derzeit Ihr Datensatzarchiv. Dies umfasst das Extrahieren von Dateien, das Erkennen der Datensatzstruktur, das Identifizieren von Annotationsformaten und das Sammeln von Medien- und Labelinformationen. Bitte warten Sie, bis der Prozess abgeschlossen ist. Das Schließen des Fensters oder Wegnavigieren kann den Vorgang unterbrechen.';

  @override
  String get datasetDialogAnalyzingDatasetTips =>
      'Große Datensätze mit vielen Dateien oder komplexen Annotationen können zusätzliche Zeit benötigen.';

  @override
  String get datasetDialogFilePickErrorTitle => 'Dateiauswahlfehler';

  @override
  String get datasetDialogFilePickErrorMessage =>
      'Datei konnte nicht ausgewählt werden. Bitte versuchen Sie es erneut.';

  @override
  String get datasetDialogGenericErrorTips =>
      'Bitte überprüfen Sie Ihre Datei und versuchen Sie es erneut. Wenn das Problem weiterhin besteht, kontaktieren Sie den Support.';

  @override
  String get thumbnailGenerationTitle => 'Fehler';

  @override
  String get thumbnailGenerationFailed =>
      'Miniaturansicht konnte nicht generiert werden';

  @override
  String get thumbnailGenerationTryAgainLater =>
      'Bitte versuchen Sie es später erneut';

  @override
  String get thumbnailGenerationInProgress =>
      'Miniaturansicht wird generiert...';

  @override
  String get menuImageAnnotate => 'Annotieren';

  @override
  String get menuImageDetails => 'Details';

  @override
  String get menuImageDuplicate => 'Duplizieren';

  @override
  String get menuImageSetAsIcon => 'Als Symbol';

  @override
  String get menuImageDelete => 'Löschen';

  @override
  String get noLabelsTitle => 'Sie haben keine Labels im Projekt';

  @override
  String get noLabelsExplain1 =>
      'Sie können nicht ohne Labels annotieren, da Labels dem, was Sie markieren, Bedeutung geben';

  @override
  String get noLabelsExplain2 =>
      'Sie können Labels manuell hinzufügen oder aus einer JSON-Datei importieren.';

  @override
  String get noLabelsExplain3 =>
      'Eine Annotation ohne Label ist nur eine leere Box.';

  @override
  String get noLabelsExplain4 =>
      'Labels definieren die Kategorien oder Klassen, die Sie in Ihrem Datensatz annotieren.';

  @override
  String get noLabelsExplain5 =>
      'Ob Sie Objekte in Bildern taggen, klassifizieren oder Regionen segmentieren,';

  @override
  String get noLabelsExplain6 =>
      'Labels sind wesentlich, um Ihre Annotationen klar und konsistent zu organisieren.';

  @override
  String get importLabelsPreviewTitle => 'Label-Import-Vorschau';

  @override
  String get importLabelsFailedTitle => 'Label-Import fehlgeschlagen';

  @override
  String get importLabelsNoLabelsTitle =>
      'Keine Labels in diesem Projekt gefunden';

  @override
  String get importLabelsJsonParseError => 'JSON-Parsing fehlgeschlagen.\n';

  @override
  String get importLabelsJsonParseTips =>
      'Stellen Sie sicher, dass die Datei gültiges JSON ist. Sie können es unter https://jsonlint.com/ validieren';

  @override
  String importLabelsJsonNotList(Object type) {
    return 'Eine Liste von Labels (Array) wurde erwartet, aber erhalten: $type.';
  }

  @override
  String get importLabelsJsonNotListTips =>
      'Ihre JSON-Datei muss mit [ beginnen und mehrere Label-Objekte enthalten. Jedes Label sollte die Felder name, color und labelOrder enthalten.';

  @override
  String importLabelsJsonItemNotMap(Object type) {
    return 'Einer der Einträge in der Liste ist kein gültiges Objekt: $type';
  }

  @override
  String get importLabelsJsonItemNotMapTips =>
      'Jedes Element in der Liste muss ein gültiges Objekt mit den Feldern sein: name, color und labelOrder.';

  @override
  String get importLabelsJsonLabelParseError =>
      'Fehler beim Parsen eines der Labels.\n';

  @override
  String get importLabelsJsonLabelParseTips =>
      'Überprüfen Sie, ob jedes Label die erforderlichen Felder wie name und color hat und die Werte die richtigen Typen sind.';

  @override
  String get importLabelsUnexpectedError =>
      'Unerwarteter Fehler beim Importieren der JSON-Datei.\n';

  @override
  String get importLabelsUnexpectedErrorTip =>
      'Bitte stellen Sie sicher, dass Ihre Datei lesbar und korrekt formatiert ist.';

  @override
  String get importLabelsDatabaseError =>
      'Fehler beim Speichern von Labels in der Datenbank';

  @override
  String get importLabelsDatabaseErrorTips =>
      'Bitte überprüfen Sie Ihre Datenbankverbindung und versuchen Sie es erneut. Wenn das Problem weiterhin besteht, kontaktieren Sie den Support.';

  @override
  String get importLabelsNameMissingOrEmpty =>
      'Eines der Labels hat keinen gültigen Namen.';

  @override
  String get importLabelsNameMissingOrEmptyTips =>
      'Stellen Sie sicher, dass jedes Label im JSON ein nicht-leeres \'name\'-Feld enthält.';

  @override
  String get menuSortAZ => 'A-Z';

  @override
  String get menuSortZA => 'Z-A';

  @override
  String get menuSortProjectType => 'Projekttyp';

  @override
  String get uploadInProgressTitle => 'Upload läuft';

  @override
  String get uploadInProgressMessage =>
      'Sie haben einen aktiven Upload im Gange. Wenn Sie jetzt gehen, wird der Upload abgebrochen und Sie müssen von vorne beginnen.\n\nMöchten Sie trotzdem gehen?';

  @override
  String get uploadInProgressStay => 'Bleiben';

  @override
  String get uploadInProgressLeave => 'Verlassen';

  @override
  String get fileNotFound => 'Datei nicht gefunden oder Zugriff verweigert';

  @override
  String get labelEditSave => 'Speichern';

  @override
  String get labelEditEdit => 'Bearbeiten';

  @override
  String get labelEditMoveUp => 'Nach oben verschieben';

  @override
  String get labelEditMoveDown => 'Nach unten verschieben';

  @override
  String get labelEditDelete => 'Löschen';

  @override
  String get labelExportLabels => 'Labels exportieren';

  @override
  String get labelSaveDialogTitle => 'Labels in JSON-Datei speichern';

  @override
  String get labelSaveDefaultFilename => 'labels.json';

  @override
  String labelDeleteError(Object error) {
    return 'Fehler beim Löschen des Labels: $error';
  }

  @override
  String get labelDeleteErrorTips =>
      'Stellen Sie sicher, dass das Label noch existiert oder nicht anderswo verwendet wird.';

  @override
  String get datasetStepUploadZip =>
      'Laden Sie eine .ZIP-Datei mit COCO, YOLO, VOC, LabelMe, CVAT, Datumaro oder nur-Medien-Format hoch';

  @override
  String get datasetStepExtractingZip =>
      'ZIP wird im lokalen Speicher extrahiert ...';

  @override
  String datasetStepExtractedPath(Object path) {
    return 'Datensatz extrahiert in: $path';
  }

  @override
  String datasetStepDetectedTaskType(Object format) {
    return 'Erkannter Aufgabentyp: $format';
  }

  @override
  String get datasetStepSelectProjectType => 'Projekttyp auswählen';

  @override
  String get datasetStepProgressSelection => 'Datensatzauswahl';

  @override
  String get datasetStepProgressExtract => 'ZIP extrahieren';

  @override
  String get datasetStepProgressOverview => 'Datensatzübersicht';

  @override
  String get datasetStepProgressTaskConfirmation => 'Aufgabenbestätigung';

  @override
  String get datasetStepProgressProjectCreation => 'Projekterstellung';

  @override
  String get projectTypeDetectionBoundingBox =>
      'Erkennung mit Begrenzungsrahmen';

  @override
  String get projectTypeDetectionOriented => 'Orientierte Erkennung';

  @override
  String get projectTypeBinaryClassification => 'Binäre Klassifizierung';

  @override
  String get projectTypeMultiClassClassification =>
      'Multi-Klassen-Klassifizierung';

  @override
  String get projectTypeMultiLabelClassification =>
      'Multi-Label-Klassifizierung';

  @override
  String get projectTypeInstanceSegmentation => 'Instanz-Segmentierung';

  @override
  String get projectTypeSemanticSegmentation => 'Semantische Segmentierung';

  @override
  String get datasetStepChooseProjectType =>
      'Wählen Sie Ihren Projekttyp basierend auf erkannten Annotationen';

  @override
  String get datasetStepAllowProjectTypeChange =>
      'Projekttyp-Änderung erlauben';

  @override
  String get projectTypeBinaryClassificationDescription =>
      'Weisen Sie jedem Eingabewert eines von zwei möglichen Labels zu (z.B. Spam oder kein Spam, positiv oder negativ).';

  @override
  String get projectTypeMultiClassClassificationDescription =>
      'Weisen Sie genau ein Label aus einer Menge sich gegenseitig ausschließender Klassen zu (z.B. Katze, Hund oder Vogel).';

  @override
  String get projectTypeMultiLabelClassificationDescription =>
      'Weisen Sie ein oder mehrere Labels aus einer Menge von Klassen zu — mehrere Labels können gleichzeitig gelten (z.B. ein Bild, das sowohl als \"Katze\" als auch als \"Hund\" gekennzeichnet ist)';

  @override
  String get projectTypeDetectionBoundingBoxDescription =>
      'Zeichnen Sie ein Rechteck um ein Objekt in einem Bild.';

  @override
  String get projectTypeDetectionOrientedDescription =>
      'Zeichnen und umschließen Sie ein Objekt innerhalb eines minimalen Rechtecks.';

  @override
  String get projectTypeInstanceSegmentationDescription =>
      'Erkennen und unterscheiden Sie jedes einzelne Objekt basierend auf seinen einzigartigen Merkmalen.';

  @override
  String get projectTypeSemanticSegmentationDescription =>
      'Erkennen und klassifizieren Sie alle ähnlichen Objekte als eine einzige Entität.';
}
