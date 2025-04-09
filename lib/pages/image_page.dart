import 'dart:io';
import 'package:flutter/material.dart';
import '../models/media_item.dart';

class ImagePage extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;

  const ImagePage({super.key, required this.mediaItems, required this.initialIndex});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.mediaItems[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(current.filePath.split('/').last, style: TextStyle(color: Colors.white70)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white70),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              // TODO: implement delete or annotation action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.mediaItems.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final media = widget.mediaItems[index];
                final file = File(media.filePath);

                return InteractiveViewer(
                  child: file.existsSync()
                      ? Image.file(file, fit: BoxFit.contain)
                      : Center(
                          child: Text("File not found", style: TextStyle(color: Colors.white70)),
                        ),
                );
              },
            ),
          ),
          Container(
            height: 100,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.mediaItems.length,
              itemBuilder: (context, index) {
                final media = widget.mediaItems[index];
                final file = File(media.filePath);

                return GestureDetector(
                  onTap: () {
                    _pageController.jumpToPage(index);
                    setState(() => _currentIndex = index);
                  },
                  child: Container(
                    margin: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: index == _currentIndex ? Colors.blueAccent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: file.existsSync()
                        ? Image.file(file, width: 80, height: 80, fit: BoxFit.cover)
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[800],
                            child: Icon(Icons.broken_image, color: Colors.white24),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
