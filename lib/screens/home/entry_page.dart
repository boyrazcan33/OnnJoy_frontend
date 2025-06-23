import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/translate_text.dart';
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
  int _currentLength = 0;
  bool _hasExistingMatches = false;

  static const int maxChars = 1000;

  @override
  void initState() {
    super.initState();
    _entry.addListener(() {
      setState(() {
        _currentLength = _entry.text.length;
      });
    });
    _checkForExistingMatches();
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  Future<void> _checkForExistingMatches() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await http.get(
        Uri.parse(MatchEndpoints.latestMatch),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      if (response.statusCode == 200) {
        final matches = jsonDecode(response.body);
        setState(() {
          _hasExistingMatches = matches != null && matches.isNotEmpty;
        });
      }
    } catch (e) {
      // Silently fail , this is just for UI enhancement
      print('Error checking matches: $e');
    }
  }

  String _getUserFriendlyError(String originalError) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (originalError.contains('2 entries per week')) {
      return languageProvider.translate('weeklyLimitReached') ??
          'You have reached the weekly limit of 2 entries. Please try again next week.';
    } else if (originalError.contains('network') || originalError.contains('connection')) {
      return languageProvider.translate('networkError') ??
          'Network connection error. Please check your internet and try again.';
    } else if (originalError.contains('token') || originalError.contains('authentication')) {
      return languageProvider.translate('authenticationError') ??
          'Authentication error. Please log in again.';
    } else if (originalError.contains('server') || originalError.contains('500')) {
      return languageProvider.translate('serverError') ??
          'Server error. Please try again in a few minutes.';
    }

    return languageProvider.translate('genericError') ??
        'Something went wrong. Please try again.';
  }

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
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData.toString();
        } catch (e) {
          errorMessage = response.body;
        }

        setState(() {
          _error = _getUserFriendlyError(errorMessage);
        });
      }
    } catch (e) {
      setState(() {
        _error = _getUserFriendlyError(e.toString());
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
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/icons/logo.png', height: 40),
        actions: [
          // Add match history button if user has existing matches
          if (_hasExistingMatches)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.matches),
              tooltip: 'View Previous Matches',
            ),
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
                TranslateText(
                  'helloUser',
                  params: {'username': anonName},
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TranslateText('entryPrompt'),

                // Show match history access if available
                if (_hasExistingMatches) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.matches),
                    icon: const Icon(Icons.history, size: 16),
                    label: TranslateText('viewPreviousMatches'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.teal,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                Expanded(
                  child: TextFormField(
                    controller: _entry,
                    maxLength: maxChars,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: languageProvider.translate('writeThoughts'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: '',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return languageProvider.translate('entryCannotBeEmpty') ??
                            'Entry cannot be empty';
                      }
                      if (val.length > maxChars) {
                        return languageProvider.translate('maxCharactersExceeded') ??
                            'Max $maxChars characters allowed';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TranslateText(
                    'characterLeft',
                    params: {'count': (maxChars - _currentLength).toString()},
                    style: TextStyle(
                      color: _currentLength > maxChars ? Colors.red : Colors.grey,
                      fontWeight: _currentLength > maxChars ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Enhanced error display
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _currentLength == 0) ? null : _submitEntry,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : TranslateText('submit'),
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
                  child: TranslateText('signOut'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}