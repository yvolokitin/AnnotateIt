# Critical Remediation Plan

Status legend: `[ ]` pending, `[~]` in progress, `[x]` completed.

## Phase 1 - Data integrity and correctness (must fix now)

- [x] **P1.1 Fix dataset routing bug in tab content**
  - File: `lib/widgets/project_details/project_view_media_galery.dart`
  - Risk: Actions from one tab can target another dataset.
  - Done when: each tab passes its own `dataset.id` into `DatasetTabContent`.

- [x] **P1.2 Stop destructive deletion in classification flow**
  - Files: `lib/pages/annotator_page.dart`, `lib/data/annotation_database.dart`
  - Risk: selecting a class in single-label projects deletes non-classification annotations.
  - Done when: only `classification` annotations for that media are replaced.

- [x] **P1.3 Add async stale-context guards in annotator flows**
  - File: `lib/pages/annotator_page.dart`
  - Risk: SAM/ML/classification writes can land on wrong media after page switch.
  - Done when: operations capture index/media ID and update only the same media context.

- [x] **P1.4 Normalize YOLO bbox schema to renderer contract**
  - File: `lib/utils/dataset_annotation_parsers/yolo_parser.dart`
  - Risk: imported boxes are invisible/invalid because keys don't match `RectShape`.
  - Done when: detection import stores pixel-space `{x,y,width,height}`.

## Phase 2 - Workflow safety and cancellation

- [x] **P2.1 Honor cancel request during pre-label annotate phase**
  - File: `lib/pages/project_prelabel/pre_label_project_dialog.dart`
  - Risk: user cancels but background annotation still mutates DB.
  - Done when: annotate loop exits quickly when cancel is requested and UI reflects cancellation.

- [x] **P2.2 Make isolate dataset processing timeout-safe**
  - Files: `lib/utils/dataset_import_utils.dart`, `lib/pages/project_creation/create_from_dataset_dialog.dart`
  - Risk: timeout leaves isolate work running/orphaned.
  - Done when: timeout is handled inside isolate workflow and isolates are terminated on timeout/error.

- [x] **P2.3 Add rollback cleanup for partial import failure**
  - File: `lib/utils/dataset_import_project_creation.dart`
  - Risk: partial project/dataset leftovers after failed import.
  - Done when: failed import deletes created project and surfaces clear error.

## Phase 3 - DB consistency and deterministic reads

- [x] **P3.1 Enforce deterministic ordering for paginated media reads**
  - File: `lib/data/dataset_database.dart`
  - Risk: pagination drift/duplicate/missing items under inserts/deletes.
  - Done when: paginated and index-based reads use stable `ORDER BY id ASC`.

- [x] **P3.2 Add optimistic locking for annotation updates**
  - File: `lib/data/annotation_database.dart`
  - Risk: lost updates from concurrent edits.
  - Done when: update uses `WHERE id=? AND version=?` and increments version atomically.

- [x] **P3.3 Enable FK enforcement and add critical indexes**
  - Files: `lib/data/project_database.dart`, `lib/data/create_initial_schema.dart`
  - Risk: orphaned rows and slower joins at scale.
  - Done when: `PRAGMA foreign_keys=ON` on open and missing indexes are created idempotently.

## Verification tasks

- [x] Run static analysis on changed files (`flutter analyze` or targeted checks).
- [ ] Add/adjust focused tests for fixed critical paths where feasible.
- [x] Re-read this file and mark each task complete as implemented.
