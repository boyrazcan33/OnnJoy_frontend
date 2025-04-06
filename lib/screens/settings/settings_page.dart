import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../providers/auth_provider.dart';
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              // Call actual delete endpoint here if needed
              auth.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text("Update Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
            if (showEmailField)
              Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(hintText: "New email"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => showEmailField = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Email updated")),
                      );
                    },
                    child: const Text("Save Email"),
                  )
                ],
              )
            else
              TextButton(onPressed: _updateEmail, child: const Text("Change Email")),

            const SizedBox(height: 24),
            const Text("Update Password", style: TextStyle(fontWeight: FontWeight.bold)),
            if (showPasswordField)
              Column(
                children: [
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(hintText: "New password"),
                    obscureText: true,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => showPasswordField = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Password updated")),
                      );
                    },
                    child: const Text("Save Password"),
                  )
                ],
              )
            else
              TextButton(onPressed: _updatePassword, child: const Text("Change Password")),

            const SizedBox(height: 24),
            const Text("Contact Us", style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: _contactUs,
              child: const Text("support@onnjoy.com"),
            ),

            const SizedBox(height: 24),
            const Text("Delete Account", style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: _deleteAccount,
              child: const Text("Permanently Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}