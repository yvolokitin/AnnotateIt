import 'dart:typed_data';
import 'dart:ui';

Rect tightBbox(Uint8List mask256, Size imgSize) {
  int minX=256, minY=256, maxX=-1, maxY=-1;
  for (int y=0;y<256;y++){
    for (int x=0;x<256;x++){
      if (mask256[y*256+x] > 0) {
        if (x<minX) minX=x; if (x>maxX) maxX=x;
        if (y<minY) minY=y; if (y>maxY) maxY=y;
      }
    }
  }
  if (maxX<0) return Rect.zero;
  final sx = imgSize.width / 256.0;
  final sy = imgSize.height / 256.0;
  return Rect.fromLTRB(minX*sx, minY*sy, (maxX+1)*sx, (maxY+1)*sy);
}

List<List<Offset>> extractPolygons(Uint8List mask256, Size imgSize) {
  final bb = tightBbox(mask256, imgSize);
  if (bb == Rect.zero) return [];
  return [[
    Offset(bb.left, bb.top),
    Offset(bb.right, bb.top),
    Offset(bb.right, bb.bottom),
    Offset(bb.left, bb.bottom),
  ]];
}
