import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/translate_text.dart';
import '../../app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

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
                CustomTextField(
                  label: languageProvider.translate('email'),
                  hintText: languageProvider.translate('email'),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                  val != null && val.contains('@') ? null : 'Enter valid email',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: languageProvider.translate('password'),
                  hintText: languageProvider.translate('password'),
                  controller: _password,
                  isPassword: true,
                  obscureText: true,
                  validator: (val) =>
                  val != null && val.length >= 6 ? null : 'Min 6 characters',
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: languageProvider.translate('logIn'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await authProvider.login(
                        _email.text.trim(),
                        _password.text.trim(),
                      );

                      if (authProvider.isAuthenticated) {
                        if (authProvider.user?.language != null) {
                          // Update language based on user's saved preference
                          languageProvider.setLanguage(
                              authProvider.user!.language,
                              token: authProvider.token
                          );
                        }
                        Navigator.pushReplacementNamed(context, AppRoutes.entry);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authProvider.errorMessage ?? 'Login failed')),
                        );
                      }
                    }
                  },
                  isLoading: authProvider.isLoading,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, AppRoutes.signup),
                      child: TranslateText('createAccount'),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.resetPassword),
                      child: TranslateText('forgotPassword'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.therapistLogin),
                  child: TranslateText('iAmTherapist'),
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () => Navigator.pop(context),
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