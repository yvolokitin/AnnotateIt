import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../data/project_database.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;

    String editButton = screenWidth>500 ? l10n.userProfileEditProfileButton : l10n.buttonEdit;
    String fdbkButton = screenWidth>500 ? l10n.userProfileFeedbackButton : l10n.buttonFeedbackShort;

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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth > 1200 ? 24 : 18,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.bold,
                    ),
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
                        label: Text(
                          fdbkButton,
                          style: TextStyle(
                            fontSize: screenWidth > 1200 ? 22 : 16,
                            fontFamily: 'CascadiaCode',
                          ),
                        ),
                        icon: const Icon(Icons.feedback_outlined),
                      ),
                      const SizedBox(width: 16.0),
                      FloatingActionButton.extended(
                        onPressed: () {},
                        elevation: 0,
                        backgroundColor: Colors.redAccent,
                        label: Text(
                          editButton,
                          style: TextStyle(
                            fontSize: screenWidth > 1200 ? 22 : 16,
                            fontFamily: 'CascadiaCode',
                          ),
                        ),
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
    final l10n = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;

    final items = [
      ProfileInfoItem(screenWidth>500 ? l10n.userProfileProjects : l10n.userProfileProjects[0], projectCount),
      ProfileInfoItem(screenWidth>500 ? l10n.userProfileLabels : l10n.userProfileLabels[0], labelCount),
      ProfileInfoItem(screenWidth>500 ? l10n.userProfileMedia : l10n.userProfileMedia[0], mediaCount),
      ProfileInfoItem(screenWidth>500 ? l10n.userProfileAnnotations : l10n.userProfileAnnotations[0], annotationCount),
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
    double screenWidth = MediaQuery.of(context).size.width;

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
                fontFamily: 'CascadiaCode',
                fontSize: 20,
              ),
            ),
        ),

        Text(
            item.title,
            style: TextStyle(
              fontSize: screenWidth > 1200 ? 16 : 12,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
            ),
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
