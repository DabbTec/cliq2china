import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/utils/currency_service.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../buyer_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/buttons.dart';

class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView({super.key});

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final RxInt _currentImageIndex = 0.obs;
  final RxBool _showSearchBar = false.obs;
  final Rx<ProductModel?> _detailedProduct = Rx<ProductModel?>(null);
  final RxBool _isLoading = true.obs;
  final ProductRepository _productRepository = ProductRepository();

  // REPLACE _currentPrice with these two strict trackers
  final RxDouble _currentYuanPrice = 0.0.obs;
  final RxDouble _currentLocalPrice = 0.0.obs;
  final RxInt _selectedQty = 1.obs;

  String _formatPrice(double value) {
    final absValue = value.abs();
    final decimals = absValue < 1
        ? 3
        : absValue < 100
        ? 2
        : 0;
    return value
        .toStringAsFixed(decimals)
        .replaceAllMapped(
          RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
          (Match m) => "${m[1]},",
        );
  }

  @override
  void initState() {
    super.initState();

    // 1. Immediately extract initial data from arguments to prevent flickering (0 price)
    final dynamic args = Get.arguments;
    if (args != null && args['product'] != null) {
      final ProductModel initialProduct = args['product'] as ProductModel;
      _detailedProduct.value = initialProduct;

      // Set initial MOQ based on the lowest MOQ tier, not the raw base price.
      int initialMOQ = 1;
      if (initialProduct.moqTiers != null &&
          initialProduct.moqTiers!.isNotEmpty) {
        final firstTier = initialProduct.moqTiers!.reduce(
          (a, b) => a.minQty < b.minQty ? a : b,
        );
        initialMOQ = firstTier.minQty;
      }
      _selectedQty.value = initialMOQ;
      _updatePrice();
    }

    // 2. Setup scroll listener
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showSearchBar.value) {
        _showSearchBar.value = true;
      } else if (_scrollController.offset <= 200 && _showSearchBar.value) {
        _showSearchBar.value = false;
      }
    });

    // 3. Fetch full details in background
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    final product = _detailedProduct.value;
    if (product != null) {
      try {
        final fullProduct = await _productRepository.getProductDetail(
          product.id,
        );
        _detailedProduct.value = fullProduct;
        _updatePrice();
      } catch (e) {
        debugPrint('Error fetching product details: $e');
      } finally {
        _isLoading.value = false;
      }
    }
  }

  double _calculateYuanPrice(ProductModel product, int qty) {
    if (product.moqTiers == null || product.moqTiers!.isEmpty) {
      return product.effectiveYuan;
    }
    final sortedTiers = List<MOQTier>.from(product.moqTiers!)
      ..sort((a, b) => b.minQty.compareTo(a.minQty));
    for (var tier in sortedTiers) {
      if (qty >= tier.minQty) {
        // If backend provides a total yuan price for the tier, calculate unit price
        if (tier.yuanPrice != null && tier.yuanPrice! > 0) {
          return tier.yuanPrice! / tier.minQty;
        }
        return tier.pricePerUnit;
      }
    }
    final firstTier = sortedTiers.last;
    if (firstTier.yuanPrice != null && firstTier.yuanPrice! > 0) {
      return firstTier.yuanPrice! / firstTier.minQty;
    }
    return firstTier.pricePerUnit;
  }

  double _calculateLocalPrice(ProductModel product, int qty) {
    if (product.moqTiers == null || product.moqTiers!.isEmpty) {
      return product.effectiveLocal;
    }
    final sortedTiers = List<MOQTier>.from(product.moqTiers!)
      ..sort((a, b) => b.minQty.compareTo(a.minQty));
    for (var tier in sortedTiers) {
      if (qty >= tier.minQty) {
        // PRIORITY: Use the exact backend total local price if it exists to get unit price
        if (tier.localPrice != null && tier.localPrice! > 0) {
          return tier.localPrice! / tier.minQty;
        }
        return CurrencyService.to.convertFromYuan(
          tier.yuanPrice ?? tier.pricePerUnit,
        );
      }
    }
    final firstTier = sortedTiers.last;
    if (firstTier.localPrice != null && firstTier.localPrice! > 0) {
      return firstTier.localPrice! / firstTier.minQty;
    }
    return CurrencyService.to.convertFromYuan(
      firstTier.yuanPrice ?? firstTier.pricePerUnit,
    );
  }

  void _updatePrice() {
    final product = _detailedProduct.value;
    if (product == null) return;

    // Explicitly set both values without dynamic multiplication
    _currentYuanPrice.value = _calculateYuanPrice(product, _selectedQty.value);
    _currentLocalPrice.value = _calculateLocalPrice(
      product,
      _selectedQty.value,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final product = _detailedProduct.value;
      if (product == null) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      final controller = Get.find<BuyerController>();

      // Filter gallery to avoid duplicating the main image
      final displayGallery = [
        product.imageUrl,
        ...product.galleryUrls.where((url) => url != product.imageUrl),
      ];

      return Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 1. Image Slider & Custom App Bar
                SliverAppBar(
                  expandedHeight: 400.h,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) =>
                              _currentImageIndex.value = index,
                          itemCount: displayGallery.length,
                          itemBuilder: (context, index) {
                            final imgUrl = displayGallery[index];
                            return CachedNetworkImage(
                              imageUrl: imgUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[100],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, size: 50),
                              ),
                            );
                          },
                        ),
                        // Image Indicator (e.g., 1/3)
                        Positioned(
                          bottom: 20.h,
                          right: 20.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Text(
                              '${_currentImageIndex.value + 1}/${displayGallery.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Obx(
                    () => _showSearchBar.value
                        ? Container(
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: 20.sp,
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.h,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 22.sp,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  actions: [
                    Obx(
                      () => !_showSearchBar.value
                          ? Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.share_outlined,
                                    color: Colors.black,
                                    size: 22.sp,
                                  ),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(
                                    controller.isProductInWishlist(product.id)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        controller.isProductInWishlist(
                                          product.id,
                                        )
                                        ? Colors.red
                                        : Colors.black,
                                    size: 22.sp,
                                  ),
                                  onPressed: () =>
                                      controller.toggleWishlist(product),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.black,
                            size: 22.sp,
                          ),
                          onPressed: () => Get.toNamed(
                            Routes.buyerDashboard,
                            arguments: {'index': 4},
                          ),
                        ),
                        if (controller.cartItems.isNotEmpty)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 14.w,
                                minHeight: 14.w,
                              ),
                              child: Text(
                                '${controller.cartItems.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),

                // 1.1 Gallery Thumbnails
                if (displayGallery.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      height: 80.h,
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: displayGallery.length,
                        itemBuilder: (context, index) {
                          final imgUrl = displayGallery[index];
                          return Obx(() {
                            final isSelected =
                                _currentImageIndex.value == index;
                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                width: 60.h,
                                margin: EdgeInsets.only(right: 12.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey[200]!,
                                    width: 2,
                                  ),
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(imgUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    ),
                  ),

                // 2. Product Info Section
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price Row
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (product.moqTiers != null &&
                                  product.moqTiers!.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: Text(
                                    'Starting from',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              Obx(() {
                                // Access observables to ensure GetX tracks this widget
                                // Trigger update on location change
                                CurrencyService.to.currentLocation.value;

                                // Always calculate based on current reactive state
                                final double unitYuan = _currentYuanPrice.value;
                                final double unitLocal =
                                    _currentLocalPrice.value;
                                final int qty = _selectedQty.value;

                                final double totalYuan = unitYuan * qty;
                                final double totalLocal = unitLocal * qty;

                                if (_isLoading.value && totalLocal == 0) {
                                  return Container(
                                    width: 100.w,
                                    height: 25.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  );
                                }

                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '¥',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      _formatPrice(totalYuan),
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      '(≈ ${product.effectiveSymbol}${_formatPrice(totalLocal)})',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (product.moqTiers != null &&
                                        product.moqTiers!.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(left: 12.w),
                                        child: Text(
                                          '${_selectedQty.value} pcs',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // Title
                        Text(
                          product.name,
                          style: AppTypography.h2.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // Rating and Sold
                        Row(
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  Icons.star,
                                  size: 14.sp,
                                  color: index < product.rating.floor()
                                      ? Colors.amber
                                      : Colors.grey[300],
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              product.rating.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              '15,000+ sold',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 2.1 Wholesale Pricing Table
                if (product.moqTiers != null && product.moqTiers!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.only(top: 10.h),
                      padding: EdgeInsets.all(20.w),
                      color: Colors.white,
                      child: _buildPricingTiersTable(product),
                    ),
                  ),

                // 3. Shipping & Service
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(top: 10.h),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildClickableRow(
                          icon: Icons.local_shipping_outlined,
                          title: 'Shipping',
                          subtitle:
                              'Free shipping to Nigeria via Cliq2China Standard',
                          onTap: () {},
                        ),
                        const Divider(height: 1, indent: 60),
                        _buildClickableRow(
                          icon: Icons.verified_user_outlined,
                          title: 'Service',
                          subtitle:
                              '75-day Buyer Protection · Money back guarantee',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Key Attributes
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(top: 10.h),
                    padding: EdgeInsets.all(20.w),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Key Attributes', style: AppTypography.h3),
                        SizedBox(height: 16.h),
                        Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: [
                            _buildAttributeTag(
                              'Original',
                              const Color(0xFFE3F2FD),
                              Colors.blue,
                              Icons.check_circle_outline,
                            ),
                            _buildAttributeTag(
                              'Direct from China',
                              const Color(0xFFFFF3E0),
                              Colors.orange,
                              Icons.local_shipping_outlined,
                            ),
                            _buildAttributeTag(
                              'Quality Tested',
                              const Color(0xFFE8F5E9),
                              Colors.green,
                              Icons.fact_check_outlined,
                            ),
                            _buildAttributeTag(
                              'Best Seller',
                              const Color(0xFFF3E5F5),
                              Colors.purple,
                              Icons.stars_outlined,
                            ),
                            _buildAttributeTag(
                              '24/7 Support',
                              const Color(0xFFE0F2F1),
                              Colors.teal,
                              Icons.headset_mic_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 4.1 Store Info
                if (product.store != null)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.only(top: 10.h),
                      padding: EdgeInsets.all(20.w),
                      color: Colors.white,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: CachedNetworkImage(
                              imageUrl: product.store!.logoUrl ?? '',
                              width: 50.w,
                              height: 50.w,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.grey100,
                                child: const Icon(
                                  Icons.store,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.store!.name,
                                  style: AppTypography.h3.copyWith(
                                    fontSize: 16.sp,
                                  ),
                                ),
                                Text(
                                  'Official Store • 98% Positive Feedback',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => Get.toNamed(
                              Routes.store,
                              arguments: {
                                'sellerId': product.sellerId,
                                'sellerName': product.store!.name,
                              },
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                            child: Text(
                              'Visit',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 5. Product Description
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(top: 10.h),
                    padding: EdgeInsets.all(20.w),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Product Description', style: AppTypography.h3),
                        SizedBox(height: 12.h),
                        Text(
                          product.description,
                          style: AppTypography.bodyMedium.copyWith(
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 6. Buyer Reviews
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(top: 10.h),
                    padding: EdgeInsets.all(20.w),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Buyer Reviews (${product.reviews.where((r) => r['comment'] != null && r['comment'].toString().trim().isNotEmpty).length})',
                              style: AppTypography.h3,
                            ),
                            if (product.reviews.any(
                              (r) =>
                                  r['comment'] != null &&
                                  r['comment'].toString().trim().isNotEmpty,
                            ))
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'View All',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (product.reviews.isEmpty ||
                            !product.reviews.any(
                              (r) =>
                                  r['comment'] != null &&
                                  r['comment'].toString().trim().isNotEmpty,
                            ))
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Center(
                              child: Text(
                                'No reviews with comments yet.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: product.reviews
                                .where(
                                  (r) =>
                                      r['comment'] != null &&
                                      r['comment'].toString().trim().isNotEmpty,
                                )
                                .take(3)
                                .map((r) => _buildReviewItem(r))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),

                // 7. Similar Products
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(top: 10.h),
                    padding: EdgeInsets.all(20.w),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Similar Products', style: AppTypography.h3),
                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 240.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.products.length,
                            itemBuilder: (context, index) {
                              final p = controller.products[index];
                              return Container(
                                width: 160.w,
                                margin: EdgeInsets.only(right: 15.w),
                                child: ProductCard(
                                  title: p.name,
                                  price: p.price,
                                  originalPriceYuan: p.originalPriceYuan,
                                  moqTiers: p.moqTiers,
                                  displayPrice: p.displayPrice,
                                  displayYuan: p.displayYuan,
                                  displaySymbol: p.displaySymbol,
                                  imageUrl: p.imageUrl,
                                  rating: p.rating,
                                  stock: p.stock,
                                  onTap: () => Get.toNamed(
                                    Routes.productDetails,
                                    arguments: {'product': p},
                                    preventDuplicates: false,
                                  ),
                                  onAddToCart: () => controller.addToCart(p),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 8. Most Viewed Products
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(top: 10.h),
                    padding: EdgeInsets.all(20.w),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Most Viewed Products', style: AppTypography.h3),
                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 240.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.products.reversed.length,
                            itemBuilder: (context, index) {
                              final p = controller.products.reversed
                                  .toList()[index];
                              return Container(
                                width: 160.w,
                                margin: EdgeInsets.only(right: 15.w),
                                child: ProductCard(
                                  title: p.name,
                                  price: p.price,
                                  originalPriceYuan: p.originalPriceYuan,
                                  moqTiers: p.moqTiers,
                                  imageUrl: p.imageUrl,
                                  rating: p.rating,
                                  stock: p.stock,
                                  onTap: () => Get.toNamed(
                                    Routes.productDetails,
                                    arguments: {'product': p},
                                    preventDuplicates: false,
                                  ),
                                  onAddToCart: () => controller.addToCart(p),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),

            // Bottom Action Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      _buildBottomIconButton(Icons.chat_bubble_outline, 'Chat'),
                      SizedBox(width: 20.w),
                      GestureDetector(
                        onTap: () => Get.toNamed(
                          Routes.store,
                          arguments: {
                            'sellerId': product.sellerId,
                            'sellerName':
                                product.store?.name ??
                                product.seller?.businessName ??
                                'Unnamed Store',
                          },
                        ),
                        child: _buildBottomIconButton(
                          Icons.store_outlined,
                          'Store',
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: product.stock <= 0
                                    ? null
                                    : () {
                                        _showQtyPicker(product);
                                      },
                                child: Container(
                                  height: 48.h,
                                  decoration: BoxDecoration(
                                    color: product.stock <= 0
                                        ? Colors.grey[200]
                                        : const Color(0xFFFFF1F1),
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(24.r),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Obx(
                                    () => Text(
                                      product.stock <= 0
                                          ? 'Out of Stock'
                                          : 'Qty: ${_selectedQty.value}',
                                      style: TextStyle(
                                        color: product.stock <= 0
                                            ? Colors.grey
                                            : Colors.red[400],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: product.stock <= 0
                                    ? null
                                    : () {
                                        // Always update/add to cart with the selected quantity
                                        controller.addToCart(
                                          product,
                                          quantity: _selectedQty.value,
                                        );
                                        Get.toNamed(
                                          Routes.buyerDashboard,
                                          arguments: {'index': 4},
                                        );
                                      },
                                child: Container(
                                  height: 48.h,
                                  decoration: BoxDecoration(
                                    color: product.stock <= 0
                                        ? Colors.grey[400]
                                        : Colors.blue[700],
                                    borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(24.r),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    product.stock <= 0
                                        ? 'Not Available'
                                        : 'Go to Cart',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
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
          ],
        ),
      );
    });
  }

  Widget _buildPricingTiersTable(ProductModel product) {
    if (product.moqTiers == null || product.moqTiers!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort tiers by minQty to ensure "Starting Price" logic and "Active" state work correctly
    final sortedTiers = List<MOQTier>.from(product.moqTiers!)
      ..sort((a, b) => a.minQty.compareTo(b.minQty));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: sortedTiers.length,
            itemBuilder: (context, index) {
              final tier = sortedTiers[index];

              // Calculate "Save %" relative to the first tier
              String? savingsLabel;
              if (index > 0) {
                final basePrice = sortedTiers[0].pricePerUnit;
                final savings =
                    ((basePrice - tier.pricePerUnit) / basePrice * 100).round();
                if (savings > 0) savingsLabel = 'Save $savings%';
              }

              // Check if this is the "Best Value" tier (usually the last one)
              final bool isBestValue =
                  index == sortedTiers.length - 1 && sortedTiers.length > 1;

              return Obx(() {
                // FIX: Ensure only ONE tier is highlighted at a time
                bool active = false;
                if (index == sortedTiers.length - 1) {
                  active = _selectedQty.value >= tier.minQty;
                } else {
                  active =
                      _selectedQty.value >= tier.minQty &&
                      _selectedQty.value < sortedTiers[index + 1].minQty;
                }

                return GestureDetector(
                  onTap: () {
                    // FIX: Automatically set qty to the start of the selected tier
                    _selectedQty.value = tier.minQty;
                    _updatePrice();
                  },
                  child: Container(
                    width: 155.w,
                    margin: EdgeInsets.only(right: 14.w),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 10.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primary.withValues(alpha: 0.05)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: active
                                  ? AppColors.primary
                                  : Colors.grey[200]!,
                              width: active ? 2 : 1,
                            ),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.02,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${tier.minQty} pcs',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: active
                                      ? AppColors.primary
                                      : Colors.black87,
                                  fontWeight: active
                                      ? FontWeight.w900
                                      : FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Obx(() {
                                // Track location
                                final _ =
                                    CurrencyService.to.currentLocation.value;

                                // Calculate Total Prices using prioritized backend data
                                double localTotalPrice;
                                double yuanTotalPrice;

                                if (tier.localPrice != null &&
                                    tier.localPrice! > 0) {
                                  // Backend provides TOTAL price for this MOQ tier
                                  localTotalPrice = tier.localPrice!;
                                  yuanTotalPrice =
                                      tier.yuanPrice ??
                                      (tier.pricePerUnit * tier.minQty);
                                } else {
                                  // Fallback: Convert unit price to local and multiply by minQty
                                  final unitYuan =
                                      tier.yuanPrice ?? tier.pricePerUnit;
                                  yuanTotalPrice = unitYuan * tier.minQty;
                                  final localUnitPrice = CurrencyService.to
                                      .convertFromYuan(unitYuan);
                                  localTotalPrice =
                                      localUnitPrice * tier.minQty;
                                }

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          '¥',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Text(
                                          _formatPrice(yuanTotalPrice),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w900,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '(≈ ${CurrencyService.to.localCurrencySymbol}${_formatPrice(localTotalPrice)})',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                        if (active)
                          Positioned(
                            top: 0,
                            left: 12.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'CURRENT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        if (savingsLabel != null || isBestValue)
                          Positioned(
                            top: 0,
                            right: 8.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: isBestValue
                                    ? Colors.orange[700]
                                    : Colors.red[700],
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                isBestValue ? 'BEST VALUE' : savingsLabel!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          // FIX: Reliably find the current active tier for this alert box
          final currentTierCandidates = sortedTiers
              .where((t) => _selectedQty.value >= t.minQty)
              .toList();
          if (currentTierCandidates.isEmpty) return const SizedBox.shrink();

          final nextTier = sortedTiers.firstWhereOrNull(
            (t) => t.minQty > _selectedQty.value,
          );

          if (nextTier == null) return const SizedBox.shrink();

          final needed = nextTier.minQty - _selectedQty.value;
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.stars_rounded,
                  size: 16.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Order $needed more to drop price to ¥${nextTier.pricePerUnit.toStringAsFixed(0)}!',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showQtyPicker(ProductModel product) {
    // Calculate effective MOQ
    int effectiveMOQ = 1;
    if (product.moqTiers != null && product.moqTiers!.isNotEmpty) {
      effectiveMOQ = product.moqTiers!.first.minQty;
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Quantity', style: AppTypography.h3),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _qtyBtn(Icons.remove, () {
                  if (_selectedQty.value > effectiveMOQ) {
                    _selectedQty.value--;
                    _updatePrice();
                  } else {
                    Get.snackbar(
                      'Minimum Order',
                      'The minimum order for this item is $effectiveMOQ items',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }),
                SizedBox(width: 30.w),
                Obx(
                  () => Text(
                    _selectedQty.value.toString(),
                    style: AppTypography.h2,
                  ),
                ),
                SizedBox(width: 30.w),
                _qtyBtn(Icons.add, () {
                  if (_selectedQty.value < product.stock) {
                    _selectedQty.value++;
                    _updatePrice();
                  } else {
                    Get.snackbar(
                      'Stock Limit',
                      'Only ${product.stock} items available',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }),
              ],
            ),
            SizedBox(height: 30.h),
            PrimaryButton(text: 'Confirm', onPressed: () => Get.back()),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomIconButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22.sp, color: Colors.black87),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildClickableRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, size: 22.sp, color: Colors.black87),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeTag(
    String label,
    Color bgColor,
    Color textColor,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: textColor),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: Colors.grey[200],
                child: Text(
                  review['user']?[0] ?? 'A',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14.sp),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['user'] ?? 'Anonymous',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              size: 12.sp,
                              color: index < (review['rating'] ?? 5).floor()
                                  ? Colors.amber
                                  : Colors.grey[300],
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          (review['rating'] ?? 5.0).toString(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                review['date'] ?? '',
                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            review['comment'] ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          SizedBox(height: 15.h),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20.sp, color: Colors.black87),
      ),
    );
  }
}
