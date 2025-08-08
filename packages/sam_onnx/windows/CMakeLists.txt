cmake_minimum_required(VERSION 3.15)
project(sam_onnx_win LANGUAGES CXX)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

add_library(sam_onnx SHARED sam_onnx.cc)
target_compile_features(sam_onnx PRIVATE cxx_std_17)

# Укажи путь к распакованному ORT (где есть include/ и lib/)
if (NOT DEFINED ORT_ROOT)
  set(ORT_ROOT "C:/repos/onnxruntime-win-x64-1.20.1")
endif()

target_include_directories(sam_onnx PRIVATE "${ORT_ROOT}/include")

# 🔴 ВАЖНО: ссылаемся на .lib ПОЛНЫМ ПУТЁМ
target_link_libraries(sam_onnx PRIVATE "${ORT_ROOT}/lib/onnxruntime.lib")

# (опционально) скопировать DLL рядом с sam_onnx.dll после сборки
add_custom_command(TARGET sam_onnx POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${ORT_ROOT}/lib/onnxruntime.dll" $<TARGET_FILE_DIR:sam_onnx>
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${ORT_ROOT}/lib/onnxruntime_providers_shared.dll" $<TARGET_FILE_DIR:sam_onnx>
)
