import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/therapist_bios_service.dart';

class TherapistProfilePage extends StatefulWidget {
  const TherapistProfilePage({Key? key}) : super(key: key);

  @override
  State<TherapistProfilePage> createState() => _TherapistProfilePageState();
}

class _TherapistProfilePageState extends State<TherapistProfilePage> {
  bool isLoading = true;
  Map<String, dynamic>? therapistData;
  String? error;
  final TherapistService _therapistService = TherapistService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTherapistData();
  }

  Future<void> _loadTherapistData() async {
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;

    // Handle null arguments gracefully
    if (arguments == null) {
      setState(() {
        error = 'No therapist data provided. Please go back and try again.';
        isLoading = false;
      });
      return;
    }

    // Check if we received a map with therapist data
    if (arguments is Map<String, dynamic>) {
      setState(() {
        therapistData = arguments;
        isLoading = false;
      });
      return;
    }

    // Handle the case where we receive just an ID
    if (arguments is int) {
      final int therapistId = arguments;
      final auth = Provider.of<AuthProvider>(context, listen: false);

      try {
        final data = await _therapistService.getTherapistDetails(therapistId, auth.token ?? '');
        setState(() {
          therapistData = data;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          error = 'Failed to load therapist details: $e';
          isLoading = false;
        });
      }
      return;
    }

    // Neither a map nor an int was received
    setState(() {
      error = 'Invalid therapist data type: ${arguments.runtimeType}';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String getProfileImage(Map<String, dynamic> data) {
      final String fullName = data['full_name'] as String? ?? 'Therapist';
      final int nameHash = fullName.hashCode.abs(); // Using name as seed for consistency
      final int imageNumber = 1 + (nameHash % 14); // Range 1-14

      return 'assets/person/therapist$imageNumber.jpg';
    }

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/icons/logo.png', height: 40),
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) :
      error != null ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ) :
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal,
                backgroundImage: AssetImage(getProfileImage(therapistData!)),
                onBackgroundImageError: (_, __) {},
                child: Text(
                  (therapistData!['full_name'] as String? ?? 'T')[0],
                  style: const TextStyle(fontSize: 36, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                therapistData!['full_name'] ?? 'Therapist',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.therapistCalendar,
                    arguments: therapistData!['id'] ?? 0,
                  );
                },
                child: const Text('Book a Slot'),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    therapistData!['bio'] ?? 'No bio available.',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

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