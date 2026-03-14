# AnnotateIt On-Prem AI-Assisted Annotation Architecture Review and Plan

Date: 2026-03-14  
Repository: `/Users/yuryvolokitin/AnnotateIt`

## 1. Executive Summary

- Current state: the application is a Flutter-first, local-first annotation product with direct UI-to-SQLite interactions, image annotation tooling, media import/export utilities, and multiple local AI-assisted service prototypes.
- Evolution suitability: the current architecture is a viable starting point for an on-prem platform, but not yet ready for enterprise-grade, multi-user, backend-driven deployment.
- Biggest strengths:
  - Working annotation UX foundations in:
    - `lib/pages/annotator_page.dart`
    - `lib/widgets/imageannotator/annotator_canvas.dart`
    - `lib/widgets/imageannotator/canvas_painter.dart`
    - `lib/pages/image_editor.dart`
    - `lib/widgets/imageeditor/editor_canvas.dart`
  - Existing media and dataset operations:
    - `lib/widgets/project_details/dataset_upload_buttons.dart`
    - `lib/widgets/project_details/media_tile.dart`
    - `lib/utils/dataset_import_project_creation.dart`
    - `lib/utils/dataset_annotation_importer.dart`
    - `lib/utils/dataset_exporters/*`
  - Existing local AI integration points:
    - `lib/services/ml_kit_image_labeling_service.dart`
    - `lib/services/tflite_classification_service.dart`
    - `lib/services/tflite_detection_service.dart`
    - `lib/services/sam_segmentation_service.dart`
- Biggest weaknesses:
  - Tight coupling between UI, domain logic, and persistence.
  - No first-class backend API/authz/tenant architecture.
  - Build baseline quality risk (observed compile/import failures and high analyzer issue volume).
  - External dependencies (GitHub/CDN model/runtime delivery) that conflict with strict air-gapped on-prem expectations.

## 2. Current Architecture Review

### Flutter app structure

- Application bootstrap and shell are concentrated in:
  - `lib/main.dart`
  - `lib/pages/mainmenu.dart`
- Project listing/details and task flows are primarily page-driven:
  - `lib/pages/projects_list_page.dart`
  - `lib/pages/project_details_page.dart`
  - `lib/pages/annotator_page.dart`
  - `lib/pages/models_page.dart`

### State management approach

- Predominantly `StatefulWidget` + `setState`.
- Session-ish global handling in `lib/session/user_session.dart`.
- `flutter_riverpod` appears available but not consistently used as a central architecture.

### Navigation/routing

- Predominantly imperative routing with `MaterialPageRoute` and tab/index switching.
- No centralized route registry, no guard-based auth routing, no workflow-aware navigation policy.

### Domain boundaries

- Domain boundaries are weak:
  - Pages often call data/services directly.
  - DB wrapper classes exist, but domain orchestration is not strongly separated.
- Database access classes:
  - `lib/data/project_database.dart`
  - `lib/data/dataset_database.dart`
  - `lib/data/annotation_database.dart`
  - `lib/data/labels_database.dart`
  - `lib/data/user_database.dart`
  - `lib/data/project_database.dart`

### Data models

- SQLite schema is created in `lib/data/create_initial_schema.dart`.
- Annotation storage is flexible (`annotation_type` + payload) but lacks strict versioned schema governance.
- Migration patterns exist but appear ad-hoc and spread in persistence layer code.

### Annotation-related models and flows

- Manual drawing/editing exists and is functional.
- Project prelabeling entry point exists in:
  - `lib/pages/project_prelabel/pre_label_project_dialog.dart`
- Some flows are domain-useful but coupled tightly to widget/UI layers.

### Networking/API layer

- No robust, central backend API client for core annotation/project/media workflows.
- Existing network usage is more artifact/model download oriented than domain API oriented.

### Storage/persistence layer

- Local SQLite via `sqflite` / `sqflite_common_ffi`.
- Singleton/utility DB wrappers are used broadly across UI flows.
- No clear separation between cache vs source-of-truth for future server mode.

