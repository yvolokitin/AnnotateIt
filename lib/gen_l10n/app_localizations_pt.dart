// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get buttonKeep => 'Manter';

  @override
  String get buttonSave => 'Salvar';

  @override
  String get buttonHelp => 'Ajuda';

  @override
  String get buttonEdit => 'Editar';

  @override
  String get buttonNext => 'Próximo';

  @override
  String get buttonBack => 'Voltar';

  @override
  String get buttonApply => 'Aplicar';

  @override
  String get buttonClose => 'Fechar';

  @override
  String get buttonImport => 'Importar';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonFinish => 'Finalizar';

  @override
  String get buttonDelete => 'Excluir';

  @override
  String get buttonDuplicate => 'Duplicar';

  @override
  String get buttonConfirm => 'Confirmar';

  @override
  String get buttonDiscard => 'Descartar';

  @override
  String get buttonFeedbackShort => 'Fdbck';

  @override
  String get buttonImportLabels => 'Importar Etiquetas';

  @override
  String get buttonExportLabels => 'Exportar Etiquetas';

  @override
  String get buttonNextConfirmTask => 'Próximo: Confirmar Tarefa';

  @override
  String get buttonCreateProject => 'Criar Projeto';

  @override
  String get aboutTitle => 'Sobre o Annot@It';

  @override
  String get aboutDescription =>
      'Annot@It é um aplicativo de anotação projetado para simplificar o processo de anotação para projetos de visão computacional. Seja trabalhando em classificação de imagens, detecção de objetos, segmentação ou outras tarefas de visão, o Annot@It oferece a flexibilidade e precisão necessárias para rotulagem de dados de alta qualidade.';

  @override
  String get aboutFeaturesTitle => 'Recursos principais:';

  @override
  String get aboutFeatures =>
      '- Múltiplos Tipos de Projeto: Crie e gerencie projetos adaptados para diferentes tarefas de visão computacional.\n- Upload e Gerenciamento de Dados: Faça upload e organize facilmente seus conjuntos de dados para anotação perfeita.\n- Ferramentas Avançadas de Anotação: Use caixas delimitadoras, polígonos, pontos-chave e máscaras de segmentação.\n- Exportação e Integração: Exporte dados rotulados em vários formatos compatíveis com frameworks de IA/ML.';

  @override
  String get aboutCallToAction =>
      'Comece sua jornada de anotação hoje e construa conjuntos de dados de alta qualidade para seus modelos de visão computacional!';

  @override
  String get accountUser => 'Usuário';

  @override
  String get accountProfile => 'Perfil';

  @override
  String get accountStorage => 'Armazenamento';

  @override
  String get accountDeviceStorage => 'Armazenamento do Dispositivo';

  @override
  String get accountSettings => 'Configurações';

  @override
  String get accountApplicationSettings => 'Configurações do Aplicativo';

  @override
  String get accountLoadingMessage => 'Carregando dados do usuário...';

  @override
  String get accountErrorLoadingUser => 'Could not  load user data';

  @override
  String get accountRetry => 'Retry';

  @override
  String get userProfileName => 'Capitão Anotador';

  @override
  String get userProfileFeedbackButton => 'Feedback';

  @override
  String get userProfileEditProfileButton => 'Editar Perfil';

  @override
  String get userProfileProjects => 'Projetos';

  @override
  String get userProfileLabels => 'Etiquetas';

  @override
  String get userProfileMedia => 'Mídia';

  @override
  String get userProfileOverview => 'Visão Geral';

  @override
  String get userProfileAnnotations => 'Anotações';

  @override
  String get settingsGeneralTitle => 'Configurações Gerais';

  @override
  String get settingsProjectCreationTitle => 'Criação de Projeto';

  @override
  String get settingsProjectCreationConfirmNoLabels =>
      'Sempre perguntar para confirmar ao criar um projeto sem etiquetas';

  @override
  String get settingsProjectCreationConfirmNoLabelsNote =>
      'Você será avisado se tentar criar um projeto sem nenhuma etiqueta definida.';

  @override
  String get settingsLabelsCreationDeletionTitle =>
      'Criação / Exclusão de Etiquetas';

  @override
  String get settingsLabelsDeletionWithAnnotations =>
      'Excluir anotações quando a etiqueta for removida';

  @override
  String get settingsLabelsDeletionWithAnnotationsNote =>
      'Quando ativado, excluir uma etiqueta removerá automaticamente todas as anotações atribuídas a essa etiqueta em todos os itens de mídia.';

  @override
  String get settingsLabelsSetDefaultLabel =>
      'Definir primeira etiqueta como padrão';

  @override
  String get settingsLabelsSetDefaultLabelNote =>
      'Quando ativado, a primeira etiqueta que você criar em um projeto será automaticamente marcada como a etiqueta padrão. Você pode alterar o padrão posteriormente a qualquer momento.';

  @override
  String get settingsDatasetViewTitle => 'Visualização do Conjunto de Dados';

  @override
  String get settingsDatasetViewDuplicateWithAnnotations =>
      'Duplicar (fazer uma cópia) imagem sempre com anotações';

  @override
  String get settingsDatasetViewDuplicateWithAnnotationsNote =>
      'Ao duplicar, as anotações serão incluídas a menos que você altere as configurações';

  @override
  String get settingsDatasetViewDeleteFromOS =>
      'Ao excluir imagem do Conjunto de Dados, sempre excluí-la do sistema operacional / sistema de arquivos';

  @override
  String get settingsDatasetViewDeleteFromOSNote =>
      'Exclui o arquivo do disco também, não apenas do conjunto de dados';

  @override
  String get settingsAnnotationTitle => 'Configurações de Anotação';

  @override
  String get settingsAnnotationOpacity => 'Opacidade da anotação';

  @override
  String get settingsAnnotationAutoSave =>
      'Sempre salvar ou enviar anotação ao passar para a próxima imagem';

  @override
  String get settingsThemeTitle => 'Seleção de tema';

  @override
  String get settingsLanguageTitle => 'País / Idioma';

  @override
  String get colorPickerTitle => 'Escolher uma cor';

  @override
  String get colorPickerBasicColors => 'Cores básicas';

  @override
  String get loadingProjects => 'Carregando projetos...';

  @override
  String get importDataset => 'Importar conjunto de dados';

  @override
  String get uploadMedia => 'Carregar mídia';

  @override
  String get createProjectTitle => 'Criar um Novo Projeto';

  @override
  String get createProjectStepOneSubtitle =>
      'Por favor, insira o nome do seu novo projeto e selecione o tipo de Projeto';

  @override
  String get createProjectStepTwoSubtitle =>
      'Por favor, crie etiquetas para um Novo projeto';

  @override
  String get emptyProjectTitle => 'Inicie seu primeiro projeto';

  @override
  String get emptyProjectDescription =>
      'Crie um projeto para começar a organizar conjuntos de dados, anotar mídia e aplicar IA às suas tarefas de visão — tudo em um espaço de trabalho otimizado projetado para acelerar seu pipeline de visão computacional.';

  @override
  String get emptyProjectCreateNew => 'Criar Novo Projeto';

  @override
  String get emptyProjectCreateNewShort => 'Novo Projeto';

  @override
  String get emptyProjectImportDataset =>
      'Criar Projeto a partir da importação de Conjunto de Dados';

  @override
  String get emptyProjectImportDatasetShort => 'Importar Conjunto de Dados';

  @override
  String get dialogBack => '<- Voltar';

  @override
  String get dialogNext => 'Próximo ->';

  @override
  String get rename => 'Renomear';

  @override
  String get delete => 'Excluir';

  @override
  String get setAsDefault => 'Definir como Padrão';

  @override
  String paginationPageFromTotal(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get taskTypeRequiredTitle => 'Tipo de Tarefa Necessário';

  @override
  String taskTypeRequiredMessage(Object tab) {
    return 'Você precisa selecionar um tipo de tarefa antes de continuar. A aba atual \'$tab\' não tem um tipo de tarefa selecionado. Cada projeto deve estar associado a uma tarefa (por exemplo, detecção de objetos, classificação ou segmentação) para que o sistema saiba como processar seus dados.';
  }

  @override
  String taskTypeRequiredTips(Object tab) {
    return 'Clique em uma das opções de tipo de tarefa disponíveis abaixo da aba \'$tab\'. Se você não tem certeza de qual tarefa escolher, passe o mouse sobre o ícone de informação ao lado de cada tipo para ver uma breve descrição.';
  }

  @override
  String get menuProjects => 'Projetos';

  @override
  String get menuAccount => 'Conta';

  @override
  String get menuLearn => 'Aprender';

  @override
  String get menuAbout => 'Sobre';

  @override
  String get menuCreateNewProject => 'Criar novo projeto';

  @override
  String get menuCreateFromDataset => 'Criar a partir de Conjunto de Dados';

  @override
  String get menuImportDataset =>
      'Criar projeto a partir da Importação de Conjunto de Dados';

  @override
  String get menuSortLastUpdated => 'Última Atualização';

  @override
  String get menuSortNewestOldest => 'Mais Recente-Mais Antigo';

  @override
  String get menuSortOldestNewest => 'Mais Antigo-Mais Recente';

  @override
  String get menuSortType => 'Tipo de Projeto';

  @override
  String get menuSortAz => 'A-Z';

  @override
  String get menuSortZa => 'Z-A';

  @override
  String get projectNameLabel => 'Nome do Projeto';

  @override
  String get tabDetection => 'Detecção';

  @override
  String get tabClassification => 'Classificação';

  @override
  String get tabSegmentation => 'Segmentação';

  @override
  String get labelRequiredTitle => 'Pelo Menos Uma Etiqueta Necessária';

  @override
  String get labelRequiredMessage =>
      'Você deve criar pelo menos uma etiqueta para continuar. As etiquetas são essenciais para definir as categorias de anotação que serão usadas durante a preparação do conjunto de dados.';

  @override
  String get labelRequiredTips =>
      'Dica: Clique no botão vermelho rotulado Criar Etiqueta após inserir um nome de etiqueta para adicionar sua primeira etiqueta.';

  @override
  String get createLabelButton => 'Criar Etiqueta';

  @override
  String get labelNameHint => 'Digite um novo nome de Etiqueta aqui';

  @override
  String get createdLabelsTitle => 'Etiquetas Criadas';

  @override
  String get labelEmptyTitle => 'O nome da etiqueta não pode estar vazio!';

  @override
  String get labelEmptyMessage =>
      'Por favor, insira um nome de etiqueta. As etiquetas ajudam a identificar os objetos ou categorias em seu projeto. É recomendável usar nomes curtos, claros e descritivos, como \"Carro\", \"Pessoa\" ou \"Árvore\". Evite caracteres especiais ou espaços.';

  @override
  String get labelEmptyTips =>
      'Dicas para Nomear Etiquetas:\n• Use nomes curtos e descritivos\n• Mantenha-se com letras, dígitos, sublinhados (por exemplo, gato, placa_de_trânsito, fundo)\n• Evite espaços e símbolos (por exemplo, Pessoa 1 → pessoa_1)';

  @override
  String get labelDuplicateTitle => 'Nome de Etiqueta Duplicado';

  @override
  String labelDuplicateMessage(Object label) {
    return 'A etiqueta \'$label\' já existe neste projeto. Cada etiqueta deve ter um nome único para evitar confusão durante a anotação e o treinamento.';
  }

  @override
  String get labelDuplicateTips =>
      'Por que etiquetas únicas?\n• Reutilizar o mesmo nome pode causar problemas durante a exportação do conjunto de dados e o treinamento do modelo.\n• Nomes de etiquetas únicos ajudam a manter anotações claras e estruturadas.\n\nDica: Tente adicionar uma variação ou número para diferenciar (por exemplo, \'Carro\', \'Carro_2\').';

  @override
  String get binaryLimitTitle => 'Limite de Classificação Binária';

  @override
  String get binaryLimitMessage =>
      'Você não pode criar mais de duas etiquetas para um projeto de Classificação Binária.\n\nA Classificação Binária é projetada para distinguir entre exatamente duas classes, como \'Sim\' vs \'Não\', ou \'Spam\' vs \'Não Spam\'.';

  @override
  String get binaryLimitTips =>
      'Precisa de mais de duas etiquetas?\nConsidere mudar o tipo do seu projeto para Classificação Multi-Classe ou outra tarefa adequada para suportar três ou mais categorias.';

  @override
  String get noteBinaryClassification =>
      'Este tipo de projeto permite exatamente 2 etiquetas. A Classificação Binária é usada quando seu modelo precisa distinguir entre duas classes possíveis, como \"Sim\" vs \"Não\", ou \"Cachorro\" vs \"Não Cachorro\". Por favor, crie apenas duas etiquetas distintas.';

  @override
  String get noteMultiClassClassification =>
      'Este tipo de projeto suporta múltiplas etiquetas. A Classificação Multi-Classe é adequada quando seu modelo precisa escolher entre três ou mais categorias, como \"Gato\", \"Cachorro\", \"Coelho\". Você pode adicionar quantas etiquetas forem necessárias.';

  @override
  String get noteDetectionOrSegmentation =>
      'Este tipo de projeto suporta múltiplas etiquetas. Para Detecção de Objetos ou Segmentação, cada etiqueta normalmente representa uma classe diferente de objeto (por exemplo, \"Carro\", \"Pedestre\", \"Bicicleta\"). Você pode criar quantas etiquetas forem necessárias para seu conjunto de dados.';

  @override
  String get noteDefault =>
      'Você pode criar uma ou mais etiquetas dependendo do tipo do seu projeto. Cada etiqueta ajuda a definir uma categoria que seu modelo aprenderá a reconhecer. Consulte a documentação para melhores práticas.';

  @override
  String get discardDatasetImportTitle =>
      'Descartar Importação de Conjunto de Dados?';

  @override
  String get discardDatasetImportMessage =>
      'Você já extraiu um conjunto de dados. Cancelar agora excluirá os arquivos extraídos e os detalhes do conjunto de dados detectados. Tem certeza de que deseja continuar?';

  @override
  String get projectTypeHelpTitle => 'Ajuda para Seleção de Tipo de Projeto';

  @override
  String get projectTypeWhyDisabledTitle =>
      'Por que alguns tipos de projeto estão desativados?';

  @override
  String get projectTypeWhyDisabledBody =>
      'Quando você importa um conjunto de dados, o sistema analisa as anotações fornecidas e tenta detectar automaticamente o tipo de projeto mais adequado para você.\n\nPor exemplo, se seu conjunto de dados contém anotações de caixas delimitadoras, o tipo de projeto sugerido será \"Detecção\". Se contém máscaras, \"Segmentação\" será sugerido, e assim por diante.\n\nPara proteger seus dados, apenas tipos de projeto compatíveis são habilitados por padrão.';

  @override
  String get projectTypeAllowChangeTitle =>
      'O que acontece se eu habilitar a mudança de tipo de projeto?';

  @override
  String get projectTypeAllowChangeBody =>
      'Se você ativar \"Permitir Mudança de Tipo de Projeto\", poderá selecionar manualmente QUALQUER tipo de projeto, mesmo que não corresponda às anotações detectadas.\n\n⚠️ AVISO: Todas as anotações existentes da importação serão excluídas ao mudar para um tipo de projeto incompatível.\nVocê precisará reannotar ou importar um conjunto de dados adequado para o tipo de projeto recém-selecionado.';

  @override
  String get projectTypeWhenUseTitle => 'Quando devo usar esta opção?';

  @override
  String get projectTypeWhenUseBody =>
      'Você só deve habilitar esta opção se:\n\n- Você importou acidentalmente o conjunto de dados errado.\n- Você deseja iniciar um novo projeto de anotação com um tipo diferente.\n- A estrutura do seu conjunto de dados mudou após a importação.\n\nSe você não tem certeza, recomendamos fortemente manter a seleção padrão para evitar perda de dados.';

  @override
  String get allLabels => 'Todas as Etiquetas';

  @override
  String get setAsProjectIcon => 'Definir como Ícone do Projeto';

  @override
  String setAsProjectIconConfirm(Object filePath) {
    return 'Deseja usar \'$filePath\' como ícone para este projeto?\n\nIsso substituirá qualquer ícone definido anteriormente.';
  }

  @override
  String get removeFilesFromDatasetInProgress => 'Excluindo arquivos...';

  @override
  String get removeFilesFromDataset => 'Remover arquivos do Conjunto de Dados?';

  @override
  String removeFilesFromDatasetConfirm(Object amount) {
    return 'Tem certeza de que deseja excluir os seguintes arquivos (\'$amount\')?\n\nTodas as anotações correspondentes também serão removidas.';
  }

  @override
  String get removeFilesFailedTitle => 'Falha na Exclusão';

  @override
  String get removeFilesFailedMessage =>
      'Alguns arquivos não puderam ser excluídos';

  @override
  String get removeFilesFailedTips =>
      'Verifique as permissões de arquivo e tente novamente';

  @override
  String get duplicateImage => 'Duplicar Imagem';

  @override
  String get duplicateWithAnnotations => 'Duplicar imagem com anotações';

  @override
  String get duplicateWithAnnotationsHint =>
      'Uma cópia da imagem será criada junto com todos os dados de anotação.';

  @override
  String get duplicateImageOnly => 'Duplicar apenas a imagem';

  @override
  String get duplicateImageOnlyHint =>
      'Apenas a imagem será copiada, sem anotações.';

  @override
  String get saveDuplicateChoiceAsDefault =>
      'Salvar esta resposta como resposta padrão e não perguntar novamente\n(Você pode alterar isso em Conta -> Configurações do aplicativo -> Navegação do conjunto de dados)';

  @override
  String get editProjectTitle => 'Editar nome do projeto';

  @override
  String get editProjectDescription =>
      'Por favor, escolha um nome de projeto claro e descritivo (3 - 86 caracteres). É recomendável evitar caracteres especiais.';

  @override
  String get deleteProjectTitle => 'Excluir Projeto';

  @override
  String get deleteProjectInProgress => 'Excluindo projeto...';

  @override
  String get deleteProjectOptionDeleteFromDisk =>
      'Também excluir todos os arquivos do disco';

  @override
  String get deleteProjectOptionDontAskAgain => 'Não me pergunte novamente';

  @override
  String deleteProjectConfirm(Object projectName) {
    return 'Tem certeza de que deseja excluir o projeto \"$projectName\"?';
  }

  @override
  String deleteProjectInfoLine(Object creationDate, Object labelCount) {
    return 'O projeto foi criado em $creationDate\nNúmero de Etiquetas: $labelCount';
  }

  @override
  String get deleteDatasetTitle => 'Excluir Conjunto de Dados';

  @override
  String get deleteDatasetInProgress =>
      'Excluindo conjunto de dados... Por favor, aguarde.';

  @override
  String deleteDatasetConfirm(Object datasetName) {
    return 'Tem certeza de que deseja excluir \"$datasetName\"?';
  }

  @override
  String deleteDatasetInfoLine(
    Object creationDate,
    Object mediaCount,
    Object annotationCount,
  ) {
    return 'Este conjunto de dados foi criado em $creationDate e contém $mediaCount itens de mídia e $annotationCount anotações.';
  }

  @override
  String get editDatasetTitle => 'Renomear Conjunto de Dados';

  @override
  String get editDatasetDescription =>
      'Digite um novo nome para este conjunto de dados:';

  @override
  String get noMediaDialogUploadPrompt =>
      'Você precisa carregar imagens ou vídeos';

  @override
  String get noMediaDialogUploadPromptShort => 'Carregar mídia';

  @override
  String get noMediaDialogSupportedImageTypesTitle =>
      'Tipos de imagens suportados:';

  @override
  String get noMediaDialogSupportedImageTypesList =>
      'jpg, jpeg, png, bmp, jfif, webp';

  @override
  String get noMediaDialogSupportedVideoFormatsLink =>
      'Clique aqui para ver quais formatos de vídeo são suportados em sua plataforma';

  @override
  String get noMediaDialogSupportedVideoFormatsTitle =>
      'Formatos de Vídeo Suportados';

  @override
  String get noMediaDialogSupportedVideoFormatsList =>
      'Formatos Comumente Suportados:\n\n- MP4: Android, iOS, Web, Desktop\n- MOV: Android, iOS, macOS\n- M4V: Android, iOS, macOS\n- WEBM: Android, Web (dependente do navegador)\n- MKV: Android (parcial), Windows\n- AVI: Apenas Android/Windows (parcial)';

  @override
  String get noMediaDialogSupportedVideoFormatsWarning =>
      'O suporte pode variar dependendo da plataforma e do codec de vídeo.\nAlguns formatos podem não funcionar em navegadores ou no iOS.';

  @override
  String get annotatorTopToolbarBackTooltip => 'Voltar ao Projeto';

  @override
  String get annotatorTopToolbarSelectDefaultLabel => 'Etiqueta padrão';

  @override
  String get toolbarNavigation => 'Navegação';

  @override
  String get toolbarBbox => 'Desenhar Caixa Delimitadora';

  @override
  String get toolbarPolygon => 'Desenhar Polígono';

  @override
  String get toolbarSAM => 'Modelo de Segmentação Automática';

  @override
  String get toolbarResetZoom => 'Redefinir Zoom';

  @override
  String get toolbarToggleGrid => 'Alternar Grade';

  @override
  String get toolbarAnnotationSettings => 'Configurações de Anotação';

  @override
  String get toolbarToggleAnnotationNames => 'Alternar Nomes de Anotação';

  @override
  String get toolbarRotateLeft => 'Girar à Esquerda (Em Breve)';

  @override
  String get toolbarRotateRight => 'Girar à Direita (Em Breve)';

  @override
  String get toolbarHelp => 'Ajuda';

  @override
  String get dialogOpacityTitle => 'Opacidade de Preenchimento da Anotação';

  @override
  String get dialogHelpTitle => 'Ajuda da Barra de Ferramentas do Anotador';

  @override
  String get dialogHelpContent =>
      '• Navegação – Use para selecionar e mover pelo canvas.\n• Caixa Delimitadora – (Visível em projetos de Detecção) Desenhe caixas delimitadoras retangulares.\n• Redefinir Zoom – Redefine o nível de zoom para ajustar a imagem na tela.\n• Alternar Grade – Mostrar ou ocultar a grade de miniaturas do conjunto de dados.\n• Configurações – Ajuste a opacidade de preenchimento das anotações, a borda das anotações e o tamanho dos cantos.\n• Alternar Nomes de Anotação – Mostrar ou ocultar etiquetas de texto nas anotações.';

  @override
  String get dialogHelpTips =>
      'Dica: Use o modo de Navegação para selecionar e editar anotações.\nMais atalhos e recursos em breve!';

  @override
  String get dialogOpacityExplanation =>
      'Ajuste o nível de opacidade para tornar o conteúdo mais ou menos transparente.';

  @override
  String get deleteAnnotationTitle => 'Excluir Anotação';

  @override
  String get deleteAnnotationMessage => 'Tem certeza de que deseja excluir';

  @override
  String get unnamedAnnotation => 'esta anotação';

  @override
  String get accountStorage_importFolderTitle =>
      'Pasta de importação de Conjuntos de Dados';

  @override
  String get accountStorage_thumbnailsFolderTitle => 'Pasta de Miniaturas';

  @override
  String get accountStorage_exportFolderTitle =>
      'Pasta de exportação de Conjuntos de Dados';

  @override
  String get accountStorage_folderTooltip => 'Escolher pasta';

  @override
  String get accountStorage_helpTitle => 'Ajuda de Armazenamento';

  @override
  String get accountStorage_helpMessage =>
      'Você pode alterar a pasta onde os conjuntos de dados importados, os arquivos ZIP exportados e as miniaturas são armazenados.\nToque no ícone \"Pasta\" ao lado do campo de caminho para selecionar ou alterar o diretório.\n\nEsta pasta será usada como local padrão para:\n- Arquivos de conjuntos de dados importados (por exemplo, COCO, YOLO, VOC, Datumaro, etc.)\n- Arquivos Zip de conjuntos de dados exportados\n- Miniaturas de projetos\n\nCertifique-se de que a pasta selecionada seja gravável e tenha espaço suficiente.\nNo Android ou iOS, você pode precisar conceder permissões de armazenamento.\nAs pastas recomendadas variam por plataforma — veja abaixo dicas específicas da plataforma.';

  @override
  String get accountStorage_helpTips =>
      'Pastas recomendadas por plataforma:\n\nWindows:\n  C:\\Users\\<você>\\AppData\\Roaming\\AnnotateIt\\datasets\n\nLinux / Ubuntu:\n  /home/<você>/.annotateit/datasets\n\nmacOS:\n  /Users/<você>/Library/Application Support/AnnotateIt/datasets\n\nAndroid:\n  /storage/emulated/0/AnnotateIt/datasets\n\niOS:\n  <Caminho sandbox do app>/Documents/AnnotateIt/datasets\n';

  @override
  String get accountStorage_copySuccess =>
      'Caminho copiado para a área de transferência';

  @override
  String get accountStorage_openError => 'A pasta não existe:\n';

  @override
  String get accountStorage_pathEmpty => 'O caminho está vazio';

  @override
  String get accountStorage_openFailed => 'Falha ao abrir a pasta:\n';

  @override
  String get changeProjectTypeTitle => 'Alterar tipo de projeto';

  @override
  String get changeProjectTypeMigrating => 'Migrando tipo de projeto...';

  @override
  String get changeProjectTypeStepOneSubtitle =>
      'Por favor, selecione um novo tipo de projeto da lista abaixo';

  @override
  String get changeProjectTypeStepTwoSubtitle =>
      'Por favor, confirme sua escolha';

  @override
  String get changeProjectTypeWarningTitle =>
      'Aviso: Você está prestes a alterar o tipo de projeto.';

  @override
  String get changeProjectTypeConversionIntro =>
      'Todas as anotações existentes serão convertidas da seguinte forma:';

  @override
  String get changeProjectTypeConversionDetails =>
      '- Caixas delimitadoras (Detecção) -> convertidas em polígonos retangulares.\n- Polígonos (Segmentação) -> convertidos em caixas delimitadoras ajustadas.\n\nNota: Essas conversões podem reduzir a precisão, especialmente ao converter polígonos em caixas, pois informações detalhadas de forma serão perdidas.\n\n- Detecção / Segmentação → Classificação:\n  As imagens serão classificadas com base na etiqueta mais frequente nas anotações:\n     -> Se a imagem tiver 5 objetos rotulados como \"Cachorro\" e 10 rotulados como \"Gato\", será classificada como \"Gato\".\n     -> Se as contagens forem iguais, a primeira etiqueta encontrada será usada.\n\n- Classificação -> Detecção / Segmentação:\n  Nenhuma anotação será transferida. Você precisará reannotar todos os itens de mídia manualmente, pois os projetos de classificação não contêm dados em nível de região.';

  @override
  String get changeProjectTypeErrorTitle => 'Falha na Migração';

  @override
  String get changeProjectTypeErrorMessage =>
      'Ocorreu um erro ao alterar o tipo de projeto. As alterações não puderam ser aplicadas.';

  @override
  String get changeProjectTypeErrorTips =>
      'Verifique se o projeto tem anotações válidas e tente novamente. Se o problema persistir, reinicie o aplicativo ou entre em contato com o suporte.';

  @override
  String get exportProjectAsDataset =>
      'Exportar Projeto como Conjunto de Dados';

  @override
  String get projectHelpTitle => 'Como os Projetos Funcionam';

  @override
  String get projectHelpMessage =>
      'Os projetos permitem que você organize conjuntos de dados, arquivos de mídia e anotações em um só lugar. Você pode criar novos projetos para diferentes tarefas como detecção, classificação ou segmentação.';

  @override
  String get projectHelpTips =>
      'Dica: Você pode importar conjuntos de dados nos formatos COCO, YOLO, VOC, Labelme e Datumaro para criar um projeto automaticamente.';

  @override
  String get datasetDialogTitle =>
      'Importar Conjunto de Dados para Criar Projeto';

  @override
  String get datasetDialogProcessing => 'Processando...';

  @override
  String datasetDialogProcessingProgress(Object percent) {
    return 'Processando... $percent%';
  }

  @override
  String get datasetDialogModeIsolate => 'Modo de Isolamento Ativado';

  @override
  String get datasetDialogModeNormal => 'Modo Normal';

  @override
  String get datasetDialogNoDatasetLoaded =>
      'Nenhum conjunto de dados carregado.';

  @override
  String get datasetDialogSelectZipFile =>
      'Selecione seu arquivo ZIP de conjunto de dados';

  @override
  String get datasetDialogChooseFile => 'Escolher um arquivo';

  @override
  String get datasetDialogSupportedFormats =>
      'Formatos de conjunto de dados suportados:';

  @override
  String get datasetDialogSupportedFormatsList1 => 'COCO, YOLO, VOC, Datumaro,';

  @override
  String get datasetDialogSupportedFormatsList2 =>
      'LabelMe, CVAT, ou apenas mídia (.zip)';

  @override
  String get dialogImageDetailsTitle => 'Detalhes do Arquivo';

  @override
  String get datasetDialogImportFailedTitle => 'Falha na Importação';

  @override
  String get datasetDialogImportFailedMessage =>
      'O arquivo ZIP não pôde ser processado. Ele pode estar corrompido, incompleto ou não ser um arquivo de conjunto de dados válido.';

  @override
  String get datasetDialogImportFailedTips =>
      'Tente exportar ou compactar novamente seu conjunto de dados.\nCertifique-se de que esteja no formato COCO, YOLO, VOC ou suportado.\n\nErro: ';

  @override
  String get datasetDialogNoProjectTypeTitle =>
      'Nenhum Tipo de Projeto Selecionado';

  @override
  String get datasetDialogNoProjectTypeMessage =>
      'Por favor, selecione um Tipo de Projeto com base nos tipos de anotação detectados em seu conjunto de dados.';

  @override
  String get datasetDialogNoProjectTypeTips =>
      'Verifique o formato do seu conjunto de dados e certifique-se de que as anotações seguem uma estrutura suportada como COCO, YOLO, VOC ou Datumaro.';

  @override
  String get datasetDialogProcessingDatasetTitle =>
      'Processando Conjunto de Dados';

  @override
  String get datasetDialogProcessingDatasetMessage =>
      'Estamos atualmente extraindo seu arquivo ZIP, analisando seu conteúdo e detectando o formato do conjunto de dados e o tipo de anotação. Isso pode levar de alguns segundos a alguns minutos, dependendo do tamanho e da estrutura do conjunto de dados. Por favor, não feche esta janela ou navegue para longe durante o processo.';

  @override
  String get datasetDialogProcessingDatasetTips =>
      'Arquivos grandes com muitas imagens ou arquivos de anotação podem levar mais tempo para processar.';

  @override
  String get datasetDialogCreatingProjectTitle => 'Criando Projeto';

  @override
  String get datasetDialogCreatingProjectMessage =>
      'Estamos configurando seu projeto, inicializando seus metadados e salvando todas as configurações. Isso inclui atribuir etiquetas, criar conjuntos de dados e vincular arquivos de mídia associados. Por favor, aguarde um momento e evite fechar esta janela até que o processo seja concluído.';

  @override
  String get datasetDialogCreatingProjectTips =>
      'Projetos com muitas etiquetas ou arquivos de mídia podem levar um pouco mais de tempo.';

  @override
  String get datasetDialogAnalyzingDatasetTitle =>
      'Analisando Conjunto de Dados';

  @override
  String get datasetDialogAnalyzingDatasetMessage =>
      'Estamos atualmente analisando seu arquivo de conjunto de dados. Isso inclui extrair arquivos, detectar a estrutura do conjunto de dados, identificar formatos de anotação e coletar informações de mídia e etiquetas. Por favor, aguarde até que o processo seja concluído. Fechar a janela ou navegar para longe pode interromper a operação.';

  @override
  String get datasetDialogAnalyzingDatasetTips =>
      'Conjuntos de dados grandes com muitos arquivos ou anotações complexas podem levar tempo adicional.';

  @override
  String get datasetDialogFilePickErrorTitle => 'Erro de Seleção de Arquivo';

  @override
  String get datasetDialogFilePickErrorMessage =>
      'Falha ao selecionar o arquivo. Por favor, tente novamente.';

  @override
  String get datasetDialogGenericErrorTips =>
      'Por favor, verifique seu arquivo e tente novamente. Se o problema persistir, entre em contato com o suporte.';

  @override
  String get thumbnailGenerationTitle => 'Erro';

  @override
  String get thumbnailGenerationFailed => 'Falha ao gerar miniatura';

  @override
  String get thumbnailGenerationTryAgainLater =>
      'Por favor, tente novamente mais tarde';

  @override
  String get thumbnailGenerationInProgress => 'Gerando miniatura...';

  @override
  String get menuImageAnnotate => 'Anotar';

  @override
  String get menuImageDetails => 'Detalhes';

  @override
  String get menuImageDuplicate => 'Duplicar';

  @override
  String get menuImageSetAsIcon => 'Como Ícone';

  @override
  String get menuImageDelete => 'Excluir';

  @override
  String get noLabelsTitle => 'Você não tem Etiquetas no Projeto';

  @override
  String get noLabelsExplain1 =>
      'Você não pode anotar sem etiquetas porque as etiquetas dão significado ao que você está marcando';

  @override
  String get noLabelsExplain2 =>
      'Você pode adicionar etiquetas manualmente ou importá-las de um arquivo JSON.';

  @override
  String get noLabelsExplain3 =>
      'Uma anotação sem etiqueta é apenas uma caixa vazia.';

  @override
  String get noLabelsExplain4 =>
      'As etiquetas definem as categorias ou classes que você está anotando em seu conjunto de dados.';

  @override
  String get noLabelsExplain5 =>
      'Seja você rotulando objetos em imagens, classificando ou segmentando regiões,';

  @override
  String get noLabelsExplain6 =>
      'as etiquetas são essenciais para organizar suas anotações de forma clara e consistente.';

  @override
  String get importLabelsPreviewTitle =>
      'Visualização da Importação de Etiquetas';

  @override
  String get importLabelsFailedTitle => 'Falha na Importação de Etiquetas';

  @override
  String get importLabelsNoLabelsTitle =>
      'Nenhuma etiqueta encontrada neste projeto';

  @override
  String get importLabelsJsonParseError => 'Falha na análise do JSON.\n';

  @override
  String get importLabelsJsonParseTips =>
      'Certifique-se de que o arquivo seja JSON válido. Você pode validá-lo em https://jsonlint.com/';

  @override
  String importLabelsJsonNotList(Object type) {
    return 'Era esperada uma lista de etiquetas (array), mas foi obtido: $type.';
  }

  @override
  String get importLabelsJsonNotListTips =>
      'Seu arquivo JSON deve começar com [ e conter vários objetos de etiqueta. Cada etiqueta deve incluir campos de nome, cor e ordemEtiqueta.';

  @override
  String importLabelsJsonItemNotMap(Object type) {
    return 'Uma das entradas na lista não é um objeto válido: $type';
  }

  @override
  String get importLabelsJsonItemNotMapTips =>
      'Cada item na lista deve ser um objeto válido com campos: nome, cor e ordemEtiqueta.';

  @override
  String get importLabelsJsonLabelParseError =>
      'Falha ao analisar uma das etiquetas.\n';

  @override
  String get importLabelsJsonLabelParseTips =>
      'Verifique se cada etiqueta tem os campos necessários como nome e cor, e se os valores são dos tipos corretos.';

  @override
  String get importLabelsUnexpectedError =>
      'Ocorreu um erro inesperado durante a importação do arquivo JSON.\n';

  @override
  String get importLabelsUnexpectedErrorTip =>
      'Por favor, certifique-se de que seu arquivo seja legível e formatado corretamente.';

  @override
  String get importLabelsDatabaseError =>
      'Falha ao salvar etiquetas no banco de dados';

  @override
  String get importLabelsDatabaseErrorTips =>
      'Por favor, verifique sua conexão com o banco de dados e tente novamente. Se o problema persistir, entre em contato com o suporte.';

  @override
  String get importLabelsNameMissingOrEmpty =>
      'Uma das etiquetas não tem um nome válido.';

  @override
  String get importLabelsNameMissingOrEmptyTips =>
      'Certifique-se de que cada etiqueta no JSON inclua um campo \'nome\' não vazio.';

  @override
  String get menuSortAZ => 'A-Z';

  @override
  String get menuSortZA => 'Z-A';

  @override
  String get menuSortProjectType => 'Tipo de Projeto';

  @override
  String get uploadInProgressTitle => 'Upload em Andamento';

  @override
  String get uploadInProgressMessage =>
      'Você tem um upload ativo em andamento. Se sair agora, o upload será cancelado e você precisará começar de novo.\n\nDeseja sair mesmo assim?';

  @override
  String get uploadInProgressStay => 'Ficar';

  @override
  String get uploadInProgressLeave => 'Sair';

  @override
  String get fileNotFound => 'Arquivo não encontrado ou permissão negada';

  @override
  String get labelEditSave => 'Salvar';

  @override
  String get labelEditEdit => 'Editar';

  @override
  String get labelEditMoveUp => 'Mover para Cima';

  @override
  String get labelEditMoveDown => 'Mover para Baixo';

  @override
  String get labelEditDelete => 'Excluir';

  @override
  String get labelExportLabels => 'Exportar Etiquetas';

  @override
  String get labelSaveDialogTitle => 'Salvar etiquetas em arquivo JSON';

  @override
  String get labelSaveDefaultFilename => 'etiquetas.json';

  @override
  String labelDeleteError(Object error) {
    return 'Falha ao excluir etiqueta: $error';
  }

  @override
  String get labelDeleteErrorTips =>
      'Certifique-se de que a etiqueta ainda existe ou não está sendo usada em outro lugar.';

  @override
  String get datasetStepUploadZip =>
      'Faça upload de um arquivo ZIP com formato COCO, YOLO, VOC, LabelMe, CVAT, Datumaro ou apenas mídia';

  @override
  String get datasetStepExtractingZip =>
      'Extraindo ZIP no armazenamento local ...';

  @override
  String datasetStepExtractedPath(Object path) {
    return 'Conjunto de dados extraído em: $path';
  }

  @override
  String datasetStepDetectedTaskType(Object format) {
    return 'Tipo de tarefa detectado: $format';
  }

  @override
  String get datasetStepSelectProjectType => 'Selecionar tipo de projeto';

  @override
  String get datasetStepProgressSelection => 'Seleção de Conjunto de Dados';

  @override
  String get datasetStepProgressExtract => 'Extrair ZIP';

  @override
  String get datasetStepProgressOverview => 'Visão Geral do Conjunto de Dados';

  @override
  String get datasetStepProgressTaskConfirmation => 'Confirmação de Tarefa';

  @override
  String get datasetStepProgressProjectCreation => 'Criação de Projeto';

  @override
  String get projectTypeDetectionBoundingBox =>
      'Detecção com caixa delimitadora';

  @override
  String get projectTypeDetectionOriented => 'Detecção orientada';

  @override
  String get projectTypeBinaryClassification => 'Classificação Binária';

  @override
  String get projectTypeMultiClassClassification =>
      'Classificação Multi-classe';

  @override
  String get projectTypeMultiLabelClassification =>
      'Classificação Multi-etiqueta';

  @override
  String get projectTypeInstanceSegmentation => 'Segmentação de Instâncias';

  @override
  String get projectTypeSemanticSegmentation => 'Segmentação Semântica';

  @override
  String get datasetStepChooseProjectType =>
      'Escolha seu tipo de Projeto com base nas anotações detectadas';

  @override
  String get datasetStepAllowProjectTypeChange =>
      'Permitir Alteração de Tipo de Projeto';

  @override
  String get projectTypeBinaryClassificationDescription =>
      'Atribuir uma de duas etiquetas possíveis a cada entrada (por exemplo, spam ou não spam, positivo ou negativo).';

  @override
  String get projectTypeMultiClassClassificationDescription =>
      'Atribuir exatamente uma etiqueta de um conjunto de classes mutuamente exclusivas (por exemplo, gato, cachorro ou pássaro).';

  @override
  String get projectTypeMultiLabelClassificationDescription =>
      'Atribuir uma ou mais etiquetas de um conjunto de classes — várias etiquetas podem ser aplicadas ao mesmo tempo (por exemplo, uma imagem etiquetada como \"gato\" e \"cachorro\")';

  @override
  String get projectTypeDetectionBoundingBoxDescription =>
      'Desenhar um retângulo ao redor de um objeto em uma imagem.';

  @override
  String get projectTypeDetectionOrientedDescription =>
      'Desenhar e envolver um objeto dentro de um retângulo mínimo.';

  @override
  String get projectTypeInstanceSegmentationDescription =>
      'Detectar e distinguir cada objeto individual com base em suas características únicas.';

  @override
  String get projectTypeSemanticSegmentationDescription =>
      'Detectar e classificar todos os objetos semelhantes como uma única entidade.';
}
