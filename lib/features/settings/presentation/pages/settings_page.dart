import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('settings'.tr()),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text('language'.tr()),
              trailing: DropdownButton<String>(
                value: context.locale.languageCode,
                items: [
                  DropdownMenuItem(
                    value: 'tr',
                    child: Text('turkish'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'en',
                    child: Text('english'.tr()),
                  ),
                ],
                onChanged: (String? value) {
                  if (value == 'tr') {
                    context.setLocale(const Locale('tr', 'TR'));
                  } else if (value == 'en') {
                    context.setLocale(const Locale('en', 'US'));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
} 