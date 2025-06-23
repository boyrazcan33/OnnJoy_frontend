class TherapistImageUtils {
  static const int maxFemaleImages = 8;
  static const int maxMaleImages = 6;

  static const List<String> maleNames = [
    'paul', 'steven', 'christian', 'james', 'christopher', 'brian', 'aaron',
    'cody', 'patrick', 'charles', 'peter', 'kevin', 'anthony', 'dillon',
    'gregory', 'brandon', 'dave', 'francisco', 'ryan', 'carl', 'william',
    'devin', 'eric', 'jonathan', 'cameron'
  ];

  static String getProfileImage(Map<String, dynamic> therapistData) {
    final String fullName = therapistData['full_name'] as String? ?? 'Therapist';
    final String firstName = fullName.toLowerCase().split(' ').first;
    final bool isMale = maleNames.contains(firstName);
    final String gender = isMale ? 'male' : 'female';
    final int maxImages = isMale ? maxMaleImages : maxFemaleImages;

    final int nameHash = fullName.hashCode.abs();
    final int matchScore = (therapistData['match_score'] is num)
        ? (therapistData['match_score'] * 100).round()
        : 0;

    final int imageNumber = 1 + ((nameHash + matchScore) % maxImages);
    return 'assets/person/$gender/therapist$imageNumber.jpg';
  }
}