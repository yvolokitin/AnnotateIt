# Platform Capability Matrix

**Date:** 2026-03-30
**App version:** 4.4.0+31
**Flutter:** 3.41.4 stable, Dart 3.11.1

---

## 1. Capability Table

| Capability | Windows | iOS | macOS | Web |
|---|---|---|---|---|
| **Video import** | File picker (`file_picker`) | Photos library (`image_picker`) + camera capture | File picker + drag-and-drop | File picker (browser `<input>`) |
| **Frame extraction** | FFmpeg CLI (`Process.run`) | `ffmpeg_kit_flutter_new` (bundled) | FFmpeg CLI (Homebrew/MacPorts auto-detected) | Not available natively |
| **Video metadata** | Stub (returns zeros) | Stub (returns zeros) | Stub (returns zeros) | Stub (returns zeros) |
| **Camera capture** | Not supported by `camera` plugin | Full support (AVFoundation) | Entitlements granted, limited plugin support | `camera_web` (basic, no video recording) |
| **Image annotation** | Full (bbox, polygon, classification, segmentation, keypoints, OCR) | Full | Full | Full |
| **SAM segmentation** | Heuristic fallback (region growing + marching squares) | Heuristic fallback | Heuristic fallback | Real ONNX inference via `onnxruntime-web` (WASM backend) |
| **TFLite inference** | Via `tflite_flutter` + bundled `libtensorflowlite_c-win.dll` | Via `tflite_flutter` (native) | Via `tflite_flutter` (native) | Stub — throws `UnsupportedError` |
| **ML Kit (OCR, labeling)** | Not available (`google_ml_kit` = mobile-only) | Full (`google_ml_kit` native) | Not available | Not available |
| **SQLite database** | `sqflite_common_ffi` (dart:ffi) | `sqflite` (native iOS driver) | `sqflite_common_ffi` (dart:ffi) | `sqflite_common_ffi_web` + `sqlite3.wasm` |
| **File system access** | Unrestricted (`dart:io`) | App sandbox + Photos permission | App sandbox with entitlements | No direct FS; browser File API only |
| **Video playback** | `video_player` (limited desktop support) | `video_player` (AVPlayer) | `video_player` (AVPlayer) | `video_player_web` (HTML5 `<video>`) |
| **Export/share** | File dialog + `share_plus` | Share sheet + file dialog | File dialog + `share_plus` | Browser download via `web_download_helper` |
| **Window management** | `window_size` (min size enforced) | N/A (mobile) | `window_size` (min size enforced) | N/A (browser tab) |
| **App packaging** | MSIX (Microsoft Store ready) | IPA (App Store) | .app bundle (App Store) | Static hosting |

---

## 2. Detailed Notes per Platform

### Windows (primary desktop target)

**Strengths:**
- Unrestricted file system access — no sandbox constraints.
- TFLite inference with bundled DLL (`windows/tflite/libtensorflowlite_c-win.dll`).
- FFmpeg via `Process.run` — user configures path or auto-detected at `C:\ffmpeg\bin\ffmpeg.exe`.
- MSIX packaging configured for Microsoft Store.

**Limitations:**
- `camera` plugin does not support Windows desktop.
- `google_ml_kit` unavailable — OCR and image labeling require either TFLite models or API backend.
- Video metadata probe is a stub — no ffprobe integration yet.
- `video_player` desktop support is limited (no seek accuracy guarantees).

**Fallback strategies:**
- Camera: use file picker for image/video import instead.
- OCR: route to on-prem API backend or skip.
- Video metadata: planned ffprobe integration (Playbook Step 4).

---

### iOS

**Strengths:**
- Full `google_ml_kit` support (OCR, face detection, image labeling, pose detection).
- Native camera capture via `camera` plugin (AVFoundation).
- `ffmpeg_kit_flutter_new` bundled — frame extraction works without external binary.
- `image_picker` integrates with Photos library (multi-select, video pick).
- TFLite inference via native `tflite_flutter`.

**Limitations:**
- App sandbox — can only access files via Photos permission or document picker.
- Memory pressure on large video frame extraction (no lazy loading yet).
- Video metadata probe is a stub despite `ffmpeg_kit` being available.
- No direct file system browsing — must use picker APIs.

**Fallback strategies:**
- File access: use `image_picker` (requestFullMetadata: false) and `file_picker` for imports.
- Memory: planned lazy loading for frame thumbnails (Playbook Step 18).
- Video metadata: planned AVAsset-based probe (Playbook Step 4).

**Permissions configured in `Info.plist`:**
- `NSCameraUsageDescription` — camera access for photos/videos.
- `NSMicrophoneUsageDescription` — microphone for video recording.
- `NSPhotoLibraryUsageDescription` — photo library read access.
- `NSPhotoLibraryAddUsageDescription` — save to photo library.
- `UIFileSharingEnabled` + `LSSupportsOpeningDocumentsInPlace` — Files app integration.

---

### macOS

