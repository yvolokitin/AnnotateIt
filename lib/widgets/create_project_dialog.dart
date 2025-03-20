import 'package:flutter/material.dart';
// import 'edit_labels_dialog.dart'; // Previous step
import 'label_selection_dialog.dart'; // Next step

class CreateProjectDialog extends StatefulWidget {
  @override
  _CreateProjectDialogState createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late TabController _tabController;
  String _selectedTaskType = "Detection bounding box"; // Default selection

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // 5 tabs for project types
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double dialogWidth = MediaQuery.of(context).size.width * 0.9; // ✅ 80% of window width
    double dialogHeight = MediaQuery.of(context).size.height * 0.9; // ✅ 80% of window height

    return Dialog(
      backgroundColor: Colors.grey[900], // Dark background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        padding: EdgeInsets.all(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 📌 Title Section
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("New Project Creation", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 4),
                  Text("Please, enter your new project name and select Project type", style: TextStyle(fontSize: 22, color: Colors.white70)),
                ],
              ),
            ),
            SizedBox(height: 26),

            // 📌 Project Name Input Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Project Name", filled: true, fillColor: Colors.grey[850]),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 26),

            // 📌 Tabs for Project Types
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: "Detection"),
                Tab(text: "Segmentation"),
                Tab(text: "Classification"),
                Tab(text: "Anomaly"),
                Tab(text: "Chained tasks"),
              ],
            ),
            SizedBox(height: 16),

            // 📌 Scrollable Content Area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 📌 Task Type Selection Cards
                    _buildTaskTypeSelection(),
                  ],
                ),
              ),
            ),

            // 📌 Bottom Navigation Buttons
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: TextStyle(color: Colors.white70)),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Back", style: TextStyle(color: Colors.white70)),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close current step
                          showDialog(
                            context: context,
                            builder: (context) => LabelSelectionDialog(
                              projectName: _nameController.text,
                              projectType: _selectedTaskType,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text("Next", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📌 Task Type Selection Cards
  Widget _buildTaskTypeSelection() {
    return Row(
      children: [
        Expanded(child: _buildTaskOption("Detection bounding box", "Draw a rectangle around an object in an image.", true)),
        SizedBox(width: 16),
        Expanded(child: _buildTaskOption("Detection oriented", "Draw and enclose an object within a minimal rectangle.", false)),
      ],
    );
  }

  // 📌 Single Selection Card
  Widget _buildTaskOption(String title, String description, bool isLeft) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTaskType = title;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850], // Darker box
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _selectedTaskType == title ? Colors.blueAccent : Colors.transparent,
            width: 2,
          ),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Image.asset(
              isLeft ? 'assets/images/detection_bounding_box.png' : 'assets/images/detection_oriented.png', // Example images
              height: 100,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Radio<String>(
                  value: title,
                  groupValue: _selectedTaskType,
                  onChanged: (value) {
                    setState(() {
                      _selectedTaskType = value!;
                    });
                  },
                  activeColor: Colors.blueAccent,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 4),
                      Text(description, style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
