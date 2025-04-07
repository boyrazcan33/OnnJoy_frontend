import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_router.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/translate_text.dart';

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
    required String translationKey,
    required String priceKey,
    required String descriptionKey,
    required String value,
    required bool popular,
  }) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

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
                child: TranslateText(
                  'bestChoice',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            TranslateText(
                translationKey,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 4),
            TranslateText(
                priceKey,
                style: const TextStyle(fontSize: 16, color: Colors.teal)
            ),
            const SizedBox(height: 8),
            TranslateText(descriptionKey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TranslateText('selectPackage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPackageCard(
              translationKey: 'packageSingle',
              priceKey: 'packageSinglePrice',
              descriptionKey: 'packageSingleDesc',
              value: 'single',
              popular: false,
            ),
            _buildPackageCard(
              translationKey: 'packageMonthly',
              priceKey: 'packageMonthlyPrice',
              descriptionKey: 'packageMonthlyDesc',
              value: 'monthly',
              popular: false,
            ),
            _buildPackageCard(
              translationKey: 'packageIntensive',
              priceKey: 'packageIntensivePrice',
              descriptionKey: 'packageIntensiveDesc',
              value: 'intensive',
              popular: true,
            ),
            const SizedBox(height: 8),
            TranslateText(
              'preSessionMessage',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: selectedPackage != null ? _confirmPurchase : null,
                child: TranslateText('purchase'),
              ),
            )
          ],
        ),
      ),
    );
  }
}