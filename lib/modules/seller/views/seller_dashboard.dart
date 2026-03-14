import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../data/models/product.dart';
import '../../../routes/app_pages.dart';
import '../seller_controller.dart';

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
                      offset: isMenuTab ? Offset.zero : const Offset(0, -10), // Pull up to meet the curve
                      child: Container(
                        decoration: BoxDecoration(
                          color: isMenuTab ? Colors.black : Colors.white,
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
                          const Center(child: Text('Search Content')), // Index 0
                          _buildHomeTab(), // Index 1
                          _buildOrdersTab(), // Index 2
                          _buildProductsTab(), // Index 3
                          _buildMenuTab(), // Index 4
                          const Center(child: Text('Profile Content')), // Index 5
                          _buildSettingsView(), // Index 6
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
              // Floating Bottom Nav Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
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
            color: Colors.black.withOpacity(0.12), // Increased from 0.08
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
          color: (isMorphed || controller.currentTabIndex.value == 4 || isSettingsPage)
              ? Colors.grey.withOpacity(0.15)
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
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 12), // Reduced from 30
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
                      image: NetworkImage('https://images.unsplash.com/photo-1560179707-f14e90ef3623?q=80&w=100'), // Company placeholder
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (controller.currentTabIndex.value == 1) const SizedBox(width: 12),
              Text(
                title,
                style: AppTypography.h2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              if (!isMenuTab && (controller.currentTabIndex.value == 2 || controller.currentTabIndex.value == 3 || controller.currentTabIndex.value == 6))
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 24),
                ),
            ],
          ),
          Row(
            children: [
              if (controller.currentTabIndex.value == 3)
                IconButton(
                  onPressed: () => Get.toNamed(Routes.addProduct),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                ),
              if (controller.currentTabIndex.value == 6)
                const Icon(Icons.help_outline, color: Colors.white),
              
              if (!isMenuTab) ...[
                const SizedBox(width: 8),
                const Icon(Icons.notifications_none, color: Colors.white),
                const SizedBox(width: 16),
              ],

              if (controller.currentTabIndex.value == 1)
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.purple,
                  child: Text('C', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              if (!isMenuTab && controller.currentTabIndex.value != 1)
                const Icon(Icons.more_vert, color: Colors.white),
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
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard('Total Sales', '₦12,450.00', Icons.payments_outlined, Colors.blue),
              _buildMetricCard('Total Orders', '156', Icons.shopping_bag_outlined, Colors.orange),
              _buildMetricCard('Total Products', '42', Icons.inventory_2_outlined, Colors.green),
              _buildMetricCard('Total Customers', '1,204', Icons.people_outline, Colors.purple),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text('Quick Actions', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickAction('Add Product', Icons.add_circle_outline, () => Get.toNamed(Routes.addProduct)),
                _buildQuickAction('View Orders', Icons.list_alt_outlined, () => controller.changeTab(2)),
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
              Text('Recent Activities', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                _buildActivityItem(
                  'New Order Received',
                  'Order #ORD-2024-001 from Sam Mikky',
                  '2 mins ago',
                  Icons.shopping_cart_outlined,
                  Colors.blue,
                ),
                Divider(height: 1, color: Colors.grey.shade100),
                _buildActivityItem(
                  'Product Out of Stock',
                  'Premium Leather Jacket is now out of stock',
                  '1 hour ago',
                  Icons.warning_amber_outlined,
                  Colors.orange,
                ),
                Divider(height: 1, color: Colors.grey.shade100),
                _buildActivityItem(
                  'Payout Successful',
                  'A payout of ₦1,200.00 has been processed',
                  '5 hours ago',
                  Icons.check_circle_outline,
                  Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 100), // Space for nav
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Icon(Icons.trending_up, color: Colors.green, size: 16),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold)),
              Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Column(
      children: [
        _buildFilterBar('Filter orders'),
        _buildStatusChips(['All', 'Unfulfilled', 'Unpaid', 'Open', 'Archived']),
        Expanded(
          child: ListView.builder(
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return _buildOrderItem(order);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductsTab() {
    return Column(
      children: [
        _buildFilterBar('Filter products'),
        _buildStatusChips(['All', 'Active', 'Draft', 'Archived', 'Fast Food']),
        Expanded(
          child: ListView.builder(
            itemCount: controller.myProducts.length,
            itemBuilder: (context, index) {
              final product = controller.myProducts[index];
              return _buildProductListItem(product);
            },
          ),
        ),
      ],
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
          child: Text(chips[index], style: TextStyle(color: index == 0 ? Colors.black : Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (order['date'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(order['date'], style: AppTypography.bodySmall.copyWith(color: Colors.grey)),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order['id'], style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              Text('NGN ${order['amount'].toStringAsFixed(2)}', style: AppTypography.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          Text('${order['customer']} • ${order['items']} items • ${order['time']}', style: AppTypography.bodySmall.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              _statusBadge(order['status'], Colors.yellow.shade700),
              const SizedBox(width: 8),
              _statusBadge(order['paymentStatus'], Colors.orange.shade300),
            ],
          ),
          const SizedBox(height: 4),
          Text(order['type'], style: AppTypography.bodySmall.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProductListItem(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(imageUrl: product.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text('${product.stock} variants', style: AppTypography.bodySmall.copyWith(color: Colors.grey)),
              ],
            ),
          ),
          _statusBadge(product.status?.capitalizeFirst ?? 'Active', Colors.green.shade400),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMenuTab() {
    return Container(
      color: Colors.black, // Background should be black
      child: Obx(() => ListView(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 20), // More top padding to start under status bar
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
              padding: const EdgeInsets.only(left: 56), // More left padding for larger icons
              child: Column(
                children: [
                  _subMenu('All orders', onTap: () => controller.changeTab(2)),
                  _subMenu('Drafts'),
                  _subMenu('Abandoned checkouts'),
                ],
              ),
            ),

          // Products Dropdown
          _menuItem(
            Icons.label, 
            'Products', 
            hasArrow: true, 
            isExpanded: controller.isProductsExpanded.value,
            onTap: () => controller.isProductsExpanded.toggle(),
          ),
          if (controller.isProductsExpanded.value)
            Padding(
              padding: const EdgeInsets.only(left: 56), // More left padding for larger icons
              child: Column(
                children: [
                  _subMenu('All products', onTap: () => controller.changeTab(3)),
                  _subMenu('Collections'),
                  _subMenu('Inventory'),
                  _subMenu('Purchase orders'),
                  _subMenu('Transfers'),
                  _subMenu('Gift cards'),
                  _subMenu('Scan inventory', icon: Icons.document_scanner),
                ],
              ),
            ),

          _menuItem(Icons.person, 'Customers'),
          _menuItem(Icons.campaign, 'Marketing'),
          _menuItem(Icons.percent, 'Discounts'),
          _menuItem(Icons.photo_library, 'Content'),
          _menuItem(Icons.public, 'Markets'),
          _menuItem(Icons.settings, 'Settings', onTap: () => controller.changeTab(6)),
          const SizedBox(height: 100), // Space for the floating nav
        ],
      )),
    );
  }

  Widget _menuItem(IconData icon, String label, {
    bool isExpanded = false, 
    bool hasArrow = false, 
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8), // More space between items
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
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
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
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
        _settingGroup('Store Profile', [
          _settingItem(Icons.info_outline, 'Store details', 'Name, address, and contact info'),
          _settingItem(Icons.description_outlined, 'Legal', 'Privacy policy, terms of service'),
        ]),
        const SizedBox(height: 24),
        _settingGroup('Operations', [
          _settingItem(Icons.payment, 'Payments', 'Payment providers and methods'),
          _settingItem(Icons.local_shipping_outlined, 'Shipping and delivery', 'Rates and processing times'),
          _settingItem(Icons.receipt_long_outlined, 'Taxes and duties', 'Manage how you charge tax'),
        ]),
        const SizedBox(height: 24),
        _settingGroup('Preferences', [
          _settingItem(Icons.language, 'Languages', 'Store language and translations'),
          _settingItem(Icons.notifications_active_outlined, 'Notifications', 'Customer and staff notifications'),
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
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _settingItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: AppTypography.bodySmall.copyWith(color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: () {},
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
          color: isSelected ? Colors.grey.withOpacity(0.15) : (isStandalone ? Colors.white : Colors.transparent),
          shape: BoxShape.circle,
          boxShadow: isStandalone && !isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12), // Increased from 0.08
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
