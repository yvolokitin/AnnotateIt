// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get buttonKeep => 'Сохранить как есть';

  @override
  String get buttonSave => 'Сохранить';

  @override
  String get buttonHelp => 'Помощь';

  @override
  String get buttonEdit => 'Редактировать';

  @override
  String get buttonNext => 'Далее';

  @override
  String get buttonBack => 'Назад';

  @override
  String get buttonApply => 'Применить';

  @override
  String get buttonClose => 'Закрыть';

  @override
  String get buttonImport => 'Импортировать';

  @override
  String get buttonCancel => 'Отмена';

  @override
  String get buttonFinish => 'Завершить';

  @override
  String get buttonDelete => 'Удалить';

  @override
  String get buttonDuplicate => 'Дублировать';

  @override
  String get buttonConfirm => 'Подтвердить';

  @override
  String get buttonDiscard => 'Отклонить';

  @override
  String get buttonFeedbackShort => 'Отзвыв';

  @override
  String get buttonImportLabels => 'Импортировать метки';

  @override
  String get buttonExportLabels => 'Экспортировать метки';

  @override
  String get buttonNextConfirmTask => 'Далее: Подтвердить задачу';

  @override
  String get buttonCreateProject => 'Создать проект';

  @override
  String get aboutTitle => 'О приложении Annot@It';

  @override
  String get aboutDescription =>
      'Annot@It — это приложение для разметки, разработанное для оптимизации процесса аннотирования в проектах компьютерного зрения. Независимо от того, работаете ли вы над классификацией изображений, обнаружением объектов, сегментацией или другими задачами, Annot@It обеспечивает гибкость и точность, необходимые для качественной разметки данных.';

  @override
  String get aboutFeaturesTitle => 'Основные функции:';

  @override
  String get aboutFeatures =>
      '- Несколько типов проектов: создавайте и управляйте проектами под различные задачи CV.\n- Загрузка и управление данными: удобно загружайте и организуйте датасеты.\n- Продвинутые инструменты разметки: ограничивающие рамки, полигоны, ключевые точки и маски сегментации.\n- Экспорт и интеграция: экспортируйте разметку в форматах, совместимых с AI/ML.';

  @override
  String get aboutCallToAction =>
      'Начните работу с Annot@It уже сегодня и создавайте качественные датасеты для моделей компьютерного зрения!';

  @override
  String get accountUser => 'Пользователь';

  @override
  String get accountProfile => 'Профиль';

  @override
  String get accountStorage => 'Хранилище';

  @override
  String get accountDeviceStorage => 'Хранилище устройства';

  @override
  String get accountSettings => 'Настройки';

  @override
  String get accountApplicationSettings => 'Настройки приложения';

  @override
  String get accountLoadingMessage => 'Загрузка данных пользователя...';

  @override
  String get accountErrorLoadingUser =>
      'Не удалось загрузить данные пользователя';

  @override
  String get accountRetry => 'Повторить';

  @override
  String get userProfileName => 'Капитан Аннотатор';

  @override
  String get userProfileFeedbackButton => 'Обратная связь';

  @override
  String get userProfileEditProfileButton => 'Редактировать профиль';

  @override
  String get userProfileProjects => 'Проекты';

  @override
  String get userProfileLabels => 'Метки';

  @override
  String get userProfileMedia => 'Медиа';

  @override
  String get userProfileOverview => 'Обзор';

  @override
  String get userProfileAnnotations => 'Аннотации';

  @override
  String get settingsGeneralTitle => 'Общие настройки';

  @override
  String get settingsProjectCreationTitle => 'Создание проекта';

  @override
  String get settingsProjectCreationConfirmNoLabels =>
      'Всегда запрашивать подтверждение при создании проекта без меток';

  @override
  String get settingsProjectCreationConfirmNoLabelsNote =>
      'Вы получите предупреждение, если попытаетесь создать проект без заданных меток.';

  @override
  String get settingsLabelsCreationDeletionTitle => 'Создание / удаление меток';

  @override
  String get settingsLabelsDeletionWithAnnotations =>
      'Удалять аннотации при удалении метки';

  @override
  String get settingsLabelsDeletionWithAnnotationsNote =>
      'Если включено, при удалении метки автоматически удаляются все связанные с ней аннотации во всех медиафайлах.';

  @override
  String get settingsLabelsSetDefaultLabel =>
      'Установить первую метку по умолчанию';

  @override
  String get settingsLabelsSetDefaultLabelNote =>
      'Если включено, первая созданная метка будет автоматически назначена как метка по умолчанию. Это можно изменить позже.';

  @override
  String get settingsDatasetViewTitle => 'Просмотр датасета';

  @override
  String get settingsDatasetViewDuplicateWithAnnotations =>
      'Всегда дублировать изображения с аннотациями';

  @override
  String get settingsDatasetViewDuplicateWithAnnotationsNote =>
      'При дублировании аннотации будут включены, если вы не измените настройки';

  @override
  String get settingsDatasetViewDeleteFromOS =>
      'Удалять файл с диска при удалении из датасета';

  @override
  String get settingsDatasetViewDeleteFromOSNote =>
      'Файл будет удален не только из датасета, но и с диска';

  @override
  String get settingsAnnotationTitle => 'Настройки аннотации';

  @override
  String get settingsAnnotationOpacity => 'Прозрачность аннотаций';

  @override
  String get settingsAnnotationAutoSave =>
      'Автоматически сохранять или отправлять аннотацию при переходе к следующему изображению';

  @override
  String get settingsThemeTitle => 'Выбор темы';

  @override
  String get settingsLanguageTitle => 'Страна / Язык';

  @override
  String get colorPickerTitle => 'Выберите цвет';

  @override
  String get colorPickerBasicColors => 'Базовые цвета';

  @override
  String get loadingProjects => 'Загрузка проектов...';

  @override
  String get importDataset => 'Импортировать датасет';

  @override
  String get uploadMedia => 'Загрузить медиа';

  @override
  String get createProjectTitle => 'Создать новый проект';

  @override
  String get createProjectStepOneSubtitle =>
      'Введите название проекта и выберите тип проекта';

  @override
  String get createProjectStepTwoSubtitle =>
      'Создайте метки для нового проекта';

  @override
  String get emptyProjectTitle => 'Начните свой первый проект';

  @override
  String get emptyProjectDescription =>
      'Создайте проект, чтобы начать организовывать датасеты, размечать изображения и применять ИИ к задачам CV — всё в одном удобном пространстве.';

  @override
  String get emptyProjectCreateNew => 'Создать новый проект';

  @override
  String get emptyProjectCreateNewShort => 'Новый проект';

  @override
  String get emptyProjectImportDataset => 'Создать проект из датасета';

  @override
  String get emptyProjectImportDatasetShort => 'Импорт датасета';

  @override
  String get dialogBack => '<- Назад';

  @override
  String get dialogNext => 'Далее ->';

  @override
  String get rename => 'Переименовать';

  @override
  String get delete => 'Удалить';

  @override
  String get setAsDefault => 'Установить по умолчанию';

  @override
  String paginationPageFromTotal(int current, int total) {
    return 'Страница $current из $total';
  }

  @override
  String get taskTypeRequiredTitle => 'Необходимо указать тип задачи';

  @override
  String taskTypeRequiredMessage(Object tab) {
    return 'Вы должны выбрать тип задачи, прежде чем продолжить. Вкладка \'$tab\' пока не содержит выбранного типа задачи. Каждый проект должен быть связан с задачей (например, обнаружение объектов, классификация или сегментация), чтобы система знала, как обрабатывать ваши данные.';
  }

  @override
  String taskTypeRequiredTips(Object tab) {
    return 'Нажмите на один из доступных типов задач ниже вкладки \'$tab\'. Если вы не уверены, наведите курсор на значок информации рядом с каждым типом, чтобы увидеть краткое описание.';
  }

  @override
  String get menuProjects => 'Проекты';

  @override
  String get menuAccount => 'Аккаунт';

  @override
  String get menuLearn => 'Обучение';

  @override
  String get menuAbout => 'О приложении';

  @override
  String get menuCreateNewProject => 'Создать новый проект';

  @override
  String get menuCreateFromDataset => 'Создать из датасета';

  @override
  String get menuImportDataset => 'Импортировать проект из датасета';

  @override
  String get menuSortLastUpdated => 'Последнее обновление';

  @override
  String get menuSortNewestOldest => 'Сначала новые';

  @override
  String get menuSortOldestNewest => 'Сначала старые';

  @override
  String get menuSortType => 'Тип проекта';

  @override
  String get menuSortAz => 'А-Я';

  @override
  String get menuSortZa => 'Я-А';

  @override
  String get projectNameLabel => 'Название проекта';

  @override
  String get tabDetection => 'Обнаружение';

  @override
  String get tabClassification => 'Классификация';

  @override
  String get tabSegmentation => 'Сегментация';

  @override
  String get labelRequiredTitle => 'Необходима хотя бы одна метка';

  @override
  String get labelRequiredMessage =>
      'Для продолжения необходимо создать хотя бы одну метку. Метки определяют категории аннотаций, используемые при подготовке датасета.';

  @override
  String get labelRequiredTips =>
      'Совет: нажмите красную кнопку «Создать метку» после ввода имени метки, чтобы добавить её.';

  @override
  String get createLabelButton => 'Создать метку';

  @override
  String get labelNameHint => 'Введите имя новой метки';

  @override
  String get createdLabelsTitle => 'Созданные метки';

  @override
  String get labelEmptyTitle => 'Имя метки не может быть пустым!';

  @override
  String get labelEmptyMessage =>
      'Пожалуйста, введите имя метки. Метки помогают определить объекты или категории в проекте. Рекомендуется использовать короткие и понятные имена, такие как «Машина», «Человек» или «Дерево». Избегайте специальных символов и пробелов.';

  @override
  String get labelEmptyTips =>
      'Советы по выбору имени:\n• Используйте короткие и описательные названия\n• Используйте только буквы, цифры и подчёркивания (например: cat, road_sign, background)\n• Избегайте пробелов и символов (например: Person 1 → person_1)';

  @override
  String get labelDuplicateTitle => 'Повторяющееся имя метки';

  @override
  String labelDuplicateMessage(Object label) {
    return 'Метка «$label» уже существует в этом проекте. Каждая метка должна иметь уникальное имя, чтобы избежать путаницы при аннотировании и обучении.';
  }

  @override
  String get labelDuplicateTips =>
      'Зачем нужны уникальные метки?\n• Повторяющиеся имена могут вызвать ошибки при экспорте и обучении модели.\n• Уникальные имена помогают сохранять структуру аннотаций.\n\nСовет: добавьте номер или вариант (например, «Car», «Car_2»).';

  @override
  String get binaryLimitTitle => 'Ограничение бинарной классификации';

  @override
  String get binaryLimitMessage =>
      'Вы не можете создать более двух меток для проекта бинарной классификации.\n\nБинарная классификация предполагает различие между двумя классами, например «Да» и «Нет», или «Спам» и «Не спам».';

  @override
  String get binaryLimitTips =>
      'Нужно больше меток?\nПереключитесь на многоклассовую классификацию или другую задачу, поддерживающую более двух категорий.';

  @override
  String get noteBinaryClassification =>
      'Этот тип проекта допускает ровно 2 метки. Бинарная классификация используется, когда модель должна различать два класса, например: «Да» и «Нет» или «Собака» и «Не собака». Создайте только две разные метки.';

  @override
  String get noteMultiClassClassification =>
      'Этот тип проекта поддерживает несколько меток. Многоклассовая классификация подходит, когда модель выбирает из 3 и более категорий (например: «Кошка», «Собака», «Кролик»).';

  @override
  String get noteDetectionOrSegmentation =>
      'Этот тип проекта поддерживает несколько меток. В задачах обнаружения или сегментации каждая метка представляет свой класс объекта (например, «Автомобиль», «Пешеход», «Велосипед»).';

  @override
  String get noteDefault =>
      'Вы можете создать одну или несколько меток в зависимости от типа проекта. Каждая метка помогает определить категорию, которую будет распознавать модель.';

  @override
  String get discardDatasetImportTitle => 'Отменить импорт датасета?';

  @override
  String get discardDatasetImportMessage =>
      'Вы уже распаковали датасет. Отмена приведёт к удалению извлечённых файлов и информации о датасете. Вы уверены, что хотите продолжить?';

  @override
  String get projectTypeHelpTitle => 'Помощь по выбору типа проекта';

  @override
  String get projectTypeWhyDisabledTitle =>
      'Почему некоторые типы проектов недоступны?';

  @override
  String get projectTypeWhyDisabledBody =>
      'При импорте датасета система анализирует аннотации и автоматически определяет наиболее подходящий тип проекта.\n\nНапример, если в вашем датасете есть аннотации с ограничивающими рамками, будет предложен тип «Обнаружение». Если найдены маски — «Сегментация» и т. д.\n\nДля защиты ваших данных включаются только совместимые типы проектов.';

  @override
  String get projectTypeAllowChangeTitle =>
      'Что произойдет, если разрешить изменение типа проекта?';

  @override
  String get projectTypeAllowChangeBody =>
      'Если вы включите опцию «Разрешить изменение типа проекта», вы сможете вручную выбрать ЛЮБОЙ тип проекта, даже если он не соответствует аннотациям.\n\n⚠️ ПРЕДУПРЕЖДЕНИЕ: При переключении на несовместимый тип проекта все существующие аннотации будут удалены.\nВам придётся повторно аннотировать или импортировать подходящий датасет.';

  @override
  String get projectTypeWhenUseTitle => 'Когда использовать эту опцию?';

  @override
  String get projectTypeWhenUseBody =>
      'Используйте эту опцию, только если:\n\n- Вы случайно импортировали неверный датасет.\n- Хотите начать новый проект с другим типом.\n- Структура вашего датасета изменилась после импорта.\n\nЕсли вы не уверены — оставьте выбор по умолчанию, чтобы избежать потери данных.';

  @override
  String get allLabels => 'Все метки';

  @override
  String get setAsProjectIcon => 'Установить как иконку проекта';

  @override
  String setAsProjectIconConfirm(Object filePath) {
    return 'Вы хотите использовать файл «$filePath» как иконку для этого проекта?\n\nЭто заменит предыдущую иконку.';
  }

  @override
  String get removeFilesFromDatasetInProgress => 'Удаление файлов...';

  @override
  String get removeFilesFromDataset => 'Удалить файлы из датасета?';

  @override
  String removeFilesFromDatasetConfirm(Object amount) {
    return 'Вы уверены, что хотите удалить следующие файлы («$amount»)?\n\nВсе соответствующие аннотации также будут удалены.';
  }

  @override
  String get removeFilesFailedTitle => 'Ошибка удаления';

  @override
  String get removeFilesFailedMessage => 'Некоторые файлы не удалось удалить';

  @override
  String get removeFilesFailedTips =>
      'Проверьте права доступа к файлам и попробуйте снова.';

  @override
  String get duplicateImage => 'Дублировать изображение';

  @override
  String get duplicateWithAnnotations => 'С аннотациями';

  @override
  String get duplicateWithAnnotationsHint =>
      'Будет создана копия изображения с аннотациями.';

  @override
  String get duplicateImageOnly => 'Только изображение';

  @override
  String get duplicateImageOnlyHint =>
      'Будет скопировано только изображение, без аннотаций.';

  @override
  String get saveDuplicateChoiceAsDefault =>
      'Сохранить этот выбор по умолчанию и больше не спрашивать\n(можно изменить в Настройки → Приложение → Навигация по датасету)';

  @override
  String get editProjectTitle => 'Редактировать название проекта';

  @override
  String get editProjectDescription =>
      'Выберите чёткое и понятное название проекта (3–86 символов). Рекомендуется избегать специальных символов.';

  @override
  String get deleteProjectTitle => 'Удалить проект';

  @override
  String get deleteProjectInProgress => 'Удаление проекта...';

  @override
  String get deleteProjectOptionDeleteFromDisk =>
      'Также удалить все файлы с диска';

  @override
  String get deleteProjectOptionDontAskAgain => 'Больше не спрашивать';

  @override
  String deleteProjectConfirm(Object projectName) {
    return 'Вы уверены, что хотите удалить проект «$projectName»?';
  }

  @override
  String deleteProjectInfoLine(Object creationDate, Object labelCount) {
    return 'Проект создан $creationDate\nКоличество меток: $labelCount';
  }

  @override
  String get deleteDatasetTitle => 'Удалить датасет';

  @override
  String get deleteDatasetInProgress =>
      'Удаление датасета... Пожалуйста, подождите.';

  @override
  String deleteDatasetConfirm(Object datasetName) {
    return 'Вы уверены, что хотите удалить «$datasetName»?';
  }

  @override
  String deleteDatasetInfoLine(
    Object creationDate,
    Object mediaCount,
    Object annotationCount,
  ) {
    return 'Этот датасет был создан $creationDate и содержит $mediaCount медиафайлов и $annotationCount аннотаций.';
  }

  @override
  String get editDatasetTitle => 'Переименовать датасет';

  @override
  String get editDatasetDescription => 'Введите новое имя для этого датасета:';

  @override
  String get noMediaDialogUploadPrompt =>
      'Необходимо загрузить изображения или видео';

  @override
  String get noMediaDialogUploadPromptShort => 'Загрузить медиа';

  @override
  String get noMediaDialogSupportedImageTypesTitle =>
      'Поддерживаемые форматы изображений:';

  @override
  String get noMediaDialogSupportedImageTypesList =>
      'jpg, jpeg, png, bmp, jfif, webp';

  @override
  String get noMediaDialogSupportedVideoFormatsLink =>
      'Нажмите здесь, чтобы посмотреть поддерживаемые форматы видео для вашей платформы';

  @override
  String get noMediaDialogSupportedVideoFormatsTitle =>
      'Поддерживаемые форматы видео';

  @override
  String get noMediaDialogSupportedVideoFormatsList =>
      'Часто поддерживаемые форматы:\n\n- MP4: Android, iOS, Web, Desktop\n- MOV: Android, iOS, macOS\n- M4V: Android, iOS, macOS\n- WEBM: Android, Web (зависит от браузера)\n- MKV: Android (частично), Windows\n- AVI: только Android/Windows (частично)';

  @override
  String get noMediaDialogSupportedVideoFormatsWarning =>
      'Поддержка может варьироваться в зависимости от платформы и видеокодека.\nНекоторые форматы могут не работать в браузерах или на iOS.';

  @override
  String get annotatorTopToolbarBackTooltip => 'Назад к проекту';

  @override
  String get annotatorTopToolbarSelectDefaultLabel => 'Метка по умолчанию';

  @override
  String get toolbarNavigation => 'Навигация';

  @override
  String get toolbarBbox => 'Рисовать ограничивающий прямоугольник';

  @override
  String get toolbarPolygon => 'Рисовать полигон';

  @override
  String get toolbarSAM => 'Segment Anything Model';

  @override
  String get toolbarResetZoom => 'Сбросить масштаб';

  @override
  String get toolbarToggleGrid => 'Показать/скрыть сетку';

  @override
  String get toolbarAnnotationSettings => 'Настройки аннотаций';

  @override
  String get toolbarToggleAnnotationNames => 'Показать/скрыть имена аннотаций';

  @override
  String get toolbarRotateLeft => 'Повернуть влево (скоро)';

  @override
  String get toolbarRotateRight => 'Повернуть вправо (скоро)';

  @override
  String get toolbarHelp => 'Помощь';

  @override
  String get dialogOpacityTitle => 'Прозрачность заливки аннотаций';

  @override
  String get dialogHelpTitle => 'Справка по панели инструментов аннотатора';

  @override
  String get dialogHelpContent =>
      '• Навигация – выбор и перемещение по холсту.\n• Прямоугольник – (в проектах обнаружения) рисование ограничивающих рамок.\n• Сброс масштаба – подгонка изображения по размеру экрана.\n• Сетка – показать или скрыть миниатюры изображений.\n• Настройки – изменить прозрачность, толщину границы и размер углов.\n• Названия аннотаций – показать или скрыть подписи к аннотациям.';

  @override
  String get dialogHelpTips =>
      'Совет: используйте режим навигации для выбора и редактирования аннотаций.\nБольше функций и горячих клавиш — скоро!';

  @override
  String get dialogOpacityExplanation =>
      'Отрегулируйте уровень прозрачности, чтобы сделать содержимое более или менее видимым.';

  @override
  String get deleteAnnotationTitle => 'Удалить аннотацию';

  @override
  String get deleteAnnotationMessage => 'Вы уверены, что хотите удалить';

  @override
  String get unnamedAnnotation => 'эту аннотацию';

  @override
  String get accountStorage_importFolderTitle => 'Папка импорта датасетов';

  @override
  String get accountStorage_thumbnailsFolderTitle => 'Папка миниатюр';

  @override
  String get accountStorage_exportFolderTitle => 'Папка экспорта датасетов';

  @override
  String get accountStorage_folderTooltip => 'Выбрать папку';

  @override
  String get accountStorage_helpTitle => 'Настройки хранилища';

  @override
  String get accountStorage_helpMessage =>
      'Здесь вы можете настроить папки по умолчанию.';

  @override
  String get accountStorage_helpTips =>
      'Используйте единообразную структуру папок для упрощения навигации.';

  @override
  String get accountStorage_copySuccess => 'Путь скопирован в буфер обмена';

  @override
  String get accountStorage_openError => 'Папка не существует:\n';

  @override
  String get accountStorage_pathEmpty => 'Путь не указан';

  @override
  String get accountStorage_openFailed => 'Не удалось открыть папку:\n';

  @override
  String get changeProjectTypeTitle => 'Изменить тип проекта';

  @override
  String get changeProjectTypeMigrating => 'Миграция типа проекта...';

  @override
  String get changeProjectTypeStepOneSubtitle =>
      'Пожалуйста, выберите новый тип проекта из списка ниже';

  @override
  String get changeProjectTypeStepTwoSubtitle => 'Подтвердите ваш выбор';

  @override
  String get changeProjectTypeWarningTitle =>
      'Внимание: вы собираетесь изменить тип проекта.';

  @override
  String get changeProjectTypeConversionIntro =>
      'Все существующие аннотации будут преобразованы следующим образом:';

  @override
  String get changeProjectTypeConversionDetails =>
      '- Прямоугольники (Обнаружение) → преобразуются в полигоны.\n- Полигоны (Сегментация) → преобразуются в прямоугольники по границам.\n\nПримечание: при преобразовании полигонов в прямоугольники может теряться точность.\n\n- Обнаружение / Сегментация → Классификация:\n  Изображения будут классифицированы по наиболее часто встречающейся метке:\n     → Если есть 5 меток «Собака» и 10 — «Кошка», будет выбрана «Кошка».\n     → При равенстве — используется первая найденная метка.\n\n- Классификация → Обнаружение / Сегментация:\n  Аннотации не переносятся. Придётся заново разметить медиафайлы вручную.';

  @override
  String get changeProjectTypeErrorTitle => 'Ошибка при миграции';

  @override
  String get changeProjectTypeErrorMessage =>
      'Не удалось изменить тип проекта. Изменения не применены.';

  @override
  String get changeProjectTypeErrorTips =>
      'Проверьте, есть ли в проекте допустимые аннотации, и повторите попытку. Если ошибка сохраняется — перезапустите приложение или обратитесь в поддержку.';

  @override
  String get exportProjectAsDataset => 'Экспортировать проект как датасет';

  @override
  String get projectHelpTitle => 'Как работают проекты';

  @override
  String get projectHelpMessage =>
      'Проекты позволяют объединить датасеты, медиафайлы и аннотации в одном месте. Вы можете создавать проекты под разные задачи: обнаружение, классификация или сегментация.';

  @override
  String get projectHelpTips =>
      'Совет: вы можете импортировать датасеты в форматах COCO, YOLO, VOC, Labelme или Datumaro для автоматического создания проекта.';

  @override
  String get datasetDialogTitle => 'Импорт датасета для создания проекта';

  @override
  String get datasetDialogProcessing => 'Обработка...';

  @override
  String datasetDialogProcessingProgress(Object percent) {
    return 'Обработка... $percent%';
  }

  @override
  String get datasetDialogModeIsolate => 'Режим изоляции включён';

  @override
  String get datasetDialogModeNormal => 'Обычный режим';

  @override
  String get datasetDialogNoDatasetLoaded => 'Датасет не загружен.';

  @override
  String get datasetDialogSelectZipFile => 'Выберите ZIP-файл датасета';

  @override
  String get datasetDialogChooseFile => 'Выбрать файл';

  @override
  String get datasetDialogSupportedFormats =>
      'Поддерживаемые форматы датасетов:';

  @override
  String get datasetDialogSupportedFormatsList1 => 'COCO, YOLO, VOC, Datumaro,';

  @override
  String get datasetDialogSupportedFormatsList2 =>
      'LabelMe, CVAT или только медиа (.zip)';

  @override
  String get dialogImageDetailsTitle => 'Информация о файле';

  @override
  String get datasetDialogImportFailedTitle => 'Ошибка импорта';

  @override
  String get datasetDialogImportFailedMessage =>
      'ZIP-файл не удалось обработать. Возможно, он повреждён, неполный или не является допустимым архивом датасета.';

  @override
  String get datasetDialogImportFailedTips =>
      'Попробуйте заново экспортировать или упаковать ваш датасет.\nУбедитесь, что он соответствует форматам COCO, YOLO, VOC и т.п.\n\nОшибка: ';

  @override
  String get datasetDialogNoProjectTypeTitle => 'Тип проекта не выбран';

  @override
  String get datasetDialogNoProjectTypeMessage =>
      'Пожалуйста, выберите тип проекта на основе аннотаций в вашем датасете.';

  @override
  String get datasetDialogNoProjectTypeTips =>
      'Проверьте структуру датасета и убедитесь, что аннотации соответствуют одному из поддерживаемых форматов: COCO, YOLO, VOC, Datumaro.';

  @override
  String get datasetDialogProcessingDatasetTitle => 'Обработка датасета';

  @override
  String get datasetDialogProcessingDatasetMessage =>
      'Мы извлекаем ZIP-архив, анализируем его содержимое и определяем формат датасета и тип аннотаций. Пожалуйста, не закрывайте окно во время процесса.';

  @override
  String get datasetDialogProcessingDatasetTips =>
      'Большие архивы с множеством изображений и аннотаций могут обрабатываться дольше.';

  @override
  String get datasetDialogCreatingProjectTitle => 'Создание проекта';

  @override
  String get datasetDialogCreatingProjectMessage =>
      'Инициализация проекта, сохранение конфигураций, меток, датасетов и связей с медиафайлами. Пожалуйста, подождите.';

  @override
  String get datasetDialogCreatingProjectTips =>
      'Проекты с большим числом медиафайлов или меток могут создаваться немного дольше.';

  @override
  String get datasetDialogAnalyzingDatasetTitle => 'Анализ датасета';

  @override
  String get datasetDialogAnalyzingDatasetMessage =>
      'Анализ содержимого архива датасета: извлечение файлов, определение структуры и аннотаций, сбор информации. Не закрывайте окно до завершения.';

  @override
  String get datasetDialogAnalyzingDatasetTips =>
      'Датасеты с большим количеством файлов или сложными аннотациями могут потребовать больше времени.';

  @override
  String get datasetDialogFilePickErrorTitle => 'Ошибка выбора файла';

  @override
  String get datasetDialogFilePickErrorMessage =>
      'Не удалось выбрать файл. Повторите попытку.';

  @override
  String get datasetDialogGenericErrorTips =>
      'Проверьте файл и повторите попытку. Если ошибка сохраняется, обратитесь в поддержку.';

  @override
  String get thumbnailGenerationTitle => 'Ошибка';

  @override
  String get thumbnailGenerationFailed => 'Не удалось создать миниатюру';

  @override
  String get thumbnailGenerationTryAgainLater => 'Повторите попытку позже';

  @override
  String get thumbnailGenerationInProgress => 'Создание миниатюры...';

  @override
  String get menuImageAnnotate => 'Разметить';

  @override
  String get menuImageDetails => 'Детали';

  @override
  String get menuImageDuplicate => 'Дублировать';

  @override
  String get menuImageSetAsIcon => 'Иконка';

  @override
  String get menuImageDelete => 'Удалить';

  @override
  String get noLabelsTitle => 'Нет меток в проекте';

  @override
  String get noLabelsExplain1 =>
      'Нельзя аннотировать без меток — они придают смысл разметке.';

  @override
  String get noLabelsExplain2 =>
      'Вы можете добавить метки вручную или импортировать из JSON-файла.';

  @override
  String get noLabelsExplain3 =>
      'Аннотация без метки — просто пустой прямоугольник.';

  @override
  String get noLabelsExplain4 =>
      'Метки определяют категории объектов, которые вы размечаете.';

  @override
  String get noLabelsExplain5 =>
      'Неважно, размечаете ли вы объекты, классифицируете или сегментируете области —';

  @override
  String get noLabelsExplain6 =>
      'метки необходимы для чёткого и структурированного аннотирования.';

  @override
  String get importLabelsPreviewTitle => 'Предпросмотр импортируемых меток';

  @override
  String get importLabelsFailedTitle => 'Ошибка при импорте меток';

  @override
  String get importLabelsNoLabelsTitle => 'В проекте не найдено меток';

  @override
  String get importLabelsJsonParseError => 'Ошибка разбора JSON.\n';

  @override
  String get importLabelsJsonParseTips =>
      'Убедитесь, что файл — допустимый JSON. Проверьте его на https://jsonlint.com/';

  @override
  String importLabelsJsonNotList(Object type) {
    return 'Ожидался список меток (массив), но получено: $type.';
  }

  @override
  String get importLabelsJsonNotListTips =>
      'JSON-файл должен начинаться с [ и содержать список объектов меток. Каждая метка должна содержать name, color и labelOrder.';

  @override
  String importLabelsJsonItemNotMap(Object type) {
    return 'Один из элементов списка — не объект: $type';
  }

  @override
  String get importLabelsJsonItemNotMapTips =>
      'Каждый элемент должен быть объектом с полями: name, color, labelOrder.';

  @override
  String get importLabelsJsonLabelParseError =>
      'Не удалось разобрать одну из меток.\n';

  @override
  String get importLabelsJsonLabelParseTips =>
      'Проверьте, что каждая метка содержит необходимые поля и имеет правильные значения.';

  @override
  String get importLabelsUnexpectedError =>
      'Произошла непредвиденная ошибка при импорте JSON.\n';

  @override
  String get importLabelsUnexpectedErrorTip =>
      'Убедитесь, что файл читается и имеет правильный формат.';

  @override
  String get importLabelsDatabaseError =>
      'Не удалось сохранить метки в базу данных';

  @override
  String get importLabelsDatabaseErrorTips =>
      'Проверьте подключение к базе данных и повторите попытку. Если ошибка не исчезает, обратитесь в поддержку.';

  @override
  String get importLabelsNameMissingOrEmpty =>
      'У одной из меток отсутствует имя.';

  @override
  String get importLabelsNameMissingOrEmptyTips =>
      'Убедитесь, что каждая метка содержит поле \'name\' и оно не пустое.';

  @override
  String get menuSortAZ => 'А-Я';

  @override
  String get menuSortZA => 'Я-А';

  @override
  String get menuSortProjectType => 'Тип проекта';

  @override
  String get uploadInProgressTitle => 'Идёт загрузка';

  @override
  String get uploadInProgressMessage =>
      'В данный момент выполняется загрузка. Если вы покинете страницу, загрузка будет отменена и её нужно будет начать заново.\n\nВы действительно хотите выйти?';

  @override
  String get uploadInProgressStay => 'Остаться';

  @override
  String get uploadInProgressLeave => 'Выйти';

  @override
  String get fileNotFound => 'Файл не найден или доступ запрещён';

  @override
  String get labelEditSave => 'Сохранить';

  @override
  String get labelEditEdit => 'Редактировать';

  @override
  String get labelEditMoveUp => 'Вверх';

  @override
  String get labelEditMoveDown => 'Вниз';

  @override
  String get labelEditDefault => 'По умолчанию';

  @override
  String get labelEditUndefault => 'Без умолч';

  @override
  String get labelEditDelete => 'Удалить';

  @override
  String get labelExportLabels => 'Экспортировать метки';

  @override
  String get labelSaveDialogTitle => 'Сохранить метки в JSON-файл';

  @override
  String get labelSaveDefaultFilename => 'labels.json';

  @override
  String labelDeleteError(Object error) {
    return 'Не удалось удалить метку: $error';
  }

  @override
  String get labelDeleteErrorTips =>
      'Убедитесь, что метка существует и не используется в других местах.';

  @override
  String get datasetStepUploadZip =>
      'Загрузите ZIP-файл с форматом COCO, YOLO, VOC, LabelMe, CVAT, Datumaro или только медиа';

  @override
  String get datasetStepExtractingZip =>
      'Извлечение ZIP в локальное хранилище ...';

  @override
  String datasetStepExtractedPath(Object path) {
    return 'Датасет извлечен в: $path';
  }

  @override
  String datasetStepDetectedTaskType(Object format) {
    return 'Обнаруженный тип задачи: $format';
  }

  @override
  String get datasetStepSelectProjectType => 'Выберите тип проекта';

  @override
  String get datasetStepProgressSelection => 'Выбор датасета';

  @override
  String get datasetStepProgressExtract => 'Извлечение ZIP';

  @override
  String get datasetStepProgressOverview => 'Обзор датасета';

  @override
  String get datasetStepProgressTaskConfirmation => 'Подтверждение задачи';

  @override
  String get datasetStepProgressProjectCreation => 'Создание проекта';

  @override
  String get projectTypeDetectionBoundingBox =>
      'Детекция (прямоугольные рамки)';

  @override
  String get projectTypeDetectionOriented => 'Детекция (поворотные рамки)';

  @override
  String get projectTypeBinaryClassification => 'Бинарная классификация';

  @override
  String get projectTypeMultiClassClassification =>
      'Многоклассовая классификация';

  @override
  String get projectTypeMultiLabelClassification =>
      'Многометочная классификация';

  @override
  String get projectTypeInstanceSegmentation => 'Сегментация экземпляров';

  @override
  String get projectTypeSemanticSegmentation => 'Семантическая сегментация';

  @override
  String get datasetStepChooseProjectType =>
      'Выберите тип проекта на основе обнаруженных аннотаций';

  @override
  String get datasetStepAllowProjectTypeChange =>
      'Разрешить изменение типа проекта';

  @override
  String get projectTypeBinaryClassificationDescription =>
      'Присвоение одной из двух возможных меток каждому входному изображению (например, спам или не спам, положительный или отрицательный).';

  @override
  String get projectTypeMultiClassClassificationDescription =>
      'Присвоение ровно одной метки из набора взаимоисключающих классов (например, кошка, собака или птица).';

  @override
  String get projectTypeMultiLabelClassificationDescription =>
      'Присвоение одной или нескольких меток из набора классов — несколько меток могут применяться одновременно (например, изображение с метками \"кошка\" и \"собака\")';

  @override
  String get projectTypeDetectionBoundingBoxDescription =>
      'Нарисуйте прямоугольник вокруг объекта на изображении.';

  @override
  String get projectTypeDetectionOrientedDescription =>
      'Нарисуйте и заключите объект в минимальный прямоугольник.';

  @override
  String get projectTypeInstanceSegmentationDescription =>
      'Обнаружение и различение каждого отдельного объекта на основе его уникальных особенностей.';

  @override
  String get projectTypeSemanticSegmentationDescription =>
      'Обнаружение и классификация всех похожих объектов как единого целого.';
}
