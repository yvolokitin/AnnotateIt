import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoMediaDialog extends StatefulWidget {
  final int project_id;
  final String dataset_id;

  const NoMediaDialog({
    required this.project_id,
    required this.dataset_id,
    super.key,
  });

  @override
  _NoMediaDialogState createState() => _NoMediaDialogState();
}

class _NoMediaDialogState extends State<NoMediaDialog> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (screenWidth >= 800) const SizedBox(height: 40),

                  const Text(
                    "You need to upload images or videos",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                  ),

                  if (screenWidth >= 800)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: SvgPicture.asset(
                          'assets/images/media_upload.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                  const Text(
                    "Supported images types:",
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                  const Text(
                    "jpg, jpeg, png, bmp, jfif, webp",
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: _showSupportedVideoDialog,
                    child: const Text(
                      "Click here to see which video formats are supported on your platform",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        decoration: TextDecoration.underline,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportedVideoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text("Supported Video Formats", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("🎥 Commonly Supported Formats:\n", style: TextStyle(color: Colors.white70)),
              Text("• MP4 – ✅ Android, iOS, Web, Desktop", style: TextStyle(color: Colors.white)),
              Text("• MOV – ✅ Android, iOS, macOS", style: TextStyle(color: Colors.white)),
              Text("• M4V – ✅ Android, iOS, macOS", style: TextStyle(color: Colors.white)),
              Text("• WEBM – ✅ Android, Web (browser-dependent)", style: TextStyle(color: Colors.white)),
              Text("• MKV – ⚠️ Android (partial), Windows", style: TextStyle(color: Colors.white)),
              Text("• AVI – ⚠️ Android/Windows only (partial)", style: TextStyle(color: Colors.white)),
              SizedBox(height: 12),
              Text(
                "⚠️ Support may vary depending on the platform and video codec. "
                "Some formats may not work in browsers or on iOS.",
                style: TextStyle(color: Colors.orangeAccent),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[850],
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.red, width: 2),
                ),
              ),
              child: Text(
                "Close",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        /*actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.redAccent)),
          ),
        ],*/
      ),
    );
  }
}
