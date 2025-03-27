import "package:flutter_svg/flutter_svg.dart";
import "package:flutter/material.dart";

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
      child: Column(
        children: [
          Expanded(
            child: Container(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (screenWidth >= 800)
                      SizedBox(height: 40),

                    Text(
                      "You have to upload images and videos",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24),
                    ),

                    if (screenWidth >= 800)
                      Expanded (
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: SvgPicture.asset(
                            'assets/images/media_upload.svg',
                            fit: BoxFit.contain,
                            // color: Colors.white,
                          ),
                        ),
                      ),

                    Text(
                      "jpg, jpeg, bmp, png, jfif,",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 20),
                    ),
                    Text(
                      "webp, tif, tiff, mp4, avi,",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 20),
                    ),
                    Text(
                      "mkv, mov, webm, m4v",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
