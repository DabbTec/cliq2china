import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/password_strength_indicator.dart';
import 'forgot_password_modal.dart';

import '../auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  bool isBuyer = true; // Switcher for Signup
  bool rememberMe = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedCountryCode = '+234'; // Default to Nigeria

  // Controllers for Login
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Controllers for Buyer Signup
  final buyerNameController = TextEditingController();
  final buyerEmailController = TextEditingController();
  final buyerPhoneController = TextEditingController();
  final buyerPasswordController = TextEditingController();
  final buyerConfirmPasswordController = TextEditingController();

  // Controllers for Seller Signup
  final businessNameController = TextEditingController();
  final businessEmailController = TextEditingController();
  final businessPhoneController = TextEditingController();
  final sellerPasswordController = TextEditingController();
  final sellerConfirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    buyerPasswordController.addListener(() => setState(() {}));
    sellerPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    buyerNameController.dispose();
    buyerEmailController.dispose();
    buyerPhoneController.dispose();
    buyerPasswordController.dispose();
    buyerConfirmPasswordController.dispose();
    businessNameController.dispose();
    businessEmailController.dispose();
    businessPhoneController.dispose();
    sellerPasswordController.dispose();
    sellerConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // Parent dashboard handles this
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 60,
                ), // Increased from 30 to move content down
                // Login/Signup Switcher
                Container(
                  height: 44, // Reduced from 50
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildSwitchItem(
                        'Log In',
                        isLogin,
                        () => setState(() => isLogin = true),
                      ),
                      _buildSwitchItem(
                        'Sign Up',
                        !isLogin,
                        () => setState(() => isLogin = false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20), // Reduced from 24
                // Welcome Section
                _buildWelcomeHeader(),

                const SizedBox(height: 24), // Reduced from 32
                // Dynamic Form
                Form(
                  key: _formKey,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLogin ? _buildLoginForm() : _buildSignupSection(),
                  ),
                ),

                const SizedBox(height: 24),

                // Login/Signup Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _authController.isLoading.value
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                if (isLogin) {
                                  _authController.login(
                                    emailController.text,
                                    passwordController.text,
                                    rememberMe: rememberMe,
                                  );
                                } else {
                                  if (isBuyer) {
                                    _authController.signupRole.value = 'buyer';
                                    _authController.signup(
                                      name: buyerNameController.text,
                                      email: buyerEmailController.text,
                                      password: buyerPasswordController.text,
                                      phone:
                                          '$_selectedCountryCode${buyerPhoneController.text}',
                                      onSuccess: () =>
                                          setState(() => isLogin = true),
                                    );
                                  } else {
                                    _authController.signupRole.value = 'seller';
                                    _authController.signup(
                                      name: businessNameController.text,
                                      email: businessEmailController.text,
                                      password: sellerPasswordController.text,
                                      phone:
                                          '$_selectedCountryCode${businessPhoneController.text}',
                                      businessName: businessNameController.text,
                                      onSuccess: () =>
                                          setState(() => isLogin = true),
                                    );
                                  }
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _authController.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(isLogin ? 'Log In' : 'Sign Up'),
                    ),
                  ),
                ),

                if (isLogin) ...[
                  const SizedBox(height: 24),
                  // Divider
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Google Login
                  SizedBox(
                    width: double.infinity,
                    height: 48, // Reduced from 56
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://www.gstatic.com/images/branding/product/2x/googleg_96dp.png',
                            height: 20,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isActive
                  ? const Color(0xFF334155)
                  : const Color(0xFF94A3B8),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Image.asset(
          'assets/images/c2cheader-logo.png',
          height: 26,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 4),
        Text(
          isLogin
              ? 'Sign in and explore the best deals from China'
              : 'Join Cliq2China and start your journey today',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          'Email',
          emailController,
          hint: 'example@email.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Password',
          passwordController,
          isPassword: true,
          obscureText: _obscurePassword,
          onToggleVisibility: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: rememberMe,
                    onChanged: (v) => setState(() => rememberMe = v!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(color: Color(0xFF94A3B8)),
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Remember me',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const ForgotPasswordModal(),
                );
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignupSection() {
    return Column(
      key: const ValueKey('signup_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role Switcher (Buyer/Seller)
        Container(
          height: 38,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              _buildRoleItem(
                'Buyer',
                isBuyer,
                () => setState(() => isBuyer = true),
              ),
              _buildRoleItem(
                'Seller',
                !isBuyer,
                () => setState(() => isBuyer = false),
              ),
            ],
          ),
        ),

        // Dynamic Signup Form
        isBuyer ? _buildBuyerSignupForm() : _buildSellerSignupForm(),
      ],
    );
  }

  Widget _buildRoleItem(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCountryCode,
                  onChanged: (value) =>
                      setState(() => _selectedCountryCode = value!),
                  items: [
                    DropdownMenuItem(
                      value: '+234',
                      child: Row(
                        children: [
                          const Text('🇳🇬 ', style: TextStyle(fontSize: 18)),
                          Text('+234', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: '+86',
                      child: Row(
                        children: [
                          const Text('🇨🇳 ', style: TextStyle(fontSize: 18)),
                          Text('+86', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 14),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: '800 000 0000',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBuyerSignupForm() {
    return Column(
      key: const ValueKey('buyer_signup'),
      children: [
        _buildTextField('Full Name', buyerNameController, hint: 'Mikky Brown'),
        const SizedBox(height: 16),
        _buildTextField(
          'Email',
          buyerEmailController,
          hint: 'example@email.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildPhoneField('Phone Number', buyerPhoneController),
        const SizedBox(height: 16),
        _buildTextField(
          'Create Password',
          buyerPasswordController,
          isPassword: true,
          obscureText: _obscurePassword,
          onToggleVisibility: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        PasswordStrengthIndicator(password: buyerPasswordController.text),
        const SizedBox(height: 16),
        _buildTextField(
          'Confirm Password',
          buyerConfirmPasswordController,
          isPassword: true,
          obscureText: _obscureConfirmPassword,
          onToggleVisibility: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
          validator: (value) {
            if (value != buyerPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSellerSignupForm() {
    return Column(
      key: const ValueKey('seller_signup'),
      children: [
        _buildTextField(
          'Business Name',
          businessNameController,
          hint: 'e.g. Mikky Global Stores',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Business Email',
          businessEmailController,
          hint: 'business@email.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildPhoneField('Business Phone', businessPhoneController),
        const SizedBox(height: 16),
        _buildTextField(
          'Create Password',
          sellerPasswordController,
          isPassword: true,
          obscureText: _obscurePassword,
          onToggleVisibility: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        PasswordStrengthIndicator(password: sellerPasswordController.text),
        const SizedBox(height: 16),
        _buildTextField(
          'Confirm Password',
          sellerConfirmPasswordController,
          isPassword: true,
          obscureText: _obscureConfirmPassword,
          onToggleVisibility: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
          validator: (value) {
            if (value != sellerPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String hint = '',
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    Widget? prefixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          style: const TextStyle(fontSize: 14),
          keyboardType: keyboardType,
          validator:
              validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: prefixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: onToggleVisibility,
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[400],
                      size: 18,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
