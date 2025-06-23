import 'package:flutter/material.dart';
import '../../models/therapist.dart';
import '../../utils/constants.dart';
import '../../utils/therapist_image_utils.dart';

class TherapistCard extends StatelessWidget {
  final Therapist therapist;
  final VoidCallback onReadBio;

  const TherapistCard({
    Key? key,
    required this.therapist,
    required this.onReadBio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> therapistData = {
      'id': therapist.id,
      'therapist_id': therapist.id,
      'full_name': therapist.fullName,
      'profile_picture_url': therapist.profilePictureUrl,
      'match_score': therapist.matchScore,
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.secondaryColor),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
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
                  therapist.fullName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Match Score: ${therapist.matchScore.toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onReadBio,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                  child: const Text('Read Bio'),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              TherapistImageUtils.getProfileImage(therapistData),
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) => const Icon(Icons.person, size: 64),
            ),
          ),
        ],
      ),
    );
  }
}