import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/api_endpoints.dart';
import '../../app_router.dart';

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
    debugPrint("Fetching matches...");
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await http.get(
        Uri.parse(MatchEndpoints.latestMatch),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      debugPrint("Match response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final matchesData = jsonDecode(response.body);
        debugPrint("Received matches: $matchesData");

        setState(() {
          matches = matchesData;
          isLoading = false;
        });
      } else {
        debugPrint("Error fetching matches: ${response.body}");
        setState(() {
          error = 'Failed to load matches: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Exception fetching matches: $e");
      setState(() {
        error = 'Error occurred: $e';
        isLoading = false;
      });
    }
  }

  void _viewTherapistBio(Map<String, dynamic> match) {
    // No need to extract any ID or rank
    // Pass the entire match data to the profile page
    Navigator.pushNamed(
      context,
      AppRoutes.therapistProfile,
      arguments: match, // Pass the complete match data
    );
  }

  @override
  Widget build(BuildContext context) {
    final anonName = Provider.of<AuthProvider>(context).user?.anonUsername ?? 'User';

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
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('No matches found. Please try again later.',
                    style: TextStyle(fontSize: 16),
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
              child: const Text('Back to Entry page for a new match'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
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
                Text(
                  '${(match['match_score'] is num ? (match['match_score'] * 100).toStringAsFixed(1) : "0")}% match',
                  style: const TextStyle(color: Colors.green, fontSize: 14),
                ),
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
                child: const Text('Read Bio'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}