**Strengths:**
- App Sandbox with broad entitlements (camera, microphone, pictures R/W, movies R/O, Downloads R/O, user-selected files R/W, network).
- FFmpeg auto-detected at Homebrew/MacPorts paths: `/opt/homebrew/bin/ffmpeg`, `/usr/local/bin/ffmpeg`, `/opt/local/bin/ffmpeg`.
- Mach-O header validation for FFmpeg binary (avoids executing non-binaries).
- TFLite inference via native `tflite_flutter`.
- Drag-and-drop file import.

**Limitations:**
- `google_ml_kit` unavailable on macOS desktop.
- `camera` plugin macOS support is limited/experimental.
- Sandbox restricts file access to user-selected files and specific entitlement-granted locations.
- Video metadata probe is a stub.
- Release entitlements are more restrictive than Debug (no pictures write, no music, no microphone, no network server).

**Fallback strategies:**
- OCR: route to on-prem API backend or skip.
- Camera: use file picker for import.
- Video metadata: planned ffprobe integration (Playbook Step 4).
- Sandbox: all file operations use user-selected file picker (entitlement granted).

**macOS entitlements (Debug/Profile):**

| Entitlement | Granted |
|---|---|
| `app-sandbox` | Yes |
| `camera` | Yes |
| `microphone` | Yes |
| `pictures` | Read/Write |
| `movies` | Read-only |
| `music` | Read-only |
| `downloads` | Read-only |
| `user-selected files` | Read/Write |
| `network.client` | Yes |
| `network.server` | Yes |
| `cs.allow-jit` | Yes |

**macOS entitlements (Release) — reduced:**

| Entitlement | Granted |
|---|---|
| `app-sandbox` | Yes |
| `camera` | Yes |
| `pictures` | Read-only |
| `movies` | Read-only |
| `downloads` | Read-only |
| `user-selected files` | Read/Write |
| `network.client` | Yes |

---

### Web

**Strengths:**
- SAM segmentation with real ONNX inference via `onnxruntime-web` (WASM backend) — the only platform with real SAM.
- SQLite via `sqflite_common_ffi_web` + bundled `sqlite3.wasm`.
- Zero-install deployment — accessible via browser.
- Browser-native file picker for import.
- `video_player_web` via HTML5 `<video>` element.

**Limitations:**
- No TFLite inference — stubs throw `UnsupportedError`.
- No `google_ml_kit` — mobile-only package.
- No `dart:io` — no direct file system access, no `Process.run`.
- No FFmpeg — cannot extract frames natively.
- No camera video recording (camera_web supports basic preview only).
- `js` package is discontinued — should migrate to `dart:js_interop`.
- Large ONNX model download on first use (encoder + decoder).

**Fallback strategies:**
- Frame extraction: require pre-extracted frames or use server-side FFmpeg via API.
- TFLite/ML Kit: route all inference to on-prem API backend.
- File system: use browser File API via `file_picker` and IndexedDB for storage.
- Camera: use file picker to upload existing images/videos.
- Video metadata: use HTML5 `<video>` element properties (duration, videoWidth, videoHeight) — not yet implemented.

---

## 3. AI Inference Routing Summary

| AI Capability | Windows | iOS | macOS | Web |
|---|---|---|---|---|
| Classification (TFLite) | Local | Local | Local | API only |
| Detection (TFLite) | Local | Local | Local | API only |
| OCR (ML Kit) | API only | Local | API only | API only |
| Image labeling (ML Kit) | API only | Local | API only | API only |
| SAM segmentation | Heuristic fallback | Heuristic fallback | Heuristic fallback | Local (ONNX/WASM) |
| On-prem/external API | All platforms (when `APP_DEPLOYMENT_MODE=onprem` and `APP_API_BASE_URL` configured) |

---

## 4. Limitations & Risks Cross-Reference

| # | Limitation | Affected Platforms | Mitigation / Playbook Step |
|---|---|---|---|
| L1 | Video metadata returns zeros | All | Step 4: ffprobe (Win/macOS), AVAsset (iOS), `<video>` element (Web) |
| L2 | No frame identity contract | All | Step 5: FrameIdentity model |
| L3 | Frame extraction unavailable | Web | Server-side FFmpeg or pre-extracted import |
| L4 | TFLite unavailable | Web | API backend routing |
| L5 | ML Kit unavailable | Windows, macOS, Web | API backend or TFLite alternative models |
| L6 | SAM is heuristic-only | Windows, iOS, macOS | Integrate ONNX Runtime native (future) |
| L7 | Camera not supported | Windows, Web (limited) | File picker import |
| L8 | macOS Release entitlements restricted | macOS | May need to add write entitlements for export |
| L9 | No feature flags | All | Step 3: runtime feature flag system |
| L10 | `js` package discontinued | Web | Migrate to `dart:js_interop` (partially done in `sam_web_ffi_web.dart`) |

---

## 5. Platform Priority and Rollout Order

Per playbook:

| Wave | Platform | Status | Notes |
|---|---|---|---|
| 1 | **Windows** | Primary | Most complete desktop support, MSIX packaging ready |
| 2 | **iOS** | Secondary | Best mobile ML support, App Store ready |
| 3 | **macOS** | Tertiary | Shares iOS ecosystem, sandbox considerations |
| 4 | **Web** | Future | Best SAM support, but no local TFLite/ML Kit |

---

*This document is a reference snapshot. Update when platform support changes.*
