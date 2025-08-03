// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get buttonKeep => 'Mantener';

  @override
  String get buttonSave => 'Guardar';

  @override
  String get buttonHelp => 'Ayuda';

  @override
  String get buttonEdit => 'Editar';

  @override
  String get buttonNext => 'Siguiente';

  @override
  String get buttonBack => 'Atrás';

  @override
  String get buttonApply => 'Aplicar';

  @override
  String get buttonClose => 'Cerrar';

  @override
  String get buttonImport => 'Importar';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonFinish => 'Finalizar';

  @override
  String get buttonDelete => 'Eliminar';

  @override
  String get buttonDuplicate => 'Duplicar';

  @override
  String get buttonConfirm => 'Confirmar';

  @override
  String get buttonDiscard => 'Descartar';

  @override
  String get buttonFeedbackShort => 'Coment';

  @override
  String get buttonImportLabels => 'Importar Etiquetas';

  @override
  String get buttonExportLabels => 'Exportar Etiquetas';

  @override
  String get buttonNextConfirmTask => 'Siguiente: Confirmar Tarea';

  @override
  String get buttonCreateProject => 'Crear Proyecto';

  @override
  String get aboutTitle => 'Acerca de Annot@It';

  @override
  String get aboutDescription =>
      'Annot@It es una aplicación de anotación diseñada para agilizar el proceso de anotación para proyectos de visión por computadora. Ya sea que esté trabajando en clasificación de imágenes, detección de objetos, segmentación u otras tareas de visión, Annot@It proporciona la flexibilidad y precisión necesarias para el etiquetado de datos de alta calidad.';

  @override
  String get aboutFeaturesTitle => 'Características principales:';

  @override
  String get aboutFeatures =>
      '- Múltiples tipos de proyectos: Cree y gestione proyectos adaptados para diferentes tareas de visión por computadora.\n- Carga y gestión de datos: Cargue y organice fácilmente sus conjuntos de datos para una anotación sin problemas.\n- Herramientas avanzadas de anotación: Utilice cuadros delimitadores, polígonos, puntos clave y máscaras de segmentación.\n- Exportación e integración: Exporte datos etiquetados en varios formatos compatibles con marcos de IA/ML.';

  @override
  String get aboutCallToAction =>
      '¡Comience su viaje de anotación hoy y construya conjuntos de datos de alta calidad para sus modelos de visión por computadora!';

  @override
  String get accountUser => 'Usuario';

  @override
  String get accountProfile => 'Perfil';

  @override
  String get accountStorage => 'Almacenamiento';

  @override
  String get accountDeviceStorage => 'Almacenamiento del Dispositivo';

  @override
  String get accountSettings => 'Ajustes';

  @override
  String get accountApplicationSettings => 'Ajustes de la Aplicación';

  @override
  String get accountLoadingMessage => 'Cargando datos de usuario...';

  @override
  String get accountErrorLoadingUser => 'Could not  load user data';

  @override
  String get accountRetry => 'Retry';

  @override
  String get userProfileName => 'Capitán Anotador';

  @override
  String get userProfileFeedbackButton => 'Comentarios';

  @override
  String get userProfileEditProfileButton => 'Editar Perfil';

  @override
  String get userProfileProjects => 'Proyectos';

  @override
  String get userProfileLabels => 'Etiquetas';

  @override
  String get userProfileMedia => 'Medios';

  @override
  String get userProfileOverview => 'Resumen';

  @override
  String get userProfileAnnotations => 'Anotaciones';

  @override
  String get settingsGeneralTitle => 'Ajustes Generales';

  @override
  String get settingsProjectCreationTitle => 'Creación de Proyectos';

  @override
  String get settingsProjectCreationConfirmNoLabels =>
      'Siempre preguntar para confirmar cuando se crea un proyecto sin etiquetas';

  @override
  String get settingsProjectCreationConfirmNoLabelsNote =>
      'Se le advertirá si intenta crear un proyecto sin ninguna etiqueta definida.';

  @override
  String get settingsLabelsCreationDeletionTitle =>
      'Creación / Eliminación de Etiquetas';

  @override
  String get settingsLabelsDeletionWithAnnotations =>
      'Eliminar anotaciones cuando se elimina la etiqueta';

  @override
  String get settingsLabelsDeletionWithAnnotationsNote =>
      'Cuando está habilitado, eliminar una etiqueta eliminará automáticamente todas las anotaciones asignadas a esa etiqueta en todos los elementos multimedia.';

  @override
  String get settingsLabelsSetDefaultLabel =>
      'Establecer la primera etiqueta como predeterminada';

  @override
  String get settingsLabelsSetDefaultLabelNote =>
      'Cuando está habilitado, la primera etiqueta que cree en un proyecto se marcará automáticamente como la etiqueta predeterminada. Puede cambiar la predeterminada más tarde en cualquier momento.';

  @override
  String get settingsDatasetViewTitle => 'Vista del Conjunto de Datos';

  @override
  String get settingsDatasetViewDuplicateWithAnnotations =>
      'Duplicar (hacer una copia) imagen siempre con anotaciones';

  @override
  String get settingsDatasetViewDuplicateWithAnnotationsNote =>
      'Al duplicar, las anotaciones se incluirán a menos que cambie la configuración';

  @override
  String get settingsDatasetViewDeleteFromOS =>
      'Al eliminar imagen del Conjunto de Datos, siempre eliminarla del sistema operativo / sistema de archivos';

  @override
  String get settingsDatasetViewDeleteFromOSNote =>
      'Elimina el archivo del disco también, no solo del conjunto de datos';

  @override
  String get settingsAnnotationTitle => 'Ajustes de Anotación';

  @override
  String get settingsAnnotationOpacity => 'Opacidad de anotación';

  @override
  String get settingsAnnotationAutoSave =>
      'Siempre guardar o enviar anotación al pasar a la siguiente imagen';

  @override
  String get settingsThemeTitle => 'Selección de tema';

  @override
  String get settingsLanguageTitle => 'País / Idioma';

  @override
  String get colorPickerTitle => 'Elegir un color';

  @override
  String get colorPickerBasicColors => 'Colores básicos';

  @override
  String get loadingProjects => 'Cargando proyectos...';

  @override
  String get importDataset => 'Importar conjunto de datos';

  @override
  String get uploadMedia => 'Subir medios';

  @override
  String get createProjectTitle => 'Crear un Nuevo Proyecto';

  @override
  String get createProjectStepOneSubtitle =>
      'Por favor, ingrese el nombre de su nuevo proyecto y seleccione el tipo de Proyecto';

  @override
  String get createProjectStepTwoSubtitle =>
      'Por favor, cree etiquetas para un Nuevo proyecto';

  @override
  String get emptyProjectTitle => 'Comience su primer proyecto';

  @override
  String get emptyProjectDescription =>
      'Cree un proyecto para comenzar a organizar conjuntos de datos, anotar medios y aplicar IA a sus tareas de visión, todo en un espacio de trabajo optimizado diseñado para acelerar su flujo de trabajo de visión por computadora.';

  @override
  String get emptyProjectCreateNew => 'Crear Nuevo Proyecto';

  @override
  String get emptyProjectCreateNewShort => 'Nuevo Proyecto';

  @override
  String get emptyProjectImportDataset =>
      'Crear Proyecto desde importación de Conjunto de Datos';

  @override
  String get emptyProjectImportDatasetShort => 'Importar Conjunto de Datos';

  @override
  String get dialogBack => '<- Atrás';

  @override
  String get dialogNext => 'Siguiente ->';

  @override
  String get rename => 'Renombrar';

  @override
  String get delete => 'Eliminar';

  @override
  String get setAsDefault => 'Establecer como Predeterminado';

  @override
  String paginationPageFromTotal(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get taskTypeRequiredTitle => 'Tipo de Tarea Requerido';

  @override
  String taskTypeRequiredMessage(Object tab) {
    return 'Necesita seleccionar un tipo de tarea antes de continuar. La pestaña actual \'$tab\' no tiene ningún tipo de tarea seleccionado. Cada proyecto debe estar asociado con una tarea (por ejemplo, detección de objetos, clasificación o segmentación) para que el sistema sepa cómo procesar sus datos.';
  }

  @override
  String taskTypeRequiredTips(Object tab) {
    return 'Haga clic en una de las opciones de tipo de tarea disponibles debajo de la pestaña \'$tab\'. Si no está seguro de qué tarea elegir, pase el cursor sobre el icono de información junto a cada tipo para ver una breve descripción.';
  }

  @override
  String get menuProjects => 'Proyectos';

  @override
  String get menuAccount => 'Cuenta';

  @override
  String get menuLearn => 'Aprender';

  @override
  String get menuAbout => 'Acerca de';

  @override
  String get menuCreateNewProject => 'Crear nuevo proyecto';

  @override
  String get menuCreateFromDataset => 'Crear desde Conjunto de Datos';

  @override
  String get menuImportDataset =>
      'Crear proyecto desde Importación de Conjunto de Datos';

  @override
  String get menuSortLastUpdated => 'Última Actualización';

  @override
  String get menuSortNewestOldest => 'Más Reciente-Más Antiguo';

  @override
  String get menuSortOldestNewest => 'Más Antiguo-Más Reciente';

  @override
  String get menuSortType => 'Tipo de Proyecto';

  @override
  String get menuSortAz => 'A-Z';

  @override
  String get menuSortZa => 'Z-A';

  @override
  String get projectNameLabel => 'Nombre del Proyecto';

  @override
  String get tabDetection => 'Detección';

  @override
  String get tabClassification => 'Clasificación';

  @override
  String get tabSegmentation => 'Segmentación';

  @override
  String get labelRequiredTitle => 'Se Requiere Al Menos Una Etiqueta';

  @override
  String get labelRequiredMessage =>
      'Debe crear al menos una etiqueta para continuar. Las etiquetas son esenciales para definir las categorías de anotación que se utilizarán durante la preparación del conjunto de datos.';

  @override
  String get labelRequiredTips =>
      'Consejo: Haga clic en el botón rojo etiquetado Crear Etiqueta después de ingresar un nombre de etiqueta para agregar su primera etiqueta.';

  @override
  String get createLabelButton => 'Crear Etiqueta';

  @override
  String get labelNameHint => 'Ingrese un nuevo nombre de Etiqueta aquí';

  @override
  String get createdLabelsTitle => 'Etiquetas Creadas';

  @override
  String get labelEmptyTitle =>
      '¡El nombre de la etiqueta no puede estar vacío!';

  @override
  String get labelEmptyMessage =>
      'Por favor, ingrese un nombre de etiqueta. Las etiquetas ayudan a identificar los objetos o categorías en su proyecto. Se recomienda utilizar nombres cortos, claros y descriptivos, como \"Coche\", \"Persona\" o \"Árbol\". Evite caracteres especiales o espacios.';

  @override
  String get labelEmptyTips =>
      'Consejos para Nombrar Etiquetas:\n• Use nombres cortos y descriptivos\n• Utilice letras, dígitos, guiones bajos (por ejemplo, gato, señal_de_tráfico, fondo)\n• Evite espacios y símbolos (por ejemplo, Persona 1 → persona_1)';

  @override
  String get labelDuplicateTitle => 'Nombre de Etiqueta Duplicado';

  @override
  String labelDuplicateMessage(Object label) {
    return 'La etiqueta \'$label\' ya existe en este proyecto. Cada etiqueta debe tener un nombre único para evitar confusiones durante la anotación y el entrenamiento.';
  }

  @override
  String get labelDuplicateTips =>
      '¿Por qué etiquetas únicas?\n• Reutilizar el mismo nombre puede causar problemas durante la exportación del conjunto de datos y el entrenamiento del modelo.\n• Los nombres de etiquetas únicos ayudan a mantener anotaciones claras y estructuradas.\n\nConsejo: Intente agregar una variación o número para diferenciar (por ejemplo, \'Coche\', \'Coche_2\').';

  @override
  String get binaryLimitTitle => 'Límite de Clasificación Binaria';

  @override
  String get binaryLimitMessage =>
      'No puede crear más de dos etiquetas para un proyecto de Clasificación Binaria.\n\nLa Clasificación Binaria está diseñada para distinguir entre exactamente dos clases, como \'Sí\' vs \'No\', o \'Spam\' vs \'No Spam\'.';

  @override
  String get binaryLimitTips =>
      '¿Necesita más de dos etiquetas?\nConsidere cambiar el tipo de proyecto a Clasificación Multi-Clase u otra tarea adecuada para admitir tres o más categorías.';

  @override
  String get noteBinaryClassification =>
      'Este tipo de proyecto permite exactamente 2 etiquetas. La Clasificación Binaria se utiliza cuando su modelo necesita distinguir entre dos clases posibles, como \"Sí\" vs \"No\", o \"Perro\" vs \"No Perro\". Por favor, cree solo dos etiquetas distintas.';

  @override
  String get noteMultiClassClassification =>
      'Este tipo de proyecto admite múltiples etiquetas. La Clasificación Multi-Clase es adecuada cuando su modelo necesita elegir entre tres o más categorías, como \"Gato\", \"Perro\", \"Conejo\". Puede agregar tantas etiquetas como sea necesario.';

  @override
  String get noteDetectionOrSegmentation =>
      'Este tipo de proyecto admite múltiples etiquetas. Para Detección de Objetos o Segmentación, cada etiqueta típicamente representa una clase diferente de objeto (por ejemplo, \"Coche\", \"Peatón\", \"Bicicleta\"). Puede crear tantas etiquetas como requiera para su conjunto de datos.';

  @override
  String get noteDefault =>
      'Puede crear una o más etiquetas dependiendo del tipo de proyecto. Cada etiqueta ayuda a definir una categoría que su modelo aprenderá a reconocer. Consulte la documentación para conocer las mejores prácticas.';

  @override
  String get discardDatasetImportTitle =>
      '¿Descartar Importación de Conjunto de Datos?';

  @override
  String get discardDatasetImportMessage =>
      'Ya ha extraído un conjunto de datos. Cancelar ahora eliminará los archivos extraídos y los detalles del conjunto de datos detectados. ¿Está seguro de que desea continuar?';

  @override
  String get projectTypeHelpTitle => 'Ayuda para Selección de Tipo de Proyecto';

  @override
  String get projectTypeWhyDisabledTitle =>
      '¿Por qué algunos tipos de proyecto están deshabilitados?';

  @override
  String get projectTypeWhyDisabledBody =>
      'Cuando importa un conjunto de datos, el sistema analiza las anotaciones proporcionadas e intenta detectar automáticamente el tipo de proyecto más adecuado para usted.\n\nPor ejemplo, si su conjunto de datos contiene anotaciones de cuadros delimitadores, el tipo de proyecto sugerido será \"Detección\". Si contiene máscaras, se sugerirá \"Segmentación\", y así sucesivamente.\n\nPara proteger sus datos, solo los tipos de proyecto compatibles están habilitados de forma predeterminada.';

  @override
  String get projectTypeAllowChangeTitle =>
      '¿Qué sucede si habilito el cambio de tipo de proyecto?';

  @override
  String get projectTypeAllowChangeBody =>
      'Si activa \"Permitir cambio de tipo de proyecto\", puede seleccionar manualmente CUALQUIER tipo de proyecto, incluso si no coincide con las anotaciones detectadas.\n\n⚠️ ADVERTENCIA: Todas las anotaciones existentes de la importación se eliminarán al cambiar a un tipo de proyecto incompatible.\nTendrá que volver a anotar o importar un conjunto de datos adecuado para el tipo de proyecto recién seleccionado.';

  @override
  String get projectTypeWhenUseTitle => '¿Cuándo debería usar esta opción?';

  @override
  String get projectTypeWhenUseBody =>
      'Solo debe habilitar esta opción si:\n\n- Importó accidentalmente el conjunto de datos incorrecto.\n- Desea iniciar un nuevo proyecto de anotación con un tipo diferente.\n- La estructura de su conjunto de datos cambió después de la importación.\n\nSi no está seguro, recomendamos encarecidamente mantener la selección predeterminada para evitar la pérdida de datos.';

  @override
  String get allLabels => 'Todas las Etiquetas';

  @override
  String get setAsProjectIcon => 'Establecer como Icono del Proyecto';

  @override
  String setAsProjectIconConfirm(Object filePath) {
    return '¿Desea usar \'$filePath\' como icono para este proyecto?\n\nEsto reemplazará cualquier icono establecido anteriormente.';
  }

  @override
  String get removeFilesFromDatasetInProgress => 'Eliminando archivos...';

  @override
  String get removeFilesFromDataset =>
      '¿Eliminar archivos del Conjunto de Datos?';

  @override
  String removeFilesFromDatasetConfirm(Object amount) {
    return '¿Está seguro de que desea eliminar los siguientes archivos (\'$amount\')?\n\nTodas las anotaciones correspondientes también se eliminarán.';
  }

  @override
  String get removeFilesFailedTitle => 'Error al Eliminar';

  @override
  String get removeFilesFailedMessage =>
      'Algunos archivos no pudieron ser eliminados';

  @override
  String get removeFilesFailedTips =>
      'Por favor, verifique los permisos de archivo e intente nuevamente';

  @override
  String get duplicateImage => 'Duplicar Imagen';

  @override
  String get duplicateWithAnnotations => 'Duplicar imagen con anotaciones';

  @override
  String get duplicateWithAnnotationsHint =>
      'Se creará una copia de la imagen junto con todos los datos de anotación.';

  @override
  String get duplicateImageOnly => 'Duplicar solo la imagen';

  @override
  String get duplicateImageOnlyHint =>
      'Solo se copiará la imagen, sin anotaciones.';

  @override
  String get saveDuplicateChoiceAsDefault =>
      'Guardar esta respuesta como respuesta predeterminada y no preguntar de nuevo\n(Puede cambiar esto en Cuenta -> Ajustes de la aplicación -> Navegación del conjunto de datos)';

  @override
  String get editProjectTitle => 'Editar nombre del proyecto';

  @override
  String get editProjectDescription =>
      'Por favor, elija un nombre de proyecto claro y descriptivo (3 - 86 caracteres). Se recomienda evitar caracteres especiales.';

  @override
  String get deleteProjectTitle => 'Eliminar Proyecto';

  @override
  String get deleteProjectInProgress => 'Eliminando proyecto...';

  @override
  String get deleteProjectOptionDeleteFromDisk =>
      'También eliminar todos los archivos del disco';

  @override
  String get deleteProjectOptionDontAskAgain => 'No preguntar de nuevo';

  @override
  String deleteProjectConfirm(Object projectName) {
    return '¿Está seguro de que desea eliminar el proyecto \"$projectName\"?';
  }

  @override
  String deleteProjectInfoLine(Object creationDate, Object labelCount) {
    return 'El proyecto fue creado el $creationDate\nNúmero de Etiquetas: $labelCount';
  }

  @override
  String get deleteDatasetTitle => 'Eliminar Conjunto de Datos';

  @override
  String get deleteDatasetInProgress =>
      'Eliminando conjunto de datos... Por favor espere.';

  @override
  String deleteDatasetConfirm(Object datasetName) {
    return '¿Está seguro de que desea eliminar \"$datasetName\"?';
  }

  @override
  String deleteDatasetInfoLine(
    Object creationDate,
    Object mediaCount,
    Object annotationCount,
  ) {
    return 'Este conjunto de datos fue creado el $creationDate y contiene $mediaCount elementos multimedia y $annotationCount anotaciones.';
  }

  @override
  String get editDatasetTitle => 'Renombrar Conjunto de Datos';

  @override
  String get editDatasetDescription =>
      'Ingrese un nuevo nombre para este conjunto de datos:';

  @override
  String get noMediaDialogUploadPrompt => 'Debe cargar imágenes o videos';

  @override
  String get noMediaDialogUploadPromptShort => 'Cargar medios';

  @override
  String get noMediaDialogSupportedImageTypesTitle =>
      'Tipos de imágenes compatibles:';

  @override
  String get noMediaDialogSupportedImageTypesList =>
      'jpg, jpeg, png, bmp, jfif, webp';

  @override
  String get noMediaDialogSupportedVideoFormatsLink =>
      'Haga clic aquí para ver qué formatos de video son compatibles en su plataforma';

  @override
  String get noMediaDialogSupportedVideoFormatsTitle =>
      'Formatos de Video Compatibles';

  @override
  String get noMediaDialogSupportedVideoFormatsList =>
      'Formatos Comúnmente Compatibles:\n\n- MP4: Android, iOS, Web, Escritorio\n- MOV: Android, iOS, macOS\n- M4V: Android, iOS, macOS\n- WEBM: Android, Web (dependiente del navegador)\n- MKV: Android (parcial), Windows\n- AVI: Solo Android/Windows (parcial)';

  @override
  String get noMediaDialogSupportedVideoFormatsWarning =>
      'La compatibilidad puede variar según la plataforma y el códec de video.\nAlgunos formatos pueden no funcionar en navegadores o en iOS.';

  @override
  String get annotatorTopToolbarBackTooltip => 'Volver al Proyecto';

  @override
  String get annotatorTopToolbarSelectDefaultLabel =>
      'Seleccionar etiqueta predeterminada';

  @override
  String get toolbarNavigation => 'Navegación';

  @override
  String get toolbarBbox => 'Dibujar Cuadro Delimitador';

  @override
  String get toolbarPolygon => 'Dibujar Polígono';

  @override
  String get toolbarSAM => 'Modelo de Segmentación Automática';

  @override
  String get toolbarResetZoom => 'Restablecer Zoom';

  @override
  String get toolbarToggleGrid => 'Alternar Cuadrícula';

  @override
  String get toolbarAnnotationSettings => 'Configuración de Anotación';

  @override
  String get toolbarToggleAnnotationNames => 'Alternar Nombres de Anotación';

  @override
  String get toolbarRotateLeft => 'Rotar a la Izquierda (Próximamente)';

  @override
  String get toolbarRotateRight => 'Rotar a la Derecha (Próximamente)';

  @override
  String get toolbarHelp => 'Ayuda';

  @override
  String get dialogOpacityTitle => 'Opacidad de Relleno de Anotación';

  @override
  String get dialogHelpTitle =>
      'Ayuda de la Barra de Herramientas del Anotador';

  @override
  String get dialogHelpContent =>
      '• Navegación – Utilice para seleccionar y moverse por el lienzo.\n• Cuadro Delimitador – (Visible en proyectos de Detección) Dibuje cuadros delimitadores rectangulares.\n• Restablecer Zoom – Restablece el nivel de zoom para ajustar la imagen en la pantalla.\n• Alternar Cuadrícula – Mostrar u ocultar la cuadrícula de miniaturas del conjunto de datos.\n• Configuración – Ajuste la opacidad de relleno de las anotaciones, el borde de las anotaciones y el tamaño de las esquinas.\n• Alternar Nombres de Anotación – Mostrar u ocultar etiquetas de texto en las anotaciones.';

  @override
  String get dialogHelpTips =>
      'Consejo: Utilice el modo de Navegación para seleccionar y editar anotaciones.\n¡Más atajos y funciones próximamente!';

  @override
  String get dialogOpacityExplanation =>
      'Ajuste el nivel de opacidad para hacer que el contenido sea más o menos transparente.';

  @override
  String get deleteAnnotationTitle => 'Eliminar Anotación';

  @override
  String get deleteAnnotationMessage => '¿Está seguro de que desea eliminar';

  @override
  String get unnamedAnnotation => 'esta anotación';

  @override
  String get accountStorage_importFolderTitle =>
      'Carpeta de importación de Conjuntos de Datos';

  @override
  String get accountStorage_thumbnailsFolderTitle => 'Carpeta de Miniaturas';

  @override
  String get accountStorage_exportFolderTitle =>
      'Carpeta de exportación de Conjuntos de Datos';

  @override
  String get accountStorage_folderTooltip => 'Elegir carpeta';

  @override
  String get accountStorage_helpTitle => 'Ayuda de Almacenamiento';

  @override
  String get accountStorage_helpMessage =>
      'Puede cambiar la carpeta donde se almacenan los conjuntos de datos importados, los archivos ZIP exportados y las miniaturas.\nToque el icono \"Carpeta\" junto al campo de ruta para seleccionar o cambiar el directorio.\n\nEsta carpeta se utilizará como ubicación predeterminada para:\n- Archivos de conjuntos de datos importados (por ejemplo, COCO, YOLO, VOC, Datumaro, etc.)\n- Archivos Zip de conjuntos de datos exportados\n- Miniaturas de proyectos\n\nAsegúrese de que la carpeta seleccionada sea escribible y tenga suficiente espacio.\nEn Android o iOS, es posible que deba otorgar permisos de almacenamiento.\nLas carpetas recomendadas varían según la plataforma; consulte a continuación los consejos específicos de la plataforma.';

  @override
  String get accountStorage_helpTips =>
      'Carpetas recomendadas por plataforma:\n\nWindows:\n  C:\\Users\\<usted>\\AppData\\Roaming\\AnnotateIt\\datasets\n\nLinux / Ubuntu:\n  /home/<usted>/.annotateit/datasets\n\nmacOS:\n  /Users/<usted>/Library/Application Support/AnnotateIt/datasets\n\nAndroid:\n  /storage/emulated/0/AnnotateIt/datasets\n\niOS:\n  <Ruta sandbox de la aplicación>/Documents/AnnotateIt/datasets\n';

  @override
  String get accountStorage_copySuccess => 'Ruta copiada al portapapeles';

  @override
  String get accountStorage_openError => 'La carpeta no existe:\n';

  @override
  String get accountStorage_pathEmpty => 'La ruta está vacía';

  @override
  String get accountStorage_openFailed => 'No se pudo abrir la carpeta:\n';

  @override
  String get changeProjectTypeTitle => 'Cambiar tipo de proyecto';

  @override
  String get changeProjectTypeMigrating => 'Migrando tipo de proyecto...';

  @override
  String get changeProjectTypeStepOneSubtitle =>
      'Por favor, seleccione un nuevo tipo de proyecto de la lista a continuación';

  @override
  String get changeProjectTypeStepTwoSubtitle =>
      'Por favor, confirme su elección';

  @override
  String get changeProjectTypeWarningTitle =>
      'Advertencia: Está a punto de cambiar el tipo de proyecto.';

  @override
  String get changeProjectTypeConversionIntro =>
      'Todas las anotaciones existentes se convertirán de la siguiente manera:';

  @override
  String get changeProjectTypeConversionDetails =>
      '- Cuadros delimitadores (Detección) -> convertidos a polígonos rectangulares.\n- Polígonos (Segmentación) -> convertidos a cuadros delimitadores ajustados.\n\nNota: Estas conversiones pueden reducir la precisión, especialmente al convertir polígonos a cuadros, ya que se perderá información detallada de la forma.\n\n- Detección / Segmentación → Clasificación:\n  Las imágenes se clasificarán según la etiqueta más frecuente en las anotaciones:\n     -> Si la imagen tiene 5 objetos etiquetados como \"Perro\" y 10 etiquetados como \"Gato\", se clasificará como \"Gato\".\n     -> Si los recuentos son iguales, se utilizará la primera etiqueta encontrada.\n\n- Clasificación -> Detección / Segmentación:\n  No se transferirán anotaciones. Deberá volver a anotar todos los elementos multimedia manualmente, ya que los proyectos de clasificación no contienen datos a nivel de región.';

  @override
  String get changeProjectTypeErrorTitle => 'Error en la Migración';

  @override
  String get changeProjectTypeErrorMessage =>
      'Se produjo un error al cambiar el tipo de proyecto. Los cambios no pudieron aplicarse.';

  @override
  String get changeProjectTypeErrorTips =>
      'Por favor, verifique si el proyecto tiene anotaciones válidas e intente nuevamente. Si el problema persiste, reinicie la aplicación o contacte con soporte.';

  @override
  String get exportProjectAsDataset =>
      'Exportar Proyecto como Conjunto de Datos';

  @override
  String get projectHelpTitle => 'Cómo Funcionan los Proyectos';

  @override
  String get projectHelpMessage =>
      'Los proyectos le permiten organizar conjuntos de datos, archivos multimedia y anotaciones en un solo lugar. Puede crear nuevos proyectos para diferentes tareas como detección, clasificación o segmentación.';

  @override
  String get projectHelpTips =>
      'Consejo: Puede importar conjuntos de datos en formato COCO, YOLO, VOC, Labelme y Datumaro para crear un proyecto automáticamente.';

  @override
  String get datasetDialogTitle =>
      'Importar Conjunto de Datos para Crear Proyecto';

  @override
  String get datasetDialogProcessing => 'Procesando...';

  @override
  String datasetDialogProcessingProgress(Object percent) {
    return 'Procesando... $percent%';
  }

  @override
  String get datasetDialogModeIsolate => 'Modo Aislado Habilitado';

  @override
  String get datasetDialogModeNormal => 'Modo Normal';

  @override
  String get datasetDialogNoDatasetLoaded =>
      'No se ha cargado ningún conjunto de datos.';

  @override
  String get datasetDialogSelectZipFile =>
      'Seleccione su archivo ZIP de conjunto de datos';

  @override
  String get datasetDialogChooseFile => 'Elegir un archivo';

  @override
  String get datasetDialogSupportedFormats =>
      'Formatos de conjunto de datos compatibles:';

  @override
  String get datasetDialogSupportedFormatsList1 => 'COCO, YOLO, VOC, Datumaro,';

  @override
  String get datasetDialogSupportedFormatsList2 =>
      'LabelMe, CVAT o solo medios (.zip)';

  @override
  String get datasetDialogImportFailedTitle => 'Error en la Importación';

  @override
  String get datasetDialogImportFailedMessage =>
      'El archivo ZIP no pudo ser procesado. Puede estar corrupto, incompleto o no ser un archivo de conjunto de datos válido.';

  @override
  String get datasetDialogImportFailedTips =>
      'Intente exportar o comprimir nuevamente su conjunto de datos.\nAsegúrese de que esté en formato COCO, YOLO, VOC o compatible.\n\nError: ';

  @override
  String get datasetDialogNoProjectTypeTitle =>
      'No se ha Seleccionado Tipo de Proyecto';

  @override
  String get datasetDialogNoProjectTypeMessage =>
      'Por favor, seleccione un Tipo de Proyecto basado en los tipos de anotación detectados en su conjunto de datos.';

  @override
  String get datasetDialogNoProjectTypeTips =>
      'Verifique el formato de su conjunto de datos y asegúrese de que las anotaciones sigan una estructura compatible como COCO, YOLO, VOC o Datumaro.';

  @override
  String get datasetDialogProcessingDatasetTitle =>
      'Procesando Conjunto de Datos';

  @override
  String get datasetDialogProcessingDatasetMessage =>
      'Actualmente estamos extrayendo su archivo ZIP, analizando su contenido y detectando el formato del conjunto de datos y el tipo de anotación. Esto puede tomar desde unos segundos hasta unos minutos dependiendo del tamaño y la estructura del conjunto de datos. Por favor, no cierre esta ventana ni navegue fuera durante el proceso.';

  @override
  String get datasetDialogProcessingDatasetTips =>
      'Los archivos grandes con muchas imágenes o archivos de anotación pueden tardar más en procesarse.';

  @override
  String get datasetDialogCreatingProjectTitle => 'Creando Proyecto';

  @override
  String get datasetDialogCreatingProjectMessage =>
      'Estamos configurando su proyecto, inicializando sus metadatos y guardando todas las configuraciones. Esto incluye asignar etiquetas, crear conjuntos de datos y vincular archivos multimedia asociados. Por favor, espere un momento y evite cerrar esta ventana hasta que el proceso esté completo.';

  @override
  String get datasetDialogCreatingProjectTips =>
      'Los proyectos con muchas etiquetas o archivos multimedia pueden tardar un poco más.';

  @override
  String get datasetDialogAnalyzingDatasetTitle =>
      'Analizando Conjunto de Datos';

  @override
  String get datasetDialogAnalyzingDatasetMessage =>
      'Actualmente estamos analizando su archivo de conjunto de datos. Esto incluye extraer archivos, detectar la estructura del conjunto de datos, identificar formatos de anotación y recopilar información de medios y etiquetas. Por favor, espere hasta que el proceso esté completo. Cerrar la ventana o navegar fuera puede interrumpir la operación.';

  @override
  String get datasetDialogAnalyzingDatasetTips =>
      'Los conjuntos de datos grandes con muchos archivos o anotaciones complejas pueden tomar tiempo adicional.';

  @override
  String get datasetDialogFilePickErrorTitle => 'Error de Selección de Archivo';

  @override
  String get datasetDialogFilePickErrorMessage =>
      'No se pudo seleccionar el archivo. Por favor, intente nuevamente.';

  @override
  String get datasetDialogGenericErrorTips =>
      'Por favor, verifique su archivo e intente nuevamente. Si el problema persiste, contacte con soporte.';

  @override
  String get thumbnailGenerationTitle => 'Error';

  @override
  String get thumbnailGenerationFailed => 'No se pudo generar la miniatura';

  @override
  String get thumbnailGenerationTryAgainLater =>
      'Por favor, intente nuevamente más tarde';

  @override
  String get thumbnailGenerationInProgress => 'Generando miniatura...';

  @override
  String get menuImageAnnotate => 'Anotar';

  @override
  String get menuImageDetails => 'Detalles';

  @override
  String get menuImageDuplicate => 'Duplicar';

  @override
  String get menuImageSetAsIcon => 'Establecer como Icono';

  @override
  String get menuImageDelete => 'Eliminar';

  @override
  String get noLabelsTitle => 'No tiene Etiquetas en el Proyecto';

  @override
  String get noLabelsExplain1 =>
      'No puede anotar sin etiquetas porque las etiquetas dan significado a lo que está marcando';

  @override
  String get noLabelsExplain2 =>
      'Puede agregar etiquetas manualmente o importarlas desde un archivo JSON.';

  @override
  String get noLabelsExplain3 =>
      'Una anotación sin etiqueta es solo una caja vacía.';

  @override
  String get noLabelsExplain4 =>
      'Las etiquetas definen las categorías o clases que está anotando en su conjunto de datos.';

  @override
  String get noLabelsExplain5 =>
      'Ya sea que esté etiquetando objetos en imágenes, clasificando o segmentando regiones,';

  @override
  String get noLabelsExplain6 =>
      'las etiquetas son esenciales para organizar sus anotaciones de manera clara y consistente.';

  @override
  String get importLabelsPreviewTitle =>
      'Vista Previa de Importación de Etiquetas';

  @override
  String get importLabelsFailedTitle => 'Error en la Importación de Etiquetas';

  @override
  String get importLabelsNoLabelsTitle =>
      'No se encontraron etiquetas en este proyecto';

  @override
  String get importLabelsJsonParseError => 'Error al analizar JSON.\n';

  @override
  String get importLabelsJsonParseTips =>
      'Asegúrese de que el archivo sea JSON válido. Puede validarlo en https://jsonlint.com/';

  @override
  String importLabelsJsonNotList(Object type) {
    return 'Se esperaba una lista de etiquetas (array), pero se obtuvo: $type.';
  }

  @override
  String get importLabelsJsonNotListTips =>
      'Su archivo JSON debe comenzar con [ y contener múltiples objetos de etiqueta. Cada etiqueta debe incluir campos de nombre, color y orden de etiqueta.';

  @override
  String importLabelsJsonItemNotMap(Object type) {
    return 'Una de las entradas en la lista no es un objeto válido: $type';
  }

  @override
  String get importLabelsJsonItemNotMapTips =>
      'Cada elemento en la lista debe ser un objeto válido con campos: nombre, color y orden de etiqueta.';

  @override
  String get importLabelsJsonLabelParseError =>
      'Error al analizar una de las etiquetas.\n';

  @override
  String get importLabelsJsonLabelParseTips =>
      'Verifique que cada etiqueta tenga los campos requeridos como nombre y color, y que los valores sean de los tipos correctos.';

  @override
  String get importLabelsUnexpectedError =>
      'Se produjo un error inesperado durante la importación del archivo JSON.\n';

  @override
  String get importLabelsUnexpectedErrorTip =>
      'Por favor, asegúrese de que su archivo sea legible y esté formateado correctamente.';

  @override
  String get importLabelsDatabaseError =>
      'Error al guardar etiquetas en la base de datos';

  @override
  String get importLabelsDatabaseErrorTips =>
      'Por favor, verifique su conexión a la base de datos e intente nuevamente. Si el problema persiste, contacte con soporte.';

  @override
  String get importLabelsNameMissingOrEmpty =>
      'Una de las etiquetas no tiene un nombre válido.';

  @override
  String get importLabelsNameMissingOrEmptyTips =>
      'Asegúrese de que cada etiqueta en el JSON incluya un campo \'nombre\' no vacío.';

  @override
  String get menuSortAZ => 'A-Z';

  @override
  String get menuSortZA => 'Z-A';

  @override
  String get menuSortProjectType => 'Tipo de Proyecto';

  @override
  String get uploadInProgressTitle => 'Carga en Progreso';

  @override
  String get uploadInProgressMessage =>
      'Tiene una carga activa en progreso. Si sale ahora, la carga se cancelará y tendrá que comenzar de nuevo.\n\n¿Desea salir de todos modos?';

  @override
  String get uploadInProgressStay => 'Quedarse';

  @override
  String get uploadInProgressLeave => 'Salir';

  @override
  String get fileNotFound => 'Archivo no encontrado';

  @override
  String get labelEditSave => 'Guardar';

  @override
  String get labelEditEdit => 'Editar';

  @override
  String get labelEditMoveUp => 'Mover Arriba';

  @override
  String get labelEditMoveDown => 'Mover Abajo';

  @override
  String get labelEditDelete => 'Eliminar';

  @override
  String get labelExportLabels => 'Exportar Etiquetas';

  @override
  String get labelSaveDialogTitle => 'Guardar etiquetas en archivo JSON';

  @override
  String get labelSaveDefaultFilename => 'etiquetas.json';

  @override
  String labelDeleteError(Object error) {
    return 'Error al eliminar etiqueta: $error';
  }

  @override
  String get labelDeleteErrorTips =>
      'Asegúrese de que la etiqueta aún existe o no se está utilizando en otro lugar.';

  @override
  String get datasetStepUploadZip =>
      'Suba un archivo ZIP con formato COCO, YOLO, VOC, LabelMe, CVAT, Datumaro o solo medios';

  @override
  String get datasetStepExtractingZip =>
      'Extrayendo ZIP en almacenamiento local ...';

  @override
  String datasetStepExtractedPath(Object path) {
    return 'Conjunto de datos extraído en: $path';
  }

  @override
  String datasetStepDetectedTaskType(Object format) {
    return 'Tipo de tarea detectado: $format';
  }

  @override
  String get datasetStepSelectProjectType => 'Seleccionar tipo de proyecto';

  @override
  String get datasetStepProgressSelection => 'Selección de Conjunto de Datos';

  @override
  String get datasetStepProgressExtract => 'Extraer ZIP';

  @override
  String get datasetStepProgressOverview => 'Resumen del Conjunto de Datos';

  @override
  String get datasetStepProgressTaskConfirmation => 'Confirmación de Tarea';

  @override
  String get datasetStepProgressProjectCreation => 'Creación de Proyecto';

  @override
  String get projectTypeDetectionBoundingBox =>
      'Detección con cuadro delimitador';

  @override
  String get projectTypeDetectionOriented => 'Detección orientada';

  @override
  String get projectTypeBinaryClassification => 'Clasificación Binaria';

  @override
  String get projectTypeMultiClassClassification => 'Clasificación Multi-clase';

  @override
  String get projectTypeMultiLabelClassification =>
      'Clasificación Multi-etiqueta';

  @override
  String get projectTypeInstanceSegmentation => 'Segmentación de Instancias';

  @override
  String get projectTypeSemanticSegmentation => 'Segmentación Semántica';

  @override
  String get datasetStepChooseProjectType =>
      'Elija su tipo de Proyecto basado en las anotaciones detectadas';

  @override
  String get datasetStepAllowProjectTypeChange =>
      'Permitir Cambio de Tipo de Proyecto';

  @override
  String get projectTypeBinaryClassificationDescription =>
      'Asignar una de dos etiquetas posibles a cada entrada (por ejemplo, spam o no spam, positivo o negativo).';

  @override
  String get projectTypeMultiClassClassificationDescription =>
      'Asignar exactamente una etiqueta de un conjunto de clases mutuamente excluyentes (por ejemplo, gato, perro o pájaro).';

  @override
  String get projectTypeMultiLabelClassificationDescription =>
      'Asignar una o más etiquetas de un conjunto de clases — múltiples etiquetas pueden aplicarse al mismo tiempo (por ejemplo, una imagen etiquetada como \"gato\" y \"perro\")';

  @override
  String get projectTypeDetectionBoundingBoxDescription =>
      'Dibujar un rectángulo alrededor de un objeto en una imagen.';

  @override
  String get projectTypeDetectionOrientedDescription =>
      'Dibujar y encerrar un objeto dentro de un rectángulo mínimo.';

  @override
  String get projectTypeInstanceSegmentationDescription =>
      'Detectar y distinguir cada objeto individual basado en sus características únicas.';

  @override
  String get projectTypeSemanticSegmentationDescription =>
      'Detectar y clasificar todos los objetos similares como una sola entidad.';
}
