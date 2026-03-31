import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/password_strength_indicator.dart';
import '../auth_controller.dart';
import '../../../core/utils/validators.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final AuthController controller = Get.find<AuthController>();
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final businessNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxString selectedCountryCode = '+234'.obs;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    businessNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false, // Parent dashboard handles this
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
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
                  Text(
                    'Create Account',
                    style: AppTypography.h1.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text('Join Cliq2China today', style: AppTypography.bodyLarge),
                  const SizedBox(height: 32),
                  _buildRoleSelector(),
                  const SizedBox(height: 24),
                  Obx(() {
                    final isSeller = controller.signupRole.value == 'seller';
                    return Column(
                      children: [
                        CustomTextField(
                          controller: nameController,
                          labelText: isSeller
                              ? 'Business Owner Name'
                              : 'Full Name',
                          hintText: 'Enter your name',
                          prefixIcon: Icons.person_outline,
                          validator: (v) =>
                              AppValidators.validateRequired(v, 'Name'),
                        ),
                        const SizedBox(height: 16),
                        if (isSeller) ...[
                          CustomTextField(
                            controller: businessNameController,
                            labelText: 'Business Name',
                            hintText: 'Enter your business name',
                            prefixIcon: Icons.business_outlined,
                            validator: (v) => AppValidators.validateRequired(
                              v,
                              'Business Name',
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        CustomTextField(
                          controller: emailController,
                          labelText: isSeller
                              ? 'Business Email'
                              : 'Email Address',
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: AppValidators.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone Number',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Obx(
                                  () => Container(
                                    height: 56,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.grey200,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedCountryCode.value,
                                        onChanged: (v) =>
                                            selectedCountryCode.value = v!,
                                        items: const [
                                          DropdownMenuItem(
                                            value: '+234',
                                            child: Row(
                                              children: [
                                                Text(
                                                  '🇳🇬 ',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  '+234',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: '+86',
                                            child: Row(
                                              children: [
                                                Text(
                                                  '🇨🇳 ',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  '+86',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomTextField(
                                    controller: phoneController,
                                    labelText: 'Number',
                                    hintText: '800 000 0000',
                                    keyboardType: TextInputType.phone,
                                    validator: (v) =>
                                        AppValidators.validateRequired(
                                          v,
                                          'Phone',
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                  CustomTextField(
                    controller: passwordController,
                    labelText: 'Password',
                    hintText: 'Create a password',
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    validator: AppValidators.validatePassword,
                  ),
                  PasswordStrengthIndicator(password: passwordController.text),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Repeat password',
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (v) {
                      if (v != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Obx(
                    () => PrimaryButton(
                      text: 'Sign Up',
                      isLoading: controller.isLoading.value,
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          controller.signup(
                            name: nameController.text,
                            email: emailController.text,
                            password: passwordController.text,
                            phone:
                                '${selectedCountryCode.value}${phoneController.text}',
                            businessName: businessNameController.text,
                            onSuccess: () => Get.back(),
                          );
                        }
                      },
                    ),
                  ),
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
                                fontWeight: FontWeight.bold,
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
        Text(
          'I am signing up as a:',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _RoleOption(
                  title: 'Buyer',
                  icon: Icons.shopping_bag_outlined,
                  isSelected: controller.signupRole.value == 'buyer',
                  onTap: () => controller.signupRole.value = 'buyer',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => _RoleOption(
                  title: 'Seller',
                  icon: Icons.storefront_outlined,
                  isSelected: controller.signupRole.value == 'seller',
                  onTap: () => controller.signupRole.value = 'seller',
                ),
              ),
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
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
