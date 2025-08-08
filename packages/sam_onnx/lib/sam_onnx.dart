library sam_onnx;

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

enum SamProvider { auto, cpu, directml, nnapi }

class _Native {
  static DynamicLibrary _lib() {
    if (Platform.isWindows) return DynamicLibrary.open('sam_onnx.dll');
    if (Platform.isAndroid) return DynamicLibrary.open('libsam_onnx.so');
    if (Platform.isLinux) return DynamicLibrary.open('libsam_onnx.so');
    if (Platform.isMacOS) return DynamicLibrary.open('libsam_onnx.dylib');
    if (Platform.isIOS) return DynamicLibrary.process();
    throw UnsupportedError('Platform not supported');
  }

  static final DynamicLibrary lib = _lib();

  static final _samInit = lib.lookupFunction<
      Int32 Function(Int32), int Function(int)>('sam_init');

  static final _samCreateEncoder =
      lib.lookupFunction<Pointer<Void> Function(Pointer<Utf8>), Pointer<Void> Function(Pointer<Utf8>)>('sam_create_encoder_session');
  static final _samCreateDecoder =
      lib.lookupFunction<Pointer<Void> Function(Pointer<Utf8>), Pointer<Void> Function(Pointer<Utf8>)>('sam_create_decoder_session');

  static final _samRunEncoder = lib.lookupFunction<
      Int32 Function(Pointer<Void>, Pointer<Float>, Pointer<Float>),
      int Function(Pointer<Void>, Pointer<Float>, Pointer<Float>)>('sam_run_encoder');

  static final _samRunDecoder = lib.lookupFunction<
      Int32 Function(
          Pointer<Void>, Pointer<Float>,
          Pointer<Float>, Pointer<Int32>, Int32,
          Pointer<Float>, Int32,
          Pointer<Float>, Int32,
          Int32, Int32,
          Pointer<Uint8>, Pointer<Float>
      ),
      int Function(
          Pointer<Void>, Pointer<Float>,
          Pointer<Float>, Pointer<Int32>, int,
          Pointer<Float>, int,
          Pointer<Float>, int,
          int, int,
          Pointer<Uint8>, Pointer<Float>
      )>('sam_run_decoder');
}

class SamOnnx {
  SamOnnx._();
  static final SamOnnx instance = SamOnnx._();

  Pointer<Void>? _encoder;
  Pointer<Void>? _decoder;

  Future<void> init({
    required String encoderPath,
    required String decoderPath,
    SamProvider provider = SamProvider.auto,
  }) async {
    final prov = switch (provider) {
      SamProvider.cpu => 0,
      SamProvider.directml => 1,
      SamProvider.nnapi => 2,
      SamProvider.auto => -1,
    };
    final rc = _Native._samInit(prov);
    if (rc != 0) {
      throw Exception('sam_init failed rc=$rc');
    }
    _encoder = _Native._samCreateEncoder(encoderPath.toNativeUtf8());
    _decoder = _Native._samCreateDecoder(decoderPath.toNativeUtf8());
    if (_encoder == nullptr || _decoder == nullptr) {
      throw Exception('Failed to create encoder/decoder sessions');
    }
  }

  Future<void> dispose() async {}

  Float32List runEncoder(Float32List imageCHWFloat) {
    final imgPtr = calloc<Float>(imageCHWFloat.length);
    imgPtr.asTypedList(imageCHWFloat.length).setAll(0, imageCHWFloat);
    final out = calloc<Float>(256 * 64 * 64);
    final rc = _Native._samRunEncoder(_encoder!, imgPtr, out);
    calloc.free(imgPtr);
    if (rc != 0) {
      calloc.free(out);
      throw Exception('sam_run_encoder failed rc=$rc');
    }
    final result = Float32List.fromList(out.asTypedList(256 * 64 * 64));
    calloc.free(out);
    return result;
  }

  (Uint8List, double) runDecoder({
    required Float32List embedding,
    required Float32List points,
    required Int32List labels,
    Float32List? box,
    Float32List? prevMask,
    required int origH,
    required int origW,
  }) {
    final emb = calloc<Float>(embedding.length)..asTypedList(embedding.length).setAll(0, embedding);
    final pts = calloc<Float>(points.length)..asTypedList(points.length).setAll(0, points);
    final lbs = calloc<Int32>(labels.length)..asTypedList(labels.length).setAll(0, labels);
    final hasBox = box != null ? 1 : 0;
    final bx = calloc<Float>(4);
    if (box != null) bx.asTypedList(4).setAll(0, box!);
    final hasPrev = prevMask != null ? 1 : 0;
    final prev = calloc<Float>(256*256);
    if (prevMask != null) prev.asTypedList(256*256).setAll(0, prevMask!);

    final outMask = calloc<Uint8>(256*256);
    final outIou = calloc<Float>(1);

    final rc = _Native._samRunDecoder(
      _decoder!, emb, pts, lbs, labels.length,
      bx, hasBox, prev, hasPrev, origH, origW, outMask, outIou
    );

    calloc.free(emb); calloc.free(pts); calloc.free(lbs); calloc.free(bx); calloc.free(prev);
    if (rc != 0) {
      calloc.free(outMask); calloc.free(outIou);
      throw Exception('sam_run_decoder failed rc=$rc');
    }
    final mask = Uint8List.fromList(outMask.asTypedList(256*256));
    final iou = outIou.value;
    calloc.free(outMask); calloc.free(outIou);
    return (mask, iou);
  }
}
