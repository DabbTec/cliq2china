import 'package:get/get.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../modules/auth/views/role_selection_view.dart';
import '../modules/buyer/views/buyer_dashboard.dart';
import '../modules/seller/views/seller_dashboard.dart';
import '../modules/loan/views/loan_dashboard.dart';
import '../modules/referral/views/referral_view.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/admin/views/admin_dashboard.dart';
import '../modules/admin/admin_controller.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/onboarding/onboarding_controller.dart';
import '../modules/auth/auth_controller.dart';
import '../modules/buyer/buyer_controller.dart';
import '../modules/seller/seller_controller.dart';
import '../modules/loan/loan_controller.dart';
import '../modules/web_landing/views/web_landing_view.dart';
import '../modules/seller/views/add_product_view.dart';

class AppPages {
  static const initial = Routes.onboarding;
  static const webInitial = Routes.landing;

  static final routes = [
    GetPage(
      name: Routes.landing,
      page: () => const WebLandingView(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: Routes.signup,
      page: () => const SignupView(),
    ),
    GetPage(
      name: Routes.roleSelection,
      page: () => const RoleSelectionView(),
    ),
    GetPage(
      name: Routes.buyerDashboard,
      page: () => const BuyerDashboard(),
      binding: BindingsBuilder(() {
        Get.put(BuyerController());
        if (!Get.isRegistered<AuthController>()) {
          Get.put(AuthController());
        }
      }),
    ),
    GetPage(
      name: Routes.sellerDashboard,
      page: () => const SellerDashboard(),
      binding: BindingsBuilder(() {
        Get.put(SellerController());
        if (!Get.isRegistered<AuthController>()) {
          Get.put(AuthController());
        }
      }),
    ),
    GetPage(
      name: Routes.addProduct,
      page: () => const AddProductView(),
    ),
    GetPage(
      name: Routes.loanDashboard,
      page: () => const LoanDashboard(),
      binding: BindingsBuilder(() {
        Get.put(LoanController());
        if (!Get.isRegistered<AuthController>()) {
          Get.put(AuthController());
        }
      }),
    ),
    GetPage(
      name: Routes.referral,
      page: () => const ReferralView(),
    ),
    GetPage(
      name: Routes.chat,
      page: () => const ChatView(),
    ),
    GetPage(
      name: Routes.adminDashboard,
      page: () => const AdminDashboard(),
      binding: BindingsBuilder(() {
        Get.put(AdminController());
      }),
    ),
  ];
}

abstract class Routes {
  static const landing = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const roleSelection = '/role-selection';
  static const buyerDashboard = '/buyer-dashboard';
  static const sellerDashboard = '/seller-dashboard';
  static const addProduct = '/add-product';
  static const loanDashboard = '/loan-dashboard';
  static const referral = '/referral';
  static const chat = '/chat';
  static const adminDashboard = '/admin-dashboard';
}
