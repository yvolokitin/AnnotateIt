@JS()
library sam_web_ffi;

import 'dart:async';
import 'dart:typed_data';
import 'package:js/js.dart';
import 'package:js/js_util.dart' as jsu;
import 'dart:html' as html;

@JS('SAM')
external Object? get _sam;

Future<bool> samInit({String? encoderUrl, String? decoderUrl}) async {
  final sam = _sam;
  if (sam == null) return false;
  try {
    final res = jsu.callMethod<Object?>(sam, 'init', [encoderUrl, decoderUrl]);
    final ok = await jsu.promiseToFuture(res as Object);
    return ok == true;
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
    final resP = jsu.callMethod<Object?>(sam, 'run', [
      inputNCHW,
      origW,
      origH,
      tapX1024,
      tapY1024,
    ]);
    final jsResult = await jsu.promiseToFuture<Object?>(resP as Object);

    // jsResult is a Uint8Array; convert to Dart Uint8List
    final length = jsu.getProperty(jsResult as Object, 'length') as int;
    final out = Uint8List(length);
    for (var i = 0; i < length; i++) {
      out[i] = (jsu.getProperty(jsResult, i) as num).toInt();
    }
    return out;
  } catch (e) {
    return null;
  }
}
