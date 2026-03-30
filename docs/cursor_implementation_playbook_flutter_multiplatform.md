# AnnotateIt — пошаговый implementation playbook для Cursor

Дата: 2026-03-30  
Приоритет платформ: **Windows → iOS → macOS → Web** (единая кодовая база Flutter).

---

## Как пользоваться этим документом

- Идешь строго по шагам: **1 → 2 → 3 → ... → N**.
- На каждом шаге:
  1. Копируешь prompt в Cursor.
  2. Даешь Cursor внести изменения.
  3. Прогоняешь check-команды шага.
  4. Фиксируешь commit.
- Не перепрыгивай шаги: архитектурные шаги до функциональных.

---

## Step 1. Baseline и ветка под roadmap

### Цель
Зафиксировать стартовую точку и создать рабочую ветку.

### Prompt для Cursor
```text
Сделай baseline-аудит Flutter проекта:
1) Выведи список ключевых модулей для: media import, annotation canvas, AI services, API client.
2) Создай markdown docs/implementation_baseline_2026_03_30.md с текущими рисками и зависимостями.
3) Ничего не рефактори пока — только audit и doc.
```

### Check
- `flutter --version`
- `flutter pub get`
- `flutter analyze`

### DoD
- Есть baseline-документ и понятна стартовая архитектура.

---

## Step 2. Платформенная матрица (Windows/iOS/macOS/Web)

### Цель
Описать capability matrix по платформам (камера, видео, fs, ffmpeg, web workers, on-device ML).

### Prompt для Cursor
```text
Добавь docs/platform_capability_matrix.md:
- Таблица по платформам Windows/iOS/macOS/Web.
- Для каждой платформы: поддержка video import, frame extraction, camera capture, local model inference, file system permissions.
- Отдельно: ограничения и fallback-стратегии.
```

### Check
- `flutter analyze`

### DoD
- Есть единый источник правды по платформенным ограничениям.

---

## Step 3. Ввести feature flags под видео-эволюцию

### Цель
Добавить управляемые флаги, чтобы катить поэтапно без регрессий.

### Prompt для Cursor
```text
Введи конфиг feature flags (runtime/env):
- enable_video_timeline
- enable_track_annotations
- enable_realtime_streams
- enable_remote_inference
Сделай безопасные дефолты: все false.
Добавь helper-класс и удобный доступ из UI/services.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Новые функции выключены по умолчанию, код компилируется.

---

## Step 4. Реальные video metadata (убрать заглушку)

### Цель
Заменить stub metadata на реальный probe.

### Prompt для Cursor
```text
Реализуй production-ready VideoMetadataService:
1) Интерфейс VideoProbeEngine.
2) IO реализация через ffprobe/ffmpeg (Windows/macOS), AVAsset для iOS, web fallback.
3) Возвращай: width, height, durationSec, fpsNominal, frameCountEstimate, codec.
4) Добавь graceful fallback и structured logs.
5) Покрой unit-тестами с mock engine.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Метаданные видео перестают быть нулями в нормальном happy path.

---

## Step 5. Канонический frame identity контракт

### Цель
Ввести стабильную идентификацию кадра.

### Prompt для Cursor
```text
Добавь в domain контракт FrameIdentity:
- videoId
- frameIndex
- timestampMs
- sourceFps
- samplingPolicy
- extractionRunId
Интегрируй в pipeline frame extraction и сохранение media items.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Каждый извлеченный кадр имеет воспроизводимую identity-модель.

---

## Step 6. Миграция БД под temporal video

### Цель
Подготовить схему для video-native аннотаций.

### Prompt для Cursor
```text
Сделай DB migration:
1) Таблица video_assets (исходное видео).
2) Таблица video_frames (связь video_asset -> frame identity).
3) Таблица annotation_tracks (track_id, label_id, status, created_at).
4) Таблица track_keyframes (track_id, frame_id, geometry, confidence).
5) Индексы на video_id/frame_index/track_id.
Добавь rollback-safe migration comments.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Схема поддерживает temporal workflow.

---

## Step 7. Репозитории и use-cases для tracks/keyframes

### Цель
Отвязать UI от SQL.

