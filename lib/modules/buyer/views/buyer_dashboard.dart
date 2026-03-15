import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../buyer_controller.dart';
import 'buyer_profile_view.dart';
import '../../../core/widgets/cards.dart';
import 'package:shimmer/shimmer.dart';
import '../../../routes/app_pages.dart';

class BuyerDashboard extends GetView<BuyerController> {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // If on Web, redirect to Landing Page immediately
    if (kIsWeb) {
      Future.microtask(() => Get.offAllNamed(Routes.landing));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Get.put(BuyerController());
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => _buildBody()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 18), // Moved down more from 10
        child: FloatingActionButton(
          onPressed: () {}, 
          backgroundColor: Colors.red,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
        ),
      ),
      bottomNavigationBar: Obx(() => BottomAppBar(
        padding: EdgeInsets.zero,
        height: 65,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(1, Icons.category_outlined, Icons.category, 'Categories'),
            const SizedBox(width: 40), // Space for FAB
            _buildNavItem(2, Icons.favorite_border, Icons.favorite, 'Wishlist'),
            _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
          ],
        ),
      )),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = controller.currentIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changePage(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (controller.currentIndex.value) {
      case 0:
        return _buildHomeView();
      case 1:
        return _buildCategoriesView();
      case 2:
        return _buildWishlistView();
      case 3:
        return _buildProfileView();
      default:
        return _buildHomeView();
    }
  }

  Widget _buildHomeView() {
    return Scaffold(
      backgroundColor: Colors.white, // Reverted to pure white background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Column(
              children: [
                // Top Search Bar (Temu Style)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Logic for opening search
                          },
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.camera_alt_outlined, color: Colors.black, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Search for products from China...',
                                    style: TextStyle(color: Colors.grey[800], fontSize: 14),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.search, color: Colors.white, size: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Horizontal Tabs (Explore, Anniversary Sale, etc.)
                _buildCategoriesRow(),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmer();
        }
        return RefreshIndicator(
          onRefresh: controller.loadProducts,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBanners(),
                _buildShippingInfo(),
                _buildProductsGrid(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCategoriesView() {
    return const Center(child: Text('Categories View'));
  }

  Widget _buildWishlistView() {
    return const Center(child: Text('Wishlist View'));
  }

  Widget _buildProfileView() {
    return const BuyerProfileView();
  }

  Widget _buildCategoriesRow() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTabItem('Explore', isSelected: true),
          _buildTabItem('Super Deals', isSpecial: true), // Changed name and color will be brand blue
          _buildTabItem('Women\'s'),
          _buildTabItem('Men\'s'),
          _buildTabItem('Jewelry'),
        ],
      ),
    );
  }

  Widget _buildTabItem(String text, {bool isSelected = false, bool isSpecial = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected || isSpecial ? FontWeight.w900 : FontWeight.w500,
              color: isSpecial ? AppColors.primary : (isSelected ? Colors.black : Colors.grey[600]), // Brand blue for special
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 20,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShippingInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white, // Changed from cream to white
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Free shipping', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.green)),
                    Text('Limited-time offer', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 30, width: 1, color: Colors.grey[300]),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.assignment_return_outlined, color: Colors.black87, size: 16),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Delivery guarantee', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                    Text('Refund for any issue', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanners() {
    return SizedBox(
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: controller.banners.isNotEmpty ? controller.banners[0] : 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=1000',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildProductsGrid() {
    final List<Widget> leftColumn = [];
    final List<Widget> rightColumn = [];

    for (int i = 0; i < controller.featuredProducts.length; i++) {
      final product = controller.featuredProducts[i];
      // Vary height for Pinterest effect
      final double imageHeight = (i % 3 == 0) ? 220.0 : (i % 2 == 0 ? 160.0 : 190.0);
      
      final card = Padding(
        padding: const EdgeInsets.all(4.0),
        child: ProductCard(
          title: product.name,
          price: (product.price * 10) + (i * 1234.56 % 5000), // Significantly bigger amounts
          imageUrl: product.imageUrl,
          imageHeight: imageHeight, // Pass the dynamic height
          rating: product.rating,
          tag: i % 3 == 0 ? 'Choice' : (i % 5 == 0 ? 'Bundle' : null),
          showChoice: i % 2 == 0, // Alternate showing choice badge
          showSale: i % 3 == 0, // Alternate showing sale badge
          onTap: () {},
          onAddToCart: () {},
        ),
      );

      if (i % 2 == 0) {
        leftColumn.add(card);
      } else {
        rightColumn.add(card);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: leftColumn)),
          Expanded(child: Column(children: rightColumn)),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(margin: const EdgeInsets.all(16), height: 50, color: Colors.white),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (context, index) => Container(margin: const EdgeInsets.only(right: 12), width: 80, color: Colors.white),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 16, mainAxisSpacing: 16),
              itemCount: 4,
              itemBuilder: (context, index) => Container(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
