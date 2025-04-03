import 'package:flutter/material.dart';
import '../../app_router.dart'; // <- added this

class PackageSelectionPage extends StatefulWidget {
  const PackageSelectionPage({Key? key}) : super(key: key);

  @override
  State<PackageSelectionPage> createState() => _PackageSelectionPageState();
}

class _PackageSelectionPageState extends State<PackageSelectionPage> {
  String? selectedPackage;

  late int therapistId;
  late DateTime selectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    therapistId = args['therapistId'];
    selectedDate = args['selectedDate'];
  }

  void _confirmPurchase() {
    if (selectedPackage != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.payment,
        arguments: {
          'packageType': selectedPackage,
          'therapistId': therapistId,
          'selectedDate': selectedDate,
        },
      );
    }
  }

  Widget _buildPackageCard({
    required String title,
    required String price,
    required String description,
    required String value,
    required bool popular,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPackage = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selectedPackage == value ? Colors.teal.shade100 : Colors.white,
          border: Border.all(
            color: selectedPackage == value ? Colors.teal : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (popular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '⭐ Best Choice',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(price, style: const TextStyle(fontSize: 16, color: Colors.teal)),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/icons/logo.png', height: 40),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPackageCard(
              title: '🟢 Instant Support',
              price: '€29 / session',
              description:
              '20-minute session. Ideal for sudden challenges or quick emotional relief.',
              value: 'single',
              popular: false,
            ),
            _buildPackageCard(
              title: '🔵 Monthly Wellness Pack',
              price: '€79 / month',
              description:
              'One session weekly. Perfect for steady, step-by-step emotional balance.',
              value: 'monthly',
              popular: false,
            ),
            _buildPackageCard(
              title: '🌟 Monthly Intensive Boost',
              price: '€129 / month',
              description:
              'Two sessions weekly. Best for deep healing & fast progress.',
              value: 'intensive',
              popular: true,
            ),
            const SizedBox(height: 8),
            const Text(
              '* You can send a 1000-character message to guide your therapist before the meeting.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
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
                  onPressed: selectedPackage != null ? _confirmPurchase : null,
                  child: const Text('Purchase'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
