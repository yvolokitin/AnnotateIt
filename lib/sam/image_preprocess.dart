import 'dart:typed_data';
import 'dart:ui';

class ImageData {
  final int width, height;
  final Uint8List rgbBytes;
  ImageData(this.width, this.height, this.rgbBytes);
}

class PreprocessResult {
  final Float32List tensor;
  PreprocessResult(this.tensor);
}

PreprocessResult preprocessToSamInput(ImageData img) {
  const int S = 1024;
  final scale = (img.width >= img.height) ? S / img.width : S / img.height;
  final newW = (img.width * scale).round();
  final newH = (img.height * scale).round();
  final resized = _resizeBilinear(img.rgbBytes, img.width, img.height, newW, newH);
  final out = Float32List(1*3*S*S);
  final padX = (S - newW) ~/ 2;
  final padY = (S - newH) ~/ 2;

  for (int y=0; y<S; y++) {
    for (int x=0; x<S; x++) {
      int rx = x - padX, ry = y - padY;
      int r=0,g=0,b=0;
      if (rx>=0 && rx<newW && ry>=0 && ry<newH) {
        final p = (ry*newW + rx)*3;
        r = resized[p]; g = resized[p+1]; b = resized[p+2];
      }
      final fr = r/255.0, fg = g/255.0, fb = b/255.0;
      out[0*S*S + y*S + x] = fr;
      out[1*S*S + y*S + x] = fg;
      out[2*S*S + y*S + x] = fb;
    }
  }
  return PreprocessResult(out);
}

Uint8List _resizeBilinear(Uint8List src, int w, int h, int nw, int nh) {
  final dst = Uint8List(nw*nh*3);
  final xRatio = (w-1)/nw;
  final yRatio = (h-1)/nh;
  for (int j=0;j<nh;j++){
    for (int i=0;i<nw;i++){
      final x = xRatio*i;
      final y = yRatio*j;
      final xL = x.floor(), yT = y.floor();
      final xH = (xL+1).clamp(0, w-1);
      final yB = (yT+1).clamp(0, h-1);
      final xWeight = x - xL;
      final yWeight = y - yT;
      for (int c=0;c<3;c++){
        int idxTL = (yT*w + xL)*3 + c;
        int idxTR = (yT*w + xH)*3 + c;
        int idxBL = (yB*w + xL)*3 + c;
        int idxBR = (yB*w + xH)*3 + c;
        final top = src[idxTL]*(1-xWeight) + src[idxTR]*xWeight;
        final bot = src[idxBL]*(1-xWeight) + src[idxBR]*xWeight;
        final val = top*(1-yWeight) + bot*yWeight;
        dst[(j* nw + i)*3 + c] = val.round().clamp(0,255);
      }
    }
  }
  return dst;
}

Offset Function(double,double) buildToSamSpace(int w, int h) {
  const int S = 1024;
  final scale = (w >= h) ? S / w : S / h;
  final newW = w*scale, newH = h*scale;
  final padX = (S - newW)/2.0, padY = (S - newH)/2.0;
  return (double x, double y) => Offset(x*scale + padX, y*scale + padY);
}