### Media handling capabilities

- Media upload/listing support is present in project details UI.
- Media processing responsibilities are distributed across widgets/services rather than centralized.

### Camera/video/image support

- Camera capture functionality is present:
  - `lib/widgets/camera/camera_capture_widget.dart`
- Video handling exists but metadata quality concerns were identified (stub/zero-value metadata in specific paths).
- Frame extraction/sampling logic appears duplicated across modules.

### Platform-specific code

- Platform permissions and settings are configured in:
  - `android/app/src/main/AndroidManifest.xml`
  - `ios/Runner/Info.plist`
  - `macos/Runner/Info.plist`
  - `macos/Runner/DebugProfile.entitlements`
  - `macos/Runner/Release.entitlements`

### Security-sensitive areas

- External runtime/model loading:
  - `web/index.html`
  - `web/sam_inference.js`
  - model download paths in model UI/prelabel components.
- Executable/path handling and broad filesystem operations require stricter validation and policy.
- No strong app-level role-based authorization model in current architecture.

### Test coverage and code quality signals

- Observed in workspace validation:
  - `flutter test` compile/import failures across multiple files.
  - `flutter analyze` ~707 issues (warnings/info).
- These signal significant technical debt and weak reliability baseline.

### Modularity and coupling issues

- UI components own orchestration decisions that should live in application/domain services.
- Direct DB access from UI creates hidden coupling and makes backend evolution expensive.

### Scalability concerns for future AI/video features

- No explicit job queue model for heavy inference.
- Client-heavy inference design will not scale for multi-user on-prem workloads and long video processing.

## 3. Product-Critical Workflows

| Workflow | Current Support | Gaps | Complexity | Architectural Blockers |
|---|---|---|---|---|
| Manual annotation creation | Strong local support in annotator/editor flows | Domain rules and consistency checks are weakly centralized | Medium | UI directly coupled to persistence |
| Edit/delete annotations | Supported locally | Missing robust audit trail and versioning | Medium | No lifecycle/event model |
| Attach annotations to image/video/frame/time range | Partial | Missing canonical timeline/frame index contract; metadata reliability issues | High | No unified media domain layer |
| AI-assisted suggestions | Partial (ML Kit/TFLite/SAM hooks) | No unified inference API contract or async job state model | High | Missing backend orchestration boundary |
| OCR/text extraction annotations | Not complete end-to-end | OCR capability not productized as a full workflow | Medium | No standardized AI capability abstraction |
| Live camera/frame suggestions | Camera capture exists | Real-time inference loop, throttling, and backpressure strategy missing | High | Missing streaming/pipeline architecture |
| Review/approval workflows | Minimal or absent | No robust reviewer states/assignment/audit | Medium | Annotation schema lacks review lifecycle fields |
| Offline/low-connectivity | Local-first behavior is good | No sync protocol/conflict resolution strategy | High | Missing cache-sync contract and remote source-of-truth |

## 4. On-Prem Readiness Assessment

### Separation of client and backend responsibilities

- Current: insufficient separation.
- Required: Flutter client should be workflow UI + local cache; backend should own authoritative storage, policy, and workflow transitions.

### Ability to connect to customer-hosted APIs

- Current: no first-class API architecture for core domain.
- Required: typed API client abstraction, environment-driven endpoints, retry and resilience patterns.

### Auth and tenant boundary implications

- Current: local session model, no clear server-side RBAC/tenant isolation.
- Required: tenant/project/user boundaries with server-enforced authorization.

### Environment/config management

- Current: mixed/hardcoded dependencies in places.
- Required: explicit runtime config profile for `local`, `onprem`, and `airgap`.

### Local network / air-gapped deployment considerations

- Current: external runtime/model dependencies conflict with strict air-gapped operation.
- Required: internal model registry and bundled or internally hosted runtimes.

### Data privacy and retention implications

- Current: local DB provides basic locality but no policy controls.
- Required: retention/deletion policies, auditability, encryption strategy.

