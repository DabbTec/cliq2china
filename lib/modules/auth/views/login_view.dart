import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../auth_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/validators.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text('Welcome back to', style: AppTypography.bodyLarge),
                  Text('Cliq2China', style: AppTypography.h1.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 32),
                  _buildRoleSelector(),
                  const SizedBox(height: 32),
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
                    hintText: 'Enter your password',
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    validator: AppValidators.validatePassword,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Forgot Password?', 
                        style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() => PrimaryButton(
                    text: 'Login',
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        controller.login(emailController.text, passwordController.text);
                      }
                    },
                  )),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: AppTypography.bodySmall),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SecondaryButton(
                    text: 'Login with Google',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => Get.offAllNamed(Routes.buyerDashboard),
                      child: Text('Skip to Marketplace (Guest)', 
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Don\'t have an account? ', style: AppTypography.bodyMedium),
                      GestureDetector(
                        onTap: () => Get.toNamed(Routes.signup),
                        child: Text('Sign Up', 
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary, 
                            fontWeight: FontWeight.bold
                          )),
                      ),
                    ],
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
        Text('Login as:', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(() => _RoleOption(
                    title: 'Buyer',
                    icon: Icons.shopping_bag_outlined,
                    isSelected: controller.loginRole.value == 'buyer',
                    onTap: () => controller.loginRole.value = 'buyer',
                  )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => _RoleOption(
                    title: 'Seller',
                    icon: Icons.storefront_outlined,
                    isSelected: controller.loginRole.value == 'seller',
                    onTap: () => controller.loginRole.value = 'seller',
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
