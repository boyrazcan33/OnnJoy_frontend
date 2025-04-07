import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/constants.dart';
import '../../utils/language_utils.dart';

class LanguagePicker extends StatelessWidget {
  final bool useContainer;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showNativeNames;

  const LanguagePicker({
    Key? key,
    this.useContainer = true,
    this.backgroundColor,
    this.iconColor,
    this.showNativeNames = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLang = languageProvider.currentLanguage;
    final supportedLanguages = LanguageUtils.getSupportedLanguages();

    Widget dropdownWidget = DropdownButton<String>(
      value: currentLang,
      underline: const SizedBox(),
      icon: Icon(
        Icons.language,
        color: iconColor ?? Colors.black87,
      ),
      items: [
        for (final code in supportedLanguages)
          DropdownMenuItem(
            value: code,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  LanguageUtils.getFlagAsset(code),
                  width: 24,
                  height: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  showNativeNames
                      ? LanguageUtils.getNativeLanguageName(code)
                      : LanguageUtils.getLanguageName(code),
                ),
              ],
            ),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          languageProvider.setLanguage(value);
        }
      },
    );

    if (!useContainer) {
      return dropdownWidget;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: dropdownWidget,
    );
  }
}