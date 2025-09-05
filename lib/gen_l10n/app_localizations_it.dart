// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get buttonKeep => 'Mantieni';

  @override
  String get buttonSave => 'Salva';

  @override
  String get buttonHelp => 'Aiuto';

  @override
  String get buttonEdit => 'Modifica';

  @override
  String get buttonNext => 'Avanti';

  @override
  String get buttonBack => 'Indietro';

  @override
  String get buttonApply => 'Applica';

  @override
  String get buttonClose => 'Chiudi';

  @override
  String get buttonImport => 'Importa';

  @override
  String get buttonCancel => 'Annulla';

  @override
  String get buttonFinish => 'Termina';

  @override
  String get buttonDelete => 'Elimina';

  @override
  String get buttonDuplicate => 'Duplica';

  @override
  String get buttonConfirm => 'Conferma';

  @override
  String get buttonDiscard => 'Scarta';

  @override
  String get buttonFeedbackShort => 'Fdbck';

  @override
  String get buttonImportLabels => 'Importa Etichette';

  @override
  String get buttonExportLabels => 'Esporta Etichette';

  @override
  String get buttonNextConfirmTask => 'Avanti: Conferma Attività';

  @override
  String get buttonCreateProject => 'Crea Progetto';

  @override
  String get modelsAnnotation => 'Modelli di annotazione';

  @override
  String get modelDescriptionSamMobile =>
      'Variante leggera di SAM per la segmentazione sul dispositivo.';

  @override
  String get modelDescriptionSAM2HieraBasePlus =>
      'Equilibrio tra accuratezza e velocità con backbone Hiera base+.';

  @override
  String get modelDescriptionSAM2HieraLarge =>
      'Variante ad alta precisione per ottenere maschere di massima qualità.';

  @override
  String get modelDescriptionSSDMobileNet =>
      'Rilevatore veloce a singolo passaggio per oggetti generici.';

  @override
  String get modelBuildIn => 'Integrato';

  @override
  String get modelDownload => 'Scarica';

  @override
  String get modelDownloaded => 'Scaricato';

  @override
  String get modelBuildInAndReady => 'Integrato e pronto all\'uso';

  @override
  String get modelComingSoon => 'In arrivo – Non ancora disponibile';

  @override
  String get modelShowPath => 'Mostra percorso dove è salvato il modello';

  @override
  String get modelOpenPath => 'Apri percorso dove è salvato il modello';

  @override
  String get modelDownloading => 'Download in corso';

  @override
  String get modelStartingDownload => 'Avvio del download';

  @override
  String get modelsHelpBody =>
      'I modelli di annotazione (basati su SAM) trasformano input rapidi — clic, riquadri o tratti grossolani — in maschere precise.\n\nCome funziona:\n• L’encoder viene eseguito una volta per immagine per costruire le caratteristiche.\n• Il decoder viene eseguito dopo ogni input per generare o regolare la maschera.\n\nPerché è utile:\nSi dedica meno tempo a disegnare poligoni; il modello propone maschere che puoi perfezionare con pochi clic.';

  @override
  String get modelsHelpTips =>
      'Suggerimenti:\n• Input migliori: inizia con un riquadro o 1–2 clic positivi, quindi aggiungi clic negativi per escludere elementi.\n• Raffina, non ridisegnare: continua ad aggiungere input per aggiornare la stessa maschera.\n• Prestazioni: l’encoder è la parte più pesante; riutilizzalo per molti input sulla stessa immagine.\n• Immagini grandi: ingrandisci prima di dare input per ottenere bordi più netti.\n• Quantizzato vs piena precisione: il quantizzato è più veloce e usa meno memoria, ma può perdere dettagli fini.';

  @override
  String get aboutTitle => 'Informazioni su AnnotateIt';

  @override
  String get aboutDescription =>
      'AnnotateIt è un\'applicazione di annotazione progettata per semplificare il processo di annotazione per progetti di computer vision. Che tu stia lavorando su classificazione di immagini, rilevamento di oggetti, segmentazione o altre attività di visione, AnnotateIt offre la flessibilità e la precisione necessarie per un\'etichettatura di dati di alta qualità.';

  @override
  String get aboutFeaturesTitle => 'Funzionalità principali:';

  @override
  String get aboutFeatures =>
      '- Tipi di progetto multipli: Crea e gestisci progetti su misura per diverse attività di computer vision.\n- Caricamento e gestione dei dati: Carica e organizza facilmente i tuoi dataset per un\'annotazione senza problemi.\n- Strumenti di annotazione avanzati: Utilizza riquadri di delimitazione, poligoni, punti chiave e maschere di segmentazione.\n- Esportazione e integrazione: Esporta dati etichettati in vari formati compatibili con framework di AI/ML.';

  @override
  String get aboutCallToAction =>
      'Inizia oggi il tuo percorso di annotazione e costruisci dataset di alta qualità per i tuoi modelli di computer vision!';

  @override
  String get accountUser => 'Utente';

  @override
  String get accountProfile => 'Profilo';

  @override
  String get accountStorage => 'Archiviazione';

  @override
  String get accountDeviceStorage => 'Archiviazione Dispositivo';

  @override
  String get accountSettings => 'Impostazioni';

  @override
  String get accountApplicationSettings => 'Impostazioni Applicazione';

  @override
  String get accountLoadingMessage => 'Caricamento dati utente...';

  @override
  String get accountErrorLoadingUser => 'Could not  load user data';

  @override
  String get accountRetry => 'Retry';

  @override
  String get userProfileName => 'Capitano Annotatore';

  @override
  String get userProfileFeedbackButton => 'Feedback';

  @override
  String get userProfileEditProfileButton => 'Modifica Profilo';

  @override
  String get userProfileProjects => 'Progetti';

  @override
  String get userProfileLabels => 'Etichette';

  @override
  String get userProfileMedia => 'Media';

  @override
  String get userProfileOverview => 'Panoramica';

  @override
  String get userProfileAnnotations => 'Annotazioni';

  @override
  String get settingsGeneralTitle => 'Impostazioni Generali';

  @override
  String get settingsProjectCreationTitle => 'Creazione Progetto';

  @override
  String get settingsProjectCreationConfirmNoLabels =>
      'Chiedi sempre conferma quando crei un progetto senza etichette';

  @override
  String get settingsProjectCreationConfirmNoLabelsNote =>
      'Verrai avvisato se provi a creare un progetto senza etichette definite.';

  @override
  String get settingsLabelsCreationDeletionTitle =>
      'Creazione / Eliminazione Etichette';

  @override
  String get settingsLabelsDeletionWithAnnotations =>
      'Elimina annotazioni quando l\'etichetta viene rimossa';

  @override
  String get settingsLabelsDeletionWithAnnotationsNote =>
      'Quando abilitato, l\'eliminazione di un\'etichetta rimuoverà automaticamente tutte le annotazioni assegnate a quell\'etichetta in tutti gli elementi multimediali.';

  @override
  String get settingsLabelsSetDefaultLabel =>
      'Imposta la prima etichetta come predefinita';

  @override
  String get settingsLabelsSetDefaultLabelNote =>
      'Quando abilitato, la prima etichetta che crei in un progetto sarà automaticamente contrassegnata come etichetta predefinita. Puoi modificare l\'impostazione predefinita in seguito in qualsiasi momento.';

  @override
  String get settingsDatasetViewTitle => 'Visualizzazione Dataset';

  @override
  String get settingsDatasetViewDuplicateWithAnnotations =>
      'Duplica (crea una copia) immagine sempre con annotazioni';

  @override
  String get settingsDatasetViewDuplicateWithAnnotationsNote =>
      'Durante la duplicazione, le annotazioni saranno incluse a meno che non si modifichino le impostazioni';

  @override
  String get settingsDatasetViewDeleteFromOS =>
      'Quando elimini un\'immagine dal Dataset, eliminala sempre dal sistema operativo / file system';

  @override
  String get settingsDatasetViewDeleteFromOSNote =>
      'Elimina il file anche dal disco, non solo dal dataset';

  @override
  String get settingsAnnotationTitle => 'Impostazioni Annotazione';

  @override
  String get settingsAnnotationOpacity => 'Opacità annotazione';

  @override
  String get settingsAnnotationAutoSave =>
      'Salva o invia sempre l\'annotazione quando passi all\'immagine successiva';

  @override
  String get settingsThemeTitle => 'Selezione tema';

  @override
  String get settingsLanguageTitle => 'Paese / Lingua';

  @override
  String get settingsApplicationLogs => 'Registri dell’applicazione';

  @override
  String get settingsLogsSaveInFile =>
      'Salva i registri dell\'applicazione in un file';

  @override
  String get colorPickerTitle => 'Scegli un colore';

  @override
  String get colorPickerBasicColors => 'Colori base';

  @override
  String get loadingProjects => 'Caricamento progetti...';

  @override
  String get importDataset => 'Importa dataset';

  @override
  String get uploadMedia => 'Carica media';

  @override
  String get uploadVideo => 'Carica video';

  @override
  String get uploadCamera => 'Fotocamera';

  @override
  String get createProjectTitle => 'Crea un Nuovo Progetto';

  @override
  String get createProjectStepOneSubtitle =>
      'Per favore, inserisci il nome del tuo nuovo progetto e seleziona il tipo di Progetto';

  @override
  String get createProjectStepTwoSubtitle =>
      'Per favore, crea etichette per un Nuovo progetto';

  @override
  String get emptyProjectTitle => 'Inizia il tuo primo progetto';

  @override
  String get emptyProjectDescription =>
      'Crea un progetto per iniziare a organizzare dataset, annotare media e applicare l\'IA alle tue attività di visione — tutto in uno spazio di lavoro ottimizzato progettato per accelerare la tua pipeline di computer vision.';

  @override
  String get emptyProjectCreateNew => 'Crea Nuovo Progetto';

  @override
  String get emptyProjectCreateNewShort => 'Nuovo Progetto';

  @override
  String get emptyProjectImportDataset =>
      'Crea Progetto da importazione Dataset';

  @override
  String get emptyProjectImportDatasetShort => 'Importa Dataset';

  @override
  String get dialogBack => '<- Indietro';

  @override
  String get dialogNext => 'Avanti ->';

  @override
  String get rename => 'Rinomina';

  @override
  String get betaDialogTitle => 'Modelli di segmentazione (Beta)';

  @override
  String get betaDialogMessage =>
      'Perché SAM Mobile, SAM2 Hiera Base+ e SAM2 Hiera Large spesso sembrano produrre risultati simili?\n\nBuild non Web (Windows/macOS/Linux/Android/iOS): l\'inferenza SAM reale non è ancora abilitata. L\'app utilizza un\'euristica basata sul contenuto (region growing con seme + estrazione dei contorni). Cambiare modello non modifica questa euristica, quindi i risultati sono simili.\n\nBuild Web: viene usata un\'inferenza ONNX reale quando il modello si carica correttamente, ma i risultati vengono comunque post‑processati allo stesso modo: maschera del decoder a 256×256 → sogliatura (Otsu), filtraggio del componente connesso al tocco, riempimento dei buchi, smoothing e semplificazione del poligono. Questo può rimuovere dettagli fini e far apparire i modelli più simili del previsto.\n\nLimitazioni note in questa Beta:\n • Solo prompt a singolo punto (niente box/indicazioni multi‑punto).\n • L\'immagine è preprocessata a 1024 px e la maschera del decoder è 256×256 → perdita di dettaglio su oggetti/bordi minuti.\n • Sogliatura/smoothing possono sovra/sotto‑segmentare a seconda di contrasto/rumore dell\'immagine.\n • Su piattaforme non Web, il cambio modello incide soprattutto su etichette/UI, non sul backend di segmentazione reale.';

  @override
  String get betaDialogTips =>
      'Suggerimenti per migliorare subito i risultati:\n • Esegui zoom e fai clic ben dentro l\'oggetto di interesse.\n • Preferisci immagini con buon contrasto locale e pochi artefatti di compressione.\n • Se possibile, prova la versione Web per un\'inferenza SAM reale.\n • Rifinisci manualmente i contorni dopo l\'auto‑segmentazione quando necessario.';

  @override
  String get delete => 'Elimina';

  @override
  String get setAsDefault => 'Imposta come Predefinito';

  @override
  String paginationPageFromTotal(int current, int total) {
    return 'Pagina $current di $total';
  }

  @override
  String get taskTypeRequiredTitle => 'Tipo di Attività Richiesto';

  @override
  String taskTypeRequiredMessage(Object tab) {
    return 'Devi selezionare un tipo di attività prima di continuare. La scheda corrente \'$tab\' non ha un tipo di attività selezionato. Ogni progetto deve essere associato a un\'attività (ad esempio, rilevamento oggetti, classificazione o segmentazione) in modo che il sistema sappia come elaborare i tuoi dati.';
  }

  @override
  String taskTypeRequiredTips(Object tab) {
    return 'Clicca su una delle opzioni di tipo di attività disponibili sotto la scheda \'$tab\'. Se non sei sicuro di quale attività scegliere, passa il mouse sull\'icona informativa accanto a ciascun tipo per vedere una breve descrizione.';
  }

  @override
  String get menuProjects => 'Progetti';

  @override
  String get menuModels => 'Modelle';

  @override
  String get menuAccount => 'Account';

  @override
  String get menuLearn => 'Impara';

  @override
  String get menuAbout => 'Info';

  @override
  String get menuExportedDatasetsLong => 'Set di dati esportati';

  @override
  String get menuExportedDatasetsShort => 'Set di dati';

  @override
  String get menuCreateNewProject => 'Crea nuovo progetto';

  @override
  String get menuCreateFromDataset => 'Crea da Dataset';

  @override
  String get menuImportDataset => 'Crea progetto da Importazione Dataset';

  @override
  String get menuSortCustomOrder => 'Ordine personalizzato';

  @override
  String get menuSortLastUpdated => 'Ultimo Aggiornamento';

  @override
  String get menuSortNewestOldest => 'Più Recente-Più Vecchio';

  @override
  String get menuSortOldestNewest => 'Più Vecchio-Più Recente';

  @override
  String get menuSortProjectType => 'Tipo di Progetto';

  @override
  String get menuSortAZ => 'A-Z';

  @override
  String get menuSortZA => 'Z-A';

  @override
  String get projectNameLabel => 'Nome Progetto';

  @override
  String get tabDetection => 'Rilevamento';

  @override
  String get tabClassification => 'Classificazione';

  @override
  String get tabSegmentation => 'Segmentazione';

  @override
  String get labelRequiredTitle => 'Almeno Un\'Etichetta Richiesta';

  @override
  String get labelRequiredMessage =>
      'Devi creare almeno un\'etichetta per procedere. Le etichette sono essenziali per definire le categorie di annotazione che verranno utilizzate durante la preparazione del dataset.';

  @override
  String get labelRequiredTips =>
      'Suggerimento: Clicca sul pulsante rosso etichettato Crea Etichetta dopo aver inserito un nome di etichetta per aggiungere la tua prima etichetta.';

  @override
  String get createLabelButton => 'Crea Etichetta';

  @override
  String get labelNameHint => 'Inserisci qui un nuovo nome di Etichetta';

  @override
  String get createdLabelsTitle => 'Etichette Create';

  @override
  String get labelEmptyTitle => 'Il nome dell\'etichetta non può essere vuoto!';

  @override
  String get labelEmptyMessage =>
      'Per favore inserisci un nome di etichetta. Le etichette aiutano a identificare gli oggetti o le categorie nel tuo progetto. Si consiglia di utilizzare nomi brevi, chiari e descrittivi, come \"Auto\", \"Persona\" o \"Albero\". Evita caratteri speciali o spazi.';

  @override
  String get labelEmptyTips =>
      'Suggerimenti per la Denominazione delle Etichette:\n• Usa nomi brevi e descrittivi\n• Attieniti a lettere, cifre, trattini bassi (ad esempio, gatto, segnale_stradale, sfondo)\n• Evita spazi e simboli (ad esempio, Persona 1 → persona_1)';

  @override
  String get labelDuplicateTitle => 'Nome Etichetta Duplicato';

  @override
  String labelDuplicateMessage(Object label) {
    return 'L\'etichetta \'$label\' esiste già in questo progetto. Ogni etichetta deve avere un nome unico per evitare confusione durante l\'annotazione e l\'addestramento.';
  }

  @override
  String get labelDuplicateTips =>
      'Perché etichette uniche?\n• Riutilizzare lo stesso nome può causare problemi durante l\'esportazione del dataset e l\'addestramento del modello.\n• I nomi di etichette unici aiutano a mantenere annotazioni chiare e strutturate.\n\nSuggerimento: Prova ad aggiungere una variazione o un numero per differenziare (ad esempio, \'Auto\', \'Auto_2\').';

  @override
  String get binaryLimitTitle => 'Limite Classificazione Binaria';

  @override
  String get binaryLimitMessage =>
      'Non puoi creare più di due etichette per un progetto di Classificazione Binaria.\n\nLa Classificazione Binaria è progettata per distinguere tra esattamente due classi, come \'Sì\' vs \'No\', o \'Spam\' vs \'Non Spam\'.';

  @override
  String get binaryLimitTips =>
      'Hai bisogno di più di due etichette?\nConsidera di cambiare il tipo di progetto in Classificazione Multi-Classe o un\'altra attività adatta per supportare tre o più categorie.';

  @override
  String get noteBinaryClassification =>
      'Questo tipo di progetto consente esattamente 2 etichette. La Classificazione Binaria viene utilizzata quando il tuo modello deve distinguere tra due possibili classi, come \"Sì\" vs \"No\", o \"Cane\" vs \"Non Cane\". Per favore crea solo due etichette distinte.';

  @override
  String get noteMultiClassClassification =>
      'Questo tipo di progetto supporta più etichette. La Classificazione Multi-Classe è adatta quando il tuo modello deve scegliere tra tre o più categorie, come \"Gatto\", \"Cane\", \"Coniglio\". Puoi aggiungere tutte le etichette necessarie.';

  @override
  String get noteDetectionOrSegmentation =>
      'Questo tipo di progetto supporta più etichette. Per il Rilevamento Oggetti o la Segmentazione, ogni etichetta rappresenta tipicamente una classe diversa di oggetto (ad esempio, \"Auto\", \"Pedone\", \"Bicicletta\"). Puoi creare tutte le etichette necessarie per il tuo dataset.';

  @override
  String get noteDefault =>
      'Puoi creare una o più etichette a seconda del tipo di progetto. Ogni etichetta aiuta a definire una categoria che il tuo modello imparerà a riconoscere. Consulta la documentazione per le migliori pratiche.';

  @override
  String get discardDatasetImportTitle =>
      'Scartare l\'Importazione del Dataset?';

  @override
  String get discardDatasetImportMessage =>
      'Hai già estratto un dataset. Annullando ora verranno eliminati i file estratti e i dettagli del dataset rilevati. Sei sicuro di voler procedere?';

  @override
  String get projectTypeHelpTitle =>
      'Aiuto per la Selezione del Tipo di Progetto';

  @override
  String get projectTypeWhyDisabledTitle =>
      'Perché alcuni tipi di progetto sono disabilitati?';

  @override
  String get projectTypeWhyDisabledBody =>
      'Quando importi un dataset, il sistema analizza le annotazioni fornite e cerca di rilevare automaticamente il tipo di progetto più adatto per te.\n\nAd esempio, se il tuo dataset contiene annotazioni di riquadri di delimitazione, il tipo di progetto suggerito sarà \"Rilevamento\". Se contiene maschere, verrà suggerito \"Segmentazione\", e così via.\n\nPer proteggere i tuoi dati, solo i tipi di progetto compatibili sono abilitati per impostazione predefinita.';

  @override
  String get projectTypeAllowChangeTitle =>
      'Cosa succede se abilito il cambio di tipo di progetto?';

  @override
  String get projectTypeAllowChangeBody =>
      'Se attivi \"Consenti Cambio Tipo di Progetto\", puoi selezionare manualmente QUALSIASI tipo di progetto, anche se non corrisponde alle annotazioni rilevate.\n\n⚠️ ATTENZIONE: Tutte le annotazioni esistenti dall\'importazione verranno eliminate quando si passa a un tipo di progetto incompatibile.\nDovrai ri-annotare o importare un dataset adatto al tipo di progetto appena selezionato.';

  @override
  String get projectTypeWhenUseTitle => 'Quando dovrei usare questa opzione?';

  @override
  String get projectTypeWhenUseBody =>
      'Dovresti abilitare questa opzione solo se:\n\n- Hai importato accidentalmente il dataset sbagliato.\n- Vuoi iniziare un nuovo progetto di annotazione con un tipo diverso.\n- La struttura del tuo dataset è cambiata dopo l\'importazione.\n\nSe non sei sicuro, ti consigliamo vivamente di mantenere la selezione predefinita per evitare la perdita di dati.';

  @override
  String get allLabels => 'Tutte le Etichette';

  @override
  String get setAsProjectIcon => 'Imposta come Icona del Progetto';

  @override
  String setAsProjectIconConfirm(Object filePath) {
    return 'Vuoi usare \'$filePath\' come icona per questo progetto?\n\nQuesto sostituirà qualsiasi icona precedentemente impostata.';
  }

  @override
  String get removeFilesFromDatasetInProgress => 'Eliminazione file...';

  @override
  String get removeFilesFromDataset => 'Rimuovere file dal Dataset?';

  @override
  String removeFilesFromDatasetConfirm(Object amount) {
    return 'Sei sicuro di voler eliminare i seguenti file (\'$amount\')?\n\nTutte le annotazioni corrispondenti verranno rimosse.';
  }

  @override
  String get removeFilesFailedTitle => 'Eliminazione Fallita';

  @override
  String get removeFilesFailedMessage =>
      'Alcuni file non possono essere eliminati';

  @override
  String get removeFilesFailedTips => 'Controlla i permessi dei file e riprova';

  @override
  String get removeFilesDbOnlyNote =>
      'Nota: Verranno eliminati solo i record del dataset. I file originali sul disco non verranno eliminati da questa azione. Tuttavia, se vedi immagini mancanti o errori (ad es., ErrorImageTile), potrebbe essere perché il file è già stato rimosso dal disco oppure non hai l\'autorizzazione per accedervi.';

  @override
  String get duplicateImage => 'Duplica Immagine';

  @override
  String get duplicateWithAnnotations => 'Duplica immagine con annotazioni';

  @override
  String get duplicateWithAnnotationsHint =>
      'Verrà creata una copia dell\'immagine insieme a tutti i dati di annotazione.';

  @override
  String get duplicateImageOnly => 'Duplica solo immagine';

  @override
  String get duplicateImageOnlyHint =>
      'Solo l\'immagine verrà copiata, senza annotazioni.';

  @override
  String get saveDuplicateChoiceAsDefault =>
      'Salva questa risposta come risposta predefinita e non chiedere più\n(Puoi modificare questo in Account -> Impostazioni applicazione -> Navigazione dataset)';

  @override
  String get editProjectTitle => 'Modifica nome progetto';

  @override
  String get editProjectDescription =>
      'Per favore, scegli un nome di progetto chiaro e descrittivo (3 - 86 caratteri). Si consiglia di evitare caratteri speciali.';

  @override
  String get annotations => 'Annotazioni';

  @override
  String get deleteAllAnnotations => 'Elimina tutte le annotazioni';

  @override
  String get deleteAllAnnotationsConfirm =>
      'Sei sicuro di voler eliminare tutte le annotazioni per questa immagine?\nQuesta azione non può essere annullata.';

  @override
  String get deleteProjectTitle => 'Elimina Progetto';

  @override
  String get deleteProjectInProgress => 'Eliminazione progetto...';

  @override
  String get deleteProjectOptionDeleteFromDisk =>
      'Elimina anche tutti i file dal disco';

  @override
  String get deleteProjectOptionDontAskAgain => 'Non chiedere più';

  @override
  String deleteProjectConfirm(Object projectName) {
    return 'Sei sicuro di voler eliminare il progetto \"$projectName\"?';
  }

  @override
  String deleteProjectInfoLine(Object creationDate, Object labelCount) {
    return 'Il progetto è stato creato il $creationDate\nNumero di Etichette: $labelCount';
  }

  @override
  String get deleteDatasetTitle => 'Elimina Dataset';

  @override
  String get deleteDatasetInProgress =>
      'Eliminazione dataset... Attendere prego.';

  @override
  String deleteDatasetConfirm(Object datasetName) {
    return 'Sei sicuro di voler eliminare \"$datasetName\"?';
  }

  @override
  String deleteDatasetInfoLine(
    Object creationDate,
    Object mediaCount,
    Object annotationCount,
  ) {
    return 'Questo dataset è stato creato il $creationDate e contiene $mediaCount elementi multimediali e $annotationCount annotazioni.';
  }

  @override
  String get editDatasetTitle => 'Rinomina Dataset';

  @override
  String get editDatasetDescription =>
      'Inserisci un nuovo nome per questo dataset:';

  @override
  String get noMediaDialogUploadPrompt => 'Devi caricare immagini o video';

  @override
  String get noMediaDialogUploadPromptShort => 'Carica media';

  @override
  String get noMediaDialogSupportedImageTypesTitle =>
      'Tipi di immagini supportati:';

  @override
  String get noMediaDialogSupportedImageTypesList =>
      'jpg, jpeg, png, bmp, jfif, webp';

  @override
  String get noMediaDialogSupportedVideoFormatsLink =>
      'Clicca qui per vedere quali formati video sono supportati sulla tua piattaforma';

  @override
  String get noMediaDialogSupportedVideoFormatsTitle =>
      'Formati Video Supportati';

  @override
  String get noMediaDialogSupportedVideoFormatsList =>
      'Formati Comunemente Supportati:\n\n- MP4: Android, iOS, Web, Desktop\n- MOV: Android, iOS, macOS\n- M4V: Android, iOS, macOS\n- WEBM: Android, Web (dipende dal browser)\n- MKV: Android (parziale), Windows\n- AVI: Solo Android/Windows (parziale)';

  @override
  String get noMediaDialogSupportedVideoFormatsWarning =>
      'Il supporto può variare a seconda della piattaforma e del codec video.\nAlcuni formati potrebbero non funzionare nei browser o su iOS.';

  @override
  String get annotatorTopToolbarBackTooltip => 'Torna al Progetto';

  @override
  String get annotatorTopToolbarSelectDefaultLabel => 'Etichetta predefinita';

  @override
  String get toolbarNavigation => 'Navigazione';

  @override
  String get toolbarBbox => 'Disegna Riquadro di Delimitazione';

  @override
  String get toolbarPolygon => 'Disegna Poligono';

  @override
  String get toolbarSAM => 'Segment Anything Model';

  @override
  String get toolbarResetZoom => 'Reimposta Zoom';

  @override
  String get toolbarToggleGrid => 'Attiva/Disattiva Griglia';

  @override
  String get toolbarAnnotationSettings => 'Impostazioni Annotazione';

  @override
  String get toolbarToggleAnnotationNames =>
      'Attiva/Disattiva Nomi Annotazione';

  @override
  String get toolbarRotateLeft => 'Ruota a Sinistra (Prossimamente)';

  @override
  String get toolbarRotateRight => 'Ruota a Destra (Prossimamente)';

  @override
  String get toolbarHelp => 'Aiuto';

  @override
  String get dialogOpacityTitle => 'Opacità Riempimento Annotazione';

  @override
  String get dialogHelpTitle => 'Aiuto Barra degli Strumenti Annotatore';

  @override
  String get dialogHelpContent =>
      '• Navigazione – Usa per selezionare e muoverti sulla tela.\n• Riquadro di Delimitazione – (Visibile nei progetti di Rilevamento) Disegna riquadri di delimitazione rettangolari.\n• Reimposta Zoom – Reimposta il livello di zoom per adattare l\'immagine allo schermo.\n• Attiva/Disattiva Griglia – Mostra o nascondi la griglia di miniature del dataset.\n• Impostazioni – Regola l\'opacità di riempimento delle annotazioni, il bordo delle annotazioni e la dimensione degli angoli.\n• Attiva/Disattiva Nomi Annotazione – Mostra o nascondi etichette di testo sulle annotazioni.';

  @override
  String get dialogHelpTips =>
      'Suggerimento: Usa la modalità Navigazione per selezionare e modificare le annotazioni.\nAltri scorciatoie e funzionalità in arrivo!';

  @override
  String get dialogOpacityExplanation =>
      'Regola il livello di opacità per rendere il contenuto più o meno trasparente.';

  @override
  String get deleteAnnotationTitle => 'Elimina Annotazione';

  @override
  String get deleteAnnotationMessage => 'Sei sicuro di voler eliminare';

  @override
  String get unnamedAnnotation => 'questa annotazione';

  @override
  String get accountStorage_importFolderTitle =>
      'Cartella importazione Dataset';

  @override
  String get accountStorage_thumbnailsFolderTitle => 'Cartella Miniature';

  @override
  String get accountStorage_exportFolderTitle =>
      'Cartella esportazione Dataset';

  @override
  String get accountStorage_folderTooltip => 'Scegli cartella';

  @override
  String get accountStorage_helpTitle => 'Aiuto Archiviazione';

  @override
  String get accountStorage_helpMessage =>
      'Puoi modificare la cartella in cui vengono archiviati i dataset importati, gli archivi ZIP esportati e le miniature.\nTocca l\'icona \"Cartella\" accanto al campo del percorso per selezionare o modificare la directory.\n\nQuesta cartella verrà utilizzata come posizione predefinita per:\n- File di dataset importati (ad esempio, COCO, YOLO, VOC, Datumaro, ecc.)\n- Archivi Zip di dataset esportati\n- Miniature del progetto\n\nAssicurati che la cartella selezionata sia scrivibile e abbia spazio sufficiente.\nSu Android o iOS, potrebbe essere necessario concedere le autorizzazioni di archiviazione.\nLe cartelle consigliate variano in base alla piattaforma — vedi sotto i suggerimenti specifici per piattaforma.';

  @override
  String get accountStorage_helpTips =>
      'Cartelle consigliate per piattaforma:\n\nWindows:\n  C:\\Users\\<tu>\\AppData\\Roaming\\AnnotateIt\\datasets\n\nLinux / Ubuntu:\n  /home/<tu>/.annotateit/datasets\n\nmacOS:\n  /Users/<tu>/Library/Application Support/AnnotateIt/datasets\n\nAndroid:\n  /storage/emulated/0/AnnotateIt/datasets\n\niOS:\n  <Percorso sandbox app>/Documents/AnnotateIt/datasets\n';

  @override
  String get accountStorage_copySuccess => 'Percorso copiato negli appunti';

  @override
  String get accountStorage_openError => 'La cartella non esiste:\n';

  @override
  String get accountStorage_pathEmpty => 'Il percorso è vuoto';

  @override
  String get accountStorage_openFailed => 'Impossibile aprire la cartella:\n';

  @override
  String get changeProjectTypeTitle => 'Cambia tipo di progetto';

  @override
  String get changeProjectTypeMigrating => 'Migrazione tipo di progetto...';

  @override
  String get changeProjectTypeStepOneSubtitle =>
      'Seleziona un nuovo tipo di progetto dall\'elenco sottostante';

  @override
  String get changeProjectTypeStepTwoSubtitle => 'Conferma la tua scelta';

  @override
  String get changeProjectTypeWarningTitle =>
      'Attenzione: Stai per cambiare il tipo di progetto.';

  @override
  String get changeProjectTypeConversionIntro =>
      'Tutte le annotazioni esistenti verranno convertite come segue:';

  @override
  String get changeProjectTypeConversionDetails =>
      '- Riquadri di delimitazione (Rilevamento) -> convertiti in poligoni rettangolari.\n- Poligoni (Segmentazione) -> convertiti in riquadri di delimitazione aderenti.\n\nNota: Queste conversioni possono ridurre la precisione, specialmente quando si convertono poligoni in riquadri, poiché le informazioni dettagliate sulla forma andranno perse.\n\n- Rilevamento / Segmentazione → Classificazione:\n  Le immagini verranno classificate in base all\'etichetta più frequente nelle annotazioni:\n     -> Se l\'immagine ha 5 oggetti etichettati \"Cane\" e 10 etichettati \"Gatto\", sarà classificata come \"Gatto\".\n     -> Se i conteggi sono uguali, verrà utilizzata la prima etichetta trovata.\n\n- Classificazione -> Rilevamento / Segmentazione:\n  Nessuna annotazione verrà trasferita. Dovrai ri-annotare manualmente tutti gli elementi multimediali, poiché i progetti di classificazione non contengono dati a livello di regione.';

  @override
  String get changeProjectTypeErrorTitle => 'Migrazione Fallita';

  @override
  String get changeProjectTypeErrorMessage =>
      'Si è verificato un errore durante il cambio del tipo di progetto. Le modifiche non possono essere applicate.';

  @override
  String get changeProjectTypeErrorTips =>
      'Verifica che il progetto abbia annotazioni valide e riprova. Se il problema persiste, riavvia l\'app o contatta l\'assistenza.';

  @override
  String get preLabelProject => 'Progetto di pre-etichettatura';

  @override
  String get exportProjectAsDataset => 'Esporta Progetto come Dataset';

  @override
  String get projectHelpTitle => 'Come Funzionano i Progetti';

  @override
  String get projectHelpMessage =>
      'I progetti ti permettono di organizzare dataset, file multimediali e annotazioni in un unico posto. Puoi creare nuovi progetti per diverse attività come rilevamento, classificazione o segmentazione.';

  @override
  String get projectHelpTips =>
      'Suggerimento: Puoi importare dataset in formato COCO, YOLO, VOC, Labelme e Datumaro per creare un progetto automaticamente.';

  @override
  String get datasetDialogTitle => 'Importa Dataset per Creare Progetto';

  @override
  String get datasetDialogProcessing => 'Elaborazione...';

  @override
  String datasetDialogProcessingProgress(Object percent) {
    return 'Elaborazione... $percent%';
  }

  @override
  String get datasetDialogModeIsolate => 'Modalità Isolamento Abilitata';

  @override
  String get datasetDialogModeNormal => 'Modalità Normale';

  @override
  String get datasetDialogNoDatasetLoaded => 'Nessun dataset caricato.';

  @override
  String get datasetDialogSelectZipFile =>
      'Seleziona il tuo file ZIP del dataset';

  @override
  String get datasetDialogChooseFile => 'Scegli un file';

  @override
  String get datasetDialogSupportedFormats => 'Formati di dataset supportati:';

  @override
  String get datasetDialogSupportedFormatsList1 => 'COCO, YOLO, VOC, Datumaro,';

  @override
  String get datasetDialogSupportedFormatsList2 =>
      'LabelMe, CVAT, o solo media (.zip)';

  @override
  String get dialogImageDetailsTitle => 'Dettagli del File';

  @override
  String get datasetDialogImportFailedTitle => 'Importazione Fallita';

  @override
  String get datasetDialogImportFailedMessage =>
      'Il file ZIP non può essere elaborato. Potrebbe essere danneggiato, incompleto o non un archivio di dataset valido.';

  @override
  String get datasetDialogImportFailedTips =>
      'Prova a riesportare o ricomprimere il tuo dataset.\nAssicurati che sia in formato COCO, YOLO, VOC o supportato.\n\nErrore: ';

  @override
  String get datasetDialogNoProjectTypeTitle =>
      'Nessun Tipo di Progetto Selezionato';

  @override
  String get datasetDialogNoProjectTypeMessage =>
      'Seleziona un Tipo di Progetto basato sui tipi di annotazione rilevati nel tuo dataset.';

  @override
  String get datasetDialogNoProjectTypeTips =>
      'Controlla il formato del tuo dataset e assicurati che le annotazioni seguano una struttura supportata come COCO, YOLO, VOC o Datumaro.';

  @override
  String get datasetDialogProcessingDatasetTitle => 'Elaborazione Dataset';

  @override
  String get datasetDialogProcessingDatasetMessage =>
      'Stiamo attualmente estraendo il tuo archivio ZIP, analizzando il suo contenuto e rilevando il formato del dataset e il tipo di annotazione. Questo potrebbe richiedere da pochi secondi a pochi minuti a seconda della dimensione e della struttura del dataset. Non chiudere questa finestra o navigare altrove durante il processo.';

  @override
  String get datasetDialogProcessingDatasetTips =>
      'Archivi di grandi dimensioni con molte immagini o file di annotazione possono richiedere più tempo per essere elaborati.';

  @override
  String get datasetDialogCreatingProjectTitle => 'Creazione Progetto';

  @override
  String get datasetDialogCreatingProjectMessage =>
      'Stiamo configurando il tuo progetto, inizializzando i suoi metadati e salvando tutte le configurazioni. Questo include l\'assegnazione di etichette, la creazione di dataset e il collegamento dei file multimediali associati. Attendi un momento ed evita di chiudere questa finestra fino al completamento del processo.';

  @override
  String get datasetDialogCreatingProjectTips =>
      'I progetti con molte etichette o file multimediali potrebbero richiedere un po\' più di tempo.';

  @override
  String get datasetDialogAnalyzingDatasetTitle => 'Analisi Dataset';

  @override
  String get datasetDialogAnalyzingDatasetMessage =>
      'Stiamo attualmente analizzando il tuo archivio dataset. Questo include l\'estrazione di file, il rilevamento della struttura del dataset, l\'identificazione dei formati di annotazione e la raccolta di informazioni su media ed etichette. Attendi fino al completamento del processo. Chiudere la finestra o navigare altrove potrebbe interrompere l\'operazione.';

  @override
  String get datasetDialogAnalyzingDatasetTips =>
      'Dataset di grandi dimensioni con molti file o annotazioni complesse potrebbero richiedere tempo aggiuntivo.';

  @override
  String get datasetDialogFilePickErrorTitle => 'Errore Selezione File';

  @override
  String get datasetDialogFilePickErrorMessage =>
      'Impossibile selezionare il file. Riprova.';

  @override
  String get datasetDialogGenericErrorTips =>
      'Controlla il tuo file e riprova. Se il problema persiste, contatta l\'assistenza.';

  @override
  String get thumbnailGenerationTitle => 'Errore';

  @override
  String get thumbnailGenerationFailed => 'Impossibile generare la miniatura';

  @override
  String get thumbnailGenerationTryAgainLater => 'Riprova più tardi';

  @override
  String get thumbnailGenerationInProgress => 'Generazione miniatura...';

  @override
  String get menuImageAnnotate => 'Annota';

  @override
  String get menuImageDetails => 'Dettagli';

  @override
  String get menuImageDuplicate => 'Duplica';

  @override
  String get menuImageSetAsIcon => 'Come Icona';

  @override
  String get menuImageDelete => 'Elimina';

  @override
  String get noLabelsTitle => 'Non hai Etichette nel Progetto';

  @override
  String get noLabelsExplain1 =>
      'Non puoi annotare senza etichette perché le etichette danno significato a ciò che stai marcando';

  @override
  String get noLabelsExplain2 =>
      'Puoi aggiungere etichette manualmente o importarle da un file JSON.';

  @override
  String get noLabelsExplain3 =>
      'Un\'annotazione senza etichetta è solo una scatola vuota.';

  @override
  String get noLabelsExplain4 =>
      'Le etichette definiscono le categorie o classi che stai annotando nel tuo dataset.';

  @override
  String get noLabelsExplain5 =>
      'Che tu stia etichettando oggetti nelle immagini, classificando o segmentando regioni,';

  @override
  String get noLabelsExplain6 =>
      'le etichette sono essenziali per organizzare le tue annotazioni in modo chiaro e coerente.';

  @override
  String get importLabelsPreviewTitle => 'Anteprima Importazione Etichette';

  @override
  String get importLabelsFailedTitle => 'Importazione Etichette Fallita';

  @override
  String get importLabelsNoLabelsTitle =>
      'Nessuna etichetta trovata in questo progetto';

  @override
  String get importLabelsJsonParseError => 'Analisi JSON fallita.\n';

  @override
  String get importLabelsJsonParseTips =>
      'Assicurati che il file sia JSON valido. Puoi convalidarlo su https://jsonlint.com/';

  @override
  String importLabelsJsonNotList(Object type) {
    return 'Era attesa una lista di etichette (array), ma è stato ottenuto: $type.';
  }

  @override
  String get importLabelsJsonNotListTips =>
      'Il tuo file JSON deve iniziare con [ e contenere più oggetti etichetta. Ogni etichetta dovrebbe includere campi nome, colore e ordineEtichetta.';

  @override
  String importLabelsJsonItemNotMap(Object type) {
    return 'Una delle voci nell\'elenco non è un oggetto valido: $type';
  }

  @override
  String get importLabelsJsonItemNotMapTips =>
      'Ogni elemento nell\'elenco deve essere un oggetto valido con campi: nome, colore e ordineEtichetta.';

  @override
  String get importLabelsJsonLabelParseError =>
      'Impossibile analizzare una delle etichette.\n';

  @override
  String get importLabelsJsonLabelParseTips =>
      'Controlla che ogni etichetta abbia i campi richiesti come nome e colore, e che i valori siano dei tipi corretti.';

  @override
  String get importLabelsUnexpectedError =>
      'Si è verificato un errore imprevisto durante l\'importazione del file JSON.\n';

  @override
  String get importLabelsUnexpectedErrorTip =>
      'Assicurati che il tuo file sia leggibile e formattato correttamente.';

  @override
  String get importLabelsDatabaseError =>
      'Impossibile salvare le etichette nel database';

  @override
  String get importLabelsDatabaseErrorTips =>
      'Controlla la tua connessione al database e riprova. Se il problema persiste, contatta l\'assistenza.';

  @override
  String get importLabelsNameMissingOrEmpty =>
      'Una delle etichette non ha un nome valido.';

  @override
  String get importLabelsNameMissingOrEmptyTips =>
      'Assicurati che ogni etichetta nel JSON includa un campo \'nome\' non vuoto.';

  @override
  String get uploadInProgressTitle => 'Caricamento in Corso';

  @override
  String get uploadInProgressMessage =>
      'Hai un caricamento attivo in corso. Se esci ora, il caricamento verrà annullato e dovrai ricominciare da capo.\n\nVuoi uscire comunque?';

  @override
  String get uploadInProgressStay => 'Rimani';

  @override
  String get uploadInProgressLeave => 'Esci';

  @override
  String get fileNotFound => 'File non trovato o accesso negato';

  @override
  String get labelEditSave => 'Salva';

  @override
  String get labelEditEdit => 'Modifica';

  @override
  String get labelEditMoveUp => 'Su';

  @override
  String get labelEditMoveDown => 'Giù';

  @override
  String get labelEditDefault => 'Predef.';

  @override
  String get labelEditUndefault => 'NoPredef.';

  @override
  String get labelEditDelete => 'Elimina';

  @override
  String get labelExportLabels => 'Esporta Etichette';

  @override
  String get labelSaveDialogTitle => 'Salva etichette in file JSON';

  @override
  String get labelSaveDefaultFilename => 'etichette.json';

  @override
  String labelDeleteError(Object error) {
    return 'Impossibile eliminare l\'etichetta: $error';
  }

  @override
  String get labelDeleteErrorTips =>
      'Assicurati che l\'etichetta esista ancora o non sia utilizzata altrove.';

  @override
  String get datasetStepUploadZip =>
      'Carica un file .ZIP con formato COCO, YOLO, VOC, LabelMe, CVAT, Datumaro o solo media';

  @override
  String get datasetStepExtractingZip =>
      'Estrazione ZIP nell\'archiviazione locale ...';

  @override
  String datasetStepExtractedPath(Object path) {
    return 'Dataset estratto in: $path';
  }

  @override
  String datasetStepDetectedTaskType(Object format) {
    return 'Tipo di attività rilevato: $format';
  }

  @override
  String get datasetStepSelectProjectType => 'Seleziona tipo di progetto';

  @override
  String get datasetStepProgressSelection => 'Selezione Dataset';

  @override
  String get datasetStepProgressExtract => 'Estrai ZIP';

  @override
  String get datasetStepProgressOverview => 'Panoramica Dataset';

  @override
  String get datasetStepProgressTaskConfirmation => 'Conferma Attività';

  @override
  String get datasetStepProgressProjectCreation => 'Creazione Progetto';

  @override
  String get projectTypeDetectionBoundingBox =>
      'Rilevamento (Riquadro di Delimitazione)';

  @override
  String get projectTypeDetectionOriented =>
      'Rilevamento (Riquadro di Delimitazione Ruotato)';

  @override
  String get projectTypeBinaryClassification => 'Classificazione Binaria';

  @override
  String get projectTypeMultiClassClassification =>
      'Classificazione Multi-classe';

  @override
  String get projectTypeMultiLabelClassification =>
      'Classificazione Multi-etichetta';

  @override
  String get projectTypeInstanceSegmentation => 'Segmentazione di Istanze';

  @override
  String get projectTypeSemanticSegmentation => 'Segmentazione Semantica';

  @override
  String get datasetStepChooseProjectType =>
      'Scegli il tuo tipo di Progetto in base alle annotazioni rilevate';

  @override
  String get datasetStepAllowProjectTypeChange =>
      'Consenti Cambio Tipo di Progetto';

  @override
  String get projectTypeBinaryClassificationDescription =>
      'Assegna una delle due possibili etichette a ciascun input (ad esempio, spam o non spam, positivo o negativo).';

  @override
  String get projectTypeMultiClassClassificationDescription =>
      'Assegna esattamente un\'etichetta da un insieme di classi mutuamente esclusive (ad esempio, gatto, cane o uccello).';

  @override
  String get projectTypeMultiLabelClassificationDescription =>
      'Assegna una o più etichette da un insieme di classi — più etichette possono essere applicate contemporaneamente (ad esempio, un\'immagine etichettata sia come \"gatto\" che come \"cane\")';

  @override
  String get projectTypeDetectionBoundingBoxDescription =>
      'Disegna un rettangolo attorno a un oggetto in un\'immagine.';

  @override
  String get projectTypeDetectionOrientedDescription =>
      'Disegna e racchiudi un oggetto all\'interno di un rettangolo minimo.';

  @override
  String get projectTypeInstanceSegmentationDescription =>
      'Rileva e distingui ogni singolo oggetto in base alle sue caratteristiche uniche.';

  @override
  String get projectTypeSemanticSegmentationDescription =>
      'Rileva e classifica tutti gli oggetti simili come un\'unica entità.';

  @override
  String get settingsProjectCreationShowImportWarning =>
      'Mostra finestra di avviso per l\'importazione';

  @override
  String get settingsProjectCreationShowImportWarningNote =>
      'Se abilitato, viene mostrata una finestra di avviso quando si attiva \'Consenti cambio tipo di progetto\' durante l\'importazione del dataset.';

  @override
  String get settingsLabelsAskConfirmationOnAnnotationRemoval =>
      'Chiedi conferma quando si rimuovono le annotazioni';

  @override
  String get settingsLabelsAskConfirmationOnAnnotationRemovalNote =>
      'Se abilitato, verrà mostrata una finestra di conferma prima di rimuovere le annotazioni.';

  @override
  String get settingsLabelsShowExportLabelsButton =>
      'Mostra pulsante Esporta Etichette';

  @override
  String get settingsLabelsShowExportLabelsButtonNote =>
      'Se abilitato, nella vista progetto viene mostrato un pulsante per esportare le etichette.';

  @override
  String get settingsAnnotationPreferredSamModel => 'Modello SAM preferito';

  @override
  String get settingsAnnotationSamOptionMobile => 'SAM Mobile';

  @override
  String get settingsAnnotationSamOptionSam2HieraBasePlus =>
      'SAM2 (Hiera-Base+)';

  @override
  String get settingsAnnotationSamRememberChoice => 'Ricorda la mia scelta SAM';

  @override
  String get settingsAnnotationSamRememberChoiceNote =>
      'Se abilitato, la finestra SAM non verrà mostrata e il modello preferito verrà usato automaticamente.';

  @override
  String get accountStorageLogFileTitle => 'File di log dell\'applicazione';

  @override
  String accountStorageOpenLogFileFailed(Object error) {
    return 'Impossibile aprire la posizione del file di log: $error';
  }

  @override
  String get accountStorageLogFileHelp =>
      'Clicca per aprire la cartella che contiene il file di log dell\'applicazione. Questo file include tutti i log dell\'app, compresi eventuali arresti anomali.';

  @override
  String get accountStorageLogFileNotAvailable => 'File di log non disponibile';

  @override
  String get accountStorageLogFileInitError =>
      'Impossibile inizializzare il file di log dell\'applicazione. Verificare i permessi sui file.';

  @override
  String get buttonContinue => 'Continua';

  @override
  String get videoImportTitle => 'Importazione video';

  @override
  String get ffmpegStep1Title => 'Passaggio 1: Verifica FFmpeg';

  @override
  String get ffmpegDescription =>
      'FFmpeg è una suite gratuita e open source per l’elaborazione di video e audio. AnnotateIt utilizza FFmpeg su Windows per estrarre fotogrammi individuali dal tuo video per l’annotazione.';

  @override
  String get ffmpegWebsite => 'Sito web di FFmpeg';

  @override
  String get ffmpegWindowsBuilds => 'Build per Windows';

  @override
  String get ffmpegTip =>
      'Suggerimento: Dopo l’installazione, aggiungi ffmpeg.exe al PATH oppure fai clic su \"Seleziona FFmpeg\" per scegliere l’eseguibile.';

  @override
  String ffmpegUsingPath(Object path) {
    return 'Utilizzo: $path';
  }

  @override
  String get ffmpegUnavailable =>
      'FFmpeg non disponibile. Seleziona prima ffmpeg.exe.';

  @override
  String get ffmpegSelectButton => 'Seleziona FFmpeg';

  @override
  String get ffmpegRecheckButton => 'Ricontrolla';

  @override
  String get videoStep2Title => 'Passaggio 2: Seleziona il file video';

  @override
  String get videoStep2Text =>
      'Dopo aver risolto FFmpeg, fai clic su Continua per scegliere un video da importare.';

  @override
  String get mobileFramesInfo =>
      'I fotogrammi verranno estratti utilizzando le funzionalità integrate del dispositivo (FFmpeg non richiesto).';

  @override
  String get mobileTapContinueInfo =>
      'Tocca Continua per scegliere un file video da importare ed estrarre i fotogrammi come immagini.';

  @override
  String get importNotCompletedTitle => 'Importazione non completata';

  @override
  String importNotCompletedDiagnostics(Object diag) {
    return 'Impossibile estrarre i fotogrammi dal video selezionato.\n\nDiagnostica:\n$diag';
  }

  @override
  String get uploadStopped => 'Caricamento interrotto';

  @override
  String get importCompleteTitle => 'Importazione completata';

  @override
  String get importCompleteExtractedPrefix => 'Estratti';

  @override
  String get importCompleteFrame => 'fotogramma';

  @override
  String get importCompleteFrames => 'fotogrammi';

  @override
  String get importCompleteAndAdded => 'e aggiunti al dataset.';

  @override
  String get viaFfmpeg => '(tramite FFmpeg)';

  @override
  String get viaVideoThumbnail => '(tramite video_thumbnail)';

  @override
  String get cameraLinuxUnsupported =>
      'La funzionalità della fotocamera non è supportata su Linux';

  @override
  String videoToFramesFailed(Object error) {
    return 'Conversione video in fotogrammi non riuscita: $error';
  }

  @override
  String get selectFfmpegDialogTitle => 'Seleziona eseguibile ffmpeg';

  @override
  String get preLabelIntroTflite =>
      'Analizza automaticamente le immagini del progetto usando un modello TensorFlow Lite e propone nomi di etichette. Puoi rivederle e modificarle prima di salvare.';

  @override
  String get preLabelIntroMlkit =>
      'Analizza automaticamente le immagini del progetto con Google ML Kit e propone nomi di etichette. Puoi rivederle e modificarle prima di salvare.';

  @override
  String get preLabelErrorReadDatasetsTryAgain =>
      'Impossibile leggere i dataset. Riprova.';

  @override
  String get preLabelErrorCheckModelAvailability =>
      'Impossibile verificare la disponibilità del modello.';

  @override
  String preLabelProcessedOfTotalImages(Object processed, Object total) {
    return 'Elaborate $processed su $total immagini';
  }

  @override
  String get preLabelNoImagesUploadFirst =>
      'Nessuna immagine trovata nei dataset del progetto. Carica prima dei media.';

  @override
  String get preLabelNoLabelsSuggested =>
      'Non sono state suggerite etichette. Puoi chiudere questa finestra.';

  @override
  String get preLabelStep1Title => 'Passaggio 1: Verifica prerequisiti';

  @override
  String get preLabelCheckingProjectAndModels =>
      'Verifica di progetto e modelli...';

  @override
  String preLabelImagesInProjectDatasets(Object count) {
    return 'Immagini nei dataset del progetto: $count';
  }

  @override
  String get preLabelModelAvailableInFolder =>
      'Modello disponibile nella tua cartella Models';

  @override
  String get preLabelModelMissingPleaseDownload =>
      'Modello mancante. Scaricalo prima.';

  @override
  String get preLabelRecheck => 'Ricontrolla';

  @override
  String get preLabelAllPrerequisitesMet =>
      'Tutti i prerequisiti sono soddisfatti';

  @override
  String preLabelChipImages(Object count) {
    return 'Immagini: $count';
  }

  @override
  String get preLabelBackendTfliteDetection => 'Backend: TFLite Rilevamento';

  @override
  String get preLabelBackendTfliteClassification =>
      'Backend: TFLite Classificazione';

  @override
  String get preLabelBackendMlkit => 'Backend: ML Kit';

  @override
  String get preLabelYouCanProceed =>
      'Puoi procedere con la pre‑etichettatura quando sei pronto.';

  @override
  String get preLabelStartPreLabeling => 'Avvia pre‑etichettatura';

  @override
  String get preLabelStep0Title => 'Passaggio 0: Cosa succederà dopo';

  @override
  String get preLabelBulletScanTflite =>
      '• Le immagini del progetto verranno analizzate con il tuo modello TensorFlow Lite.';

  @override
  String get preLabelBulletScanMlkit =>
      '• Le immagini del progetto verranno analizzate con Google ML Kit su questo dispositivo.';

  @override
  String get preLabelBulletProposeLabels =>
      '• Proporremo nomi di etichette trovati nelle immagini. Potrai rivederli e modificarli.';

  @override
  String get preLabelBulletStartPreAnnotationSavesLabels =>
      '• Facendo clic su \"Avvia pre‑annotazione\", le etichette verranno salvate nel progetto.';

  @override
  String get preLabelBulletThenAutoAnnotateDetection =>
      '• Le immagini verranno poi annotate automaticamente con riquadri di delimitazione per le etichette rilevate.';

  @override
  String get preLabelBulletThenAutoAnnotateClassification =>
      '• Le immagini verranno poi annotate automaticamente con etichette di classificazione.';

  @override
  String get preLabelBulletRespectExisting =>
      '• Le annotazioni esistenti vengono rispettate ed evitate duplicazioni.';

  @override
  String get preLabelBulletCancelAnyTime =>
      '• Puoi annullare in qualsiasi momento. Nei progetti grandi l’operazione può richiedere tempo.';

  @override
  String preLabelProgressPercent(Object percent) {
    return 'Avanzamento: $percent%';
  }

  @override
  String get preLabelScanningImages => 'Analisi delle immagini in corso...';

  @override
  String get preLabelErrorReadDatasets => 'Impossibile leggere i dataset.';

  @override
  String get preLabelErrorDetectionModelMissing =>
      'Modello di rilevamento non trovato nella cartella Models. Scaricalo dalla schermata Modelli.';

  @override
  String get preLabelErrorClassificationModelMissing =>
      'Modello di classificazione non trovato nella cartella Models. Scaricalo dalla schermata Modelli.';

  @override
  String preLabelErrorInitBackendWithDetails(Object details) {
    return 'Impossibile inizializzare il backend di etichettatura. Controlla i file del modello o i permessi.\n\nDettagli: $details';
  }

  @override
  String get preLabelSavingLabels => 'Salvataggio etichette...';

  @override
  String get preLabelErrorSaveLabelsOrAnnotate =>
      'Impossibile salvare le etichette o annotare le immagini';

  @override
  String get preLabelAnnotatingImages => 'Annotazione delle immagini...';

  @override
  String get preLabelStartPreAnnotation => 'Avvia pre‑annotazione';

  @override
  String get preLabelSummaryTitle => 'Riepilogo';

  @override
  String get preLabelSummaryLabelsAdded => 'Etichette aggiunte';

  @override
  String get preLabelSummaryImagesAnnotated => 'Immagini annotate';

  @override
  String get preLabelSummaryAnnotationsAdded => 'Annotazioni aggiunte';

  @override
  String get buttonOpenProject => 'Apri progetto';
}
