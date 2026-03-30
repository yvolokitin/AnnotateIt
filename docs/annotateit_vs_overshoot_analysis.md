# AnnotateIt vs Overshoot.ai — Deep Product/Architecture Gap Analysis

Date: 2026-03-30

## TL;DR

AnnotateIt already has a strong local-first annotation foundation (manual annotation, dataset import/export, local AI hooks, and partial video/frame extraction).

Overshoot is currently stronger in **real-time streaming inference orchestration** (camera/screen/HLS/LiveKit sources, frame/clip modes, structured output over a streaming API, model fleet routing, latency tooling).

The biggest opportunity for AnnotateIt is **not** to clone Overshoot, but to become the best **standalone + on-prem annotation workstation** with optional backend acceleration.

---

## 1) What AnnotateIt already does well

### Local-first and standalone DNA

- Runtime has explicit deployment modes (`local`, `onprem`, `airgap`) and controls for external model downloads. This is an excellent foundation for enterprise/offline deployments.
- Project data model already includes projects/datasets/media/annotations, and media items support both image and video metadata fields.

### Existing AI/annotation capabilities

- Prelabel flow supports ML Kit + TFLite model checks/download flow.
- SAM integration is already productized for image workflows (Web: ONNX; non-Web: fallback heuristic), with shared UX for segmentation/detection.
- OCR annotation flow already exists with structured provenance payloads.

### Video entry points exist

- Video import path can extract frames and insert into dataset as images.
- There is reusable FFmpeg extraction service and diagnostics.

---

## 2) Where Overshoot is stronger today

Overshoot docs indicate:

- Streaming architecture with API key auth, stream lifecycle (`POST /streams`, keepalive, WebSocket results), and model status endpoint.
- Multiple real-time source types (camera, video file, screen share, HLS, LiveKit).
- Two processing modes: frame mode (single-frame inference) and clip mode (temporal context with `target_fps`, `clip_length_seconds`, `delay_seconds`).
- Structured output contract via JSON schema (`outputSchema` / `output_schema_json`) and result metadata (`inference_latency_ms`, `total_latency_ms`, `finish_reason`).

So Overshoot’s edge is less about “annotation UI” and more about **live video inference platform primitives**.

---

## 3) Concrete gaps in AnnotateIt (vs your target + Overshoot)

### A. Video domain model is not fully first-class yet

- `MediaMetadataService.getVideoMetadata` is still placeholder (`0` width/height/duration/fps).
- Upload pipeline falls back to stub metadata and fixed frame-count assumptions if metadata unavailable.
- Current flow stores extracted frames as media items, but no canonical timeline/frame-index contract for video-native annotation.

### B. No realtime stream orchestration layer

- You have an API client and capability endpoint scaffolding, but no stream/session API equivalent (start stream, keepalive, prompt hot-swap, websocket results).

### C. Missing temporal annotation primitives

- Existing schema handles generic annotation payloads well, but lacks explicit temporal entities (track_id, start/end timestamps, keyframes/interpolation metadata, shot/clip grouping).

### D. Missing structured inference IO contract at platform level

- OCR has a good local schema, but there is no unified envelope for all AI results (model ID/version, latency, input frame refs, confidence, validation status, replayability).

### E. MLOps/runtime governance for standalone+on-prem is early

- There are model registry URL controls and airgap flags, but limited model lifecycle management (version pinning, health scoring, fallback policy, A/B profiling).

---

## 4) Can you reuse models from Overshoot?

Short answer: **partially yes, directly no**.

1. **Using Overshoot-hosted inference directly**
   - You can call their service through their API (with their API key and terms) if your deployment allows cloud traffic.
   - This is integration, not “reusing their infra for free.”

2. **Using the same open models yourself (recommended for standalone/on-prem)**
   - Many model names shown in Overshoot docs are public/open checkpoints (e.g., Qwen/InternVL/MiniCPM style model families).
   - You can self-host compatible models in your own backend/on-prem cluster **if licenses permit your use case** (commercial, redistribution, jurisdiction, etc.).