### Observability/logging implications

- Current: insufficient for production operations.
- Required: structured logs, trace identifiers, inference/job-level metrics.

### Update/versioning concerns

- Current: limited strategy for API versioning and backward compatibility.
- Required: compatibility matrix and versioned migrations for both client and backend.

## 5. Media + AI Capability Assessment

### Image annotation

- Flutter can already support high-quality image annotation UI.
- Missing: strict annotation schema and backend-authoritative persistence path.

### Frame-based camera analysis

- Flutter can capture frames and run lightweight local analysis.
- Missing: scalable real-time policy (sampling rate, frame dropping, timeout handling).

### Uploaded video analysis

- UI can ingest/manage media.
- Missing: robust server-side video analysis pipeline and deterministic frame indexing.

### Real-time or near-real-time frame sampling

- Should be backend-driven for heavier models and repeatability.
- Client should orchestrate display and interaction, not long-running heavy inference.

### OCR

- Not yet a complete user workflow despite dependencies that could support it.

### Structured AI outputs

- Current flexible payload approach is useful but too loose for reliable workflow automation.
- Needed: typed output envelope with model/version/provenance/confidence.

### Backend inference integration

- Missing a unified interface and asynchronous job lifecycle (`queued`, `running`, `succeeded`, `failed`, `applied`).

### What Flutter can support vs what should be backend

- Flutter: annotation UX, editing, review actions, local caching, user feedback loops.
- Backend: media processing, model execution orchestration, storage of authoritative data, policy and authz.
- Should not be on client:
  - full-scale video batch inference
  - enterprise policy enforcement
  - multi-tenant model lifecycle governance

## 6. Target Architecture Proposal

### Target (evolutionary, pragmatic)

1. Flutter Client
   - Presentation/UI
   - Workflow orchestration
   - Local cache for offline-first UX
2. On-Prem Backend (start as modular monolith)
   - Project/media/annotation/review/auth APIs
   - server-side validation and policy
3. Inference Orchestrator + Workers
   - asynchronous AI jobs (OCR, detection, segmentation)
4. Media Pipeline
   - ingest, metadata, frame extraction, thumbnails
5. Storage
   - relational DB for metadata
   - object storage for media and model artifacts

### Recommended domain boundaries

- `Project`
- `Dataset`
- `MediaAsset`
- `Annotation`
- `ReviewTask`
- `AIJob`
- `ModelRegistry`
- `User` / `Role` / `Permission`

### Client responsibilities

- Rendering and editing annotations.
- Submitting operations via repository interfaces.
- Managing optimistic UI and conflict prompts.

### Backend responsibilities

- Source-of-truth state and versioning.
- Authorization and tenancy.
- Audit and policy enforcement.

### AI/inference responsibilities

- Execute models via worker pool.
- Return structured results with provenance metadata.

### Media ingestion responsibilities

- Validate uploads, compute checksums, derive metadata and frames.

### Storage responsibilities

- Client SQLite transitions to cache role in server-connected mode.

### API contracts (high-level)

- `POST /projects`
- `POST /datasets`
- `POST /media`
- `POST /annotations`
- `PATCH /annotations/{id}`
- `POST /ai/jobs`
- `GET /ai/jobs/{id}`
- `POST /ai/jobs/{id}/apply`
- `GET /media/{id}/frames`
- `GET /capabilities`
- `GET /health`

### Security boundaries

- API boundary is enforcement point.
- Model artifacts signed/verified.
- Encrypted transport and secure credential handling.
- Audit records for annotation and review transitions.

### Extensibility for future real-time capabilities

- Add SSE/WebSocket for job status and streaming updates.
- Keep capability flags to enable/disable features per deployment.

### Overengineering warnings

- Avoid premature microservice decomposition.
- Start with modular monolith backend and split only with measured scaling need.

## 7. Gap Analysis

