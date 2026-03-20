# On-Prem Plan Execution Tracker

Source plan: `docs/onprem_ai_architecture_review_and_plan.md` (Section 9).

Status legend:
- `[ ]` pending
- `[~]` in progress
- `[x]` completed
- `[-]` not feasible in current client-only repository (requires backend program/project scope)

## Steps

- [~] 1. Restore compile baseline
  - Scope now: remove analyzer regressions and symbol issues in the listed modules.
- [x] 2. Codify architecture conventions
  - Existing ADRs are present in `docs/architecture/ADR-001..003`.
- [x] 3. Introduce repository interfaces
  - `AnnotationRepository` + SQLite adapter introduced and wired into annotation call sites.
- [x] 4. Extract annotation application services
  - `AnnotationApplicationService` extracted and integrated for assignment/label-update paths.
- [x] 5. Introduce annotation schema v1
  - Added `annotation_schema_version`, provenance envelope, schema defaults, and tests.
- [x] 6. Add review lifecycle metadata
  - Added review columns + transition-safe DB API with optimistic locking and tests.
- [x] 7. Add runtime environment config
  - `AppRuntimeConfig` added with startup validation in `main.dart`.
- [x] 8. Centralize media metadata extraction
  - Shared `MediaMetadataService` created and adopted by import/upload paths.
- [x] 9. Unify frame extraction logic
  - Shared `VideoFrameExtractor` used and duplicate widget FFmpeg helpers removed.
- [x] 10. Add API client abstraction
  - Added typed `ApiClient` + `CapabilitiesApi` boundary and tests.
- [x] 11. Remove hardcoded external model/runtime dependencies
  - Model source URLs moved to runtime-configurable registry and UI guarded for air-gap misconfig.
- [x] 12. Standardize AI job lifecycle
  - Added `AiJobRunner` with queued/running/succeeded/failed/applied states and idempotent in-flight dedupe.
- [x] 13. Productize OCR workflow
  - Added OCR engine boundary and structured OCR annotation envelope service with tests.
- [ ] 14. Implement review queue UX
  - Add assignment/review/decision workflow UI.
- [~] 15. Security and observability hardening
  - Partial: runtime config validation/logging and model-download source validation added; broader telemetry/RBAC/path-hardening remains.

## Execution Notes

- This tracker is updated as each step is implemented in code and validated.
- 2026-03-20: Added schema/review lifecycle hardening, API boundary, AI job lifecycle, OCR envelope service, and model download air-gap safeguards. Full review queue UX and broader hardening remain.
