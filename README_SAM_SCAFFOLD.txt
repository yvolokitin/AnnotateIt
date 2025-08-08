Extract at the root of your repo (AnnotateIt/).

Add to AnnotateIt's pubspec.yaml:
dependencies:
  sam_onnx:
    path: packages/sam_onnx

Windows build (shim -> sam_onnx.dll):
  cd packages/sam_onnx/windows
  cmake -S . -B build -A x64
  cmake --build build --config Release
  copy build/Release/sam_onnx.dll to your Flutter EXE folder

Android:
  Place libonnxruntime.so under android/app/src/main/jniLibs/<abi>/
  Build sam_onnx.so for same ABIs and place under jniLibs too.
