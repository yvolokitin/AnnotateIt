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
  String get modelsAnnotation => 'Annotierungsmodelle';

  @override
  String get modelDescriptionSamMobile =>
      'Leichte SAM-Variante für Segmentierung direkt auf dem Gerät.';

  @override
  String get modelDescriptionSAM2HieraBasePlus =>
      'Ausgewogen zwischen Genauigkeit und Geschwindigkeit mit Hiera base+ Backbone.';

  @override
  String get modelDescriptionSAM2HieraLarge =>
      'Hochpräzise Variante für Masken in bester Qualität.';

  @override
  String get modelDescriptionSSDMobileNet =>
      'Schneller Single-Shot-Detektor für allgemeine Objekte.';

  @override
  String get modelBuildIn => 'Integriert';

  @override
  String get modelDownload => 'Herunterladen';

  @override
  String get modelDownloaded => 'Heruntergeladen';

  @override
  String get modelBuildInAndReady => 'Integriert und einsatzbereit';

  @override
  String get modelComingSoon => 'Demnächst verfügbar – Noch nicht erhältlich';

  @override
  String get modelShowPath => 'Pfad anzeigen, wo das Modell gespeichert ist';

  @override
  String get modelOpenPath => 'Pfad öffnen, wo das Modell gespeichert ist';

  @override
  String get modelDownloading => 'Wird heruntergeladen';

  @override
  String get modelStartingDownload => 'Download wird gestartet';

  @override
  String get modelsHelpBody =>
      'Annotierungsmodelle (basierend auf SAM) verwandeln schnelle Eingaben – Klicks, Boxen oder grobe Striche – in präzise Masken.\n\nFunktionsweise:\n• Der Encoder wird einmal pro Bild ausgeführt, um Bildmerkmale zu erstellen.\n• Der Decoder läuft nach jeder Eingabe, um die Maske zu erzeugen oder anzupassen.\n\nVorteile:\nSie verbringen weniger Zeit mit dem Zeichnen von Polygonen; das Modell schlägt Masken vor, die Sie mit wenigen Klicks verfeinern können.';

  @override
  String get modelsHelpTips =>
      'Tipps:\n• Beste Eingaben: beginnen Sie mit einer Box oder 1–2 positiven Klicks, fügen Sie dann negative Klicks hinzu, um Bereiche auszuschließen.\n• Verfeinern statt neu zeichnen: fügen Sie weitere Eingaben hinzu, um dieselbe Maske zu aktualisieren.\n• Leistung: der Encoder ist der aufwendige Schritt; verwenden Sie ihn mehrfach pro Bild.\n• Große Bilder: vor dem Markieren hineinzoomen für klarere Kanten.\n• Quantisiert vs. volle Präzision: quantisiert läuft schneller mit weniger Speicher, kann aber Details verlieren.';

  @override
  String get aboutTitle => 'Über AnnotateIt';

  @override
  String get aboutDescription =>
      'AnnotateIt ist eine Annotationsanwendung, die den Annotationsprozess für Computer-Vision-Projekte vereinfacht. Ob Sie an Bildklassifizierung, Objekterkennung, Segmentierung oder anderen Vision-Aufgaben arbeiten, AnnotateIt bietet die Flexibilität und Präzision, die für hochwertige Datenkennzeichnung erforderlich ist.';

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
  String get settingsApplicationLogs => 'Anwendungsprotokolle';

  @override
  String get settingsLogsSaveInFile =>
      'Anwendungsprotokolle in Datei speichern';

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
  String get uploadVideo => 'Video hochladen';

  @override
  String get uploadCamera => 'Kamera';

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
  String get betaDialogTitle => 'Segmentierungsmodelle (Beta)';

  @override
  String get betaDialogMessage =>
      'Warum wirken SAM Mobile, SAM2 Hiera Base+ und SAM2 Hiera Large oft ähnlich?\n\nNicht-Web-Builds (Windows/macOS/Linux/Android/iOS): echtes SAM-Inferencing ist noch nicht aktiviert. Die App greift auf eine inhaltsbasierte Heuristik zurück (Seeded Region Growing + Konturextraktion). Ein Modellwechsel ändert diese Heuristik nicht, daher sind die Ergebnisse ähnlich.\n\nWeb-Builds: echte ONNX-Inferenz wird verwendet, wenn das Modell erfolgreich geladen wurde, die Ergebnisse werden jedoch identisch nachverarbeitet: Decodermaske in 256×256 → Schwellwert (Otsu), Komponentenfilterung zum Tipp, Lochfüllung, Glättung und Polygonsimplifizierung. Das kann feine Details entfernen und Modelle näher beieinander erscheinen lassen, als erwartet.\n\nBekannte Einschränkungen in dieser Beta:\n • Nur Ein-Punkt-Prompts (keine Boxen/Mehrpunkt-Hinweise).\n • Bild wird auf 1024 px vorverarbeitet und die Decodermaske ist 256×256 → Detailverlust bei sehr kleinen Objekten/Kanten.\n • Schwellwert/Glättung kann je nach Bildkontrast/Rauschen über- oder untersegmentieren.\n • Auf Nicht-Web-Plattformen beeinflusst der Modellwechsel hauptsächlich Labels/UI, nicht das eigentliche Segmentierungs-Backend.';

  @override
  String get betaDialogTips =>
      'Tipps zur sofortigen Ergebnisverbesserung:\n • Heranzoomen und deutlich innerhalb des Zielobjekts klicken.\n • Bilder mit gutem lokalen Kontrast und wenigen Kompressionsartefakten bevorzugen.\n • Wenn möglich, die Web-Version für echtes SAM-Inferencing verwenden.\n • Grenzen nach der Auto-Segmentierung bei Bedarf manuell nachziehen.';

  @override
  String get delete => 'Löschen';

  @override
  String get setAsDefault => 'Als Standard festlegen';

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
  String get menuModels => 'Modelle';

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
  String get menuSortCustomOrder => 'Benutzerdefinierte Reihenfolge';

  @override
  String get menuSortLastUpdated => 'Zuletzt aktualisiert';

  @override
  String get menuSortNewestOldest => 'Neueste-Älteste';

  @override
  String get menuSortOldestNewest => 'Älteste-Neueste';

  @override
  String get menuSortProjectType => 'Projekttyp';

  @override
  String get menuSortAZ => 'A-Z';

  @override
  String get menuSortZA => 'Z-A';

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
  String get removeFilesDbOnlyNote =>
      'Hinweis: Es werden nur die Datensatzeinträge gelöscht. Die Originaldateien auf der Festplatte werden durch diese Aktion nicht gelöscht. Wenn Sie jedoch fehlende Bilder oder Fehler (z. B. ErrorImageTile) sehen, kann dies daran liegen, dass die Datei bereits von der Festplatte entfernt wurde oder Sie keine Berechtigung zum Zugriff darauf haben.';

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
  String get annotations => 'Anmerkungen';

  @override
  String get deleteAllAnnotations => 'Alle Anmerkungen löschen';

  @override
  String get deleteAllAnnotationsConfirm =>
      'Möchten Sie wirklich alle Anmerkungen für dieses Bild löschen?\nDiese Aktion kann nicht rückgängig gemacht werden.';

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
  String get preLabelProject => 'Projekt zur Vorbeschriftung';

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
  String get labelEditMoveUp => 'Hoch';

  @override
  String get labelEditMoveDown => 'Runter';

  @override
  String get labelEditDefault => 'Standard';

  @override
  String get labelEditUndefault => 'Unstandard';

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
  String get projectTypeDetectionBoundingBox => 'Erkennung (Begrenzungsrahmen)';

  @override
  String get projectTypeDetectionOriented =>
      'Erkennung (Rotierter Begrenzungsrahmen)';

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

  @override
  String get settingsProjectCreationShowImportWarning =>
      'Import-Warnungsdialog anzeigen';

  @override
  String get settingsProjectCreationShowImportWarningNote =>
      'Wenn aktiviert, wird beim Umschalten von „Projekttyp-Änderung erlauben“ während des Datensatzimports ein Warnhinweis angezeigt.';

  @override
  String get settingsLabelsAskConfirmationOnAnnotationRemoval =>
      'Beim Entfernen von Annotationen um Bestätigung bitten';

  @override
  String get settingsLabelsAskConfirmationOnAnnotationRemovalNote =>
      'Wenn aktiviert, wird vor dem Entfernen von Annotationen ein Bestätigungsdialog angezeigt.';

  @override
  String get settingsLabelsShowExportLabelsButton =>
      'Schaltfläche „Labels exportieren“ anzeigen';

  @override
  String get settingsLabelsShowExportLabelsButtonNote =>
      'Wenn aktiviert, wird in der Projektansicht eine Schaltfläche zum Exportieren von Labels angezeigt.';

  @override
  String get settingsAnnotationPreferredSamModel => 'Bevorzugtes SAM‑Modell';

  @override
  String get settingsAnnotationSamOptionMobile => 'SAM Mobile';

  @override
  String get settingsAnnotationSamOptionSam2HieraBasePlus =>
      'SAM2 (Hiera‑Base+)';

  @override
  String get settingsAnnotationSamRememberChoice => 'Meine SAM‑Auswahl merken';

  @override
  String get settingsAnnotationSamRememberChoiceNote =>
      'Wenn aktiviert, wird der SAM‑Dialog nicht angezeigt und Ihr bevorzugtes Modell wird automatisch verwendet.';

  @override
  String get accountStorageLogFileTitle => 'Anwendungsprotokolldatei';

  @override
  String accountStorageOpenLogFileFailed(Object error) {
    return 'Speicherort der Protokolldatei konnte nicht geöffnet werden: $error';
  }

  @override
  String get accountStorageLogFileHelp =>
      'Klicken Sie, um den Ordner mit der Anwendungsprotokolldatei zu öffnen. Diese Datei enthält alle App‑Protokolle, einschließlich möglicher Abstürze.';

  @override
  String get accountStorageLogFileNotAvailable =>
      'Protokolldatei nicht verfügbar';

  @override
  String get accountStorageLogFileInitError =>
      'Die Anwendungsprotokolldatei konnte nicht initialisiert werden. Überprüfen Sie die Dateiberechtigungen.';

  @override
  String get buttonContinue => 'Weiter';

  @override
  String get videoImportTitle => 'Videoimport';

  @override
  String get ffmpegStep1Title => 'Schritt 1: FFmpeg prüfen';

  @override
  String get ffmpegDescription =>
      'FFmpeg ist eine kostenlose, Open‑Source‑Suite zur Verarbeitung von Video und Audio. AnnotateIt verwendet FFmpeg unter Windows, um einzelne Frames aus Ihrem Video zur Annotation zu extrahieren.';

  @override
  String get ffmpegWebsite => 'FFmpeg‑Webseite';

  @override
  String get ffmpegWindowsBuilds => 'Windows‑Builds';

  @override
  String get ffmpegTip =>
      'Tipp: Nach der Installation fügen Sie entweder ffmpeg.exe zu Ihrem PATH hinzu oder klicken Sie auf „FFmpeg auswählen“, um die ausführbare Datei zu wählen.';

  @override
  String ffmpegUsingPath(Object path) {
    return 'Verwendet: $path';
  }

  @override
  String get ffmpegUnavailable =>
      'FFmpeg nicht verfügbar. Wählen Sie zuerst ffmpeg.exe.';

  @override
  String get ffmpegSelectButton => 'FFmpeg auswählen';

  @override
  String get ffmpegRecheckButton => 'Erneut prüfen';

  @override
  String get videoStep2Title => 'Schritt 2: Videodatei auswählen';

  @override
  String get videoStep2Text =>
      'Nachdem FFmpeg gefunden wurde, klicken Sie auf Weiter, um ein Video zum Importieren auszuwählen.';

  @override
  String get mobileFramesInfo =>
      'Frames werden mit den integrierten Funktionen Ihres Geräts extrahiert (kein FFmpeg erforderlich).';

  @override
  String get mobileTapContinueInfo =>
      'Tippen Sie auf Weiter, um eine Videodatei auszuwählen und die Frames als Bilder zu extrahieren.';

  @override
  String get importNotCompletedTitle => 'Import nicht abgeschlossen';

  @override
  String importNotCompletedDiagnostics(Object diag) {
    return 'Konnte keine Frames aus dem ausgewählten Video extrahieren.\n\nDiagnose:\n$diag';
  }

  @override
  String get uploadStopped => 'Upload gestoppt';

  @override
  String get importCompleteTitle => 'Import abgeschlossen';

  @override
  String get importCompleteExtractedPrefix => 'Extrahiert';

  @override
  String get importCompleteFrame => 'Frame';

  @override
  String get importCompleteFrames => 'Frames';

  @override
  String get importCompleteAndAdded => 'und zum Datensatz hinzugefügt.';

  @override
  String get viaFfmpeg => '(über FFmpeg)';

  @override
  String get viaVideoThumbnail => '(via video_thumbnail)';

  @override
  String get cameraLinuxUnsupported =>
      'Kamerafunktion ist unter Linux nicht unterstützt';

  @override
  String videoToFramesFailed(Object error) {
    return 'Umwandlung von Video in Frames fehlgeschlagen: $error';
  }

  @override
  String get selectFfmpegDialogTitle => 'ffmpeg‑Programm auswählen';

  @override
  String get preLabelIntroTflite =>
      'Projektbilder automatisch mit einem TensorFlow‑Lite‑Modell scannen und Labelnamen vorschlagen. Sie können vor dem Speichern prüfen und bearbeiten.';

  @override
  String get preLabelIntroMlkit =>
      'Projektbilder automatisch mit Google ML Kit scannen und Labelnamen vorschlagen. Sie können vor dem Speichern prüfen und bearbeiten.';

  @override
  String get preLabelErrorReadDatasetsTryAgain =>
      'Datensätze konnten nicht gelesen werden. Bitte erneut versuchen.';

  @override
  String get preLabelErrorCheckModelAvailability =>
      'Prüfung der Modellverfügbarkeit fehlgeschlagen.';

  @override
  String preLabelProcessedOfTotalImages(Object processed, Object total) {
    return 'Verarbeitet $processed von $total Bildern';
  }

  @override
  String get preLabelNoImagesUploadFirst =>
      'Keine Bilder in den Projektdatensätzen gefunden. Bitte zuerst Medien hochladen.';

  @override
  String get preLabelNoLabelsSuggested =>
      'Es wurden keine Labels vorgeschlagen. Sie können diesen Dialog schließen.';

  @override
  String get preLabelStep1Title => 'Schritt 1: Voraussetzungen prüfen';

  @override
  String get preLabelCheckingProjectAndModels =>
      'Projekt und Modelle werden geprüft...';

  @override
  String preLabelImagesInProjectDatasets(Object count) {
    return 'Bilder in Projektdatensätzen: $count';
  }

  @override
  String get preLabelModelAvailableInFolder =>
      'Modell im Ordner „Models“ vorhanden';

  @override
  String get preLabelModelMissingPleaseDownload =>
      'Modell fehlt. Bitte zuerst herunterladen.';

  @override
  String get preLabelRecheck => 'Erneut prüfen';

  @override
  String get preLabelAllPrerequisitesMet => 'Alle Voraussetzungen erfüllt';

  @override
  String preLabelChipImages(Object count) {
    return 'Bilder: $count';
  }

  @override
  String get preLabelBackendTfliteDetection => 'Backend: TFLite‑Erkennung';

  @override
  String get preLabelBackendTfliteClassification =>
      'Backend: TFLite‑Klassifizierung';

  @override
  String get preLabelBackendMlkit => 'Backend: ML Kit';

  @override
  String get preLabelYouCanProceed =>
      'Sie können die Vorbeschriftung starten, sobald Sie bereit sind.';

  @override
  String get preLabelStartPreLabeling => 'Vorbeschriftung starten';

  @override
  String get preLabelStep0Title => 'Schritt 0: Was als Nächstes passiert';

  @override
  String get preLabelBulletScanTflite =>
      '• Die Projektbilder werden mit Ihrem TensorFlow‑Lite‑Modell gescannt.';

  @override
  String get preLabelBulletScanMlkit =>
      '• Die Projektbilder werden mit Google ML Kit auf diesem Gerät gescannt.';

  @override
  String get preLabelBulletProposeLabels =>
      '• Wir schlagen gefundene Labelnamen vor. Sie können sie prüfen und bearbeiten.';

  @override
  String get preLabelBulletStartPreAnnotationSavesLabels =>
      '• Wenn Sie „Vor‑Annotation starten“ klicken, werden die Labels im Projekt gespeichert.';

  @override
  String get preLabelBulletThenAutoAnnotateDetection =>
      '• Bilder werden anschließend automatisch mit Begrenzungsrahmen für die erkannten Labels annotiert.';

  @override
  String get preLabelBulletThenAutoAnnotateClassification =>
      '• Bilder werden anschließend automatisch mit Klassifikationslabels annotiert.';

  @override
  String get preLabelBulletRespectExisting =>
      '• Vorhandene Annotationen werden respektiert, doppelte werden vermieden.';

  @override
  String get preLabelBulletCancelAnyTime =>
      '• Sie können jederzeit abbrechen. Bei großen Projekten kann es länger dauern.';

  @override
  String preLabelProgressPercent(Object percent) {
    return 'Fortschritt: $percent%';
  }

  @override
  String get preLabelScanningImages => 'Bilder werden gescannt...';

  @override
  String get preLabelErrorReadDatasets =>
      'Datensätze konnten nicht gelesen werden.';

  @override
  String get preLabelErrorDetectionModelMissing =>
      'Erkennungsmodell nicht im Ordner „Models“ gefunden. Bitte auf der Modellseite herunterladen.';

  @override
  String get preLabelErrorClassificationModelMissing =>
      'Klassifikationsmodell nicht im Ordner „Models“ gefunden. Bitte auf der Modellseite herunterladen.';

  @override
  String preLabelErrorInitBackendWithDetails(Object details) {
    return 'Initialisierung des Beschriftungs‑Backends fehlgeschlagen. Prüfen Sie Modellsdateien oder Berechtigungen.\n\nDetails: $details';
  }

  @override
  String get preLabelSavingLabels => 'Labels werden gespeichert...';

  @override
  String get preLabelErrorSaveLabelsOrAnnotate =>
      'Labels konnten nicht gespeichert oder Bilder nicht annotiert werden';

  @override
  String get preLabelAnnotatingImages => 'Bilder werden annotiert...';

  @override
  String get preLabelStartPreAnnotation => 'Vor‑Annotation starten';

  @override
  String get preLabelSummaryTitle => 'Zusammenfassung';

  @override
  String get preLabelSummaryLabelsAdded => 'Hinzugefügte Labels';

  @override
  String get preLabelSummaryImagesAnnotated => 'Annotierte Bilder';

  @override
  String get preLabelSummaryAnnotationsAdded => 'Hinzugefügte Annotationen';

  @override
  String get buttonOpenProject => 'Projekt öffnen';
}
