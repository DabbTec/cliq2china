import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../auth_controller.dart';

class RoleSelectionView extends GetView<AuthController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text('How do you want to use', style: AppTypography.bodyLarge),
              Text('Cliq2China?', style: AppTypography.h1.copyWith(color: AppColors.primary)),
              const SizedBox(height: 40),
              _RoleCard(
                title: 'I want to Buy',
                subtitle: 'Find products from China and get them delivered to Nigeria.',
                icon: Icons.shopping_bag,
                onTap: () => controller.selectRole('buyer'),
              ),
              const SizedBox(height: 24),
              _RoleCard(
                title: 'I want to Sell',
                subtitle: 'Manage your inventory and sell to customers across Nigeria.',
                icon: Icons.storefront,
                onTap: () => controller.selectRole('seller'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.h3),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
