import onnxruntime as ort
import numpy as np
import cv2

# === 1. Load and prepare input image ===
image = cv2.imread("test.jpg")
if image is None:
    raise FileNotFoundError("Make sure 'test.jpg' is in the same folder!")

image = cv2.resize(image, (1024, 1024))
image = image.astype(np.float32) / 255.0
image = image.transpose(2, 0, 1)[np.newaxis, :]  # [1, 3, 1024, 1024]

# === 2. Load encoder and inspect outputs ===
encoder_session = ort.InferenceSession("sam2_hiera_small.encoder.onnx", providers=["CPUExecutionProvider"])

print("Encoder model outputs:")
for output in encoder_session.get_outputs():
    print(f"- {output.name} : {output.shape} ({output.type})")

# Run encoder
encoder_outputs = encoder_session.run(None, {"image": image})
print("✅ Encoder inference OK")

# Extract individual outputs
high_res_feats_0 = encoder_outputs[0]
high_res_feats_1 = encoder_outputs[1]
image_embed      = encoder_outputs[2]

# === 3. Load decoder and inspect inputs ===
decoder_session = ort.InferenceSession("sam2_hiera_small.decoder.onnx", providers=["CPUExecutionProvider"])

print("\nDecoder model inputs:")
for input in decoder_session.get_inputs():
    print(f"- {input.name} : {input.shape} ({input.type})")

# === 4. Prepare point prompt ===
point_coords = np.array([[[512.0, 512.0]]], dtype=np.float32)  # [1, 1, 2]
point_labels = np.array([[1]], dtype=np.float32)               # [1, 1] — must be float!
has_mask_input = np.array([0.0], dtype=np.float32)             # [1]
mask_input = np.zeros((1, 1, 256, 256), dtype=np.float32)      # [1, 1, 256, 256]

# === 5. Run decoder inference ===
outputs = decoder_session.run(None, {
    "image_embed": image_embed,
    "high_res_feats_0": high_res_feats_0,
    "high_res_feats_1": high_res_feats_1,
    "point_coords": point_coords,
    "point_labels": point_labels,
    "mask_input": mask_input,
    "has_mask_input": has_mask_input
})

mask = outputs[0][0, 0]  # [256, 256]

print("✅ Decoder inference OK")

# === 6. Save mask to file ===
cv2.imwrite("mask_output.png", (mask > 0.5).astype(np.uint8) * 255)
print("✅ Mask saved as 'mask_output.png'")
