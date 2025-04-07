import 'package:flutter/material.dart';

class TaskTypeGrid extends StatelessWidget {
  final List<Map<String, String>> tasks;
  final String selectedTaskType;
  final ValueChanged<String> onTaskSelected;

  const TaskTypeGrid({
    Key? key,
    required this.tasks,
    required this.selectedTaskType,
    required this.onTaskSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        int crossAxisCount = (maxWidth / 300).floor().clamp(1, 3);
        return GridView.builder(
          padding: EdgeInsets.only(top: 16),
          itemCount: tasks.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _TaskOptionCard(
              title: task['title']!,
              description: task['description']!,
              imagePath: task['image']!,
              selected: selectedTaskType == task['title'],
              onSelected: () => onTaskSelected(task['title']!),
            );
          },
        );
      },
    );
  }
}

class _TaskOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final bool selected;
  final VoidCallback onSelected;

  const _TaskOptionCard({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.red : Colors.grey[700]!,
            width: 2,
          ),
        ),
        clipBehavior: Clip.hardEdge, // ensures image corners follow card radius
        child: Column(
          children: [
            // Image section (70% height, 100% width, no padding)
            Expanded(
              flex: 7,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // Text + radio section (30% height)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Radio<String>(
                      value: title,
                      groupValue: selected ? title : '',
                      onChanged: (_) => onSelected(),
                      activeColor: Colors.red,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
