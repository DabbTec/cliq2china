import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/services/app_update_service.dart';
import '../../auth/auth_controller.dart';
import '../../auth/views/login_view.dart';
import '../buyer_controller.dart';
import '../../../routes/app_pages.dart';

class BuyerProfileView extends GetView<AuthController> {
  const BuyerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
    return Obx(() {
      if (controller.user.value == null) {
        return _buildAuthGateway();
      }
      return _buildProfileContent();
    });
  }

  Widget _buildAuthGateway() {
    return const LoginView();
  }

  Widget _buildProfileContent() {
    final user = controller.user.value;
    if (user == null) return _buildAuthGateway();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // 1. Premium Header
          SliverAppBar(
            expandedHeight: 160.h,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.black,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Color(0xFF1A1A1A)],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 20.w, bottom: 20.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 70.w,
                        height: 70.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 35.w,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 40.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Order Summary Icons (Matching DSers Flow)
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOrderIcon('Processing', Icons.sync, 1),
                  _buildOrderIcon('Shipped', Icons.local_shipping_outlined, 2),
                  _buildOrderIcon('To Receive', Icons.home_work_outlined, 3),
                  _buildOrderIcon('Completed', Icons.check_circle_outline, 4),
                ],
              ),
            ),
          ),

          // 3. Menu Sections
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('MY ACTIVITY'),
                _buildMenuCard([
                  _buildMenuItem(Icons.favorite_border, 'My Wishlist', () {
                    final buyerController = Get.find<BuyerController>();
                    buyerController.currentIndex.value = 2;
                    Get.offAllNamed(Routes.buyerDashboard);
                  }),
                  _buildMenuItem(Icons.star_border, 'My Reviews', () {}),
                  _buildMenuItem(
                    Icons.share_outlined,
                    'Refer & Earn',
                    () => Get.toNamed(Routes.referral),
                  ),
                ]),
                SizedBox(height: 20.h),
                _buildSectionHeader('FINANCE'),
                _buildMenuCard([
                  _buildMenuItem(
                    Icons.account_balance_wallet_outlined,
                    'Loan Dashboard',
                    () => Get.toNamed(Routes.loanDashboard),
                  ),
                  _buildMenuItem(
                    Icons.confirmation_number_outlined,
                    'My Coupons',
                    () {},
                  ),
                ]),
                SizedBox(height: 20.h),
                _buildSectionHeader('SETTINGS'),
                _buildMenuCard([
                  _buildMenuItem(
                    Icons.person_outline,
                    'Edit Profile',
                    () => Get.toNamed(Routes.editProfile),
                  ),
                  _buildMenuItem(
                    Icons.location_on_outlined,
                    'Shipping Addresses',
                    () => Get.toNamed(Routes.shippingAddresses),
                  ),
                  _buildMenuItem(
                    Icons.security_outlined,
                    'Security & Privacy',
                    () => Get.toNamed(Routes.securityPrivacy),
                  ),
                  _buildMenuItem(
                    Icons.help_outline,
                    'Help Center',
                    () => Get.toNamed(Routes.helpCenter),
                  ),
                  _buildMenuItem(
                    Icons.system_update_outlined,
                    'Check for Updates',
                    () => AppUpdateService.to.checkForUpdates(
                      showNoUpdateSnackBar: true,
                    ),
                  ),
                ]),
                SizedBox(height: 30.h),
                _buildLogoutButton(),
                SizedBox(height: 50.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderIcon(String label, IconData icon, int index) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(Routes.buyerOrders, arguments: {'initialIndex': index}),
      child: Column(
        children: [
          Icon(icon, color: Colors.black, size: 28.sp),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.black, size: 22.sp),
      title: Text(
        title,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.chevron_right, size: 18.sp, color: Colors.grey),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => controller.logout(),
        icon: Icon(Icons.logout, color: Colors.red, size: 20.sp),
        label: Text(
          'LOGOUT ACCOUNT',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
            letterSpacing: 1,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          backgroundColor: Colors.red.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.w),
          ),
        ),
      ),
    );
  }
}
