import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';

class WebLandingView extends StatelessWidget {
  const WebLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navbar
            _buildNavbar(isDesktop),
            
            // Hero Section
            _buildHero(context, isDesktop),
            
            // Features Section
            _buildFeatures(isDesktop),
            
            // App Preview Section
            _buildAppPreview(isDesktop),
            
            // Footer
            _buildFooter(isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag, color: AppColors.primary, size: 32),
              const SizedBox(width: 12),
              Text(
                'Cliq2China',
                style: AppTypography.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isDesktop)
            Row(
              children: [
                _navLink('Features'),
                _navLink('How it works'),
                _navLink('Support'),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Download Now', style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          else
            IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        ],
      ),
    );
  }

  Widget _navLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: isDesktop ? 100 : 60,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: _heroContent(isDesktop)),
                Expanded(child: _heroImage()),
              ],
            )
          : Column(
              children: [
                _heroContent(isDesktop),
                const SizedBox(height: 60),
                _heroImage(),
              ],
            ),
    );
  }

  Widget _heroContent(bool isDesktop) {
    return Column(
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            'The Ultimate Marketplace',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Connect Directly to\nChinese Markets.',
          style: (isDesktop ? AppTypography.h1 : AppTypography.h2).copyWith(
            fontSize: isDesktop ? 64 : 36,
            height: 1.1,
            color: AppColors.primary,
          ),
          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          'Cliq2China bridges the gap between buyers and sellers, providing a seamless marketplace for quality products from China with secure payments and integrated financing.',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            _downloadButton('App Store', Icons.apple),
            const SizedBox(width: 16),
            _downloadButton('Google Play', Icons.play_arrow),
          ],
        ),
      ],
    );
  }

  Widget _heroImage() {
    return Center(
      child: Container(
        height: 500,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
          border: Border.all(color: Colors.black, width: 8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(
            'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=800',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _downloadButton(String store, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Download on the',
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
              Text(
                store,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: 100,
      ),
      child: Column(
        children: [
          Text('Why Choose Cliq2China?', style: AppTypography.h2),
          const SizedBox(height: 16),
          Text(
            'Everything you need to trade across borders successfully.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 60),
          isDesktop
              ? Row(
                  children: [
                    _featureCard('Direct Sourcing', Icons.hub, 'Buy directly from verified Chinese manufacturers and sellers.'),
                    _featureCard('Secure Logistics', Icons.local_shipping, 'End-to-end tracking and secure delivery for all your purchases.'),
                    _featureCard('Smart Financing', Icons.account_balance_wallet, 'Get instant shopping loans to scale your business or personal needs.'),
                  ],
                )
              : Column(
                  children: [
                    _featureCard('Direct Sourcing', Icons.hub, 'Buy directly from verified Chinese manufacturers and sellers.'),
                    _featureCard('Secure Logistics', Icons.local_shipping, 'End-to-end tracking and secure delivery for all your purchases.'),
                    _featureCard('Smart Financing', Icons.account_balance_wallet, 'Get instant shopping loans to scale your business or personal needs.'),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _featureCard(String title, IconData icon, String desc) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 24),
            Text(title, style: AppTypography.h3),
            const SizedBox(height: 16),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppPreview(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: 100,
      ),
      color: Colors.black,
      child: Column(
        children: [
          Text(
            'Ready to get started?',
            style: AppTypography.h2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Download our mobile app to experience the full marketplace.',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _downloadButton('App Store', Icons.apple),
              const SizedBox(width: 16),
              _downloadButton('Google Play', Icons.play_arrow),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: 60,
      ),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2026 Cliq2China. All rights reserved.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              Row(
                children: [
                  _footerLink('Terms'),
                  _footerLink('Privacy'),
                  _footerLink('Contact'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        title,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