| Area | Current State | Target State | Risk | Priority | Recommendation |
|---|---|---|---|---|---|
| Build baseline | Compile/import instability and analyzer noise | Stable, testable baseline with CI gates | Very High | P0 | Fix imports, restore green build, enforce CI checks |
| Architecture layering | UI directly uses DB/services | UI -> application services -> repositories -> adapters | High | P0 | Introduce repository and service boundaries incrementally |
| Annotation contract | Flexible but weakly typed payload | Versioned, typed schema with migration policy | High | P0 | Define schema v1 and migration tests |
| Backend readiness | No first-class domain API integration | Customer-hosted API as primary integration path | High | P0 | Add API client abstraction + config-driven endpoints |
| Authz/tenancy | Local user/session style | Server-side RBAC and tenant/project boundaries | High | P1 | Define role matrix and enforce in backend |
| Media pipeline | Distributed/duplicated logic | Canonical ingest + metadata + frame indexing | High | P1 | Centralize media services and metadata extraction |
| AI orchestration | Fragmented local services | Unified async AI job lifecycle | High | P1 | Introduce `AIJob` domain and result contract |
| Air-gap support | External GitHub/CDN dependencies | Fully internal model/runtime sourcing | High | P1 | Replace external fetches with on-prem registry |
| Observability | Limited diagnostics | Structured logs + metrics + tracing | Medium | P1 | Add telemetry standard early |
| Offline sync | Local-first but unsynced model | explicit sync/conflict strategy | Medium | P2 | Implement after backend contracts stabilize |
| Review workflow | Minimal states | Approve/reject assignment workflow with audit | Medium | P2 | Add lifecycle states and reviewer UX |
| Security hardening | Broad local permissions and path usage | validated paths, least privilege, secure defaults | High | P1 | Harden filesystem and executable path handling |

## 8. Delivery Roadmap

### Phase 0: Architecture Stabilization

- Goals:
  - Re-establish reliable engineering baseline.
- Deliverables:
  - Fix compile/import breakages.
  - Reduce analyzer debt to an agreed threshold.
  - Add CI checks for analyze and test.
  - Publish architecture conventions (ADR).
- Dependencies:
  - None.
- Risks:
  - Fixes may reveal hidden coupling and regressions.
- Exit criteria:
  - `flutter test` passes on core suites.
  - `flutter analyze` is within controlled threshold.
  - Architecture conventions are documented and adopted.

### Phase 1: Annotation Domain Foundation

- Goals:
  - Define annotation domain contracts and decouple from UI.
- Deliverables:
  - Repository interfaces and initial implementations.
  - Schema v1 for annotation payload envelope.
  - Review lifecycle fields (`draft/proposed/accepted/rejected`).
- Dependencies:
  - Phase 0 baseline.
- Risks:
  - Existing data migration regressions.
- Exit criteria:
  - Core annotation flows run through repositories/services.
  - Schema migration validated against real sample datasets.

### Phase 2: Media Support Foundation

- Goals:
  - Establish robust media pipeline and frame model.
- Deliverables:
  - Centralized media metadata extraction service.
  - Unified frame extraction and indexing utility.
  - Deterministic media identification/checksum path.
- Dependencies:
  - Phase 1 domain interfaces.
- Risks:
  - Platform differences (desktop/mobile/web) complicate parity.
- Exit criteria:
  - Accurate metadata/frame indexing on test corpus.

### Phase 3: Backend AI Integration

- Goals:
  - Enable on-prem backend-driven AI workflows.
- Deliverables:
  - Flutter API client abstraction with environment profiles.
  - On-prem backend endpoints for project/media/annotation/AI jobs.
  - Worker integration for selected AI tasks.
- Dependencies:
  - Phase 1 and 2 contracts.
- Risks:
  - Contract mismatches between client and backend.
- Exit criteria:
  - End-to-end AI job lifecycle works in customer-hosted environment.

### Phase 4: AI-Assisted Annotation UX

- Goals:
  - Deliver productive and trustworthy AI-assisted annotation experiences.
- Deliverables:
  - Suggestion panel with confidence + provenance.
  - Apply/reject/edit AI proposal workflow.
  - Human review queue and approval loop.
