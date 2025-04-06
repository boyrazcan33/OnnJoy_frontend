import 'package:flutter/material.dart';
import 'package:onnjoy_frontend/screens/home/therapist_calendar_page.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../app_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/api_endpoints.dart';
import '../../utils/debug_utils.dart';

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
    DebugLogger.log("TherapistProfilePage: Received arguments type: ${arguments.runtimeType}", tag: "TherapistProfile");
    DebugLogger.log("TherapistProfilePage: Received arguments: $arguments", tag: "TherapistProfile");

    if (arguments is Map<String, dynamic>) {
      // Store the match data for displaying basic info immediately
      matchData = Map<String, dynamic>.from(arguments);
      DebugLogger.logMap("TherapistProfilePage: Valid match data received", matchData!, tag: "TherapistProfile");

      // Update UI with the match data while we fetch full details
      setState(() {
        therapistData = matchData;
        isLoading = false;
      });

      // Then fetch full therapist details from API
      _fetchFullTherapistDetails();
    } else {
      DebugLogger.log("TherapistProfilePage: Invalid arguments received: $arguments", tag: "TherapistProfile", important: true);
      setState(() {
        error = 'Invalid data received. Please go back and try again.';
        isLoading = false;
      });
    }
  }

  // Fetch complete therapist details from the API
  Future<void> _fetchFullTherapistDetails() async {
    if (matchData == null) {
      DebugLogger.log("TherapistProfilePage: No match data to fetch details from", tag: "TherapistProfile", important: true);
      return;
    }

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
      // First try to use therapist_id directly
      int? therapistId;

      // Try every possible way to get the therapist ID
      if (matchData!.containsKey('therapist_id')) {
        final dynamic rawId = matchData!['therapist_id'];
        if (rawId is int) {
          therapistId = rawId;
        } else if (rawId is String) {
          therapistId = int.tryParse(rawId);
        }
        DebugLogger.log("Found therapist_id: $therapistId", tag: "TherapistProfile");
      } else if (matchData!.containsKey('id')) {
        final dynamic rawId = matchData!['id'];
        if (rawId is int) {
          therapistId = rawId;
        } else if (rawId is String) {
          therapistId = int.tryParse(rawId);
        }
        DebugLogger.log("Found id: $therapistId", tag: "TherapistProfile");
      } else if (matchData!.containsKey('rank')) {
        final dynamic rawRank = matchData!['rank'];
        if (rawRank is int) {
          therapistId = rawRank;
        } else if (rawRank is String) {
          therapistId = int.tryParse(rawRank);
        }
        DebugLogger.log("Using rank as fallback: $therapistId", tag: "TherapistProfile");
      }

      if (therapistId == null) {
        DebugLogger.logMap("Cannot extract therapist ID from data", matchData!, tag: "TherapistProfile", important: true);
        setState(() {
          error = 'No therapist identifier found in the match data.';
          isLoading = false;
        });
        return;
      }

      DebugLogger.log("Fetching full therapist details using ID: $therapistId", tag: "TherapistProfile");

      final url = TherapistEndpoints.getTherapistDetails(therapistId);
      DebugLogger.log("API URL: $url", tag: "TherapistProfile");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      DebugLogger.log("Therapist API response status: ${response.statusCode}", tag: "TherapistProfile");
      DebugLogger.log("Therapist API response body: ${response.body}", tag: "TherapistProfile");

      if (response.statusCode == 200) {
        final fullData = jsonDecode(response.body);
        DebugLogger.logMap("Full therapist data received", fullData, tag: "TherapistProfile");

        // Combine the match data (for match score) with the full details
        final Map<String, dynamic> combinedData = Map<String, dynamic>.from(fullData);

        // Make sure to keep the match score from the original match data
        if (matchData!.containsKey('match_score')) {
          combinedData['match_score'] = matchData!['match_score'];
        }

        // Ensure the therapist_id is set in combined data
        if (!combinedData.containsKey('id') && therapistId != null) {
          combinedData['id'] = therapistId;
        }

        // If not already present, also set therapist_id separately
        if (!combinedData.containsKey('therapist_id') && therapistId != null) {
          combinedData['therapist_id'] = therapistId;
        }

        setState(() {
          therapistData = combinedData;
          isLoading = false;
        });
      } else {
        DebugLogger.log("Error response: ${response.body}", tag: "TherapistProfile", important: true);
        // In case of error, keep using the match data but show an error message
        setState(() {
          error = 'Could not fetch complete therapist details. Status: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      DebugLogger.logError("Exception fetching therapist details", e, stackTrace, tag: "TherapistProfile");
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // Helper function to get profile image - Using the same logic as TherapistMatchesPage
  String getProfileImage(Map<String, dynamic> data) {
    final String fullName = data['full_name'] as String? ?? 'Therapist';
    final int nameHash = fullName.hashCode;
    final int matchScore = (data['match_score'] is num)
        ? (data['match_score'] * 100).round()
        : 0;
    final int imageNumber = 1 + ((nameHash + matchScore) % 14);
    return 'assets/person/therapist$imageNumber.jpg';
  }

  @override
  Widget build(BuildContext context) {
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
        child: Center(
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
                    // Get the therapist ID to pass to the calendar page
                    int? therapistId;

                    // Try all possible sources of the ID
                    if (therapistData?.containsKey('therapist_id') ?? false) {
                      final dynamic rawId = therapistData!['therapist_id'];
                      if (rawId is int) {
                        therapistId = rawId;
                      } else if (rawId is String) {
                        therapistId = int.tryParse(rawId);
                      }
                    } else if (therapistData?.containsKey('id') ?? false) {
                      final dynamic rawId = therapistData!['id'];
                      if (rawId is int) {
                        therapistId = rawId;
                      } else if (rawId is String) {
                        therapistId = int.tryParse(rawId);
                      }
                    } else if (matchData?.containsKey('rank') ?? false) {
                      final dynamic rawRank = matchData!['rank'];
                      if (rawRank is int) {
                        therapistId = rawRank;
                      } else if (rawRank is String) {
                        therapistId = int.tryParse(rawRank);
                      }
                    }

                    if (therapistId != null) {
                      DebugLogger.log("Navigating to calendar with ID: $therapistId", tag: "TherapistProfile");

                      // Direct push with MaterialPageRoute to ensure args are passed
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TherapistCalendarPage(),
                          settings: RouteSettings(arguments: therapistId),
                        ),
                      );
                    } else {
                      DebugLogger.logMap("Cannot book: Missing therapist identifier",
                          therapistData ?? {'error': 'No data available'},
                          tag: "TherapistProfile",
                          important: true);

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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const Text(
                            'About the Therapist',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            therapistData?['bio'] ?? 'Loading bio...',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),

                          // Show match score if available
                          if (therapistData?['match_score'] != null) ...[
                            const SizedBox(height: 24),
                            const Text(
                              'Match Score',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(therapistData!['match_score'] is num ? (therapistData!['match_score'] * 100).toStringAsFixed(1) : "0")}% match with your needs',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}