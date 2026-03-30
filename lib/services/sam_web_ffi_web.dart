import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

@JS('SAM')
external JSObject? get _sam;

Future<bool> samInit({String? encoderUrl, String? decoderUrl}) async {
  final sam = _sam;
  if (sam == null) return false;
  try {
    final args = <JSAny?>[encoderUrl?.toJS, decoderUrl?.toJS].toJS;
    final res = sam.callMethod<JSAny?>('init'.toJS, args);
    if (res == null) return false;
    final ok = await (res as JSPromise).toDart;
    return ok.dartify() == true;
  } catch (e) {
    return false;
  }
}

Future<Uint8List?> samRun(
  Float32List inputNCHW,
  int origW,
  int origH,
  double tapX1024,
  double tapY1024,
) async {
  final sam = _sam;
  if (sam == null) return null;
  try {
    final args = <JSAny?>[
      inputNCHW.toJS,
      origW.toJS,
      origH.toJS,
      tapX1024.toJS,
      tapY1024.toJS,
    ].toJS;
    final resP = sam.callMethod<JSAny?>('run'.toJS, args);
    if (resP == null) return null;
    final jsResult = await (resP as JSPromise).toDart;
    if (jsResult == null) return null;

    final jsArray = jsResult as JSUint8Array;
    return jsArray.toDart;
  } catch (e) {
    return null;
  }
}
