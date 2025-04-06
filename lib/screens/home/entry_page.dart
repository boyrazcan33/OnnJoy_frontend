import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../providers/auth_provider.dart';
import '../../utils/api_endpoints.dart';
import '../../app_router.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({Key? key}) : super(key: key);

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _entry = TextEditingController();

  bool _isLoading = false;
  String? _error;

  static const int maxChars = 1000;

  Future<void> _submitEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse(EntryEndpoints.submitEntry),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.token}',
        },
        body: jsonEncode({
          'text': _entry.text.trim(),
          'language': auth.user?.language ?? 'en',
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushNamed(context, AppRoutes.matches);
      } else {
        setState(() {
          _error = jsonDecode(response.body)['message'] ??
              'Submission failed. Try again later.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final anonName = auth.user?.anonUsername ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/icons/logo.png', height: 40),
        actions: [
          IconButton(
            icon: Image.asset('assets/icons/settings.png', height: 24),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          IconButton(
            icon: Image.asset('assets/icons/bell.png', height: 24),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello $anonName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Type in an entry to find the best therapist match. We give you two options among many therapists.',
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: TextFormField(
                    controller: _entry,
                    maxLength: maxChars,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Write your thoughts here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Entry cannot be empty';
                      }
                      if (val.length > maxChars) {
                        return 'Max $maxChars characters allowed';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${maxChars - _entry.text.length} characters left',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 8),
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitEntry,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.welcome,
                          (route) => false,
                    );
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}