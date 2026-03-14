import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
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
      backgroundColor: AppColors.background,
      body: Obx(() => _buildBody()),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changePage,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category_outlined), activeIcon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      )),
    );
  }

  Widget _buildBody() {
    switch (controller.currentIndex.value) {
      case 0:
        return _buildHomeView();
      case 1:
        return _buildCategoriesView();
      case 2:
        return _buildOrdersView();
      case 3:
        return _buildProfileView();
      default:
        return _buildHomeView();
    }
  }

  Widget _buildHomeView() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cliq2China', style: AppTypography.h2.copyWith(color: AppColors.primary)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textPrimary)
          ),
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary)
          ),
        ],
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
                _buildSearchBar(),
                _buildBanners(),
                _buildCategories(),
                _buildFeaturedHeader(),
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

  Widget _buildOrdersView() {
    return const Center(child: Text('Orders View'));
  }

  Widget _buildProfileView() {
    return const BuyerProfileView();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search products from China...', 
            hintStyle: AppTypography.bodySmall,
            border: InputBorder.none, 
            icon: const Icon(Icons.search, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildBanners() {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: controller.banners.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: controller.banners[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.grey200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getCategoryIcon(category['icon']!), color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(category['name']!, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'flash_on': return Icons.flash_on;
      case 'phone_android': return Icons.phone_android;
      case 'checkroom': return Icons.checkroom;
      case 'home': return Icons.home;
      case 'face': return Icons.face;
      case 'toys': return Icons.toys;
      default: return Icons.category;
    }
  }

  Widget _buildFeaturedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Featured Products', style: AppTypography.h3),
          TextButton(onPressed: () {}, child: const Text('See All')),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.featuredProducts.length,
      itemBuilder: (context, index) {
        final product = controller.featuredProducts[index];
        return ProductCard(
          title: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          rating: product.rating,
          onTap: () {},
          onAddToCart: () {},
        );
      },
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
