// sam_smoke.c
#include <stdio.h>
#include <stdint.h>
#ifdef _WIN32
#include <windows.h>
#endif

typedef int32_t (*PFN_sam_init)(int32_t);
typedef void*   (*PFN_sam_create_encoder_session)(const char*);
typedef int32_t (*PFN_sam_run_encoder)(void*, const float*, float*);

int main(int argc, char** argv){
  const char* dll = "sam_onnx.dll";
  const char* enc = "C:\\repos\\AnnotateIt\\assets\\models_sam\\mobile_sam.encoder.onnx";

#ifdef _WIN32
  HMODULE h = LoadLibraryA(dll);
  if(!h){ printf("LoadLibrary failed\n"); return 1; }
  PFN_sam_init sam_init = (PFN_sam_init)GetProcAddress(h, "sam_init");
  PFN_sam_create_encoder_session sam_create_encoder =
      (PFN_sam_create_encoder_session)GetProcAddress(h, "sam_create_encoder_session");
  PFN_sam_run_encoder sam_run_encoder =
      (PFN_sam_run_encoder)GetProcAddress(h, "sam_run_encoder");
#endif

  if(!sam_init || !sam_create_encoder || !sam_run_encoder){ printf("lookup failed\n"); return 2; }

  // 1) init CPU (поменяй на -1, 0, 1 по очереди)
  int rc = sam_init(0);
  printf("sam_init rc=%d\n", rc);

  // 2) make session
  void* enc_sess = sam_create_encoder(enc);
  if(!enc_sess){ printf("encoder session null\n"); return 3; }

  // 3) zeros in, embedding out
  float* in  = (float*)calloc(1*3*1024*1024, sizeof(float));
  float* out = (float*)calloc(256*64*64, sizeof(float));
  rc = sam_run_encoder(enc_sess, in, out);
  printf("sam_run_encoder rc=%d, out0=%f\n", rc, out[0]);
  return 0;
}
