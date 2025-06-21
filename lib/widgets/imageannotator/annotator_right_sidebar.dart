import 'package:flutter/material.dart';
import '../../models/annotation.dart';

class AnnotatorRightSidebar extends StatelessWidget {
  final bool collapsed;
  final List<Annotation> annotations;

  const AnnotatorRightSidebar({
    super.key,
    required this.collapsed,
    required this.annotations,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: collapsed ? 0 : 200,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        border: const Border(
          left: BorderSide(
            color: Colors.black,
            width: 2,
          ),
        ),
      ),      

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!collapsed)...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Annotations (${annotations.length})",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: annotations.length,
                itemBuilder: (context, index) {
                  final annotation = annotations[index];
                  return Text(
                    annotation.name ?? 'Unnamed',
                    style: TextStyle(
                      fontSize: 20,
                      color: annotation.color ?? Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