### Prompt для Cursor
```text
Создай repository + usecase слой:
- VideoAssetRepository
- VideoFrameRepository
- TrackRepository
Use-cases:
- createTrack
- addKeyframe
- interpolateTrackSegment
- listTrackAtFrame
Не вызывать SQL из widgets/pages напрямую.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Работа с треками идет через domain/usecase слой.

---

## Step 8. Timeline MVP UI

### Цель
Добавить первичный timeline/scrubber интерфейс.

### Prompt для Cursor
```text
Сделай Timeline MVP в annotator:
- scrubber по кадрам,
- текущий frame index,
- keyframe markers,
- jump to previous/next keyframe.
Состояние хранить в отдельном controller/provider.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Можно перемещаться по кадрам и видеть keyframe-метки.

---

## Step 9. Interpolation для bbox

### Цель
Автоматически интерполировать объект между keyframes.

### Prompt для Cursor
```text
Реализуй линейную интерполяцию bbox между keyframes:
- x,y,w,h + optional rotation.
- Визуально отличай interpolated от manual.
- Дай toggle: show interpolated.
Добавь unit tests на интерполяцию.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Между двумя keyframes строятся промежуточные bbox.

---

## Step 10. Interpolation для polygon (phase-1 simplification)

### Цель
Добавить базовую интерполяцию полигонов.

### Prompt для Cursor
```text
Сделай phase-1 polygon interpolation:
- Нормализуй число вершин (resample).
- Интерполируй вершины по t.
- Флаг качества: low/medium/high.
- При low confidence показывай warning badge.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Полигонные треки можно предварительно протянуть по времени.

---

## Step 11. Review workflow для auto-label

### Цель
Контроль качества предразметки.

### Prompt для Cursor
```text
Добавь review workflow для video annotations:
- draft -> proposed -> accepted/rejected.
- Bulk-операции по диапазону кадров.
- UI-фильтры по review status.
- Audit fields: reviewed_by, reviewed_at, comment.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Есть жизненный цикл ревью для временных аннотаций.

---

## Step 12. Unified inference envelope

### Цель
Единый формат результатов AI независимо от backend.

### Prompt для Cursor
```text
Сделай unified AI result envelope:
- modelName
- modelVersion
- backendType(local/onprem/external)
- inferenceLatencyMs
- totalLatencyMs
- finishReason
- payload (typed)
- provenance
Интегрируй минимум в OCR + prelabel + video suggestions.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Все AI результаты сериализуются единообразно.

---

## Step 13. Job persistence для тяжелых задач

### Цель
Сделать надежный асинхронный пайплайн.

### Prompt для Cursor
```text
Расширь существующий job lifecycle:
- Персистентная таблица ai_jobs.
- Статусы queued/running/succeeded/failed/canceled/applied.
- progress %, startedAt, finishedAt, errorCode.
- Resume после перезапуска приложения.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Долгие video/AI задачи восстанавливаются после рестарта.

---

## Step 14. Stream abstraction interface

### Цель
Подготовить realtime сценарии без vendor lock-in.

### Prompt для Cursor
```text
Добавь StreamInferencePort интерфейс:
- startStream(source, mode, prompt, schema)
- updatePrompt(streamId, prompt)
- subscribeResults(streamId)
- stopStream(streamId)
Сделай пока mock implementation + local no-op implementation.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Архитектурно готово к realtime интеграциям.

---

## Step 15. External adapter (Overshoot-like) как опциональный backend

### Цель
Вынести внешнюю интеграцию в отдельный адаптер.

### Prompt для Cursor
```text
Реализуй ExternalStreamAdapter (опционально):
- API key из secure storage/env.
- create stream / keepalive / websocket results.
- Маппинг внешних ответов в unified envelope.
- Полная деградация если ключа нет.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Внешний backend подключается без ломки core.

---

## Step 16. Policy engine (local/onprem/external routing)

### Цель
Автоматический выбор backend под задачу.

### Prompt для Cursor
```text
Добавь InferenceRoutingPolicy:
Вход: taskType, mediaType, latencyTarget, privacyLevel, platform.
Выход: backend choice (local/onprem/external) + reason.
Добавь UI override (ручной выбор пользователем).
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Маршрутизация прозрачна и объяснима.

---

## Step 17. Нативная оптимизация под Windows

### Цель
Сделать Windows главным desktop контуром.

