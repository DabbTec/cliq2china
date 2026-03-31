import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerLanguagesView extends StatelessWidget {
  const SellerLanguagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Languages',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildLanguageItem('English', 'Primary Store Language', true),
          const Divider(),
          _buildLanguageItem(
            'Chinese (Simplified)',
            'Automatic Translation Enabled',
            false,
          ),
          const SizedBox(height: 32),
          const Text(
            'Currency Preference',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildCurrencyItem('CNY - Chinese Yuan', true),
          _buildCurrencyItem('USD - US Dollar', false),
          _buildCurrencyItem('NGN - Nigerian Naira', false),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem(String title, bool isSelected) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: isSelected
          ? const Icon(Icons.radio_button_checked, color: Colors.black)
          : const Icon(Icons.radio_button_off, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _buildLanguageItem(String title, String subtitle, bool isSelected) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: () {},
    );
  }
}
