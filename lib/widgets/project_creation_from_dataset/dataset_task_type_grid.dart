import 'package:flutter/material.dart';

class DatasetTaskTypeGrid extends StatelessWidget {
  final String? selectedTaskType;
  final ValueChanged<String> onTaskSelected;
  final List<Map<String, String>> tasks;
  final int? maxCrossAxisCount;
  final double? aspectRatio;
  final double imageAspectRatio;

  const DatasetTaskTypeGrid({
    super.key,
    this.selectedTaskType,
    required this.onTaskSelected,
    required this.tasks,
    this.maxCrossAxisCount,
    this.aspectRatio,
    this.imageAspectRatio = 16 / 9,
  });

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid calculation
        final width = constraints.maxWidth;
        final crossAxisCount = maxCrossAxisCount ?? 
            (width > 1200 ? 3 : width > 600 ? 2 : 1);
            
        return GridView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: aspectRatio ?? (width > 600 ? 1 : 1.2),
          ),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final isSelected = selectedTaskType == task['title'];
            
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                    ? Colors.deepOrangeAccent
                    : Colors.grey[800]!,
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onTaskSelected(task['title']!),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: imageAspectRatio,
                      child: Image.asset(
                        task['image']!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                                size: 20,
                                color: isSelected 
                                  ? Colors.deepOrangeAccent 
                                  : Colors.white70,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task['title']!,
                                  style: TextStyle(
                                    fontSize: width>1200 ? 20 : 18,
                                    fontFamily: 'CascadiaCode',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task['description']!,
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'CascadiaCode',
                              fontSize: width>1200 ? 16 : 10,
                            ),
                            maxLines: width > 600 ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}