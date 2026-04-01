import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../seller_controller.dart';

class OperationsView extends GetView<SellerController> {
  const OperationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final store = controller.store.value;

    final TextEditingController shippingController = TextEditingController(
      text: store?.metadata?['shipping_rates'] ?? '',
    );
    final TextEditingController return_policyController = TextEditingController(
      text: store?.metadata?['return_policy'] ?? '',
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
          'Store Operations',
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
              'Shipping & Policy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure how you handle shipping, returns, and working hours.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Shipping'),
            _buildTextField(
              'Shipping Rates',
              shippingController,
              Icons.local_shipping_outlined,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Policies'),
            _buildTextField(
              'Return Policy',
              return_policyController,
              Icons.assignment_return_outlined,
              maxLines: 4,
            ),
            const SizedBox(height: 48),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.isUpdatingStore.value
                      ? null
                      : () {
                          if (shippingController.text.trim().isEmpty ||
                              return_policyController.text.trim().isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Please fill in all required fields',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red.withValues(
                                alpha: 0.1,
                              ),
                              colorText: Colors.red,
                            );
                            return;
                          }
                          controller
                              .updateStoreInfo({
                                'metadata': {
                                  'shipping_rates': shippingController.text,
                                  'return_policy': return_policyController.text,
                                },
                              })
                              .then((_) {
                                Get.back();
                                Get.snackbar(
                                  'Success',
                                  'Store information updated successfully',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green.withOpacity(
                                    0.1,
                                  ),
                                  colorText: Colors.green,
                                );
                              })
                              .catchError((error) {
                                Get.snackbar(
                                  'Error',
                                  'Failed to update store information: $error',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  colorText: Colors.red,
                                );
                              });
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
                          'Save Operations',
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
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
