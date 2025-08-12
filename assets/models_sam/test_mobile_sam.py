import argparse
import os
import sys
from typing import Tuple, Dict, Any, List

import numpy as np
from PIL import Image

try:
    import onnxruntime as ort
except Exception as e:
    print("Failed to import onnxruntime. Install it via 'pip install onnxruntime' (or onnxruntime-directml).")
    raise

S = 1024  # encoder input size
LOW_RES = 256  # decoder low-res mask size


def preprocess_imagenet(img: Image.Image) -> Tuple[np.ndarray, Tuple[float, float, float, float]]:
    """
    Resize+pad to 1024 with aspect kept. Return NCHW float32 normalized by ImageNet mean/std.
    Also return (scale, pad_left, pad_top, pad_bottom) to map points later if нужно.
    """
    img = img.convert("RGB")
    w, h = img.size
    scale = S / max(w, h)
    new_w = int(round(w * scale))
    new_h = int(round(h * scale))
    resized = img.resize((new_w, new_h), Image.BILINEAR)

    canvas = Image.new("RGB", (S, S), (0, 0, 0))
    pad_left = (S - new_w) // 2
    pad_top = (S - new_h) // 2
    canvas.paste(resized, (pad_left, pad_top))

    arr = np.asarray(canvas).astype(np.float32) / 255.0  # HWC, [0..1]
    # ImageNet mean/std
    mean = np.array([0.485, 0.456, 0.406], dtype=np.float32)[None, None, :]
    std = np.array([0.229, 0.224, 0.225], dtype=np.float32)[None, None, :]
    arr = (arr - mean) / std
    # HWC -> NCHW
    nchw = np.transpose(arr, (2, 0, 1))[None, ...]  # 1x3x1024x1024
    return nchw, (scale, pad_left, pad_top, float(w), float(h))


def map_point_to_sam(xy: Tuple[float, float], scale_pad: Tuple[float, float, float, float]) -> Tuple[float, float]:
    """Map original image coords (x,y) -> SAM input coords (after resize+pad)."""
    scale, pad_left, pad_top, _, _ = scale_pad
    x, y = xy
    return x * scale + pad_left, y * scale + pad_top


def pick_provider(ep: str) -> List[str]:
    ep = ep.lower()
    if ep == "cpu":
        return ["CPUExecutionProvider"]
    if ep in ("dml", "directml", "onnxruntime-directml"):
        return ["DmlExecutionProvider", "CPUExecutionProvider"]
    # fallback to default order
    return ort.get_available_providers()


def run_encoder(encoder_path: str, img_tensor: np.ndarray, providers: List[str]) -> np.ndarray:
    print(f"[Encoder] Loading: {encoder_path}")
    print(f"[Encoder] Providers requested: {providers}")
    sess = ort.InferenceSession(encoder_path, providers=providers)

    # smoke test: names & shapes
    print("[Encoder] Inputs:")
    for i in sess.get_inputs():
        print(f"  - {i.name}: {i.shape}, {i.type}")
    print("[Encoder] Outputs:")
    for o in sess.get_outputs():
        print(f"  - {o.name}: {o.shape}, {o.type}")

    # попытка угадать имя входа (обычно один)
    in_name = sess.get_inputs()[0].name
    print(f"[Encoder] Using input: {in_name}, tensor shape {img_tensor.shape}")

    # dry-run с нулевым тензором:
    zero = np.zeros_like(img_tensor, dtype=np.float32)
    _ = sess.run(None, {in_name: zero})
    print("[Encoder] Dry-run OK")

    # реальный прогон:
    outs = sess.run(None, {in_name: img_tensor})
    # ищем эмбеддинг — чаще всего 1x256x64x64 или похоже
    emb = None
    for out in outs:
        if out.ndim == 4 and out.shape[0] == 1:
            emb = out
            break
    if emb is None:
        print("[Encoder] Could not detect embedding tensor among outputs. Dumping shapes:")
        for idx, out in enumerate(outs):
            print(f"  out[{idx}].shape = {out.shape}")
        raise RuntimeError("Embedding not found in encoder outputs")
    print(f"[Encoder] Embedding shape: {emb.shape}")
    return emb


