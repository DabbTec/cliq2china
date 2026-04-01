import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../seller_controller.dart';

class VerificationView extends GetView<SellerController> {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final store = controller.store.value;

    final TextEditingController taxIdController = TextEditingController(
      text: controller.verificationStatus['tax_id'] ?? '',
    );
    final TextEditingController bankNameController = TextEditingController(
      text: store?.metadata?['bank_name'] ?? '',
    );
    final TextEditingController accountNoController = TextEditingController(
      text: store?.metadata?['bank_account'] ?? '',
    );

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
          'Verification & Payouts',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compliance & Finance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit your details for verification and payout setup.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              'Tax ID / CAC Number',
              taxIdController,
              Icons.description_outlined,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              'Bank Name',
              bankNameController,
              Icons.account_balance_outlined,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              'Account Number',
              accountNoController,
              Icons.credit_card_outlined,
            ),
            const SizedBox(height: 48),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.submitNewVerification({
                            'tax_id': taxIdController.text,
                            'bank_name': bankNameController.text,
                            'bank_account': accountNoController.text,
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Verification',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
