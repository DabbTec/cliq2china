import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';

class SellerLegalView extends StatelessWidget {
  const SellerLegalView({super.key});

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
          'Legal',
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
          _buildLegalItem(
            'Privacy Policy',
            'Last updated: March 2024',
            onTap: () => Get.toNamed(
              Routes.sellerEditPolicy,
              arguments: {
                'title': 'Privacy Policy',
                'text':
                    'Our Privacy Policy details how we handle your information...',
              },
            ),
          ),
          const Divider(),
          _buildLegalItem(
            'Terms of Service',
            'Last updated: March 2024',
            onTap: () => Get.toNamed(
              Routes.sellerEditPolicy,
              arguments: {
                'title': 'Terms of Service',
                'text': 'By using our platform, you agree to these terms...',
              },
            ),
          ),
          const Divider(),
          _buildLegalItem(
            'Return & Refund Policy',
            'Standard guidelines',
            onTap: () => Get.toNamed(
              Routes.sellerEditPolicy,
              arguments: {
                'title': 'Return & Refund Policy',
                'text': 'Items can be returned within 30 days...',
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem(String title, String subtitle, {VoidCallback? onTap}) {
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
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