def run_decoder(decoder_path: str,
                embedding: np.ndarray,
                point_xy_sam: Tuple[float, float],
                orig_hw: Tuple[int, int],
                providers: List[str]) -> Dict[str, Any]:
    print(f"[Decoder] Loading: {decoder_path}")
    print(f"[Decoder] Providers requested: {providers}")
    sess = ort.InferenceSession(decoder_path, providers=providers)

    print("[Decoder] Inputs:")
    for i in sess.get_inputs():
        print(f"  - {i.name}: {i.shape}, {i.type}")
    print("[Decoder] Outputs:")
    for o in sess.get_outputs():
        print(f"  - {o.name}: {o.shape}, {o.type}")

    # Подготовим типичные входы MobileSAM:
    # image_embeddings: (1, 256, 64, 64) или похожее — возьмём как есть из encoder
    # point_coords: (1, 1, 2)
    # point_labels: (1, 1)
    # mask_input: (1, 1, 256, 256) нулевой
    # has_mask_input: (1,) = 0
    # orig_im_size: (2,) = [H, W]

    H, W = orig_hw
    point = np.array(point_xy_sam, dtype=np.float32).reshape(1, 1, 2)
    labels = np.array([[1]], dtype=np.float32)  # 1 = foreground
    mask_input = np.zeros((1, 1, LOW_RES, LOW_RES), dtype=np.float32)
    has_mask = np.array([0], dtype=np.float32)
    orig_im_size = np.array([H, W], dtype=np.float32)

    # Попробуем найти имена входов по наиболее частым ключам
    names = {i.name for i in sess.get_inputs()}
    feed = {}
    def assign(name_candidates, value, required=True):
        for nm in name_candidates:
            if nm in names:
                feed[nm] = value
                return True
        if required:
            print(f"[Decoder] Missing any of {name_candidates} in model inputs.")
        return False

    ok = True
    ok &= assign(["image_embeddings", "embeddings", "image_embedding"], embedding)
    ok &= assign(["point_coords", "coords", "prompt_points"], point)
    ok &= assign(["point_labels", "labels", "prompt_labels"], labels)
    # mask input может быть необязателен у некоторых вариантов — не делаем hard fail
    assign(["mask_input", "masks", "low_res_masks"], mask_input, required=False)
    assign(["has_mask_input", "has_mask"], has_mask, required=False)
    ok &= assign(["orig_im_size", "orig_hw", "original_size"], orig_im_size)

    if not ok:
        print("[Decoder] Could not match required inputs. See the list above.")
        sys.exit(2)

    outs = sess.run(None, feed)
    print("[Decoder] Got outputs:")
    for idx, o in enumerate(outs):
        print(f"  out[{idx}] shape={o.shape} dtype={o.dtype}")

    # Найдём 256x256 маску и IoU
    mask = None
    iou = None
    for o in outs:
        if o.ndim == 4 and o.shape[-2:] == (LOW_RES, LOW_RES):
            mask = o
        if o.ndim == 2 and o.shape[0] == 1 and o.shape[1] == 1:
            iou = float(o[0, 0])

    result = {"mask": mask, "iou": iou}
    return result


def save_mask(mask: np.ndarray, out_path: str):
    # Обычно маска выходит как logits (не 0/1). Возьмём >0.
    m = mask
    if m.ndim == 4:
        m = m[0, 0]  # 1x1x256x256 -> 256x256
    m = (m > 0).astype(np.uint8) * 255
    Image.fromarray(m, mode="L").save(out_path)
    print(f"[Result] Saved mask to {out_path}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--encoder", required=True, help="Path to mobile_sam.encoder.onnx")
    ap.add_argument("--decoder", required=True, help="Path to mobile_sam.decoder.onnx")
    ap.add_argument("--image", required=True, help="Path to test image")
    ap.add_argument("--ep", default="cpu", help="Execution provider: cpu|directml (or leave default)")
    args = ap.parse_args()

    assert os.path.exists(args.encoder), f"Encoder not found: {args.encoder}"
    assert os.path.exists(args.decoder), f"Decoder not found: {args.decoder}"
    assert os.path.exists(args.image), f"Image not found: {args.image}"

    providers = pick_provider(args.ep)

    # --- Encoder ---
    # Подготовим вход
    pil = Image.open(args.image)
    img_tensor, sp = preprocess_imagenet(pil)  # 1x3x1024x1024 float32
    print(f"[Prep] Tensor shape: {img_tensor.shape}, dtype={img_tensor.dtype}")

    # Прогон encoder
    emb = run_encoder(args.encoder, img_tensor, providers)

    # --- Decoder ---
    # возьмём центральную точку исходного изображения как подсказку
    w, h = pil.size
    cx, cy = w * 0.5, h * 0.5
    px, py = map_point_to_sam((cx, cy), sp)
    print(f"[Prompt] Center point in SAM space: ({px:.1f}, {py:.1f})")

    res = run_decoder(args.decoder, emb, (px, py), (h, w), providers)

    mask = res.get("mask", None)
    iou = res.get("iou", None)
    if mask is None:
        print("[Result] Decoder ran, but mask output (256x256) not found. Check output names above.")
        sys.exit(3)

    print(f"[Result] IoU: {iou}")
    out_path = "sam_mask.png"
    save_mask(mask, out_path)
    print("[OK] End-to-end test complete.")


if __name__ == "__main__":
    main()
