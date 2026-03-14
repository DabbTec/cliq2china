import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../auth_controller.dart';
import '../../../core/utils/validators.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: AppColors.textPrimary)
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create Account', 
                    style: AppTypography.h1.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text('Join Cliq2China today', style: AppTypography.bodyLarge),
                  const SizedBox(height: 32),
                  _buildRoleSelector(),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: nameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your name',
                    prefixIcon: Icons.person_outline,
                    validator: (v) => AppValidators.validateRequired(v, 'Name'),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: emailController,
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: AppValidators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: passwordController,
                    labelText: 'Password',
                    hintText: 'Create a password',
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    validator: AppValidators.validatePassword,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Repeat password',
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (v) {
                      if (v != passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Obx(() => PrimaryButton(
                    text: 'Sign Up',
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        controller.signup(
                          nameController.text, 
                          emailController.text, 
                          passwordController.text
                        );
                      }
                    },
                  )),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: AppTypography.bodyMedium,
                          children: [
                            TextSpan(
                              text: 'Log In',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('I am signing up as a:', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(() => _RoleOption(
                    title: 'Buyer',
                    icon: Icons.shopping_bag_outlined,
                    isSelected: controller.signupRole.value == 'buyer',
                    onTap: () => controller.signupRole.value = 'buyer',
                  )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => _RoleOption(
                    title: 'Seller',
                    icon: Icons.storefront_outlined,
                    isSelected: controller.signupRole.value == 'seller',
                    onTap: () => controller.signupRole.value = 'seller',
                  )),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey200),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppColors.textSecondary, size: 28),
            const SizedBox(height: 8),
            Text(title,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }
}
