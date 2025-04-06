class Therapist {
  final int id;
  final String fullName;
  final String profilePictureUrl;
  final double matchScore;

  Therapist({
    required this.id,
    required this.fullName,
    required this.profilePictureUrl,
    required this.matchScore,
  });

  factory Therapist.fromJson(Map<String, dynamic> json) {
    // Try to get the ID from various possible fields
    final int therapistId = json['therapist_id'] ?? json['id'] ?? 0;

    return Therapist(
      id: therapistId,
      fullName: json['full_name'] ?? '',
      profilePictureUrl: json['profile_picture_url'] ?? '',
      matchScore: (json['match_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'therapist_id': id, // Include both forms to ensure compatibility
      'full_name': fullName,
      'profile_picture_url': profilePictureUrl,
      'match_score': matchScore,
    };
  }
}