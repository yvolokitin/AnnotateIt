# AnnotateIt — Implementation Baseline

**Date:** 2026-03-30
**Flutter:** 3.41.4 (stable), Dart 3.11.1
**App version:** 4.4.0+31
**Codebase:** 239 Dart files in `lib/`, 8 test files

---

## 1. Key Module Map

### Media Import

| File | Role |
|------|------|
| `lib/services/video_frame_extractor.dart` | FFmpeg path resolution + frame extraction to PNG |
| `lib/services/media_metadata_service.dart` | Image metadata via `image` pkg; **video metadata is a stub** (returns zeros) |
| `lib/services/photo_picker_service.dart` | Camera/gallery import via `image_picker` |
| `lib/utils/folder_picker.dart` | OS folder selection |
| `lib/utils/media_bytes_helper.dart` (+io/stub) | Platform-conditional byte loading |
| `lib/utils/dataset_import_utils.dart` | Batch import orchestration |
| `lib/utils/dataset_import_project_creation.dart` | Project setup from imported dataset |
| `lib/models/media_item.dart` | Domain model; supports `image` and `video` types with optional `width/height/duration/fps/numberOfFrames` |
| `lib/data/dataset_database.dart` | SQLite CRUD for datasets + media items |

### Annotation Canvas

| File | Role |
|------|------|
| `lib/widgets/imageannotator/` | Main annotator widget tree (bbox, polygon, classification, editing UX) |
| `lib/widgets/imageeditor/` | Image editing overlay |
| `lib/models/shape/` | Shape hierarchy: `Shape`, `RectShape`, `RotatedRectShape`, `CircleShape`, `PolygonShape` |
| `lib/models/annotation.dart` | Annotation domain model (`bbox`, `classification`, `segmentation`, `keypoints`, `ocr_text`) |
| `lib/models/annotation_review.dart` | Review status FSM (`draft` → `proposed` → `accepted`/`rejected`) |
| `lib/pages/annotator_page.dart` | Top-level annotator page |

### AI Services

| File | Role |
|------|------|
| `lib/services/ai_job_lifecycle.dart` | `AiJobRunner` with in-memory idempotency dedup, status FSM (`queued`→`running`→`succeeded`/`failed`→`applied`) |
| `lib/services/ocr_annotation_service.dart` | OCR via ML Kit, produces `ocr_text` annotations with provenance |
| `lib/services/ml_kit_image_labeling_service.dart` | Google ML Kit image labeling |
| `lib/services/sam_segmentation_service.dart` | SAM (Segment Anything) — real ONNX inference on Web, heuristic fallback elsewhere (~1450 LOC) |
| `lib/services/tflite_classification_service.dart` (+barrel/stub) | TFLite classification |
| `lib/services/tflite_detection_service.dart` (+barrel/stub) | TFLite object detection |
| `lib/services/annotation_application_service.dart` | Application service for classification label assignment + label updates |

### API Client

| File | Role |
|------|------|
| `lib/services/api/api_client.dart` | HTTP client with retry/backoff, idempotency keys, timeout; configurable from `AppRuntimeConfig` |
| `lib/services/api/capabilities_api.dart` | Fetches server capabilities JSON |
| `lib/config/app_runtime_config.dart` | Deployment mode (`local`/`onprem`/`airgap`), env-var driven config |
| `lib/config/model_registry_urls.dart` | Model download URL registry |

---

## 2. Architecture Overview

### Layer Structure (per ADR-001)

```
presentation/   (lib/pages/, lib/widgets/)
     ↓
application/    (lib/services/annotation_application_service.dart — partial)
     ↓
repositories/   (lib/repositories/annotation_repository.dart — interface only)
     ↓
adapters/       (lib/data/*, lib/services/api/*)
```

