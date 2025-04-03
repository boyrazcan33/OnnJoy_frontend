import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/api_endpoints.dart';
import '../../app_router.dart'; // added to use AppRoutes constants

class PaymentCheckoutPage extends StatefulWidget {
  const PaymentCheckoutPage({Key? key}) : super(key: key);

  @override
  State<PaymentCheckoutPage> createState() => _PaymentCheckoutPageState();
}

class _PaymentCheckoutPageState extends State<PaymentCheckoutPage> {
  late int therapistId;
  late DateTime selectedDate;
  late String packageType;

  bool agreedToTerms = false;
  bool isLoading = false;

  final Map<String, int> packagePrices = {
    'single': 29,
    'monthly': 79,
    'intensive': 129,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    therapistId = args['therapistId'];
    selectedDate = args['selectedDate'];
    packageType = args['packageType'];
  }

  Future<void> _payNow() async {
    if (!agreedToTerms) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(PaymentEndpoints.createCheckout),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': auth.user?.id,
          'appointmentId': 0,
          'packageType': packageType,
        }),
      );

      if (response.statusCode == 200) {
        final url = response.body.replaceAll('"', '');
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment failed.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final username = auth.user?.anonUsername ?? 'User';
    final amount = packagePrices[packageType]!;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/icons/logo.png', height: 40),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text(username, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Image.asset('assets/icons/visa.png', height: 32),
                const SizedBox(width: 12),
                Image.asset('assets/icons/mastercard.png', height: 32),
                const SizedBox(width: 12),
                Image.asset('assets/icons/stripe.png', height: 32),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Total: €$amount',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Package: ${packageType[0].toUpperCase()}${packageType.substring(1)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            CheckboxListTile(
              value: agreedToTerms,
              onChanged: (val) {
                setState(() => agreedToTerms = val ?? false);
              },
              title: const Text('I have read and approved the Terms and Privacy Policy'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Image.asset('assets/icons/step-backward.png', height: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  onPressed: (agreedToTerms && !isLoading) ? _payNow : null,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Pay Securely with Stripe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
