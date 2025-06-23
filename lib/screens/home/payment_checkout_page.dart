import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/api_endpoints.dart';
import '../../app_router.dart';
import '../../utils/constants.dart';
import '../../widgets/common/translate_text.dart';

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
  int _selectedPaymentMethod = 0; // 0: Card, 1: PayPal (though we'll use Stripe for both)

  // Package display information
  final Map<String, Map<String, dynamic>> packageInfo = {
    'single': {
      'title': 'packageSingle',
      'price': 29,
      'sessions': 'packageSingleSessions',
      'duration': 'packageSingleDuration',
      'icon': '🟢'
    },
    'monthly': {
      'title': 'packageMonthly',
      'price': 79,
      'sessions': 'packageMonthlySessions',
      'duration': 'packageMonthlyDuration',
      'icon': '🔵'
    },
    'intensive': {
      'title': 'packageIntensive',
      'price': 129,
      'sessions': 'packageIntensiveSessions',
      'duration': 'packageIntensiveDuration',
      'icon': '🌟'
    },
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
    if (!agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TranslateText("pleaseAgreeToTerms")),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(PaymentEndpoints.createCheckout),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${auth.token}'},
        body: jsonEncode({
          'userId': auth.user?.id,
          'appointmentId': 0,
          'packageType': packageType,
        }),
      );

      if (response.statusCode == 200) {
        final url = response.body.replaceAll('"', '');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Payment'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: WebViewWidget(
                controller: WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  ..loadRequest(Uri.parse(url)),
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: TranslateText("paymentFailed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  Widget _buildPaymentMethodSelector() {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslateText(
          'paymentMethod',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              RadioListTile(
                title: Row(
                  children: [
                    Image.asset('assets/icons/visa.png', height: 24),
                    const SizedBox(width: 8),
                    Image.asset('assets/icons/mastercard.png', height: 24),
                    const SizedBox(width: 12),
                    TranslateText('creditDebitCard'),
                  ],
                ),
                value: 0,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() => _selectedPaymentMethod = value as int);
                },
                activeColor: AppColors.primary,
              ),
              Divider(height: 1, color: Colors.grey.shade300),
              RadioListTile(
                title: Row(
                  children: [
                    const SizedBox(width: 4),
                    Image.asset('assets/icons/stripe.png', height: 24),
                    const SizedBox(width: 12),
                    TranslateText('stripePayment'),
                  ],
                ),
                value: 1,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() => _selectedPaymentMethod = value as int);
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    final info = packageInfo[packageType]!;
    final auth = Provider.of<AuthProvider>(context);
    final username = auth.user?.anonUsername ?? 'User';
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TranslateText(
                'orderSummary',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(username, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  info['icon'],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslateText(
                      info['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    TranslateText(
                      info['sessions'],
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Text(
                '€${info['price']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Expanded(child: TranslateText('selectedDate')),
              Text(
                '${selectedDate.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TranslateText('serviceFee')),
              TranslateText(
                'included',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TranslateText('vatIncluded')),
              Text(
                '€${(info['price'] * 0.2).toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TranslateText(
                  'total',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Text(
                '€${info['price']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TranslateText('checkout'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslateText(
                'checkout',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Order Summary Section
              _buildOrderSummary(),
              const SizedBox(height: 24),

              // Payment Method Selection
              _buildPaymentMethodSelector(),
              const SizedBox(height: 24),

              // Terms & Conditions
              CheckboxListTile(
                value: agreedToTerms,
                onChanged: (val) {
                  setState(() => agreedToTerms = val ?? false);
                },
                title: TranslateText(
                  'userTermsCheckout',
                  style: const TextStyle(fontSize: 14),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
              ),

              const SizedBox(height: 12),

              // Security Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TranslateText(
                        'securityNotice',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment Button & Back Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: (agreedToTerms && !isLoading) ? _payNow : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : TranslateText(
                    'paySecurely',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}