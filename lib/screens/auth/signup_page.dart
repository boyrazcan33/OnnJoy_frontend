import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/translate_text.dart';
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
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    // Initialize with the current language from the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedLanguage = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Try to get language from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _selectedLanguage = args;
    } else {
      // Use current language as fallback
      _selectedLanguage = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    }
  }

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
                Center(
                  child: TranslateText(
                    'signup',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: languageProvider.translate('email'),
                  hintText: languageProvider.translate('email'),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                  val != null && val.contains('@') ? null : 'Invalid email',
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
                const SizedBox(height: 16),
                CustomTextField(
                  label: languageProvider.translate('confirmPassword'),
                  hintText: languageProvider.translate('confirmPassword'),
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
                  decoration: InputDecoration(
                    labelText: languageProvider.translate('chooseLanguage'),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'en',
                      child: Row(
                        children: [
                          Image.asset('assets/flags/uk.png', width: 24, height: 16),
                          const SizedBox(width: 8),
                          const Text('English'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'et',
                      child: Row(
                        children: [
                          Image.asset('assets/flags/estonia.png', width: 24, height: 16),
                          const SizedBox(width: 8),
                          const Text('Estonian'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'lt',
                      child: Row(
                        children: [
                          Image.asset('assets/flags/lithuania.png', width: 24, height: 16),
                          const SizedBox(width: 8),
                          const Text('Lithuanian'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'lv',
                      child: Row(
                        children: [
                          Image.asset('assets/flags/latvia.png', width: 24, height: 16),
                          const SizedBox(width: 8),
                          const Text('Latvian'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'ru',
                      child: Row(
                        children: [
                          Image.asset('assets/flags/russia.png', width: 24, height: 16),
                          const SizedBox(width: 8),
                          const Text('Russian'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                      // Update app-wide language
                      languageProvider.setLanguage(value);
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (_) {}),
                    Expanded(
                      child: TranslateText(
                        'userTerms',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: languageProvider.translate('signup'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await authProvider.signup(
                        _email.text.trim(),
                        _password.text.trim(),
                        _selectedLanguage,
                      );

                      if (authProvider.isAuthenticated) {
                        // If signup successful, ensure the language is properly set
                        await languageProvider.setLanguage(_selectedLanguage, token: authProvider.token);
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
                  child: TranslateText('alreadyMember'),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.therapistLogin),
                  child: TranslateText('iAmTherapist'),
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