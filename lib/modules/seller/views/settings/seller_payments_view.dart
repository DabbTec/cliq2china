import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../seller_controller.dart';

class SellerPaymentsView extends GetView<SellerController> {
  const SellerPaymentsView({super.key});

  void _showAddBankDetailsModal(BuildContext context) {
    final store = controller.store.value;
    final bankNameController = TextEditingController(
      text: store?.metadata?['bank_name'] ?? '',
    );
    final accountNumberController = TextEditingController(
      text: store?.metadata?['account_number'] ?? '',
    );
    final accountNameController = TextEditingController(
      text: store?.metadata?['account_name'] ?? '',
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bank Account Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 24),
              _buildModalTextField('Bank Name', bankNameController),
              const SizedBox(height: 16),
              _buildModalTextField('Account Number', accountNumberController),
              const SizedBox(height: 16),
              _buildModalTextField('Account Name', accountNameController),
              const SizedBox(height: 32),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: controller.isUpdatingStore.value
                        ? null
                        : () {
                            if (bankNameController.text.trim().isEmpty ||
                                accountNumberController.text.trim().isEmpty ||
                                accountNameController.text.trim().isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please fill in all bank details',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red.withValues(
                                  alpha: 0.1,
                                ),
                                colorText: Colors.red,
                              );
                              return;
                            }
                            controller.updateStoreInfo({
                              'metadata': {
                                'bank_name': bankNameController.text,
                                'account_number': accountNumberController.text,
                                'account_name': accountNameController.text,
                              },
                            });
                            Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: controller.isUpdatingStore.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Bank Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

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
          'Payments',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        final store = controller.store.value;
        final bankName = store?.metadata?['bank_name'] ?? 'Not set';
        final accountNumber = store?.metadata?['account_number'] ?? 'Not set';

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildPaymentSection('Payout Methods', [
              _paymentItem(
                'Bank Transfer',
                '$bankName • $accountNumber',
                Icons.account_balance,
                onTap: () => _showAddBankDetailsModal(context),
              ),
              _paymentItem('Digital Wallet', 'Not connected', Icons.wallet),
            ]),
            const SizedBox(height: 32),
            _buildPaymentSection('Transaction History', [
              _paymentItem(
                'Recent Payouts',
                'View your last 30 days',
                Icons.history,
              ),
              _paymentItem(
                'Pending Balance',
                '¥ 12,450.00',
                Icons.pending_actions,
              ),
            ]),
          ],
        );
      }),
    );
  }

  Widget _buildPaymentSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _paymentItem(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}