- Dependencies:
  - Phase 3 AI pipeline.
- Risks:
  - Low-quality suggestions reduce operator trust.
- Exit criteria:
  - Users can complete human-in-the-loop workflow with audit history.

### Phase 5: Real-Time Frame-Based Features

- Goals:
  - Add near-real-time analysis capabilities safely.
- Deliverables:
  - Configurable frame sampling and backpressure.
  - Streaming updates (SSE/WebSocket).
  - Throughput/latency controls and operational dashboards.
- Dependencies:
  - Stable backend orchestration and monitoring.
- Risks:
  - On-prem hardware variance affects latency consistency.
- Exit criteria:
  - Latency and reliability targets validated on reference deployments.

## 9. Step-by-Step Execution Plan

| Step | Objective | Files/Modules Likely Involved | Suggested Implementation Approach | Risks | Validation Method | Safe Independently |
|---|---|---|---|---|---|---|
| 1 | Restore compile baseline | `lib/pages/project_creation/create_from_dataset_dialog.dart`, `lib/pages/project_details_page.dart`, `lib/pages/models_page.dart`, `lib/pages/account_page.dart`, `lib/widgets/project_creation_from_dataset/*`, `lib/widgets/project_details/project_details_sidebar.dart`, `lib/utils/image_utils.dart` | Resolve broken imports and symbol mismatches without behavior change | Cascading breakages | `flutter test`, `flutter analyze` | Yes |
| 2 | Codify architecture conventions | `docs/architecture/*` | Add ADR for module boundaries, naming, layering | Team adoption lag | ADR review and sign-off | Yes |
| 3 | Introduce repository interfaces | `lib/data/*`, `lib/pages/*` | Define interfaces and wrap existing SQLite adapters | Temporary duplication | Repository unit tests | Yes |
| 4 | Extract annotation application services | `lib/pages/annotator_page.dart`, `lib/widgets/imageannotator/*` | Move orchestration out of widgets into service/controller layer | UI regression | Widget/integration tests | Yes |
| 5 | Introduce annotation schema v1 | `lib/data/create_initial_schema.dart`, `lib/data/annotation_database.dart` | Add version field and migration logic | Data compatibility issues | Migration test fixtures | No |
| 6 | Add review lifecycle metadata | `lib/data/annotation_database.dart`, annotation UI modules | Add state fields and transition rules | Workflow complexity | Scenario tests for transitions | Yes |
| 7 | Add runtime environment config | `lib/main.dart`, config module | Add typed config model and startup validation | Misconfiguration | Startup config tests | Yes |
| 8 | Centralize media metadata extraction | `lib/widgets/project_details/dataset_upload_buttons.dart`, media services | Build one metadata service and route all callers through it | Platform variability | Media metadata fixture tests | Yes |
| 9 | Unify frame extraction logic | media widgets/services | Replace duplicated logic with shared pipeline utility | Performance regressions | Throughput + correctness checks | Yes |
| 10 | Add API client abstraction | `lib/services/*`, `lib/session/user_session.dart` | Introduce `ApiClient`, DTOs, and error model | Contract drift | Mock-server integration tests | Yes |
| 11 | Remove external model/runtime dependencies | `lib/widgets/model_cards/model_card.dart`, `lib/pages/project_prelabel/pre_label_project_dialog.dart`, `web/index.html`, `web/sam_inference.js` | Make model/runtime sources configurable and on-prem hosted | Air-gap failures if partial | Air-gapped smoke tests | Yes |
| 12 | Standardize AI job lifecycle | AI service modules under `lib/services` | Wrap inference calls in async job model | Mixed sync/async complexity | End-to-end AI job tests | No |
| 13 | Productize OCR workflow | OCR service + annotator integration | Add OCR capability adapter and structured annotation output | Accuracy variance | OCR fixture tests + QA | Yes |
| 14 | Implement review queue UX | `lib/pages/project_details_page.dart` and review widgets | Add queue, assignment, and decision actions | UX discoverability | Workflow acceptance tests | Yes |
| 15 | Security and observability hardening | platform manifests/plists/entitlements + logging modules | Add structured logs, tighten permissions, validate paths | Platform edge cases | Security checklist + runtime checks | No |