**Current reality:** Most UI code still calls `lib/data/*Database` singletons directly. The repository pattern exists only for `AnnotationRepository` → `SqliteAnnotationRepository`. Application services exist only for `AnnotationApplicationService`. All other domains (projects, datasets, labels, media, users) bypass the repository layer.

### Database

- Single SQLite database shared across singletons (`ProjectDatabase`, `DatasetDatabase`, `AnnotationDatabase`, `LabelsDatabase`, `UserDatabase`, `NotificationDatabase`).
- Schema created in `lib/data/create_initial_schema.dart` — 7 tables: `users`, `projects`, `datasets`, `media_folders`, `dataset_media_folders`, `media_items`, `labels`, `annotations`, `notifications`.
- No formal migration system — schema is created via `createInitialSchema(db, version)`.
- Annotations have `review_status` FSM (`draft`/`proposed`/`accepted`/`rejected`) with optimistic concurrency via `version` column.

### State Management

- `flutter_riverpod` 2.6.1 is declared as a dependency.
- `UserSession` is a hand-rolled singleton (not Riverpod).
- Most widget state is managed with `StatefulWidget` directly.

### Platform Support

| Platform | Runner present | Notes |
|----------|---------------|-------|
| **Windows** | Yes | Primary desktop target. TFLite DLL bundled. MSIX packaging configured. |
| **iOS** | Yes | Splash screen, app icons, `google_ml_kit` (native). |
| **macOS** | Yes | Entitlements, CocoaPods. FFmpeg path auto-detection for Homebrew. |
| **Android** | Yes | CameraX integration, ML Kit native. |
| **Web** | Yes | SAM ONNX via onnxruntime-web. SQLite via `sqflite_common_ffi_web` + `sqlite3.wasm`. |
| **Linux** | Yes | CMake-based runner, minimal customization. |

---

## 3. Static Analysis Summary

```
flutter analyze (2026-03-30)
────────────────────────────
Errors:    0
Warnings:  160  (mostly avoid_print, deprecated API usage, unused variables)
Info:      494  (style lints — prefer_const, avoid_print in tests, etc.)
Total:     654 issues, 0 blocking
```

No compilation errors. The codebase compiles and runs.

---

## 4. Dependency Risk Assessment

### High-Priority Risks

| # | Risk | Impact | Files |
|---|------|--------|-------|
| R1 | **Video metadata is a stub** — `getVideoMetadata()` returns zeros for width/height/duration/fps | Video workflows are non-functional for metadata-dependent features. Any video import stores `0` for dimensions. | `media_metadata_service.dart` |
| R2 | **No frame identity model** — extracted frames have no stable identity contract (no videoId, frameIndex, timestampMs linkage) | Cannot reliably map annotations back to specific video frames; frame re-extraction produces orphan annotations. | `video_frame_extractor.dart`, `media_item.dart` |
| R3 | **No DB migration system** — schema is created once via `createInitialSchema`; no versioned migration chain | Adding tables/columns for video tracks requires manual ALTER TABLE or app reinstall; risky for existing users. | `create_initial_schema.dart`, `database_initializer*.dart` |
| R4 | **AI jobs are in-memory only** — `AiJobRunner` uses `Map<String, Future>` with no persistence | App restart loses all running/queued jobs; no resume capability. | `ai_job_lifecycle.dart` |
| R5 | **Repository layer incomplete** — only `AnnotationRepository` exists; 5 other database classes called directly from UI | Adding backend integration or testing requires touching every call site. | `project_database.dart`, `dataset_database.dart`, `labels_database.dart`, etc. |
| R6 | **SAM segmentation service is ~1450 LOC** — mixes ONNX inference, heuristic fallback, image processing, contour extraction | Hard to test, maintain, or swap inference backends. | `sam_segmentation_service.dart` |

### Medium-Priority Risks

