
# Dataset Task Type Detection — Mapping Rules

This document describes the internal mapping logic used by `detectDatasetTaskType()` to assign dataset types.  
The function guarantees only one of the **9 approved project types** is returned.

---

## ✅ Supported Project Types

| Type | Description |
|------|-------------|
| Detection bounding box | Object detection with rectangular bounding boxes |
| Detection oriented | Object detection with rotated boxes or polygons |
| Anomaly detection | Image-level anomaly classification (currently not auto-detected) |
| Binary Classification | Image classification with exactly 2 classes |
| Multi-class Classification | Single-label image classification with multiple possible classes |
| Multi-label Classification | Multi-label image classification (image can have multiple labels) |
| Hierarchical Classification | Multi-level classification (currently not auto-detected) |
| Instance Segmentation | Object detection with instance-specific masks |
| Semantic Segmentation | Pixel-wise segmentation with global class masks |

---

## 🔎 Detection Rules

### 1️⃣ Datumaro format (`*.json`)
- `items[].annotations[].type == "bbox"` → **Detection bounding box**
- `items[].annotations[].type == "oriented_bbox"` → **Detection oriented**
- `items[].annotations[].type == "polygon"` → **Detection oriented**
- `items[].annotations[].type == "mask" or "segmentation"` → **Instance Segmentation**

### 2️⃣ COCO format (`*.json`)
- `annotations[].bbox` present → **Detection bounding box**
- `annotations[].oriented_bbox` present → **Detection oriented**
- `annotations[].segmentation`, `annotations[].rle`, `annotations[].mask` present → **Instance Segmentation**

### 3️⃣ LabelMe format (`*.json`)
- `shapes[]` present → **Detection bounding box**

### 4️⃣ Datumaro label-only dataset (`*.json`)
- `categories` or `labels` fields present, no annotations → **Multi-class Classification**

### 5️⃣ Pascal VOC format (`*.xml`)
- Contains `<bndbox>` or `<oriented_bbox>` → **Detection bounding box**
- Contains `<segmentation>` or `<mask>` → **Semantic Segmentation**

### 6️⃣ YOLO format (`*.txt`)
- Line has ≥5 numeric values → **Detection bounding box**
- Line has 1 numeric value → **Binary Classification**
- Line has >1 values → **Multi-label Classification**

---

## 🚧 Not Currently Auto-Detected
- `Anomaly detection` → Must be set manually or by custom importer
- `Hierarchical Classification` → Must be set manually or by custom importer

---

## 📝 Fallback
If no annotation type is detected → function returns `"Unknown"`.

---

# 👷 Notes for Developers
- Always update this document if detection rules change.
- This document and `detectDatasetTaskType()` must stay 100% aligned.
- Used by: dataset import pipelines, project creation wizard, dataset validation.

---

### 🔗 Reference file
`lib/datasets/dataset_detection.dart`
