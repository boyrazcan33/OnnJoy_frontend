import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../app_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/api_endpoints.dart';

class TherapistProfilePage extends StatefulWidget {
  const TherapistProfilePage({Key? key}) : super(key: key);

  @override
  State<TherapistProfilePage> createState() => _TherapistProfilePageState();
}

class _TherapistProfilePageState extends State<TherapistProfilePage> {
  bool isLoading = true;
  Map<String, dynamic>? therapistData;
  String? error;

  // Store the original match data
  Map<String, dynamic>? matchData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _processArguments();
  }

  // Process the arguments and fetch the full therapist details
  void _processArguments() {
    // Get match data from route arguments
    final arguments = ModalRoute.of(context)?.settings.arguments;
    debugPrint("TherapistProfilePage: Received arguments: $arguments");

    if (arguments is Map<String, dynamic>) {
      // Store the match data for displaying basic info immediately
      matchData = arguments;

      // Update UI with the match data while we fetch full details
      setState(() {
        therapistData = matchData;
        isLoading = false;
      });

      // Then fetch full therapist details from API
      _fetchFullTherapistDetails();
    } else {
      setState(() {
        error = 'Invalid data received. Please go back and try again.';
        isLoading = false;
      });
    }
  }

  // Fetch complete therapist details from the API
  Future<void> _fetchFullTherapistDetails() async {
    if (matchData == null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;

    if (token == null) {
      setState(() {
        error = 'Authentication token not found.';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Use the therapist_id or rank from the match data to fetch full details
      final therapistId = matchData!['therapist_id'] ?? matchData!['rank'];

      if (therapistId == null) {
        setState(() {
          error = 'No therapist identifier found in the match data.';
          isLoading = false;
        });
        return;
      }

      debugPrint("Fetching full therapist details using identifier: $therapistId");

      final response = await http.get(
        Uri.parse(TherapistEndpoints.getTherapistDetails(therapistId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint("Therapist API response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final fullData = jsonDecode(response.body);
        debugPrint("Full therapist data received: $fullData");

        // Combine the match data (for match score) with the full details
        final Map<String, dynamic> combinedData = Map<String, dynamic>.from(fullData);
        // Make sure to keep the match score from the original match data
        if (matchData!.containsKey('match_score')) {
          combinedData['match_score'] = matchData!['match_score'];
        }

        setState(() {
          therapistData = combinedData;
          isLoading = false;
        });
      } else {
        debugPrint("Error response: ${response.body}");
        // In case of error, keep using the match data but show an error message
        setState(() {
          error = 'Could not fetch complete therapist details.';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Exception fetching therapist details: $e");
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Helper function to get profile image
    String getProfileImage(Map<String, dynamic> data) {
      final String fullName = data['full_name'] as String? ?? 'Therapist';
      final int nameHash = fullName.hashCode.abs();
      final int imageNumber = 1 + (nameHash % 14);
      return 'assets/person/therapist$imageNumber.jpg';
    }

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/icons/logo.png', height: 40),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null && therapistData == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      )
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Profile picture
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal,
                backgroundImage: therapistData != null
                    ? AssetImage(getProfileImage(therapistData!))
                    : null,
                onBackgroundImageError: (_, __) {},
                child: Text(
                  therapistData != null
                      ? (therapistData!['full_name'] as String? ?? 'T')[0]
                      : 'T',
                  style: const TextStyle(fontSize: 36, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),

              // Name
              Text(
                therapistData?['full_name'] ?? 'Therapist',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Show loading message if we're still fetching full details
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Loading complete details...',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),

              // Show error if there was a problem getting full details
              if (error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),

              const SizedBox(height: 16),

              // Book slot button
              ElevatedButton(
                onPressed: () {
                  // For calendar navigation, use any identifier available
                  final id = therapistData?['id'] ??
                      therapistData?['therapist_id'] ??
                      matchData?['rank'];

                  if (id != null) {
                    debugPrint("Navigating to calendar with ID: $id");
                    Navigator.pushNamed(
                      context,
                      AppRoutes.therapistCalendar,
                      arguments: id,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cannot book: Missing therapist identifier'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Book a Slot'),
              ),

              const SizedBox(height: 24),

              // Bio section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About the Therapist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        therapistData?['bio'] ?? 'Loading bio...',
                        style: const TextStyle(fontSize: 16),
                      ),

                      // Show match score if available
                      if (therapistData?['match_score'] != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Match Score',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(therapistData!['match_score'] is num ? (therapistData!['match_score'] * 100).toStringAsFixed(1) : "0")}% match with your needs',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Back button
              Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  icon: Image.asset('assets/icons/step-backward.png', height: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}