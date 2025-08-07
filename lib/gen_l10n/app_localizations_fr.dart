// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get buttonKeep => 'Conserver';

  @override
  String get buttonSave => 'Enregistrer';

  @override
  String get buttonHelp => 'Aide';

  @override
  String get buttonEdit => 'Modifier';

  @override
  String get buttonNext => 'Suivant';

  @override
  String get buttonBack => 'Retour';

  @override
  String get buttonApply => 'Appliquer';

  @override
  String get buttonClose => 'Fermer';

  @override
  String get buttonImport => 'Importer';

  @override
  String get buttonCancel => 'Annuler';

  @override
  String get buttonFinish => 'Terminer';

  @override
  String get buttonDelete => 'Supprimer';

  @override
  String get buttonDuplicate => 'Dupliquer';

  @override
  String get buttonConfirm => 'Confirmer';

  @override
  String get buttonDiscard => 'Abandonner';

  @override
  String get buttonFeedbackShort => 'Retour';

  @override
  String get buttonImportLabels => 'Importer des Étiquettes';

  @override
  String get buttonExportLabels => 'Exporter des Étiquettes';

  @override
  String get buttonNextConfirmTask => 'Suivant: Confirmer la Tâche';

  @override
  String get buttonCreateProject => 'Créer un Projet';

  @override
  String get aboutTitle => 'À propos d\'Annot@It';

  @override
  String get aboutDescription =>
      'Annot@It est une application d\'annotation conçue pour simplifier le processus d\'annotation pour les projets de vision par ordinateur. Que vous travailliez sur la classification d\'images, la détection d\'objets, la segmentation ou d\'autres tâches de vision, Annot@It offre la flexibilité et la précision nécessaires pour un étiquetage de données de haute qualité.';

  @override
  String get aboutFeaturesTitle => 'Fonctionnalités clés:';

  @override
  String get aboutFeatures =>
      '- Types de projets multiples: Créez et gérez des projets adaptés à différentes tâches de vision par ordinateur.\n- Téléchargement et gestion des données: Téléchargez et organisez facilement vos ensembles de données pour une annotation fluide.\n- Outils d\'annotation avancés: Utilisez des boîtes englobantes, des polygones, des points clés et des masques de segmentation.\n- Exportation et intégration: Exportez des données étiquetées dans divers formats compatibles avec les frameworks d\'IA/ML.';

  @override
  String get aboutCallToAction =>
      'Commencez votre parcours d\'annotation aujourd\'hui et créez des ensembles de données de haute qualité pour vos modèles de vision par ordinateur!';

  @override
  String get accountUser => 'Utilisateur';

  @override
  String get accountProfile => 'Profil';

  @override
  String get accountStorage => 'Stockage';

  @override
  String get accountDeviceStorage => 'Stockage de l\'Appareil';

  @override
  String get accountSettings => 'Paramètres';

  @override
  String get accountApplicationSettings => 'Paramètres de l\'Application';

  @override
  String get accountLoadingMessage => 'Chargement des données utilisateur...';

  @override
  String get accountErrorLoadingUser => 'Could not  load user data';

  @override
  String get accountRetry => 'Retry';

  @override
  String get userProfileName => 'Capitaine Annotateur';

  @override
  String get userProfileFeedbackButton => 'Commentaires';

  @override
  String get userProfileEditProfileButton => 'Modifier le Profil';

  @override
  String get userProfileProjects => 'Projets';

  @override
  String get userProfileLabels => 'Étiquettes';

  @override
  String get userProfileMedia => 'Médias';

  @override
  String get userProfileOverview => 'Aperçu';

  @override
  String get userProfileAnnotations => 'Annotations';

  @override
  String get settingsGeneralTitle => 'Paramètres Généraux';

  @override
  String get settingsProjectCreationTitle => 'Création de Projet';

  @override
  String get settingsProjectCreationConfirmNoLabels =>
      'Toujours demander confirmation lors de la création d\'un projet sans étiquettes';

  @override
  String get settingsProjectCreationConfirmNoLabelsNote =>
      'Vous serez averti si vous essayez de créer un projet sans aucune étiquette définie.';

  @override
  String get settingsLabelsCreationDeletionTitle =>
      'Création / Suppression d\'Étiquettes';

  @override
  String get settingsLabelsDeletionWithAnnotations =>
      'Supprimer les annotations lorsque l\'étiquette est supprimée';

  @override
  String get settingsLabelsDeletionWithAnnotationsNote =>
      'Lorsque cette option est activée, la suppression d\'une étiquette supprimera automatiquement toutes les annotations attribuées à cette étiquette dans tous les éléments multimédias.';

  @override
  String get settingsLabelsSetDefaultLabel =>
      'Définir la première étiquette comme étiquette par défaut';

  @override
  String get settingsLabelsSetDefaultLabelNote =>
      'Lorsque cette option est activée, la première étiquette que vous créez dans un projet sera automatiquement marquée comme étiquette par défaut. Vous pouvez modifier la valeur par défaut ultérieurement à tout moment.';

  @override
  String get settingsDatasetViewTitle => 'Vue de l\'Ensemble de Données';

  @override
  String get settingsDatasetViewDuplicateWithAnnotations =>
      'Dupliquer (faire une copie) l\'image toujours avec les annotations';

  @override
  String get settingsDatasetViewDuplicateWithAnnotationsNote =>
      'Lors de la duplication, les annotations seront incluses à moins que vous ne modifiiez les paramètres';

  @override
  String get settingsDatasetViewDeleteFromOS =>
      'Lors de la suppression d\'une image de l\'Ensemble de Données, toujours la supprimer du système d\'exploitation / système de fichiers';

  @override
  String get settingsDatasetViewDeleteFromOSNote =>
      'Supprime également le fichier du disque, pas seulement de l\'ensemble de données';

  @override
  String get settingsAnnotationTitle => 'Paramètres d\'Annotation';

  @override
  String get settingsAnnotationOpacity => 'Opacité de l\'annotation';

  @override
  String get settingsAnnotationAutoSave =>
      'Toujours enregistrer ou soumettre l\'annotation lors du passage à l\'image suivante';

  @override
  String get settingsThemeTitle => 'Sélection du thème';

  @override
  String get settingsLanguageTitle => 'Pays / Langue';

  @override
  String get colorPickerTitle => 'Choisir une couleur';

  @override
  String get colorPickerBasicColors => 'Couleurs de base';

  @override
  String get loadingProjects => 'Chargement des projets...';

  @override
  String get importDataset => 'Importer un ensemble de données';

  @override
  String get uploadMedia => 'Télécharger des médias';

  @override
  String get createProjectTitle => 'Créer un Nouveau Projet';

  @override
  String get createProjectStepOneSubtitle =>
      'Veuillez entrer le nom de votre nouveau projet et sélectionner le type de projet';

  @override
  String get createProjectStepTwoSubtitle =>
      'Veuillez créer des étiquettes pour un nouveau projet';

  @override
  String get emptyProjectTitle => 'Commencez votre premier projet';

  @override
  String get emptyProjectDescription =>
      'Créez un projet pour commencer à organiser des ensembles de données, annoter des médias et appliquer l\'IA à vos tâches de vision — le tout dans un espace de travail rationalisé conçu pour accélérer votre pipeline de vision par ordinateur.';

  @override
  String get emptyProjectCreateNew => 'Créer un Nouveau Projet';

  @override
  String get emptyProjectCreateNewShort => 'Nouveau Projet';

  @override
  String get emptyProjectImportDataset =>
      'Créer un Projet à partir de l\'importation d\'un Ensemble de Données';

  @override
  String get emptyProjectImportDatasetShort =>
      'Importer un Ensemble de Données';

  @override
  String get dialogBack => '<- Retour';

  @override
  String get dialogNext => 'Suivant ->';

  @override
  String get rename => 'Renommer';

  @override
  String get delete => 'Supprimer';

  @override
  String get setAsDefault => 'Définir par Défaut';

  @override
  String paginationPageFromTotal(int current, int total) {
    return 'Page $current sur $total';
  }

  @override
  String get taskTypeRequiredTitle => 'Type de Tâche Requis';

  @override
  String taskTypeRequiredMessage(Object tab) {
    return 'Vous devez sélectionner un type de tâche avant de continuer. L\'onglet actuel \'$tab\' n\'a pas de type de tâche sélectionné. Chaque projet doit être associé à une tâche (par exemple, détection d\'objets, classification ou segmentation) pour que le système sache comment traiter vos données.';
  }

  @override
  String taskTypeRequiredTips(Object tab) {
    return 'Cliquez sur l\'une des options de type de tâche disponibles sous l\'onglet \'$tab\'. Si vous n\'êtes pas sûr de quelle tâche choisir, passez la souris sur l\'icône d\'information à côté de chaque type pour voir une brève description.';
  }

  @override
  String get menuProjects => 'Projets';

  @override
  String get menuAccount => 'Compte';

  @override
  String get menuLearn => 'Apprendre';

  @override
  String get menuAbout => 'À propos';

  @override
  String get menuCreateNewProject => 'Créer un nouveau projet';

  @override
  String get menuCreateFromDataset =>
      'Créer à partir d\'un Ensemble de Données';

  @override
  String get menuImportDataset =>
      'Créer un projet à partir de l\'Importation d\'un Ensemble de Données';

  @override
  String get menuSortLastUpdated => 'Dernière Mise à Jour';

  @override
  String get menuSortNewestOldest => 'Plus Récent-Plus Ancien';

  @override
  String get menuSortOldestNewest => 'Plus Ancien-Plus Récent';

  @override
  String get menuSortType => 'Type de Projet';

  @override
  String get menuSortAz => 'A-Z';

  @override
  String get menuSortZa => 'Z-A';

  @override
  String get projectNameLabel => 'Nom du Projet';

  @override
  String get tabDetection => 'Détection';

  @override
  String get tabClassification => 'Classification';

  @override
  String get tabSegmentation => 'Segmentation';

  @override
  String get labelRequiredTitle => 'Au Moins Une Étiquette Requise';

  @override
  String get labelRequiredMessage =>
      'Vous devez créer au moins une étiquette pour continuer. Les étiquettes sont essentielles pour définir les catégories d\'annotation qui seront utilisées lors de la préparation de l\'ensemble de données.';

  @override
  String get labelRequiredTips =>
      'Astuce: Cliquez sur le bouton rouge intitulé Créer une Étiquette après avoir saisi un nom d\'étiquette pour ajouter votre première étiquette.';

  @override
  String get createLabelButton => 'Créer une Étiquette';

  @override
  String get labelNameHint => 'Entrez un nouveau nom d\'Étiquette ici';

  @override
  String get createdLabelsTitle => 'Étiquettes Créées';

  @override
  String get labelEmptyTitle => 'Le nom de l\'étiquette ne peut pas être vide!';

  @override
  String get labelEmptyMessage =>
      'Veuillez entrer un nom d\'étiquette. Les étiquettes aident à identifier les objets ou catégories dans votre projet. Il est recommandé d\'utiliser des noms courts, clairs et descriptifs, tels que \"Voiture\", \"Personne\" ou \"Arbre\". Évitez les caractères spéciaux ou les espaces.';

  @override
  String get labelEmptyTips =>
      'Conseils pour Nommer les Étiquettes:\n• Utilisez des noms courts et descriptifs\n• Tenez-vous-en aux lettres, chiffres, traits de soulignement (par exemple, chat, panneau_routier, arrière-plan)\n• Évitez les espaces et les symboles (par exemple, Personne 1 → personne_1)';

  @override
  String get labelDuplicateTitle => 'Nom d\'Étiquette en Double';

  @override
  String labelDuplicateMessage(Object label) {
    return 'L\'étiquette \'$label\' existe déjà dans ce projet. Chaque étiquette doit avoir un nom unique pour éviter toute confusion lors de l\'annotation et de l\'entraînement.';
  }

  @override
  String get labelDuplicateTips =>
      'Pourquoi des étiquettes uniques?\n• Réutiliser le même nom peut causer des problèmes lors de l\'exportation de l\'ensemble de données et de l\'entraînement du modèle.\n• Les noms d\'étiquettes uniques aident à maintenir des annotations claires et structurées.\n\nAstuce: Essayez d\'ajouter une variation ou un numéro pour différencier (par exemple, \'Voiture\', \'Voiture_2\').';

  @override
  String get binaryLimitTitle => 'Limite de Classification Binaire';

  @override
  String get binaryLimitMessage =>
      'Vous ne pouvez pas créer plus de deux étiquettes pour un projet de Classification Binaire.\n\nLa Classification Binaire est conçue pour distinguer entre exactement deux classes, comme \'Oui\' vs \'Non\', ou \'Spam\' vs \'Non Spam\'.';

  @override
  String get binaryLimitTips =>
      'Besoin de plus de deux étiquettes?\nEnvisagez de changer le type de votre projet en Classification Multi-Classes ou une autre tâche appropriée afin de prendre en charge trois catégories ou plus.';

  @override
  String get noteBinaryClassification =>
      'Ce type de projet permet exactement 2 étiquettes. La Classification Binaire est utilisée lorsque votre modèle doit distinguer entre deux classes possibles, comme \"Oui\" vs \"Non\", ou \"Chien\" vs \"Pas Chien\". Veuillez créer seulement deux étiquettes distinctes.';

  @override
  String get noteMultiClassClassification =>
      'Ce type de projet prend en charge plusieurs étiquettes. La Classification Multi-Classes convient lorsque votre modèle doit choisir parmi trois catégories ou plus, comme \"Chat\", \"Chien\", \"Lapin\". Vous pouvez ajouter autant d\'étiquettes que nécessaire.';

  @override
  String get noteDetectionOrSegmentation =>
      'Ce type de projet prend en charge plusieurs étiquettes. Pour la Détection d\'Objets ou la Segmentation, chaque étiquette représente généralement une classe différente d\'objet (par exemple, \"Voiture\", \"Piéton\", \"Vélo\"). Vous pouvez créer autant d\'étiquettes que nécessaire pour votre ensemble de données.';

  @override
  String get noteDefault =>
      'Vous pouvez créer une ou plusieurs étiquettes selon votre type de projet. Chaque étiquette aide à définir une catégorie que votre modèle apprendra à reconnaître. Veuillez consulter la documentation pour les meilleures pratiques.';

  @override
  String get discardDatasetImportTitle =>
      'Abandonner l\'Importation de l\'Ensemble de Données?';

  @override
  String get discardDatasetImportMessage =>
      'Vous avez déjà extrait un ensemble de données. Annuler maintenant supprimera les fichiers extraits et les détails de l\'ensemble de données détectés. Êtes-vous sûr de vouloir continuer?';

  @override
  String get projectTypeHelpTitle => 'Aide pour la Sélection du Type de Projet';

  @override
  String get projectTypeWhyDisabledTitle =>
      'Pourquoi certains types de projet sont-ils désactivés?';

  @override
  String get projectTypeWhyDisabledBody =>
      'Lorsque vous importez un ensemble de données, le système analyse les annotations fournies et essaie de détecter automatiquement le type de projet le plus approprié pour vous.\n\nPar exemple, si votre ensemble de données contient des annotations de boîtes englobantes, le type de projet suggéré sera \"Détection\". S\'il contient des masques, \"Segmentation\" sera suggéré, et ainsi de suite.\n\nPour protéger vos données, seuls les types de projet compatibles sont activés par défaut.';

  @override
  String get projectTypeAllowChangeTitle =>
      'Que se passe-t-il si j\'active le changement de type de projet?';

  @override
  String get projectTypeAllowChangeBody =>
      'Si vous activez \"Autoriser le Changement de Type de Projet\", vous pouvez sélectionner manuellement N\'IMPORTE QUEL type de projet, même s\'il ne correspond pas aux annotations détectées.\n\n⚠️ AVERTISSEMENT: Toutes les annotations existantes de l\'importation seront supprimées lors du passage à un type de projet incompatible.\nVous devrez réannoter ou importer un ensemble de données adapté au type de projet nouvellement sélectionné.';

  @override
  String get projectTypeWhenUseTitle =>
      'Quand devrais-je utiliser cette option?';

  @override
  String get projectTypeWhenUseBody =>
      'Vous ne devriez activer cette option que si:\n\n- Vous avez accidentellement importé le mauvais ensemble de données.\n- Vous souhaitez démarrer un nouveau projet d\'annotation avec un type différent.\n- La structure de votre ensemble de données a changé après l\'importation.\n\nSi vous n\'êtes pas sûr, nous vous recommandons fortement de conserver la sélection par défaut pour éviter la perte de données.';

  @override
  String get allLabels => 'Toutes les Étiquettes';

  @override
  String get setAsProjectIcon => 'Définir comme Icône du Projet';

  @override
  String setAsProjectIconConfirm(Object filePath) {
    return 'Voulez-vous utiliser \'$filePath\' comme icône pour ce projet?\n\nCela remplacera toute icône précédemment définie.';
  }

  @override
  String get removeFilesFromDatasetInProgress => 'Suppression des fichiers...';

  @override
  String get removeFilesFromDataset =>
      'Supprimer les fichiers de l\'Ensemble de Données?';

  @override
  String removeFilesFromDatasetConfirm(Object amount) {
    return 'Êtes-vous sûr de vouloir supprimer les fichiers suivants (\'$amount\')?\n\nToutes les annotations correspondantes seront également supprimées.';
  }

  @override
  String get removeFilesFailedTitle => 'Échec de la Suppression';

  @override
  String get removeFilesFailedMessage =>
      'Certains fichiers n\'ont pas pu être supprimés';

  @override
  String get removeFilesFailedTips =>
      'Veuillez vérifier les permissions des fichiers et réessayer';

  @override
  String get duplicateImage => 'Dupliquer l\'Image';

  @override
  String get duplicateWithAnnotations =>
      'Dupliquer l\'image avec les annotations';

  @override
  String get duplicateWithAnnotationsHint =>
      'Une copie de l\'image sera créée avec toutes les données d\'annotation.';

  @override
  String get duplicateImageOnly => 'Dupliquer l\'image uniquement';

  @override
  String get duplicateImageOnlyHint =>
      'Seule l\'image sera copiée, sans les annotations.';

  @override
  String get saveDuplicateChoiceAsDefault =>
      'Enregistrer cette réponse comme réponse par défaut et ne plus demander\n(Vous pouvez modifier cela dans Compte -> Paramètres de l\'application -> Navigation de l\'ensemble de données)';

  @override
  String get editProjectTitle => 'Modifier le nom du projet';

  @override
  String get editProjectDescription =>
      'Veuillez choisir un nom de projet clair et descriptif (3 - 86 caractères). Il est recommandé d\'éviter les caractères spéciaux.';

  @override
  String get deleteProjectTitle => 'Supprimer le Projet';

  @override
  String get deleteProjectInProgress => 'Suppression du projet...';

  @override
  String get deleteProjectOptionDeleteFromDisk =>
      'Supprimer également tous les fichiers du disque';

  @override
  String get deleteProjectOptionDontAskAgain => 'Ne plus me demander';

  @override
  String deleteProjectConfirm(Object projectName) {
    return 'Êtes-vous sûr de vouloir supprimer le projet \"$projectName\"?';
  }

  @override
  String deleteProjectInfoLine(Object creationDate, Object labelCount) {
    return 'Le projet a été créé le $creationDate\nNombre d\'Étiquettes: $labelCount';
  }

  @override
  String get deleteDatasetTitle => 'Supprimer l\'Ensemble de Données';

  @override
  String get deleteDatasetInProgress =>
      'Suppression de l\'ensemble de données... Veuillez patienter.';

  @override
  String deleteDatasetConfirm(Object datasetName) {
    return 'Êtes-vous sûr de vouloir supprimer \"$datasetName\"?';
  }

  @override
  String deleteDatasetInfoLine(
    Object creationDate,
    Object mediaCount,
    Object annotationCount,
  ) {
    return 'Cet ensemble de données a été créé le $creationDate et contient $mediaCount éléments multimédias et $annotationCount annotations.';
  }

  @override
  String get editDatasetTitle => 'Renommer l\'Ensemble de Données';

  @override
  String get editDatasetDescription =>
      'Entrez un nouveau nom pour cet ensemble de données:';

  @override
  String get noMediaDialogUploadPrompt =>
      'Vous devez télécharger des images ou des vidéos';

  @override
  String get noMediaDialogUploadPromptShort => 'Télécharger des médias';

  @override
  String get noMediaDialogSupportedImageTypesTitle =>
      'Types d\'images pris en charge:';

  @override
  String get noMediaDialogSupportedImageTypesList =>
      'jpg, jpeg, png, bmp, jfif, webp';

  @override
  String get noMediaDialogSupportedVideoFormatsLink =>
      'Cliquez ici pour voir quels formats vidéo sont pris en charge sur votre plateforme';

  @override
  String get noMediaDialogSupportedVideoFormatsTitle =>
      'Formats Vidéo Pris en Charge';

  @override
  String get noMediaDialogSupportedVideoFormatsList =>
      'Formats Couramment Pris en Charge:\n\n- MP4: Android, iOS, Web, Bureau\n- MOV: Android, iOS, macOS\n- M4V: Android, iOS, macOS\n- WEBM: Android, Web (dépend du navigateur)\n- MKV: Android (partiel), Windows\n- AVI: Android/Windows uniquement (partiel)';

  @override
  String get noMediaDialogSupportedVideoFormatsWarning =>
      'La prise en charge peut varier selon la plateforme et le codec vidéo.\nCertains formats peuvent ne pas fonctionner dans les navigateurs ou sur iOS.';

  @override
  String get annotatorTopToolbarBackTooltip => 'Retour au Projet';

  @override
  String get annotatorTopToolbarSelectDefaultLabel => 'Étiquette par défaut';

  @override
  String get toolbarNavigation => 'Navigation';

  @override
  String get toolbarBbox => 'Dessiner une Boîte Englobante';

  @override
  String get toolbarPolygon => 'Dessiner un Polygone';

  @override
  String get toolbarSAM => 'Modèle de Segmentation Automatique';

  @override
  String get toolbarResetZoom => 'Réinitialiser le Zoom';

  @override
  String get toolbarToggleGrid => 'Basculer la Grille';

  @override
  String get toolbarAnnotationSettings => 'Paramètres d\'Annotation';

  @override
  String get toolbarToggleAnnotationNames => 'Basculer les Noms d\'Annotation';

  @override
  String get toolbarRotateLeft => 'Rotation à Gauche (Bientôt Disponible)';

  @override
  String get toolbarRotateRight => 'Rotation à Droite (Bientôt Disponible)';

  @override
  String get toolbarHelp => 'Aide';

  @override
  String get dialogOpacityTitle => 'Opacité de Remplissage d\'Annotation';

  @override
  String get dialogHelpTitle => 'Aide de la Barre d\'Outils de l\'Annotateur';

  @override
  String get dialogHelpContent =>
      '• Navigation – Utilisez pour sélectionner et vous déplacer sur le canevas.\n• Boîte Englobante – (Visible dans les projets de Détection) Dessinez des boîtes englobantes rectangulaires.\n• Réinitialiser le Zoom – Réinitialise le niveau de zoom pour ajuster l\'image à l\'écran.\n• Basculer la Grille – Afficher ou masquer la grille de vignettes de l\'ensemble de données.\n• Paramètres – Ajustez l\'opacité de remplissage des annotations, la bordure des annotations et la taille des coins.\n• Basculer les Noms d\'Annotation – Afficher ou masquer les étiquettes de texte sur les annotations.';

  @override
  String get dialogHelpTips =>
      'Astuce: Utilisez le mode Navigation pour sélectionner et modifier les annotations.\nPlus de raccourcis et de fonctionnalités à venir!';

  @override
  String get dialogOpacityExplanation =>
      'Ajustez le niveau d\'opacité pour rendre le contenu plus ou moins transparent.';

  @override
  String get deleteAnnotationTitle => 'Supprimer l\'Annotation';

  @override
  String get deleteAnnotationMessage => 'Êtes-vous sûr de vouloir supprimer';

  @override
  String get unnamedAnnotation => 'cette annotation';

  @override
  String get accountStorage_importFolderTitle =>
      'Dossier d\'importation des Ensembles de Données';

  @override
  String get accountStorage_thumbnailsFolderTitle => 'Dossier des Vignettes';

  @override
  String get accountStorage_exportFolderTitle =>
      'Dossier d\'exportation des Ensembles de Données';

  @override
  String get accountStorage_folderTooltip => 'Choisir un dossier';

  @override
  String get accountStorage_helpTitle => 'Aide sur le Stockage';

  @override
  String get accountStorage_helpMessage =>
      'Vous pouvez modifier le dossier où sont stockés les ensembles de données importés, les archives ZIP exportées et les vignettes.\nAppuyez sur l\'icône \"Dossier\" à côté du champ de chemin pour sélectionner ou modifier le répertoire.\n\nCe dossier sera utilisé comme emplacement par défaut pour:\n- Les fichiers d\'ensembles de données importés (par exemple, COCO, YOLO, VOC, Datumaro, etc.)\n- Les archives Zip d\'ensembles de données exportés\n- Les vignettes de projets\n\nAssurez-vous que le dossier sélectionné est accessible en écriture et dispose de suffisamment d\'espace.\nSur Android ou iOS, vous devrez peut-être accorder des autorisations de stockage.\nLes dossiers recommandés varient selon la plateforme — voir ci-dessous les conseils spécifiques à chaque plateforme.';

  @override
  String get accountStorage_helpTips =>
      'Dossiers recommandés par plateforme:\n\nWindows:\n  C:\\Users\\<vous>\\AppData\\Roaming\\AnnotateIt\\datasets\n\nLinux / Ubuntu:\n  /home/<vous>/.annotateit/datasets\n\nmacOS:\n  /Users/<vous>/Library/Application Support/AnnotateIt/datasets\n\nAndroid:\n  /storage/emulated/0/AnnotateIt/datasets\n\niOS:\n  <Chemin sandbox de l\'app>/Documents/AnnotateIt/datasets\n';

  @override
  String get accountStorage_copySuccess =>
      'Chemin copié dans le presse-papiers';

  @override
  String get accountStorage_openError => 'Le dossier n\'existe pas:\n';

  @override
  String get accountStorage_pathEmpty => 'Le chemin est vide';

  @override
  String get accountStorage_openFailed => 'Échec de l\'ouverture du dossier:\n';

  @override
  String get changeProjectTypeTitle => 'Changer le type de projet';

  @override
  String get changeProjectTypeMigrating => 'Migration du type de projet...';

  @override
  String get changeProjectTypeStepOneSubtitle =>
      'Veuillez sélectionner un nouveau type de projet dans la liste ci-dessous';

  @override
  String get changeProjectTypeStepTwoSubtitle =>
      'Veuillez confirmer votre choix';

  @override
  String get changeProjectTypeWarningTitle =>
      'Avertissement: Vous êtes sur le point de changer le type de projet.';

  @override
  String get changeProjectTypeConversionIntro =>
      'Toutes les annotations existantes seront converties comme suit:';

  @override
  String get changeProjectTypeConversionDetails =>
      '- Boîtes englobantes (Détection) -> converties en polygones rectangulaires.\n- Polygones (Segmentation) -> convertis en boîtes englobantes ajustées.\n\nRemarque: Ces conversions peuvent réduire la précision, en particulier lors de la conversion de polygones en boîtes, car les informations détaillées sur la forme seront perdues.\n\n- Détection / Segmentation → Classification:\n  Les images seront classées en fonction de l\'étiquette la plus fréquente dans les annotations:\n     -> Si l\'image a 5 objets étiquetés \"Chien\" et 10 étiquetés \"Chat\", elle sera classée comme \"Chat\".\n     -> Si les comptages sont égaux, la première étiquette trouvée sera utilisée.\n\n- Classification -> Détection / Segmentation:\n  Aucune annotation ne sera transférée. Vous devrez réannoter tous les éléments multimédias manuellement, car les projets de classification ne contiennent pas de données au niveau de la région.';

  @override
  String get changeProjectTypeErrorTitle => 'Échec de la Migration';

  @override
  String get changeProjectTypeErrorMessage =>
      'Une erreur s\'est produite lors du changement du type de projet. Les modifications n\'ont pas pu être appliquées.';

  @override
  String get changeProjectTypeErrorTips =>
      'Veuillez vérifier si le projet a des annotations valides et réessayer. Si le problème persiste, redémarrez l\'application ou contactez le support.';

  @override
  String get exportProjectAsDataset =>
      'Exporter le Projet en tant qu\'Ensemble de Données';

  @override
  String get projectHelpTitle => 'Comment Fonctionnent les Projets';

  @override
  String get projectHelpMessage =>
      'Les projets vous permettent d\'organiser des ensembles de données, des fichiers multimédias et des annotations en un seul endroit. Vous pouvez créer de nouveaux projets pour différentes tâches comme la détection, la classification ou la segmentation.';

  @override
  String get projectHelpTips =>
      'Astuce: Vous pouvez importer des ensembles de données au format COCO, YOLO, VOC, Labelme et Datumaro pour créer un projet automatiquement.';

  @override
  String get datasetDialogTitle =>
      'Importer un Ensemble de Données pour Créer un Projet';

  @override
  String get datasetDialogProcessing => 'Traitement...';

  @override
  String datasetDialogProcessingProgress(Object percent) {
    return 'Traitement... $percent%';
  }

  @override
  String get datasetDialogModeIsolate => 'Mode Isolé Activé';

  @override
  String get datasetDialogModeNormal => 'Mode Normal';

  @override
  String get datasetDialogNoDatasetLoaded =>
      'Aucun ensemble de données chargé.';

  @override
  String get datasetDialogSelectZipFile =>
      'Sélectionnez votre fichier ZIP d\'ensemble de données';

  @override
  String get datasetDialogChooseFile => 'Choisir un fichier';

  @override
  String get datasetDialogSupportedFormats =>
      'Formats d\'ensemble de données pris en charge :';

  @override
  String get datasetDialogSupportedFormatsList1 => 'COCO, YOLO, VOC, Datumaro,';

  @override
  String get datasetDialogSupportedFormatsList2 =>
      'LabelMe, CVAT, ou médias uniquement (.zip)';

  @override
  String get dialogImageDetailsTitle => 'Détails du fichier';

  @override
  String get datasetDialogImportFailedTitle => 'Échec de l\'Importation';

  @override
  String get datasetDialogImportFailedMessage =>
      'Le fichier ZIP n\'a pas pu être traité. Il peut être corrompu, incomplet ou ne pas être une archive d\'ensemble de données valide.';

  @override
  String get datasetDialogImportFailedTips =>
      'Essayez de réexporter ou de recompresser votre ensemble de données.\nAssurez-vous qu\'il est au format COCO, YOLO, VOC ou compatible.\n\nErreur: ';

  @override
  String get datasetDialogNoProjectTypeTitle =>
      'Aucun Type de Projet Sélectionné';

  @override
  String get datasetDialogNoProjectTypeMessage =>
      'Veuillez sélectionner un Type de Projet basé sur les types d\'annotation détectés dans votre ensemble de données.';

  @override
  String get datasetDialogNoProjectTypeTips =>
      'Vérifiez le format de votre ensemble de données et assurez-vous que les annotations suivent une structure prise en charge comme COCO, YOLO, VOC ou Datumaro.';

  @override
  String get datasetDialogProcessingDatasetTitle =>
      'Traitement de l\'Ensemble de Données';

  @override
  String get datasetDialogProcessingDatasetMessage =>
      'Nous extrayons actuellement votre archive ZIP, analysons son contenu et détectons le format de l\'ensemble de données et le type d\'annotation. Cela peut prendre de quelques secondes à quelques minutes selon la taille et la structure de l\'ensemble de données. Veuillez ne pas fermer cette fenêtre ou naviguer ailleurs pendant le processus.';

  @override
  String get datasetDialogProcessingDatasetTips =>
      'Les archives volumineuses avec de nombreuses images ou fichiers d\'annotation peuvent prendre plus de temps à traiter.';

  @override
  String get datasetDialogCreatingProjectTitle => 'Création du Projet';

  @override
  String get datasetDialogCreatingProjectMessage =>
      'Nous configurons votre projet, initialisons ses métadonnées et enregistrons toutes les configurations. Cela inclut l\'attribution d\'étiquettes, la création d\'ensembles de données et la liaison des fichiers multimédias associés. Veuillez patienter un moment et éviter de fermer cette fenêtre jusqu\'à ce que le processus soit terminé.';

  @override
  String get datasetDialogCreatingProjectTips =>
      'Les projets avec de nombreuses étiquettes ou fichiers multimédias peuvent prendre un peu plus de temps.';

  @override
  String get datasetDialogAnalyzingDatasetTitle =>
      'Analyse de l\'Ensemble de Données';

  @override
  String get datasetDialogAnalyzingDatasetMessage =>
      'Nous analysons actuellement votre archive d\'ensemble de données. Cela comprend l\'extraction de fichiers, la détection de la structure de l\'ensemble de données, l\'identification des formats d\'annotation et la collecte d\'informations sur les médias et les étiquettes. Veuillez attendre que le processus soit terminé. Fermer la fenêtre ou naviguer ailleurs peut interrompre l\'opération.';

  @override
  String get datasetDialogAnalyzingDatasetTips =>
      'Les ensembles de données volumineux avec de nombreux fichiers ou des annotations complexes peuvent prendre plus de temps.';

  @override
  String get datasetDialogFilePickErrorTitle =>
      'Erreur de Sélection de Fichier';

  @override
  String get datasetDialogFilePickErrorMessage =>
      'Échec de la sélection du fichier. Veuillez réessayer.';

  @override
  String get datasetDialogGenericErrorTips =>
      'Veuillez vérifier votre fichier et réessayer. Si le problème persiste, contactez le support.';

  @override
  String get thumbnailGenerationTitle => 'Erreur';

  @override
  String get thumbnailGenerationFailed =>
      'Échec de la génération de la vignette';

  @override
  String get thumbnailGenerationTryAgainLater => 'Veuillez réessayer plus tard';

  @override
  String get thumbnailGenerationInProgress => 'Génération de la vignette...';

  @override
  String get menuImageAnnotate => 'Annoter';

  @override
  String get menuImageDetails => 'Détails';

  @override
  String get menuImageDuplicate => 'Dupliquer';

  @override
  String get menuImageSetAsIcon => 'Comme Icône';

  @override
  String get menuImageDelete => 'Supprimer';

  @override
  String get noLabelsTitle => 'Vous n\'avez pas d\'Étiquettes dans le Projet';

  @override
  String get noLabelsExplain1 =>
      'Vous ne pouvez pas annoter sans étiquettes car les étiquettes donnent un sens à ce que vous marquez';

  @override
  String get noLabelsExplain2 =>
      'Vous pouvez ajouter des étiquettes manuellement ou les importer depuis un fichier JSON.';

  @override
  String get noLabelsExplain3 =>
      'Une annotation sans étiquette n\'est qu\'une boîte vide.';

  @override
  String get noLabelsExplain4 =>
      'Les étiquettes définissent les catégories ou classes que vous annotez dans votre ensemble de données.';

  @override
  String get noLabelsExplain5 =>
      'Que vous étiquetiez des objets dans des images, classiez ou segmentiez des régions,';

  @override
  String get noLabelsExplain6 =>
      'les étiquettes sont essentielles pour organiser vos annotations de manière claire et cohérente.';

  @override
  String get importLabelsPreviewTitle =>
      'Aperçu de l\'Importation d\'Étiquettes';

  @override
  String get importLabelsFailedTitle => 'Échec de l\'Importation d\'Étiquettes';

  @override
  String get importLabelsNoLabelsTitle =>
      'Aucune étiquette trouvée dans ce projet';

  @override
  String get importLabelsJsonParseError => 'Échec de l\'analyse JSON.\n';

  @override
  String get importLabelsJsonParseTips =>
      'Assurez-vous que le fichier est un JSON valide. Vous pouvez le valider sur https://jsonlint.com/';

  @override
  String importLabelsJsonNotList(Object type) {
    return 'Une liste d\'étiquettes (tableau) était attendue, mais a obtenu: $type.';
  }

  @override
  String get importLabelsJsonNotListTips =>
      'Votre fichier JSON doit commencer par [ et contenir plusieurs objets d\'étiquette. Chaque étiquette doit inclure les champs nom, couleur et ordre d\'étiquette.';

  @override
  String importLabelsJsonItemNotMap(Object type) {
    return 'L\'une des entrées de la liste n\'est pas un objet valide: $type';
  }

  @override
  String get importLabelsJsonItemNotMapTips =>
      'Chaque élément de la liste doit être un objet valide avec les champs: nom, couleur et ordre d\'étiquette.';

  @override
  String get importLabelsJsonLabelParseError =>
      'Échec de l\'analyse de l\'une des étiquettes.\n';

  @override
  String get importLabelsJsonLabelParseTips =>
      'Vérifiez que chaque étiquette a les champs requis comme le nom et la couleur, et que les valeurs sont des types corrects.';

  @override
  String get importLabelsUnexpectedError =>
      'Une erreur inattendue s\'est produite lors de l\'importation du fichier JSON.\n';

  @override
  String get importLabelsUnexpectedErrorTip =>
      'Veuillez vous assurer que votre fichier est lisible et correctement formaté.';

  @override
  String get importLabelsDatabaseError =>
      'Échec de l\'enregistrement des étiquettes dans la base de données';

  @override
  String get importLabelsDatabaseErrorTips =>
      'Veuillez vérifier votre connexion à la base de données et réessayer. Si le problème persiste, contactez le support.';

  @override
  String get importLabelsNameMissingOrEmpty =>
      'L\'une des étiquettes n\'a pas de nom valide.';

  @override
  String get importLabelsNameMissingOrEmptyTips =>
      'Assurez-vous que chaque étiquette dans le JSON inclut un champ \'nom\' non vide.';

  @override
  String get menuSortAZ => 'A-Z';

  @override
  String get menuSortZA => 'Z-A';

  @override
  String get menuSortProjectType => 'Type de Projet';

  @override
  String get uploadInProgressTitle => 'Téléchargement en Cours';

  @override
  String get uploadInProgressMessage =>
      'Vous avez un téléchargement actif en cours. Si vous quittez maintenant, le téléchargement sera annulé et vous devrez recommencer.\n\nVoulez-vous quitter quand même?';

  @override
  String get uploadInProgressStay => 'Rester';

  @override
  String get uploadInProgressLeave => 'Quitter';

  @override
  String get fileNotFound => 'Fichier introuvable ou permission refusée';

  @override
  String get labelEditSave => 'Enregistrer';

  @override
  String get labelEditEdit => 'Modifier';

  @override
  String get labelEditMoveUp => 'Déplacer vers le Haut';

  @override
  String get labelEditMoveDown => 'Déplacer vers le Bas';

  @override
  String get labelEditDelete => 'Supprimer';

  @override
  String get labelExportLabels => 'Exporter les Étiquettes';

  @override
  String get labelSaveDialogTitle =>
      'Enregistrer les étiquettes dans un fichier JSON';

  @override
  String get labelSaveDefaultFilename => 'etiquettes.json';

  @override
  String labelDeleteError(Object error) {
    return 'Échec de la suppression de l\'étiquette: $error';
  }

  @override
  String get labelDeleteErrorTips =>
      'Assurez-vous que l\'étiquette existe toujours ou n\'est pas utilisée ailleurs.';

  @override
  String get datasetStepUploadZip =>
      'Téléchargez un fichier ZIP au format COCO, YOLO, VOC, LabelMe, CVAT, Datumaro ou médias uniquement';

  @override
  String get datasetStepExtractingZip =>
      'Extraction du ZIP dans le stockage local ...';

  @override
  String datasetStepExtractedPath(Object path) {
    return 'Ensemble de données extrait dans: $path';
  }

  @override
  String datasetStepDetectedTaskType(Object format) {
    return 'Type de tâche détecté: $format';
  }

  @override
  String get datasetStepSelectProjectType => 'Sélectionner le type de projet';

  @override
  String get datasetStepProgressSelection =>
      'Sélection de l\'Ensemble de Données';

  @override
  String get datasetStepProgressExtract => 'Extraire le ZIP';

  @override
  String get datasetStepProgressOverview => 'Aperçu de l\'Ensemble de Données';

  @override
  String get datasetStepProgressTaskConfirmation => 'Confirmation de la Tâche';

  @override
  String get datasetStepProgressProjectCreation => 'Création du Projet';

  @override
  String get projectTypeDetectionBoundingBox =>
      'Détection avec boîte englobante';

  @override
  String get projectTypeDetectionOriented => 'Détection orientée';

  @override
  String get projectTypeBinaryClassification => 'Classification Binaire';

  @override
  String get projectTypeMultiClassClassification =>
      'Classification Multi-classes';

  @override
  String get projectTypeMultiLabelClassification =>
      'Classification Multi-étiquettes';

  @override
  String get projectTypeInstanceSegmentation => 'Segmentation d\'Instances';

  @override
  String get projectTypeSemanticSegmentation => 'Segmentation Sémantique';

  @override
  String get datasetStepChooseProjectType =>
      'Choisissez votre type de Projet en fonction des annotations détectées';

  @override
  String get datasetStepAllowProjectTypeChange =>
      'Autoriser le Changement de Type de Projet';

  @override
  String get projectTypeBinaryClassificationDescription =>
      'Attribuer une des deux étiquettes possibles à chaque entrée (par exemple, spam ou non spam, positif ou négatif).';

  @override
  String get projectTypeMultiClassClassificationDescription =>
      'Attribuer exactement une étiquette parmi un ensemble de classes mutuellement exclusives (par exemple, chat, chien ou oiseau).';

  @override
  String get projectTypeMultiLabelClassificationDescription =>
      'Attribuer une ou plusieurs étiquettes parmi un ensemble de classes — plusieurs étiquettes peuvent s\'appliquer en même temps (par exemple, une image étiquetée à la fois \"chat\" et \"chien\")';

  @override
  String get projectTypeDetectionBoundingBoxDescription =>
      'Dessiner un rectangle autour d\'un objet dans une image.';

  @override
  String get projectTypeDetectionOrientedDescription =>
      'Dessiner et enfermer un objet dans un rectangle minimal.';

  @override
  String get projectTypeInstanceSegmentationDescription =>
      'Détecter et distinguer chaque objet individuel en fonction de ses caractéristiques uniques.';

  @override
  String get projectTypeSemanticSegmentationDescription =>
      'Détecter et classifier tous les objets similaires comme une seule entité.';
}
