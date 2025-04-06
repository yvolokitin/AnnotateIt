import 'package:flutter/material.dart';
import '../models/user.dart';

class AccountSettings extends StatelessWidget {
  final User user;
  final Function(User) onUserChange;

  const AccountSettings({
    super.key,
    required this.user,
    required this.onUserChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: Text('Dark Mode'),
          value: user.themeMode == 'dark',
          onChanged: (val) => onUserChange(user.copyWith(themeMode: val ? 'dark' : 'light')),
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: user.language,
          items: ['en', 'nl', 'ru'].map((lang) {
            return DropdownMenuItem(
              value: lang,
              child: Text(lang.toUpperCase()),
            );
          }).toList(),
          onChanged: (val) => onUserChange(user.copyWith(language: val ?? 'en')),
          decoration: InputDecoration(labelText: 'Language'),
        ),
      ],
    );
  }
}
