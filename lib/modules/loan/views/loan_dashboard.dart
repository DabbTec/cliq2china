import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../loan_controller.dart';

class LoanDashboard extends GetView<LoanController> {
  const LoanDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoanController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Loan Dashboard', style: AppTypography.h2.copyWith(color: AppColors.primary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWalletCard(),
            const SizedBox(height: 32),
            Text('Recent Applications', style: AppTypography.h3),
            const SizedBox(height: 16),
            _buildLoanHistory(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Apply for Loan', style: AppTypography.button),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF1565C0)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available Credit Limit', style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Obx(() => Text('₦${controller.availableCredit.value.toStringAsFixed(2)}', style: AppTypography.h1.copyWith(color: Colors.white, fontSize: 32))),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWalletAction(Icons.account_balance_wallet, 'Wallet'),
              _buildWalletAction(Icons.history, 'History'),
              _buildWalletAction(Icons.help_outline, 'Help'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.bodySmall.copyWith(color: Colors.white)),
      ],
    );
  }

  Widget _buildLoanHistory() {
    return Obx(() {
      if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
      if (controller.loans.isEmpty) return const Center(child: Text('No applications yet.'));

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.loans.length,
        itemBuilder: (context, index) {
          final loan = controller.loans[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey200)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: _getStatusColor(loan.status).withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.assignment, color: _getStatusColor(loan.status), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loan.purpose, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text('₦${loan.amount.toStringAsFixed(0)}', style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
                _buildStatusBadge(loan.status),
              ],
            ),
          );
        },
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'under_review': return Colors.orange;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _getStatusColor(status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(
        status.capitalizeFirst!,
        style: AppTypography.bodySmall.copyWith(color: _getStatusColor(status), fontWeight: FontWeight.bold),
      ),
    );
  }
}
