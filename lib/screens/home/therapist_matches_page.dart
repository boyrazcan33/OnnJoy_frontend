import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/api_endpoints.dart';
import '../../app_router.dart';
import '../../utils/debug_utils.dart';
import '../home/therapist_profile_page.dart';  // Direct import for navigation
import '../../widgets/common/translate_text.dart';

class TherapistMatchesPage extends StatefulWidget {
  const TherapistMatchesPage({Key? key}) : super(key: key);

  @override
  State<TherapistMatchesPage> createState() => _TherapistMatchesPageState();
}

class _TherapistMatchesPageState extends State<TherapistMatchesPage> {
  List<dynamic> matches = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    DebugLogger.log("Fetching matches...", tag: "TherapistMatches");
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await http.get(
        Uri.parse(MatchEndpoints.latestMatch),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      DebugLogger.log("Match response status: ${response.statusCode}", tag: "TherapistMatches");
      if (response.statusCode == 200) {
        final matchesData = jsonDecode(response.body);
        DebugLogger.logObject("Received matches", matchesData, tag: "TherapistMatches");

        setState(() {
          matches = matchesData;
          isLoading = false;
        });
      } else {
        DebugLogger.log("Error fetching matches: ${response.body}", tag: "TherapistMatches", important: true);
        setState(() {
          error = 'Failed to load matches: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      DebugLogger.logError("Exception fetching matches", e, StackTrace.current, tag: "TherapistMatches");
      setState(() {
        error = 'Error occurred: $e';
        isLoading = false;
      });
    }
  }

  void _viewTherapistBio(Map<String, dynamic> match) {
    // Log the match data to verify it contains the needed information
    DebugLogger.logMap("Viewing therapist bio for", match, tag: "TherapistMatches");

    // OPTION 1: Use direct navigation with MaterialPageRoute (recommended)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TherapistProfilePage(),
        settings: RouteSettings(arguments: match),
      ),
    );

    // OPTION 2: If the above doesn't work, try this alternative
    /*
    // Deep copy the match data to prevent reference issues
    final Map<String, dynamic> therapistData = Map<String, dynamic>.from(match);

    // Make sure these key parameters exist and are correct
    if (!therapistData.containsKey('therapist_id') && therapistData.containsKey('id')) {
      therapistData['therapist_id'] = therapistData['id'];
    } else if (!therapistData.containsKey('therapist_id') && therapistData.containsKey('rank')) {
      // Only as a fallback
      therapistData['therapist_id'] = therapistData['rank'];
    }

    Navigator.pushNamed(
      context,
      AppRoutes.therapistProfile,
      arguments: therapistData,
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    final anonName = Provider.of<AuthProvider>(context).user?.anonUsername ?? 'User';
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/icons/logo.png', height: 40),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              anonName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            if (matches.isEmpty && error == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: TranslateText('noMatchesFound',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, index) => _buildMatchCard(matches[index]),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.entry);
              },
              child: TranslateText('backToEntryPage'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    // Calculate image number based on therapist data
    String getProfileImage() {
      final String fullName = match['full_name'] as String? ?? 'Therapist';
      final int nameHash = fullName.hashCode;
      final int matchScore = (match['match_score'] is num)
          ? (match['match_score'] * 100).round()
          : 0;
      final int imageNumber = 1 + ((nameHash + matchScore) % 14);
      return 'assets/person/therapist$imageNumber.jpg';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match['full_name'] ?? 'Therapist',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    TranslateText(
                      'matchPercentage',
                      style: const TextStyle(color: Colors.green, fontSize: 14),
                    ),
                    Text(
                      ': ${(match['match_score'] is num ? (match['match_score'] * 100).toStringAsFixed(1) : "0")}%',
                      style: const TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ],
                ),
                // Uncomment for debugging
                // Text(
                //   'ID: ${match['therapist_id']}',
                //   style: const TextStyle(fontSize: 12, color: Colors.grey),
                // ),
              ],
            ),
          ),
          Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.teal,
                backgroundImage: AssetImage(getProfileImage()),
                onBackgroundImageError: (_, __) {},
                child: Text(
                  (match['full_name'] as String? ?? 'T')[0],
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _viewTherapistBio(match),
                child: TranslateText('readBio'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}