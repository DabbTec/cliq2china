import 'package:get/get.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../modules/buyer/views/buyer_dashboard.dart';
import '../modules/seller/views/seller_dashboard.dart';
import '../modules/loan/views/loan_dashboard.dart';
import '../modules/referral/views/referral_view.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/onboarding/onboarding_controller.dart';
import '../modules/auth/auth_controller.dart';
import '../modules/buyer/buyer_controller.dart';
import '../modules/seller/seller_controller.dart';
import '../modules/loan/loan_controller.dart';
import '../modules/seller/views/add_product_view.dart';

import '../modules/buyer/views/product_details_view.dart';
import '../modules/buyer/views/search_view.dart';
import '../modules/buyer/views/store_view.dart';
import '../modules/buyer/views/buyer_orders_view.dart';
import '../modules/buyer/views/edit_profile_view.dart';
import '../modules/buyer/views/shipping_addresses_view.dart';
import '../modules/buyer/views/security_privacy_view.dart';
import '../modules/buyer/views/help_center_view.dart';
import '../modules/buyer/views/about_view.dart';
import '../modules/seller/views/seller_payouts_view.dart';
import '../modules/seller/views/seller_analytics_view.dart';
import '../modules/seller/views/seller_customers_view.dart';
import '../modules/seller/views/seller_discounts_view.dart';
import '../modules/seller/views/seller_store_setup_view.dart';
import '../modules/seller/views/bulk_import_view.dart';

import 'app_routes.dart';
export 'app_routes.dart';

class AppPages {
  static const initial = Routes.onboarding;

  static final routes = [
    GetPage(name: Routes.buyerOrders, page: () => const BuyerOrdersView()),
    GetPage(
      name: Routes.onboarding,
      page: () => OnboardingView(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }),
    ),
    GetPage(name: Routes.login, page: () => LoginView()),
    GetPage(name: Routes.signup, page: () => SignupView()),
    GetPage(
      name: Routes.buyerDashboard,
      page: () => BuyerDashboard(),
      binding: BindingsBuilder(() {
        Get.put(BuyerController());
        if (!Get.isRegistered<AuthController>()) {
          Get.put(AuthController());
        }
      }),
    ),
    GetPage(
      name: Routes.productDetails,
      page: () => const ProductDetailsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<BuyerController>()) {
          Get.put(BuyerController());
        }
      }),
    ),
    GetPage(
      name: Routes.search,
      page: () => const SearchView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<BuyerController>()) {
          Get.put(BuyerController());
        }
      }),
    ),
    GetPage(
      name: Routes.store,
      page: () => const StoreView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<BuyerController>()) {
          Get.put(BuyerController());
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
    GetPage(name: Routes.addProduct, page: () => const AddProductView()),
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
    GetPage(name: Routes.referral, page: () => const ReferralView()),
    GetPage(name: Routes.chat, page: () => const ChatView()),
    GetPage(name: Routes.editProfile, page: () => const EditProfileView()),
    GetPage(
      name: Routes.shippingAddresses,
      page: () => const ShippingAddressesView(),
    ),
    GetPage(
      name: Routes.securityPrivacy,
      page: () => const SecurityPrivacyView(),
    ),
    GetPage(name: Routes.helpCenter, page: () => const HelpCenterView()),
    GetPage(name: Routes.about, page: () => const AboutView()),
    // Seller Pages
    GetPage(name: Routes.sellerPayouts, page: () => const SellerPayoutsView()),
    GetPage(
      name: Routes.sellerAnalytics,
      page: () => const SellerAnalyticsView(),
    ),
    GetPage(
      name: Routes.sellerCustomers,
      page: () => const SellerCustomersView(),
    ),
    GetPage(
      name: Routes.sellerDiscounts,
      page: () => const SellerDiscountsView(),
    ),
    GetPage(
      name: Routes.sellerStoreSetup,
      page: () => const SellerStoreSetupView(),
    ),
    GetPage(name: Routes.bulkImport, page: () => const BulkImportView()),
  ];
}