### Prompt для Cursor
```text
Windows optimization pass:
- Проверить file IO hot paths.
- Уменьшить лишние копии bitmap.
- Вынести тяжелые операции в isolates.
- Добавить perf counters (frame extraction throughput, annotation paint time).
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Заметно улучшена отзывчивость на Windows.

---

## Step 18. Нативная оптимизация под iOS

### Цель
Стабильная работа с памятью и медиа на iOS.

### Prompt для Cursor
```text
iOS optimization pass:
- Уменьшить memory spikes при декоде кадров.
- Lazy loading для frame thumbnails.
- Ограничение concurrent tasks.
- Проверить permissions + UX ошибок.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Нет критических memory crash сценариев на iOS потоках.

---

## Step 19. Нативная оптимизация под macOS

### Цель
Стабильный desktop UX на Apple Silicon/Intel.

### Prompt для Cursor
```text
macOS optimization pass:
- Проверить ffmpeg path discovery и sandbox-friendly поведение.
- Улучшить drag&drop видео/изображений.
- Уменьшить jank на timeline scroll.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Плавный timeline + надежный media import на macOS.

---

## Step 20. Web-версия: progressive features

### Цель
Сделать рабочий web контур без тяжелых нативных ожиданий.

### Prompt для Cursor
```text
Web pass:
- Добавь capability detection (что доступно в текущем браузере).
- Включай timeline/features progressively.
- Для неподдерживаемых операций показывай четкий UX fallback.
- Оптимизируй web bundle (deferred loading для AI-модулей).
```

### Check
- `flutter analyze`
- `flutter test`
- `flutter build web`

### DoD
- Web сборка стабильна, ограничения прозрачны пользователю.

---

## Step 21. Telemetry и диагностика

### Цель
Сделать наблюдаемость в проде.

### Prompt для Cursor
```text
Добавь structured telemetry:
- media_import_started/finished/failed
- frame_extraction_stats
- ai_job_state_changed
- annotation_review_metrics
Сделай локальный лог + экспорт диагностического отчета в файл.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Любой сбой можно диагностировать по отчету.

---

## Step 22. E2E regression pack

### Цель
Поймать регрессии перед релизами.

### Prompt для Cursor
```text
Создай E2E regression pack (integration tests):
1) import video -> extract frames -> annotate keyframes -> export.
2) restart app -> resume pending AI job.
3) switch platform flags simulation.
Добавь CI-скрипт запуска.
```

### Check
- `flutter test`

### DoD
- Ключевые сценарии закрыты автотестами.

---

## Step 23. Экспорт temporal annotations

### Цель
Сделать переносимость video-разметки.

### Prompt для Cursor
```text
Добавь экспорт temporal annotations:
- JSON with tracks/keyframes/frame references.
- Версионирование схемы экспорта.
- Валидатор exported file + import back check.
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Видеоразметка переносима между инстансами.

---

## Step 24. Production hardening

### Цель
Финализация перед массовым использованием.

### Prompt для Cursor
```text
Сделай hardening checklist implementation:
- retry/backoff policy review,
- input validation на всех media/API границах,
- timeout/cancel support,
- safe file operations,
- user-facing error catalog.
Сформируй docs/production_readiness_checklist.md
```

### Check
- `flutter analyze`
- `flutter test`

### DoD
- Приложение готово к controlled production rollout.

---

## Step 25. Release plan по платформам

### Цель
Выпустить поэтапно в приоритетном порядке.

### Prompt для Cursor
```text
Подготовь release план:
Wave 1: Windows stable
Wave 2: iOS beta
Wave 3: macOS stable
Wave 4: Web GA
Для каждой волны: feature set, rollback strategy, success metrics.
Сохрани в docs/release_waves_multiplatform.md
```

### Check
- `flutter analyze`

### DoD
- Есть управляемый rollout с KPI и rollback-планом.

---

# Быстрый ежедневный шаблон работы с Cursor

Используй этот мини-промт каждый день перед началом:

```text
Сегодня работаем по playbook шагу <N>.
Сначала:
1) кратко перечисли какие файлы будешь менять,
2) покажи migration/architecture impact,
3) внеси минимально-необходимые изменения,
4) запусти flutter analyze + flutter test,
5) дай summary с рисками и что делать на следующем шаге.
```

---

# Что делать прямо сейчас (следующий практический шаг)

Начни с **Step 4 (реальные video metadata)**, потом сразу **Step 5 (frame identity)** и **Step 6 (DB migration)**.  
Это создаст фундамент для всего temporal/realtime слоя без хаотичных переделок UI.

