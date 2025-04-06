import 'dart:io';
import '../data/app_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';


class AccountProfile extends StatefulWidget {
  final User user;
  final bool isEditing;
  final VoidCallback onToggleEdit;
  final Function(User) onUserChange;

  const AccountProfile({
    super.key,
    required this.user,
    required this.isEditing,
    required this.onToggleEdit,
    required this.onUserChange,
  });

  @override
  State<AccountProfile> createState() => _AccountProfileState();
}

class _AccountProfileState extends State<AccountProfile> {
  bool _hovering = false;

  Future<void> _pickImage() async {
    String? path;
    if (Platform.isAndroid || Platform.isIOS) {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) path = picked.path;
    } else {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) path = result.files.single.path;
    }

    if (path != null) {
      widget.onUserChange(widget.user.copyWith(iconPath: path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideLayout = screenWidth >= 800;

    return isWideLayout
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar (1/3 width, 90px tall)
              Expanded(flex: 1, child: _buildAvatar(context, 90)),
              SizedBox(width: 40),
              // Fields (2/3 width, 3x 30px height)
              Expanded(flex: 2, child: _buildForm()),
            ],
          )
        : Column(
            children: [
              _buildAvatar(context, 60),
              SizedBox(height: 30),
              _buildForm(),
            ],
          );
  }

  Widget _buildAvatar(BuildContext context, double size) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 1),
              image: widget.user.iconPath.isNotEmpty
                  ? DecorationImage(image: FileImage(File(widget.user.iconPath)), fit: BoxFit.cover)
                  : null,
              color: Colors.grey.shade300,
            ),
            child: widget.user.iconPath.isEmpty
                ? Icon(Icons.person, size: size * 0.6, color: Colors.white70)
                : null,
          ),
          if (_hovering)
            Positioned.fill(
              child: Material(
                color: Colors.black.withOpacity(0.4),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(size),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.edit, color: Colors.white, size: 24),
                        SizedBox(height: 6),
                        Text(
                          'Update Icon',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SizedBox(
      height: 90, // total height for 3 fields
      child: Column(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: widget.user.firstName,
              enabled: widget.isEditing,
              decoration: const InputDecoration(labelText: 'First Name'),
              onChanged: (val) => widget.onUserChange(widget.user.copyWith(firstName: val)),
            ),
          ),
          Expanded(
            child: TextFormField(
              initialValue: widget.user.lastName,
              enabled: widget.isEditing,
              decoration: const InputDecoration(labelText: 'Last Name'),
              onChanged: (val) => widget.onUserChange(widget.user.copyWith(lastName: val)),
            ),
          ),
          Expanded(
            child: TextFormField(
              initialValue: widget.user.email,
              enabled: widget.isEditing,
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (val) => widget.onUserChange(widget.user.copyWith(email: val)),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: widget.onToggleEdit,
              child: Text(widget.isEditing ? 'Done' : 'Edit'),
            ),
          ),
        ],
      ),
    );
  }
}
