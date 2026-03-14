import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/widgets/buttons.dart';

class ReferralView extends StatelessWidget {
  const ReferralView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Refer & Earn', style: AppTypography.h2.copyWith(color: AppColors.primary))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const Icon(Icons.share_outlined, size: 64, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text('Share the Love', style: AppTypography.h3),
                  const SizedBox(height: 8),
                  Text('Invite your friends to Cliq2China and earn ₦1,000 for every successful signup!', textAlign: TextAlign.center, style: AppTypography.bodyMedium),
                  const SizedBox(height: 32),
                  _buildReferralCode('CLIQ-2026-X'),
                  const SizedBox(height: 24),
                  PrimaryButton(text: 'Share via WhatsApp', onPressed: () {}),
                  const SizedBox(height: 12),
                  SecondaryButton(text: 'Copy Referral Link', onPressed: () {}),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildReferralStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCode(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey200, style: BorderStyle.solid)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(code, style: AppTypography.h3.copyWith(color: AppColors.primary)),
          const Icon(Icons.copy, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildReferralStats() {
    return Row(
      children: [
        _statItem('5', 'Invites'),
        _statItem('3', 'Successful'),
        _statItem('₦3,000', 'Earned'),
      ],
    );
  }

  Widget _statItem(String val, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(val, style: AppTypography.h3),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
