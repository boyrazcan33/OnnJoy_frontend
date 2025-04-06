import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/api_endpoints.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../app_router.dart';

class TherapistLoginPage extends StatefulWidget {
  const TherapistLoginPage({Key? key}) : super(key: key);

  @override
  State<TherapistLoginPage> createState() => _TherapistLoginPageState();
}

class _TherapistLoginPageState extends State<TherapistLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _loginTherapist() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(AuthEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _email.text.trim(),
          'password': _password.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        // Replace with your token storage logic if needed

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.therapistProfile,
          arguments: token,
        );
      } else {
        setState(() {
          _errorMessage = 'Login failed: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }

    setState(() => _isLoading = false);
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
                  'If you are an OnnJoy therapist',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                  val != null && val.contains('@') ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: _password,
                  isPassword: true,
                  obscureText: true,
                  validator: (val) =>
                  val != null && val.length >= 6 ? null : 'Min 6 characters',
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Login as a Therapist',
                  onPressed: _loginTherapist,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.signup,
                  ),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
