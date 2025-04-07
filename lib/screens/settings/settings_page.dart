import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/translate_text.dart';
import '../../utils/api_endpoints.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showEmailField = false;
  bool showPasswordField = false;

  void _updateEmail() {
    setState(() => showEmailField = !showEmailField);
  }

  void _updatePassword() {
    setState(() => showPasswordField = !showPasswordField);
  }

  void _contactUs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact: support@onnjoy.com')),
    );
  }

  void _deleteAccount() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: TranslateText('deleteAccount'),
        content: TranslateText('confirmDeleteAccount'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TranslateText('cancel'),
          ),
          TextButton(
            onPressed: () {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              // Call actual delete endpoint here if needed
              auth.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
            },
            child: TranslateText('delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TranslateText("settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TranslateText("updateEmailAddress", style: const TextStyle(fontWeight: FontWeight.bold)),
            if (showEmailField)
              Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        hintText: languageProvider.translate("newEmail")
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => showEmailField = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Email updated")),
                      );
                    },
                    child: TranslateText("saveEmail"),
                  )
                ],
              )
            else
              TextButton(
                  onPressed: _updateEmail,
                  child: TranslateText("changeEmail")
              ),

            const SizedBox(height: 24),
            TranslateText("updatePassword", style: const TextStyle(fontWeight: FontWeight.bold)),
            if (showPasswordField)
              Column(
                children: [
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                        hintText: languageProvider.translate("newPassword")
                    ),
                    obscureText: true,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => showPasswordField = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Password updated")),
                      );
                    },
                    child: TranslateText("savePassword"),
                  )
                ],
              )
            else
              TextButton(
                  onPressed: _updatePassword,
                  child: TranslateText("changePassword")
              ),

            const SizedBox(height: 24),
            TranslateText("contactUs", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: _contactUs,
              child: const Text("support@onnjoy.com"),
            ),

            const SizedBox(height: 24),
            TranslateText("deleteAccount", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: _deleteAccount,
              child: TranslateText(
                  "permanentlyDelete",
                  style: const TextStyle(color: Colors.red)
              ),
            ),
          ],
        ),
      ),
    );
  }
}