3. **Important boundary**
   - Don’t assume access to Overshoot’s optimizations (routing, infra tuning, throughput tricks) just because model names overlap.
   - The model weights may be open; Overshoot’s serving layer is their product/IP.

---

## 5) How to be better than Overshoot for your positioning (standalone-first)

### Strategic differentiation (where you can win)

1. **Offline/air-gapped reliability as a first-class feature**
   - Deterministic local execution, zero-cloud mode, verifiable provenance, encrypted local projects.

2. **Best-in-class annotation ergonomics**
   - Overshoot focuses on inference stream APIs; you can win on annotator productivity:
   - keyboard-first tooling, bulk-edit, track propagation, active-learning queue, disagreement review UX.

3. **Reproducibility and dataset quality governance**
   - “Model-assisted but audit-ready” workflows: every auto-label has provenance, score, reviewer decision, and replay recipe.

4. **Hybrid execution policy engine**
   - Route each task to local CPU/GPU, on-prem worker, or external API by policy (cost, latency, privacy, model availability).

### Product thesis

> Overshoot = live vision inference API.
> AnnotateIt (future) = production-grade annotation operating system for teams with strict data/control requirements.

---

## 6) How to add full video support properly (recommended architecture)

### Phase 1 — Foundation (2–4 weeks)

1. **Canonical video metadata extraction**
   - Implement ffprobe-based metadata service (duration, avg fps, stream fps, resolution, codec, frame count estimate).

2. **Video frame index contract**
   - Introduce deterministic frame identity:
   - `video_id`, `frame_index`, `timestamp_ms`, `source_fps`, `sample_policy`.

3. **Persist extraction jobs**
   - Reuse `AiJobRunner` concepts but persist job records (queued/running/succeeded/failed/canceled), with progress and logs in DB.

### Phase 2 — Temporal annotation model (3–6 weeks)

1. **Schema extensions**
   - Add `tracks` table (object identity across frames).
   - Add `frame_annotations` or extend existing annotation payload schema with temporal keys.
   - Add review states per track segment.

2. **UI additions**
   - Timeline + scrubber + keyframe marks.
   - Interpolation between keyframes for bbox/polygon.
   - Track merge/split + occlusion flags.

### Phase 3 — Realtime/hybrid inference (4–8 weeks)

1. **Stream abstraction layer**
   - Internal interface:
     - `startStream(source, mode, prompt, schema)`
     - `updatePrompt(streamId, prompt)`
     - `onResult(StreamResult)`
     - `stopStream(streamId)`

2. **Pluggable backends**
   - `LocalBackend` (on-device models).
   - `OnPremBackend` (your own inference workers).
   - `ExternalBackend` (e.g., Overshoot-style API adapters).

3. **Result schema parity**
   - Normalize result envelope with fields similar to stream inference systems:
   - `model_name`, `backend`, `inference_latency_ms`, `total_latency_ms`, `finish_reason`, `structured_payload`.

### Phase 4 — Quality moat (ongoing)

- Active-learning loop: uncertainty sampling + reviewer feedback loop.
- Dataset drift dashboards.
- Label consistency checks (ontology constraints, impossible combinations, temporal consistency validators).

---

## 7) Practical 90-day execution plan

### Days 1–30
- Replace placeholder video metadata with real probing.
- Add frame/timestamp identity and persistent extraction job table.
- Add telemetry around import/extraction failures and throughput.

### Days 31–60
- Ship timeline UI and keyframe annotation MVP.
- Add track IDs + interpolation for bbox.
- Add review UX for auto-generated labels.

### Days 61–90
- Introduce backend adapter abstraction and one remote backend.
- Add structured output schema support for model-generated suggestions.
- Add policy engine for local vs remote routing.

---

## 8) Immediate “next best step” for your current codebase

If you do only one thing first: **implement real video metadata + deterministic frame indexing**.

Why this first:
- It unlocks reliable temporal annotations.
- It removes current fallback assumptions.
- It becomes the base for both local and remote video intelligence pipelines.

