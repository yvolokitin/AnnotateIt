#include <windows.h>
#include <string>
#include <vector>
#include <cstring>
#include <memory>
#include "onnxruntime_cxx_api.h"

static std::unique_ptr<Ort::Env> g_env;
static std::unique_ptr<Ort::SessionOptions> g_so;

static std::wstring ToW(const char* utf8) {
  if (!utf8) return L"";
  int wlen = MultiByteToWideChar(CP_UTF8, 0, utf8, -1, nullptr, 0);
  std::wstring w; w.resize(wlen ? wlen-1 : 0);
  if (wlen > 1) MultiByteToWideChar(CP_UTF8, 0, utf8, -1, &w[0], wlen);
  return w;
}

extern "C" {

// provider: -1 auto, 0 cpu, 1 directml (игнорируем в CPU-сборке)
__declspec(dllexport) int sam_init(int /*provider*/) {
  try {
    if (!g_env)  g_env  = std::make_unique<Ort::Env>(ORT_LOGGING_LEVEL_WARNING, "sam");
    if (!g_so) {
      g_so = std::make_unique<Ort::SessionOptions>();
      g_so->SetIntraOpNumThreads(1);
      g_so->SetInterOpNumThreads(1);
      g_so->SetGraphOptimizationLevel(ORT_ENABLE_BASIC);
      // В CPU билде нет DML. Добавим позже через GetProcAddress, если нужен.
    }
    return 0;
  } catch (...) { return -1; }
}

static Ort::Session* make_session(const char* model_path_utf8) {
  auto wpath = ToW(model_path_utf8); // ORTCHAR_T = wchar_t на Windows
  return new Ort::Session(*g_env, wpath.c_str(), *g_so);
}

__declspec(dllexport) void* sam_create_encoder_session(const char* model_path) {
  try { return (void*)make_session(model_path); } catch (...) { return nullptr; }
}

__declspec(dllexport) void* sam_create_decoder_session(const char* model_path) {
  try { return (void*)make_session(model_path); } catch (...) { return nullptr; }
}

// Encoder: input "image" 1x3x1024x1024 float -> output "image_embeddings" 1x256x64x64 float
__declspec(dllexport) int sam_run_encoder(void* sess_ptr, float* img_chw, float* out_embedding) {
  try {
    Ort::Session& s = *(Ort::Session*)sess_ptr;
    Ort::MemoryInfo mem = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);

    const int64_t inShape[4]  = {1,3,1024,1024};
    Ort::Value input = Ort::Value::CreateTensor<float>(mem, img_chw, (size_t)(1*3*1024*1024), inShape, 4);
    const char* inNames[1] = {"image"};

    // Подготовим выход как «пустышку» — ORT его заполнит
    // (в C++ API можно передавать только имена выходов; значения он вернёт)
    const char* outNames[1] = {"image_embeddings"};
    auto outputs = s.Run(Ort::RunOptions{nullptr}, inNames, &input, 1, outNames, 1);
    // outputs[0] — это тензор с эмбеддингом
    float* embData = outputs[0].GetTensorMutableData<float>();
    std::memcpy(out_embedding, embData, sizeof(float) * (1*256*64*64));
    return 0;
  } catch (...) { return -1; }
}

// Decoder I/O по MobileSAM: см. комментарии в коде
__declspec(dllexport) int sam_run_decoder(
  void* sess_ptr, float* embedding,
  float* point_coords, int* point_labels, int n_points,
  float* box4, int has_box,
  float* prev_mask, int has_prev,
  int orig_h, int orig_w,
  unsigned char* out_mask256, float* out_iou
) {
  try {
    Ort::Session& s = *(Ort::Session*)sess_ptr;
    Ort::MemoryInfo mem = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);

    // ---- Inputs ----
    const int64_t embShape[4] = {1,256,64,64};
    Ort::Value emb = Ort::Value::CreateTensor<float>(mem, embedding, (size_t)(1*256*64*64), embShape, 4);

    std::vector<float> pcBuf((size_t)n_points * 2);
    std::memcpy(pcBuf.data(), point_coords, sizeof(float)*pcBuf.size());
    const int64_t pcShape[3] = {1, (int64_t)n_points, 2};
    Ort::Value pc = Ort::Value::CreateTensor<float>(mem, pcBuf.data(), pcBuf.size(), pcShape, 3);

    std::vector<int32_t> plBuf((size_t)n_points);
    for (int i=0;i<n_points;i++) plBuf[i] = (int32_t)point_labels[i];
    const int64_t plShape[2] = {1, (int64_t)n_points};
    Ort::Value pl = Ort::Value::CreateTensor<int32_t>(mem, plBuf.data(), plBuf.size(), plShape, 2);

    std::vector<float> maskBuf(256*256, 0.f);
    if (has_prev) std::memcpy(maskBuf.data(), prev_mask, sizeof(float)*256*256);
    const int64_t miShape[4] = {1,1,256,256};
    Ort::Value mi = Ort::Value::CreateTensor<float>(mem, maskBuf.data(), maskBuf.size(), miShape, 4);

    int64_t hasMaskArr[1] = { has_prev ? 1 : 0 };
    const int64_t oneDim[1] = {1};
    Ort::Value hmi = Ort::Value::CreateTensor<int64_t>(mem, hasMaskArr, 1, oneDim, 1);

    int64_t origArr[2] = { (int64_t)orig_h, (int64_t)orig_w };
    const int64_t twoDim[1] = {2};
    Ort::Value orig = Ort::Value::CreateTensor<int64_t>(mem, origArr, 2, twoDim, 1);

    std::vector<const char*> inNames;
    std::vector<Ort::Value> inVals;

    inNames.push_back("image_embeddings"); inVals.push_back(std::move(emb));
    inNames.push_back("point_coords");     inVals.push_back(std::move(pc));
    inNames.push_back("point_labels");     inVals.push_back(std::move(pl));
    inNames.push_back("mask_input");       inVals.push_back(std::move(mi));
    inNames.push_back("has_mask_input");   inVals.push_back(std::move(hmi));
    inNames.push_back("orig_im_size");     inVals.push_back(std::move(orig));

    std::vector<float> boxData(4, 0.f);
    if (has_box) {
      std::memcpy(boxData.data(), box4, sizeof(float)*4);
      const int64_t bShape[2] = {1,4};
      Ort::Value b = Ort::Value::CreateTensor<float>(mem, boxData.data(), 4, bShape, 2);
      inNames.push_back("boxes"); inVals.push_back(std::move(b));
    }

    // ---- Outputs ----
    const char* outNames[2] = {"low_res_masks","iou_predictions"};
    auto outs = s.Run(Ort::RunOptions{nullptr},
                      inNames.data(), inVals.data(), (size_t)inNames.size(),
                      outNames, 2);

    // outs[0]: 1x1x256x256 float
    float* maskF = outs[0].GetTensorMutableData<float>();
    for (size_t i=0;i<256u*256u;i++) {
      float v = maskF[i];
      out_mask256[i] = static_cast<unsigned char>(v > 0.0f ? 255 : 0);
    }
    // outs[1]: 1x1 float
    float* iouF = outs[1].GetTensorMutableData<float>();
    *out_iou = iouF[0];
    return 0;
  } catch (...) { return -1; }
}

} // extern "C"
