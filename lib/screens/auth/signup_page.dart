import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/constants.dart';
import '../../app_router.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  String _selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Image.asset('assets/icons/logo.png', height: 60),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'ONNJOY',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                  val != null && val.contains('@') ? null : 'Invalid email',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Password',
                  hintText: 'Create a password',
                  controller: _password,
                  isPassword: true,
                  obscureText: true,
                  validator: (val) =>
                  val != null && val.length >= 6 ? null : 'Min 6 characters',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Confirm Password',
                  hintText: 'Repeat your password',
                  controller: _confirmPassword,
                  isPassword: true,
                  obscureText: true,
                  validator: (val) =>
                  val != null && val == _password.text
                      ? null
                      : 'Passwords do not match',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration: const InputDecoration(
                    labelText: 'Preferred Language',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'et', child: Text('Estonian')),
                    DropdownMenuItem(value: 'lt', child: Text('Lithuanian')),
                    DropdownMenuItem(value: 'lv', child: Text('Latvian')),
                    DropdownMenuItem(value: 'ru', child: Text('Russian')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (_) {}),
                    const Expanded(
                      child: Text(
                        'I have read and accept User Terms and Privacy Policy',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Sign Up',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await authProvider.signup(
                        _email.text.trim(),
                        _password.text.trim(),
                        _selectedLanguage,
                      );

                      if (authProvider.isAuthenticated) {
                        Navigator.pushReplacementNamed(context, AppRoutes.entry);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authProvider.errorMessage ?? 'Error')),
                        );
                      }
                    }
                  },
                  isLoading: authProvider.isLoading,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                  child: const Text('Already a Member? Log In'),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.therapistLogin),
                  child: const Text('I am a therapist'),
                ),
                const SizedBox(height: 16),
                IconButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.languageChoice),
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