| # | Risk | Impact |
|---|------|--------|
| R7 | **86 packages have newer incompatible versions** — notably `flutter_riverpod` 2.x vs 3.x, `camera` 0.11 vs 0.12, `tflite_flutter` 0.11 vs 0.12 | Upgrade debt; some packages may drop support for current API. |
| R8 | **`js` package is discontinued** — replaced by `dart:js_interop` in Dart 3.x | Will generate warnings and may break in future Flutter releases. |
| R9 | **No integration tests** — only 8 unit test files, no `integration_test/` directory | Regression risk on cross-cutting features (import → annotate → export). |
| R10 | **No feature flags** — all features are always enabled; no way to safely roll out video/temporal features | Cannot do incremental delivery without breaking existing workflows. |
| R11 | **Annotation schema has no video-temporal columns** — no `video_asset_id`, `frame_index`, `track_id` in the annotations table | Temporal annotations require schema extension before any video-native feature work. |

### Low-Priority Risks

| # | Risk | Impact |
|---|------|--------|
| R12 | 160 analyzer warnings (mostly `avoid_print`, deprecated APIs) | Code hygiene; no runtime impact. |
| R13 | Localization covers 8 languages but strings may be incomplete for new features | New UI strings need manual ARB additions. |
| R14 | `window_size` package (from Flutter team) is not on pub.dev — likely git dependency | May need replacement with `window_manager` for long-term support. |

---

## 5. Key Dependencies

### Core Flutter

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | 2.6.1 | State management |
| `drift` | 2.25.1 | ORM (declared but schema uses raw SQLite) |
| `sqflite` | 2.4.2 | SQLite for mobile |
| `sqflite_common_ffi` | 2.3.5 | SQLite for desktop |
| `sqflite_common_ffi_web` | 1.1.1 | SQLite for web |

### Media & Video

| Package | Version | Purpose |
|---------|---------|---------|
| `video_player` | 2.9.5 | Video playback |
| `video_thumbnail` | 0.5.3 | Video thumbnail generation |
| `ffmpeg_kit_flutter_new` | 3.2.0 | FFmpeg for frame extraction |
| `image` | 4.5.4 | Image decode/encode |
| `camera` | 0.11.2 | Camera capture |
| `image_picker` | 1.1.2 | Gallery/camera picker |

### AI / ML

| Package | Version | Purpose |
|---------|---------|---------|
| `google_ml_kit` | 0.20.0 | OCR, face detection, image labeling (iOS/Android) |
| `tflite_flutter` | 0.11.0 | TensorFlow Lite inference |

### Import/Export

| Package | Version | Purpose |
|---------|---------|---------|
| `archive` | 4.0.7 | ZIP handling |
| `xml` | 6.5.0 | VOC/CVAT XML parsing |
| `file_picker` | 10.0.0 | File selection |

---

## 6. Existing Architecture Decisions

| ADR | Status | Summary |
|-----|--------|---------|
| ADR-001 | Accepted | 4-layer boundaries: presentation → application → repositories → adapters. Transitional: existing direct coupling tolerated. |
| ADR-002 | Accepted | Data flow conventions. |
| ADR-003 | Accepted | On-prem/air-gapped deployment assumptions. |

Additional docs:
- `docs/architecture/critical_remediation_plan.md`
- `docs/architecture/onprem_execution_tracker.md`
- `docs/onprem_ai_architecture_review_and_plan.md`

---

## 7. Recommended Next Steps (per Playbook)

Based on this baseline, the playbook recommends starting with:

1. **Step 4: Real video metadata** — replace the stub in `MediaMetadataService.getVideoMetadata()` with ffprobe/AVAsset/web fallback.
2. **Step 5: Frame identity contract** — add `FrameIdentity` domain model linking videoId + frameIndex + timestampMs.
3. **Step 6: DB migration** — introduce migration system and add `video_assets`, `video_frames`, `annotation_tracks`, `track_keyframes` tables.

These three steps form the foundation for all temporal/video annotation features without disrupting existing image workflows.

---

*This document is an audit snapshot. No code was modified.*
