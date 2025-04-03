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

  Future<void> _fetchMatches() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await http.get(
        Uri.parse(MatchEndpoints.latestMatch),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          matches = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load matches.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error occurred: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMatches();
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
            ...matches.map((match) => _buildMatchCard(match)).toList(),
            const SizedBox(height: 24),
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
                  '${(match['match_score'] * 100).toStringAsFixed(1)}% match',
                  style: const TextStyle(color: Colors.green, fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  match['profile_picture_url'] ?? 'https://via.placeholder.com/100',
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.therapistProfile,
                    arguments: match,
                  );
                },
                child: const Text('Read Bio'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
