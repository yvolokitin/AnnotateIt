// Copyright (C) 2022-2025 Intel Corporation
// LIMITED EDGE SOFTWARE DISTRIBUTION LICENSE

export const SegmentAnythingModels = {
    encoder: new URL('./mobile_sam.encoder.onnx', import.meta.url).toString(),
    decoder: new URL('./mobile_sam.decoder.onnx', import.meta.url).toString(),
};
