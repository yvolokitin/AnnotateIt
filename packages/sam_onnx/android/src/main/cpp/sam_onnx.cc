#include "onnxruntime_cxx_api.h"
#include <vector>
#include <cstring>

static Ort::Env* g_env = nullptr;
static Ort::SessionOptions* g_so = nullptr;

extern "C" {

__attribute__((visibility("default"))) int sam_init(int provider) {
  try {
    if (!g_env) g_env = new Ort::Env(ORT_LOGGING_LEVEL_WARNING, "sam");
    if (!g_so) {
      g_so = new Ort::SessionOptions();
      g_so->SetIntraOpNumThreads(1);
      g_so->SetGraphOptimizationLevel(ORT_ENABLE_BASIC);
      if (provider == 2 || provider == -1) {
        try { OrtSessionOptionsAppendExecutionProvider_Nnapi(*g_so, 0); }
        catch (...) { /* fallback */ }
      }
    }
    return 0;
  } catch (...) { return -1; }
}

static Ort::Session* make_session(const char* path) {
  return new Ort::Session(*g_env, path, *g_so);
}

__attribute__((visibility("default"))) void* sam_create_encoder_session(const char* model_path) {
  try { return (void*)make_session(model_path); } catch (...) { return nullptr; }
}

__attribute__((visibility("default"))) void* sam_create_decoder_session(const char* model_path) {
  try { return (void*)make_session(model_path); } catch (...) { return nullptr; }
}

__attribute__((visibility("default"))) int sam_run_encoder(void* sess_ptr, float* img_chw, float* out_embedding) {
  try {
    Ort::Session* s = (Ort::Session*)sess_ptr;
    Ort::MemoryInfo mem = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);
    std::vector<int64_t> inShape{1,3,1024,1024};
    Ort::Value input = Ort::Value::CreateTensor<float>(mem, img_chw, (size_t)(1*3*1024*1024), inShape.data(), inShape.size());
    const char* inNames[] = {"image"};

    std::vector<float> outputBuf(1*256*64*64);
    std::vector<int64_t> outShape{1,256,64,64};
    Ort::Value output = Ort::Value::CreateTensor<float>(mem, outputBuf.data(), outputBuf.size(), outShape.data(), outShape.size());
    const char* outNames[] = {"image_embeddings"};

    s->Run(Ort::RunOptions{nullptr}, inNames, &input, 1, outNames, &output, 1);
    memcpy(out_embedding, outputBuf.data(), outputBuf.size()*sizeof(float));
    return 0;
  } catch (...) { return -1; }
}

__attribute__((visibility("default"))) int sam_run_decoder(
  void* sess_ptr, float* embedding,
  float* point_coords, int* point_labels, int n_points,
  float* box4, int has_box,
  float* prev_mask, int has_prev,
  int orig_h, int orig_w,
  unsigned char* out_mask256, float* out_iou
) {
  try {
    Ort::Session* s = (Ort::Session*)sess_ptr;
    Ort::MemoryInfo mem = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);

    auto makeTensorF = [&](float* data, const std::vector<int64_t>& shape){
      size_t total = 1; for (auto d: shape) total*=d;
      return Ort::Value::CreateTensor<float>(mem, data, total, shape.data(), shape.size());
    };
    auto makeTensorI = [&](int32_t* data, const std::vector<int64_t>& shape){
      size_t total = 1; for (auto d: shape) total*=d;
      return Ort::Value::CreateTensor<int32_t>(mem, data, total, shape.data(), shape.size());
    };

    std::vector<int64_t> embShape{1,256,64,64};
    Ort::Value emb = makeTensorF(embedding, embShape);

    std::vector<int64_t> pcShape{1, (int64_t)n_points, 2};
    Ort::Value pc = makeTensorF(point_coords, pcShape);

    std::vector<int64_t> plShape{1, (int64_t)n_points};
    Ort::Value pl = makeTensorI((int32_t*)point_labels, plShape);

    std::vector<float> zeroMask(256*256, 0.f);
    float* maskPtr = has_prev ? prev_mask : zeroMask.data();
    int64_t hasMaskArr[1] = { has_prev ? 1 : 0 };

    std::vector<int64_t> miShape{1,1,256,256};
    Ort::Value mi = makeTensorF(maskPtr, miShape);
    Ort::Value hmi = Ort::Value::CreateTensor<int64_t>(mem, hasMaskArr, 1, (int64_t[]){1}, 1);

    int64_t origArr[2] = { (int64_t)orig_h, (int64_t)orig_w };
    Ort::Value orig = Ort::Value::CreateTensor<int64_t>(mem, origArr, 2, (int64_t[]){2}, 1);

    std::vector<const char*> names;
    std::vector<Ort::Value> vals;

    names.push_back("image_embeddings"); vals.push_back(std::move(emb));
    names.push_back("point_coords");     vals.push_back(std::move(pc));
    names.push_back("point_labels");     vals.push_back(std::move(pl));
    names.push_back("mask_input");       vals.push_back(std::move(mi));
    names.push_back("has_mask_input");   vals.push_back(std::move(hmi));
    names.push_back("orig_im_size");     vals.push_back(std::move(orig));

    std::vector<float> boxData(4, 0.f);
    if (has_box) {
      memcpy(boxData.data(), box4, 4*sizeof(float));
      std::vector<int64_t> bShape{1,4};
      Ort::Value b = makeTensorF(boxData.data(), bShape);
      names.push_back("boxes"); vals.push_back(std::move(b));
    }

    std::vector<float> outMask(1*1*256*256);
    std::vector<int64_t> omShape{1,1,256,256};
    Ort::Value om = makeTensorF(outMask.data(), omShape);

    std::vector<float> outIou(1);
    std::vector<int64_t> oiShape{1,1};
    Ort::Value oi = makeTensorF(outIou.data(), oiShape);

    const char* outNames[] = {"low_res_masks","iou_predictions"};
    std::vector<const char*> inNames = names;

    s->Run(Ort::RunOptions{nullptr}, inNames.data(), vals.data(), (size_t)inNames.size(),
           outNames, (Ort::Value*[]){ &om, &oi }, 2);

    for (size_t i=0;i<256*256;i++) {
      float v = outMask[i];
      out_mask256[i] = (unsigned char)(v > 0.0f ? 255 : 0);
    }
    *out_iou = outIou[0];
    return 0;
  } catch (...) { return -1; }
}

}