## 10. Technical Debt and Refactoring Recommendations

### Must do now

1. Fix compile/import breakages and re-establish green baseline.
2. Reduce analyzer issue volume and enable CI quality gates.
3. Introduce architecture layering and repository boundaries.
4. Define annotation schema versioning and migration strategy.
5. Remove hardcoded external model/runtime dependencies that break air-gapped expectations.

### Should do soon

1. Consolidate duplicated media and frame extraction logic.
2. Standardize state management for complex flows.
3. Add typed config and deployment profiles for on-prem.
4. Add structured observability and error taxonomy.
5. Add review lifecycle and provenance metadata.

### Can wait

1. Full real-time streaming infrastructure for all use cases.
2. Premature microservice split of backend modules.
3. Large-scale autoscaling and advanced optimization before contract stabilization.
4. Advanced multi-tenant controls if initial rollout is single-tenant per deployment.

## 11. Open Questions and Assumptions

### Open questions

1. Is initial on-prem deployment single-tenant per customer instance?
2. Which platforms are required for v1 (desktop, web, mobile)?
3. What throughput targets are expected (images/day, video-hours/day)?
4. Is strict air-gapped operation mandatory from first release?
5. What auth integration is required (OIDC/LDAP/SAML)?
6. What compliance requirements apply (audit retention, encryption standards, PII policy)?
7. Which AI capabilities are mandatory in MVP (detection, segmentation, OCR, tracking)?
8. Is reproducible deterministic inference required for regulatory workflows?
9. Do you already have a backend technology preference?

### Assumptions used

1. The repository is currently client-heavy with no mature backend API layer.
2. Current AI capabilities are mostly local/on-device prototypes.
3. Existing build/test instability must be addressed before major architectural changes.

## 12. Final Recommendation

- Start with architecture stabilization and domain boundary refactoring before adding more AI complexity.
- First implementation focus:
  1. Restore compile/analyze/test baseline.
  2. Introduce repository/application-service boundaries for annotation/media.
  3. Define annotation schema v1 and migration strategy.
- Postpone:
  - Full real-time camera streaming and heavy video inference until backend AI job architecture is in place.
- MVP recommendation:
  - On-prem backend with project/media/annotation APIs,
  - asynchronous AI suggestion pipeline (at least one visual model + OCR),
  - reviewer approval workflow,
  - Flutter client integration with local cache and fallback behavior.
- Do not attempt yet:
  - Overengineered distributed architecture, broad microservice decomposition, or advanced cross-tenant capabilities before core workflow reliability.

---

## A. Architecture Review

- Completed in Sections 1, 2, 4, 5, 6, and 7 with file-aware findings and risk assessment.

## B. Phased Roadmap

- Completed in Section 8 (Phases 0 through 5 with goals, deliverables, dependencies, risks, exit criteria).

## C. Step-by-Step Plan

- Completed in Section 9 with incremental implementation slices and validation methods.

## D. Top 10 Immediate Priorities

1. Fix compile/import errors and restore a green baseline.
2. Add CI gates for `flutter analyze` and `flutter test`.
3. Introduce repository boundaries to remove direct UI-to-DB coupling.
4. Define annotation schema v1 with migration tests.
5. Centralize media metadata and frame extraction.
6. Add typed environment config for on-prem/airgap deployments.
7. Add API client abstraction for customer-hosted backend integration.
8. Eliminate GitHub/CDN runtime/model dependencies in production paths.
9. Introduce unified asynchronous AI job lifecycle.
10. Implement review/approval workflow with provenance and audit fields.

### Suggested very first repository step

- Fix the known broken imports and symbol mismatches in impacted modules, then enforce a green baseline via CI. This is the highest-leverage action before any architectural implementation.
