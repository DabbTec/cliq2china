import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../data/models/product.dart';
import '../../../routes/app_pages.dart';
import '../../auth/auth_controller.dart';
import '../seller_controller.dart';
import '../../../core/utils/currency_service.dart';
import 'add_product_view.dart';

import 'seller_profile_view.dart';

class SellerDashboard extends GetView<SellerController> {
  const SellerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Obx(() {
          bool isMenuTab = controller.currentTabIndex.value == 4;

          return Stack(
            children: [
              Column(
                children: [
                  // Hide header completely for Menu tab to let items start from top
                  if (!isMenuTab) _buildHeader(),
                  Expanded(
                    child: Transform.translate(
                      offset: isMenuTab
                          ? Offset.zero
                          : const Offset(0, -10), // Pull up to meet the curve
                      child: Container(
                        decoration: BoxDecoration(
                          color: isMenuTab
                              ? Colors.black
                              : Colors
                                    .white, // Changed from AppColors.background to white
                          borderRadius: isMenuTab
                              ? BorderRadius.zero
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: IndexedStack(
                          index: controller.currentTabIndex.value,
                          children: [
                            const Center(
                              child: Text('Search Content'),
                            ), // Index 0
                            _buildHomeTab(), // Index 1
                            _buildOrdersTab(), // Index 2
                            _buildProductsTab(), // Index 3
                            _buildMenuTab(), // Index 4
                            const SellerProfileView(), // Index 5
                            _buildSettingsView(), // Index 6
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Floating Bottom Nav Bar
              if (MediaQuery.of(context).viewInsets.bottom == 0)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20,
                  child: Obx(() => _buildFloatingNavBar()),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    bool isSettingsMode = controller.currentTabIndex.value == 6;
    bool isMenuMode = controller.currentTabIndex.value == 4;
    // The nav bar only "morphs" into settings/close mode while in the Menu tab (index 4)
    // Once the user selects Settings, the nav bar returns smoothly to the main state
    bool showSettingsNav = isMenuMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left Side Icon (Search)
          _buildAbsorbingSideIcon(
            index: 0,
            icon: Icons.search,
            isLeft: true,
            isHidden: showSettingsNav,
          ),

          // Right Side Icon (Profile)
          _buildAbsorbingSideIcon(
            index: 5,
            icon: Icons.person,
            isLeft: false,
            isHidden: showSettingsNav,
          ),

          // The Morphing Pill
          _buildMorphingPill(showSettingsNav, isSettingsMode),
        ],
      ),
    );
  }

  Widget _buildAbsorbingSideIcon({
    required int index,
    required IconData icon,
    required bool isLeft,
    required bool isHidden,
  }) {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutBack,
      alignment: isHidden
          ? Alignment.center
          : (isLeft ? Alignment.centerLeft : Alignment.centerRight),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isHidden ? 0.0 : 1.0,
        child: _navItem(index, icon),
      ),
    );
  }

  Widget _buildMorphingPill(bool isMorphed, bool isSettingsPage) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutBack,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12), // Increased from 0.08
            blurRadius: 18, // Increased from 15
            offset: const Offset(0, 6), // Slightly deeper offset
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Settings Content (Visible only when morphed in Menu mode)
          if (isMorphed) ...[
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isMorphed ? 1.0 : 0.0,
              child: GestureDetector(
                onTap: () => controller.currentTabIndex.value = 6,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(Icons.settings, color: Colors.black, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Settings',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ],

          // Main Nav Icons (Visible only in non-morphed mode)
          if (!isMorphed) ...[
            _navItem(1, Icons.home),
            const SizedBox(width: 4),
            _navItem(2, Icons.inventory_2),
            const SizedBox(width: 4),
            _navItem(3, Icons.label),
          ],

          // Morphing Menu/Close Icon
          _buildMenuToCloseIcon(isMorphed, isSettingsPage),
        ],
      ),
    );
  }

  Widget _buildMenuToCloseIcon(bool isMorphed, bool isSettingsPage) {
    return GestureDetector(
      onTap: () {
        if (isMorphed) {
          // If the "X" is visible (Menu mode), it returns back to the Home tab
          controller.changeTab(1);
        } else {
          // If the standard Menu icon is visible, it goes to the Menu tab
          controller.changeTab(4);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38,
        height: 44,
        decoration: BoxDecoration(
          color:
              (isMorphed ||
                  controller.currentTabIndex.value == 4 ||
                  isSettingsPage)
              ? Colors.grey.withValues(alpha: 0.15)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 400),
          turns: isMorphed ? 0.25 : 0, // Partial rotation (90 degrees)
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              isMorphed ? Icons.close : Icons.menu,
              key: ValueKey(isMorphed ? 'close' : 'menu'),
              color: Colors.black,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title = 'Home';
    bool isMenuTab = controller.currentTabIndex.value == 4;

    switch (controller.currentTabIndex.value) {
      case 1:
        title = 'Store Name'; // Placeholder Store Name
        break;
      case 2:
        title = 'Orders';
        break;
      case 3:
        title = 'Products';
        break;
      case 4:
        title = 'Menu';
        break;
      case 6:
        title = 'Settings';
        break;
    }

    return Container(
      padding: const EdgeInsets.only(
        top: 60,
        left: 20,
        right: 20,
        bottom: 12,
      ), // Reduced from 30
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16), // Reduced from 32
          bottomRight: Radius.circular(16), // Reduced from 32
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (controller.currentTabIndex.value == 1)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1560179707-f14e90ef3623?q=80&w=100',
                      ), // Company placeholder
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (controller.currentTabIndex.value == 1)
                const SizedBox(width: 12),
              Text(
                title,
                style: AppTypography.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (controller.currentTabIndex.value == 3)
                IconButton(
                  onPressed: () => Get.toNamed(Routes.addProduct),
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                  ),
                ),
              if (controller.currentTabIndex.value == 6)
                const Icon(Icons.help_outline, color: Colors.white),

              if (!isMenuTab) ...[
                const SizedBox(width: 8),
                const Icon(Icons.notifications_none, color: Colors.white),
                const SizedBox(width: 16),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics Summary Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25, // Improved from 1.5 to prevent overflow
            children: [
              Obx(() {
                // Ensure GetX tracks location changes
                final _ = CurrencyService.to.currentLocation.value;
                const double salesYuan = 62.25; // Example Yuan for 12,450 Naira
                final localSales = CurrencyService.to.convertFromYuan(
                  salesYuan,
                );

                return _buildMetricCard(
                  'Total Sales',
                  '¥${salesYuan.toStringAsFixed(0)} ≈ ${CurrencyService.to.localCurrencySymbol}${localSales.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                  Icons.payments_outlined,
                  AppColors.primary,
                );
              }),
              _buildMetricCard(
                'Total Orders',
                '156',
                Icons.shopping_bag_outlined,
                Colors.orange,
              ),
              _buildMetricCard(
                'Total Products',
                '42',
                Icons.inventory_2_outlined,
                Colors.green,
              ),
              _buildMetricCard(
                'Total Customers',
                '1,204',
                Icons.people_outline,
                Colors.deepPurple,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickAction(
                  'Add Product',
                  Icons.add_circle_outline,
                  () => Get.toNamed(Routes.addProduct),
                ),
                _buildQuickAction(
                  'View Orders',
                  Icons.list_alt_outlined,
                  () => controller.changeTab(2),
                ),
                _buildQuickAction(
                  'Bulk Import',
                  Icons.cloud_download_outlined,
                  () => Get.snackbar(
                    'Coming Soon',
                    'The Bulk Import feature is currently under development.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black,
                    colorText: Colors.white,
                  ),
                ),
                _buildQuickAction('Marketing', Icons.campaign_outlined, () {}),
                _buildQuickAction('Store Setup', Icons.store_outlined, () {}),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Activities
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'No recent activities yet',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100), // Space for nav
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14), // Reduced from 18 to prevent overflow
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Slightly reduced from 20
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10, // Reduced from 15
            offset: const Offset(0, 4), // Reduced from 6
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6), // Reduced from 8
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8), // Reduced from 10
                ),
                child: Icon(icon, color: color, size: 20), // Reduced from 22
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ), // Reduced from 6
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Colors.green,
                      size: 10,
                    ), // Reduced from 12
                    const SizedBox(width: 2),
                    Text(
                      '+12%',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ), // Reduced from 10
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                // Added FittedBox to prevent text overflow
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, // Reverted to original white background
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.black87,
            ), // Reverted to black icons
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87, // Reverted to black text
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Column(
      children: [
        _buildFilterBar('Filter orders'),
        _buildStatusChips(['All', 'Unpaid', 'Open', 'Archived']),
        Expanded(
          child: Obx(() {
            if (controller.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No orders yet',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When you receive orders, they will appear here.',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: controller.orders.length,
              itemBuilder: (context, index) {
                final order = controller.orders[index];
                return _buildOrderItem(order);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProductsTab() {
    return Column(
      children: [
        Obx(() {
          if (controller.selectedProductIds.isNotEmpty) {
            return _buildBulkActionToolbar();
          }
          return _buildFilterBar('Filter products');
        }),
        _buildProductStatusTabs(),
        Expanded(
          child: Obx(
            () => controller.isLoading.value && controller.myProducts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: controller.myProducts.length,
                    itemBuilder: (context, index) {
                      final product = controller.myProducts[index];
                      return _buildAdvancedProductListItem(product);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulkActionToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => controller.selectedProductIds.clear(),
          ),
          Text(
            '${controller.selectedProductIds.length} selected',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmBulkDelete(),
          ),
        ],
      ),
    );
  }

  void _confirmBulkDelete() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Products'),
        content: Text(
          'Are you sure you want to delete ${controller.selectedProductIds.length} products? This will also remove all associated images.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.bulkDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductStatusTabs() {
    final tabs = [
      {'label': 'Active', 'value': 'active'},
      {'label': 'Archived', 'value': 'archived'},
      {'label': 'Draft', 'value': 'draft'},
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(
        () => Row(
          children: tabs.map((tab) {
            bool isSelected = controller.selectedStatus.value == tab['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.setStatus(tab['value']!),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tab['label']!,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterBar(String hint) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(hint, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _iconButton(Icons.swap_vert),
          const SizedBox(width: 8),
          _iconButton(Icons.tune),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.black, size: 20),
    );
  }

  Widget _buildStatusChips(List<String> chips) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(right: 8, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: index == 0 ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            chips[index],
            style: TextStyle(color: index == 0 ? Colors.black : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    final statusColor = _getSellerStatusColor(order['status']);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['id'],
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
              _statusBadge(order['status'], statusColor),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF5F5F5)),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[100],
                child: Text(
                  order['customer'][0],
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['customer'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${order['items']} items • ${order['time']}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '¥',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          order['amount'].toStringAsFixed(0),
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      final localPrice = CurrencyService.to.convertFromYuan(
                        order['amount'].toDouble(),
                      );
                      return Text(
                        '≈ ${CurrencyService.to.localCurrencySymbol}${localPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order['type'],
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
              _statusBadge(order['paymentStatus'], Colors.green.shade400),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSellerStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAdvancedProductListItem(ProductModel product) {
    return Obx(() {
      bool isSelected = controller.selectedProductIds.contains(product.id);
      bool isSelectionMode = controller.selectedProductIds.isNotEmpty;

      return GestureDetector(
        onLongPress: () => controller.toggleSelection(product.id),
        onTap: () {
          if (isSelectionMode) {
            controller.toggleSelection(product.id);
          } else {
            Get.to(() => AddProductView(product: product));
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (isSelectionMode) ...[
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColors.primary : Colors.grey,
                ),
                const SizedBox(width: 12),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isSelectionMode)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_horiz, size: 20),
                            padding: EdgeInsets.zero,
                            onSelected: (value) {
                              if (value == 'delete') {
                                _confirmSingleDelete(product);
                              } else {
                                controller.updateProductStatus(
                                  product.id,
                                  value,
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              if (product.status != 'active')
                                const PopupMenuItem(
                                  value: 'active',
                                  child: Text('Set as Active'),
                                ),
                              if (product.status != 'archived')
                                const PopupMenuItem(
                                  value: 'archived',
                                  child: Text('Archive'),
                                ),
                              if (product.status != 'draft')
                                const PopupMenuItem(
                                  value: 'draft',
                                  child: Text('Move to Draft'),
                                ),
                              const PopupMenuDivider(),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '¥',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            product.effectiveYuan.toStringAsFixed(0),
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '≈',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Obx(() {
                            final localPrice = product.effectiveLocal;
                            return Text(
                              '${CurrencyService.to.localCurrencySymbol}${localPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${product.stock} in stock',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${product.status?.capitalizeFirst}',
                          style: TextStyle(
                            color: _getStatusColor(product.status),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'archived':
        return Colors.grey;
      case 'draft':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  void _confirmSingleDelete(ProductModel product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteProduct(product.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuTab() {
    return Container(
      color: Colors.black, // Background should be black
      child: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            60,
            16,
            20,
          ), // More top padding to start under status bar
          children: [
            _menuItem(Icons.home, 'Home', onTap: () => controller.changeTab(1)),

            // Orders Dropdown
            _menuItem(
              Icons.shopping_bag,
              'Orders',
              hasArrow: true,
              isExpanded: controller.isOrdersExpanded.value,
              onTap: () => controller.isOrdersExpanded.toggle(),
            ),
            if (controller.isOrdersExpanded.value)
              Padding(
                padding: const EdgeInsets.only(
                  left: 56,
                ), // More left padding for larger icons
                child: Column(
                  children: [
                    _subMenu(
                      'All orders',
                      onTap: () => controller.changeTab(2),
                    ),
                    _subMenu('Drafts'),
                  ],
                ),
              ),

            // Products
            _menuItem(
              Icons.label,
              'Products',
              onTap: () => controller.changeTab(3),
            ),

            _menuItem(
              Icons.payments_outlined,
              'Payouts & Finances',
              onTap: () => Get.toNamed(Routes.sellerPayouts),
            ),
            _menuItem(
              Icons.analytics_outlined,
              'Analytics',
              onTap: () => Get.toNamed(Routes.sellerAnalytics),
            ),
            _menuItem(
              Icons.person_outline,
              'Customers',
              onTap: () => Get.toNamed(Routes.sellerCustomers),
            ),
            _menuItem(
              Icons.percent,
              'Discounts',
              onTap: () => Get.toNamed(Routes.sellerDiscounts),
            ),
            _menuItem(
              Icons.store_outlined,
              'Store Setup',
              onTap: () => Get.toNamed(Routes.sellerStoreSetup),
            ),
            _menuItem(
              Icons.help_outline,
              'Help Center',
              onTap: () => Get.toNamed(Routes.sellerContactSupport),
            ),
            _menuItem(
              Icons.security_outlined,
              'Security & Privacy',
              onTap: () => Get.toNamed(Routes.securityPrivacy),
            ),

            const Divider(color: Colors.white24, height: 40),
            _menuItem(
              Icons.logout,
              'Log out',
              onTap: () => Get.find<AuthController>().logout(),
            ),
            const SizedBox(height: 100), // Space for the floating nav
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String label, {
    bool isExpanded = false,
    bool hasArrow = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8), // More space between items
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 26), // Bigger icons
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Bigger font size
                  fontWeight: FontWeight.w900, // Very bold text
                ),
              ),
            ),
            if (hasArrow)
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 26,
              ),
          ],
        ),
      ),
    );
  }

  Widget _subMenu(String label, {IconData? icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.white70, size: 22),
            if (icon != null) const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18, // Bigger font size for sub-menu
                fontWeight: FontWeight.w800, // Bold text
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _settingGroup('Policy & Legal', [
          _settingItem(
            Icons.description_outlined,
            'Legal',
            'Privacy policy, terms of service',
            onTap: () => Get.toNamed(Routes.sellerLegal),
          ),
        ]),
        const SizedBox(height: 24),
        _settingGroup('Operations', [
          _settingItem(
            Icons.payment,
            'Payments',
            'Payment providers and methods',
            onTap: () => Get.toNamed(Routes.sellerPayments),
          ),
          _settingItem(
            Icons.local_shipping_outlined,
            'Shipping and delivery',
            'Rates and processing times',
            onTap: () => Get.toNamed(Routes.sellerShipping),
          ),
          _settingItem(
            Icons.receipt_long_outlined,
            'Taxes and duties',
            'Manage how you charge tax',
            onTap: () => Get.toNamed(Routes.sellerTaxes),
          ),
        ]),
        const SizedBox(height: 24),
        _settingGroup('Preferences', [
          _settingItem(
            Icons.language,
            'Languages',
            'Store language and translations',
            onTap: () => Get.toNamed(Routes.sellerLanguages),
          ),
          _settingItem(
            Icons.notifications_active_outlined,
            'Notifications',
            'Customer and staff notifications',
            onTap: () => Get.toNamed(Routes.sellerNotifications),
          ),
        ]),
      ],
    );
  }

  Widget _settingGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _settingItem(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _navItem(int index, IconData icon) {
    bool isSelected = controller.currentTabIndex.value == index;
    // Keep Menu (index 4) selected when we are on the Settings page (index 6)
    if (index == 4 && controller.currentTabIndex.value == 6) {
      isSelected = true;
    }
    bool isStandalone = index == 0 || index == 5;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: isStandalone ? 60 : 38, // Slightly reduced widths
        height: isStandalone ? 64 : 44,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.grey.withValues(alpha: 0.15)
              : (isStandalone ? Colors.white : Colors.transparent),
          shape: BoxShape.circle,
          boxShadow: isStandalone && !isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.12,
                    ), // Increased from 0.08
                    blurRadius: 12, // Increased from 10
                    offset: const Offset(0, 5), // Slightly deeper offset
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.grey.shade400,
          size: isStandalone ? 28 : 22,
        ),
      ),
    );
  }
}
