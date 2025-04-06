import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/api_endpoints.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../app_router.dart'; // <-- Import route constants

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  bool _isLoading = false;
  String? _message;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final response = await http.post(
        Uri.parse(AuthEndpoints.resetPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _email.text.trim()}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _message = "Reset link sent to your email.";
        });
      } else {
        setState(() {
          _message = "Failed to send reset link: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error occurred: $e";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Image.asset('assets/icons/logo.png', height: 60),
                const SizedBox(height: 24),
                const Text(
                  'Reset your password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('We will send you an e-mail to reset your password.'),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                  val != null && val.contains('@') ? null : 'Enter valid email',
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Email me',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                if (_message != null)
                  Text(
                    _message!,
                    style: const TextStyle(color: Colors.green),
                  ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
