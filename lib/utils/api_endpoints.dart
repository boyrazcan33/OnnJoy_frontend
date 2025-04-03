class ApiConfig {
  // Connect to Spring backend running locally
  static const String baseUrl = 'http://localhost:8080';
}

class AuthEndpoints {
  static const String login = '${ApiConfig.baseUrl}/auth/login';
  static const String signup = '${ApiConfig.baseUrl}/auth/signup';
  static const String resetPassword = '${ApiConfig.baseUrl}/auth/reset';
}

class UserEndpoints {
  static const String me = '${ApiConfig.baseUrl}/user/me';
  static const String appointments = '${ApiConfig.baseUrl}/user/appointments';
}

class AppointmentEndpoints {
  static const String all = '${ApiConfig.baseUrl}/user/appointments';
  static const String userAppointments = '${ApiConfig.baseUrl}/user/appointments';
}

class EntryEndpoints {
  static const String submitEntry = '${ApiConfig.baseUrl}/entry';
}

class MatchEndpoints {
  static String matchEntry(int entryId) => '${ApiConfig.baseUrl}/match/$entryId';
  static const String latestMatch = '${ApiConfig.baseUrl}/match/latest';
}

class NotificationEndpoints {
  static const String all = '${ApiConfig.baseUrl}/notifications';
  static const String getAll = '${ApiConfig.baseUrl}/notifications';
  static String markRead(int id) => '${ApiConfig.baseUrl}/notifications/$id/read';
}

class AvailabilityEndpoints {
  static String byTherapist(int therapistId) => '${ApiConfig.baseUrl}/availability/$therapistId';
}

class PaymentEndpoints {
  static const String createCheckout = '${ApiConfig.baseUrl}/payments/create-checkout-session';
  static const String stripeWebhook = '${ApiConfig.baseUrl}/webhook/stripe';
}
