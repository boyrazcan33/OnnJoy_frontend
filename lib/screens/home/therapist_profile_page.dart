import 'package:flutter/material.dart';
import '../../app_router.dart';

class TherapistProfilePage extends StatelessWidget {
  const TherapistProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> therapist =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String fullName = therapist['full_name'] ?? 'Therapist';
    final String bio = therapist['bio'] ?? 'No bio available.';
    final String imageUrl = therapist['profile_picture_url'] ??
        'https://via.placeholder.com/100';
    final int therapistId = therapist['therapist_id'];

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/icons/logo.png', height: 40),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(height: 12),

              Text(
                fullName,
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
                    arguments: therapistId,
                  );
                },
                child: const Text('Book a Slot'),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    bio,
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
