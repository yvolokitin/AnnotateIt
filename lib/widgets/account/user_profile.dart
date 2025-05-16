import 'package:flutter/material.dart';
import '../../data/project_database.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Expanded(flex: 2, child: _TopPortion()),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Captain Annotator",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () {},
                        elevation: 0,
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        label: const Text("Feedback", style: TextStyle(fontSize: 22)),
                        icon: const Icon(Icons.feedback_outlined),
                      ),
                      const SizedBox(width: 16.0),
                      FloatingActionButton.extended(
                        onPressed: () {},
                        elevation: 0,
                        backgroundColor: Colors.redAccent,
                        label: const Text("Edit Profile", style: TextStyle(fontSize: 22)),
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _ProfileInfoRow()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPortion extends StatelessWidget {
  const _TopPortion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color.fromARGB(255, 66, 66, 66), Color.fromARGB(255, 66, 66, 66)],
              // colors: [Color.fromARGB(255, 244, 67, 54), Color.fromARGB(255, 66, 66, 66)],

            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // border: Border.all(color: const Color.fromARGB(255, 244, 67, 54), width: 6),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/icons/avataaars.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoRow extends StatefulWidget {
  const _ProfileInfoRow({Key? key}) : super(key: key);

  @override
  State<_ProfileInfoRow> createState() => _ProfileInfoRowState();
}

class _ProfileInfoRowState extends State<_ProfileInfoRow> {
  int? projectCount;
  int? mediaCount;
  int? annotationCount;
  int? labelCount;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final db = ProjectDatabase.instance;
    final projects = await db.getProjectCount();
    final media = await db.getMediaCount();
    final annotations = await db.getAnnotationCount();
    final labels = await db.getLabelCount();

    setState(() {
      projectCount = projects;
      mediaCount = media;
      annotationCount = annotations;
      labelCount = labels;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ProfileInfoItem("Projects", projectCount),
      ProfileInfoItem("Labels", labelCount),
      ProfileInfoItem("Media", mediaCount),
      ProfileInfoItem("Annotations", annotationCount),
    ];

    return Container(
      height: 100,
      constraints: const BoxConstraints(maxWidth: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items
            .map((item) => Expanded(
                  child: Row(
                    children: [
                      if (items.indexOf(item) != 0) const VerticalDivider(),
                      Expanded(child: _singleItem(context, item)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _singleItem(BuildContext context, ProfileInfoItem item) {
    final isLoading = item.value == null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  item.value.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
        ),
        Text(
          item.title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 16.8),
        ),
      ],
    );
  }
}

class ProfileInfoItem {
  final String title;
  final int? value;
  const ProfileInfoItem(this.title, this.value);
}
