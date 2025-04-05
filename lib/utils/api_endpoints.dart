class ApiConfig {
  // Connect to Spring backend running locally
  static const String baseUrl = 'http://localhost:8080';
}

class AuthEndpoints {
  static const String login = '${ApiConfig.baseUrl}/api/auth/login';
  static const String signup = '${ApiConfig.baseUrl}/api/auth/signup';
  static const String resetPassword = '${ApiConfig.baseUrl}/api/auth/reset';
}

class UserEndpoints {
  static const String me = '${ApiConfig.baseUrl}/api/user/me';
  static const String appointments = '${ApiConfig.baseUrl}/api/user/appointments';
}

class AppointmentEndpoints {
  static const String all = '${ApiConfig.baseUrl}/api/user/appointments';
  static const String userAppointments = '${ApiConfig.baseUrl}/api/user/appointments';
}

class EntryEndpoints {
  static const String submitEntry = '${ApiConfig.baseUrl}/api/entry';
}

class MatchEndpoints {
  static String matchEntry(int entryId) => '${ApiConfig.baseUrl}/api/match/$entryId';
  static const String latestMatch = '${ApiConfig.baseUrl}/api/match/latest';
}

class NotificationEndpoints {
  static const String all = '${ApiConfig.baseUrl}/api/notifications';
  static const String getAll = '${ApiConfig.baseUrl}/api/notifications';
  static String markRead(int id) => '${ApiConfig.baseUrl}/api/notifications/$id/read';
}

class AvailabilityEndpoints {
  static String byTherapist(int therapistId) => '${ApiConfig.baseUrl}/api/availability/$therapistId';
}

class PaymentEndpoints {
  static const String createCheckout = '${ApiConfig.baseUrl}/api/payments/create-checkout-session';
  static const String stripeWebhook = '${ApiConfig.baseUrl}/api/webhook/stripe';
}

class TherapistEndpoints {
  static String getTherapistDetails(int therapistId) =>
      '${ApiConfig.baseUrl}/api/therapists/$therapistId';
}