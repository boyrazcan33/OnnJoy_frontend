import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_endpoints.dart';

class PaymentService {
  /// Creates a Stripe checkout session and returns the redirect URL
  Future<String> createCheckoutSession({
    required int userId,
    required int appointmentId,
    required String packageType,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse(PaymentEndpoints.createCheckout),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'appointmentId': appointmentId,
        'packageType': packageType,
      }),
    );

    if (response.statusCode == 200) {
      final url = jsonDecode(response.body);
      return url.toString();
    } else {
      throw Exception('Failed to create checkout session: ${response.body}');
    }
  }
}
