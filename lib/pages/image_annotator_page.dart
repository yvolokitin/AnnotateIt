// image_annotator_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/media_item.dart';
import '../models/annotation.dart';
import '../data/annotation_database.dart';

class AnnotationRect {
  final Rect rect;
  final String label;

  AnnotationRect({required this.rect, required this.label});
}

class ImageAnnotatorPage extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;

  const ImageAnnotatorPage({super.key, required this.mediaItems, required this.initialIndex});

  @override
  State<ImageAnnotatorPage> createState() => _ImageAnnotatorPageState();
}

class _ImageAnnotatorPageState extends State<ImageAnnotatorPage> {
  late PageController _pageController;
  late int _currentIndex;
  bool _sidebarCollapsed = false;
  double _scale = 1.0;
  List<AnnotationRect> _annotations = [];
  Offset? _startPoint;
  Offset? _currentPoint;
  bool _isDrawing = false;
  String _currentLabel = "Label";

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadAnnotations();
  }

  void _loadAnnotations() async {
    final mediaId = widget.mediaItems[_currentIndex].id!;
    final loaded = await AnnotationDatabase.instance.fetchAnnotations(mediaId);
    setState(() {
      _annotations = loaded.map((a) => AnnotationRect(
        rect: Rect.fromLTWH(a.x, a.y, a.width, a.height),
        label: "Label",
      )).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMedia = widget.mediaItems[_currentIndex];
    final file = File(currentMedia.filePath);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          _buildLeftSidebar(),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.mediaItems.length,
                        onPageChanged: (index) async {
                          setState(() {
                            _currentIndex = index;
                            _annotations.clear();
                          });
                          _loadAnnotations();
                        },
                        itemBuilder: (context, index) {
                          final media = widget.mediaItems[index];
                          final file = File(media.filePath);

                          return GestureDetector(
                            onPanStart: (details) {
                              setState(() {
                                _isDrawing = true;
                                _startPoint = details.localPosition;
                                _currentPoint = _startPoint;
                              });
                            },
                            onPanUpdate: (details) {
                              setState(() {
                                _currentPoint = details.localPosition;
                              });
                            },
                            onPanEnd: (details) {
                              if (_startPoint != null && _currentPoint != null) {
                                final rect = Rect.fromPoints(_startPoint!, _currentPoint!);
                                setState(() {
                                  _annotations.add(AnnotationRect(rect: rect, label: _currentLabel));
                                  _isDrawing = false;
                                  _startPoint = null;
                                  _currentPoint = null;
                                });
                              }
                            },
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: InteractiveViewer(
                                    scaleEnabled: false,
                                    child: file.existsSync()
                                        ? Image.file(file, fit: BoxFit.contain)
                                        : Center(
                                            child: Text("File not found", style: TextStyle(color: Colors.white70)),
                                          ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _AnnotationPainter(_annotations, _startPoint, _currentPoint, _isDrawing, _currentLabel),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: _buildBottomBar(currentMedia),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildRightSidebar(),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar() {
    return Container(
      width: 60,
      color: Colors.grey[900],
      child: Column(
        children: [
          IconButton(
            icon: Icon(Icons.crop_square, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.polyline, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.select_all, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRightSidebar() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: _sidebarCollapsed ? 0 : 200,
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Annotations", style: TextStyle(color: Colors.white)),
              ),
              IconButton(
                icon: Icon(_sidebarCollapsed ? Icons.chevron_left : Icons.chevron_right, color: Colors.white),
                onPressed: () {
                  setState(() => _sidebarCollapsed = !_sidebarCollapsed);
                },
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _annotations.length,
              itemBuilder: (context, index) {
                final annotation = _annotations[index];
                return ListTile(
                  title: Text(annotation.label, style: TextStyle(color: Colors.white)),
                  subtitle: Text(annotation.rect.toString(), style: TextStyle(color: Colors.white38)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                final mediaId = widget.mediaItems[_currentIndex].id!;
                for (final ann in _annotations) {
                  final annotation = Annotation(
                    mediaItemId: mediaId,
                    labelId: 1, // TODO: dynamic label selection
                    x: ann.rect.left,
                    y: ann.rect.top,
                    width: ann.rect.width,
                    height: ann.rect.height,
                    confidence: 1.0,
                    annotator: 'admin',
                    createdAt: DateTime.now(),
                  );
                  await AnnotationDatabase.instance.insertAnnotation(annotation);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Annotations saved to database')),
                );
              },
              child: Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(MediaItem media) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Resolution: ???", style: TextStyle(color: Colors.white)),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.zoom_out, color: Colors.white),
                onPressed: () => setState(() => _scale = (_scale - 0.1).clamp(0.5, 3.0)),
              ),
              IconButton(
                icon: Icon(Icons.zoom_in, color: Colors.white),
                onPressed: () => setState(() => _scale = (_scale + 0.1).clamp(0.5, 3.0)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _AnnotationPainter extends CustomPainter {
  final List<AnnotationRect> annotations;
  final Offset? start;
  final Offset? current;
  final bool isDrawing;
  final String label;

  _AnnotationPainter(this.annotations, this.start, this.current, this.isDrawing, this.label);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var ann in annotations) {
      canvas.drawRect(ann.rect, paint);
    }

    if (isDrawing && start != null && current != null) {
      final rect = Rect.fromPoints(start!, current!);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
