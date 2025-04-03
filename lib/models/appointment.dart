class Appointment {
  final int id;
  final DateTime scheduledAt;
  final String status;
  final String packageType;
  final String? preSessionMessage;
  final String therapistName;
  final String therapistProfilePicture;

  Appointment({
    required this.id,
    required this.scheduledAt,
    required this.status,
    required this.packageType,
    this.preSessionMessage,
    required this.therapistName,
    required this.therapistProfilePicture,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      scheduledAt: DateTime.parse(json['scheduled_at']),
      status: json['status'],
      packageType: json['package_type'],
      preSessionMessage: json['pre_session_message'],
      therapistName: json['full_name'],
      therapistProfilePicture: json['profile_picture_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduled_at': scheduledAt.toIso8601String(),
      'status': status,
      'package_type': packageType,
      'pre_session_message': preSessionMessage,
      'full_name': therapistName,
      'profile_picture_url': therapistProfilePicture,
    };
  }
}
