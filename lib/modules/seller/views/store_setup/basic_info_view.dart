import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/auth_controller.dart';
import '../../seller_controller.dart';

class BasicInfoView extends GetView<SellerController> {
  const BasicInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final store = controller.store.value;

    final TextEditingController nameController = TextEditingController(
      text: controller.storeName,
    );
    final TextEditingController descriptionController = TextEditingController(
      text: store?.description ?? '',
    );
    final TextEditingController emailController = TextEditingController(
      text: store?.email ?? authController.user.value?.email ?? '',
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
          'Basic Information',
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
              'Store Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help buyers recognize your brand easily.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildTextField('Store Name', nameController, Icons.store_outlined),
            const SizedBox(height: 24),
            _buildTextField(
              'Store Description',
              descriptionController,
              Icons.description_outlined,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              'Contact Email (Constant)',
              emailController,
              Icons.email_outlined,
              enabled: false,
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
                          if (nameController.text.trim().isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Store Name cannot be empty',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red.withValues(
                                alpha: 0.1,
                              ),
                              colorText: Colors.red,
                            );
                            return;
                          }
                          controller.updateStoreInfo({
                            'name': nameController.text,
                            'description': descriptionController.text,
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
                          'Save Changes',
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
    bool enabled = true,
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
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
            filled: true,
            fillColor: enabled ? const Color(0xFFF8F9FA) : Colors.grey[100],
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
