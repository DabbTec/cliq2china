import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'About Cliq2China',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/c2cheader-logo.png',
                height: 60,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.shopping_bag_outlined,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cliq2China',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),
            const Text(
              'Empowering trade between China and Africa. Cliq2China provides a seamless platform for buyers to access quality Chinese products and for sellers to reach a global market.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            _buildAboutItem(
              'Official Website',
              'www.cliq2china.com',
              Icons.language,
            ),
            _buildAboutItem(
              'Follow us on Instagram',
              '@cliq2china_official',
              Icons.camera_alt_outlined,
            ),
            _buildAboutItem(
              'Follow us on Facebook',
              'Cliq2China',
              Icons.facebook,
            ),
            const SizedBox(height: 40),
            const Text(
              '© 2026 Cliq2China Ltd. All Rights Reserved.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutItem(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      onTap: () {},
      trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
    );
  }
}
