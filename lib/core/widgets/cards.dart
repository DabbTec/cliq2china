import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/currency_service.dart';
import '../../data/models/product.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final double price; // Converted price (optional/legacy)
  final double? originalPriceYuan; // NEW: Base price in Yuan
  final String imageUrl;
  final double rating;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback? onToggleWishlist;
  final double? originalPrice; // Original price in local currency (legacy)
  final int? discountPercentage;
  final String? trendingStatus;
  final bool showSuperDeal;
  final double imageHeight;
  final bool isInCart; // Track if product is already in cart
  final bool isInWishlist;
  final int stock;
  final List<MOQTier>? moqTiers; // NEW: MOQ Tiers for price fallback
  final double? displayPrice; // NEW: Pre-calculated price from backend
  final double? displayYuan; // NEW: Pre-calculated Yuan from backend
  final String? displaySymbol; // NEW: Pre-calculated symbol from backend

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    this.originalPriceYuan,
    required this.imageUrl,
    required this.rating,
    required this.onTap,
    required this.onAddToCart,
    this.onToggleWishlist,
    this.originalPrice,
    this.discountPercentage,
    this.trendingStatus,
    this.showSuperDeal = false,
    this.imageHeight = 150,
    this.isInCart = false,
    this.isInWishlist = false,
    this.stock = 1,
    this.moqTiers,
    this.displayPrice,
    this.displayYuan,
    this.displaySymbol,
  });

  double get effectiveYuanPrice {
    if (originalPriceYuan != null && originalPriceYuan! > 0) {
      return originalPriceYuan!;
    }
    if (moqTiers != null && moqTiers!.isNotEmpty) {
      return moqTiers!.first.pricePerUnit;
    }
    return price;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.white, // No container border or radius
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Image Section (Only the image has a border/radius)
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      8.w,
                    ), // Image border radius
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 0.5,
                    ), // Image border
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.w),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: imageHeight.h,
                      placeholder: (context, url) => Container(
                        height: imageHeight.h,
                        color: Colors.grey[100],
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: imageHeight.h,
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image, size: 30.sp),
                      ),
                    ),
                  ),
                ),
                if (stock <= 0)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'OUT OF STOCK',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (onToggleWishlist != null)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: onToggleWishlist,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: isInWishlist ? Colors.red : Colors.grey,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 2. Info Section (No border here)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 4.h,
                horizontal: 4.w,
              ), // Reduced padding from 6.0
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF222222), // Darker for visibility
                      fontSize: 14.sp,
                      fontWeight: FontWeight.normal,
                      height: 1.2,
                      fontFamily: 'Inter',
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Trending Status Row + Mini Cart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          trendingStatus ?? '✨ Recommended',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF444444),
                            fontSize: 10.sp, // Slightly smaller font
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      // Small Cart Button
                      GestureDetector(
                        onTap: (isInCart || stock <= 0) ? null : onAddToCart,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: (isInCart || stock <= 0)
                                      ? Colors.grey.withValues(alpha: 0.5)
                                      : Colors.black.withValues(alpha: 0.8),
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                Icons.shopping_cart_outlined,
                                size: 14.sp,
                                color: (isInCart || stock <= 0)
                                    ? Colors.grey
                                    : Colors.red,
                              ),
                            ),
                            if (isInCart)
                              Positioned(
                                top: -4.h,
                                right: -4.w,
                                child: Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 12.w,
                                    minHeight: 12.h,
                                  ),
                                  child: Text(
                                    '1',
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
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Price Row (Yuan Primary Red + Local Secondary Black)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (moqTiers != null && moqTiers!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(right: 4.w, bottom: 2.h),
                            child: Text(
                              'Starting from',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        Text(
                          '¥',
                          style: TextStyle(
                            color: const Color(0xFFE53935), // Primary Red
                            fontWeight: FontWeight.w900,
                            fontSize: 12.sp, // Reduced from 14
                          ),
                        ),
                        Text(
                          displayYuan != null
                              ? displayYuan!
                                    .toStringAsFixed(0)
                                    .replaceAllMapped(
                                      RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
                                      (Match m) => "${m[1]},",
                                    )
                              : effectiveYuanPrice == 0
                              ? ''
                              : effectiveYuanPrice
                                    .toStringAsFixed(0)
                                    .replaceAllMapped(
                                      RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
                                      (Match m) => "${m[1]},",
                                    ),
                          style: TextStyle(
                            color: const Color(0xFFE53935), // Primary Red
                            fontWeight: FontWeight.w900,
                            fontSize: 16.sp, // Reduced from 18
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (displayYuan != null || effectiveYuanPrice > 0) ...[
                          SizedBox(width: 4.w), // Reduced from 6
                          Text(
                            '≈',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11.sp, // Reduced from 12
                            ),
                          ),
                        ],
                        SizedBox(width: 4.w),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displaySymbol ??
                                  CurrencyService.to.localCurrencySymbol,
                              style: TextStyle(
                                color: Colors.black, // Secondary Black
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp,
                              ),
                            ),
                            const SizedBox(width: 2),
                            if (displayPrice != null)
                              Text(
                                displayPrice!
                                    .toStringAsFixed(
                                      displayPrice! < 100 ? 2 : 0,
                                    )
                                    .replaceAllMapped(
                                      RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
                                      (Match m) => "${m[1]},",
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black, // Secondary Black
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              )
                            else
                              Obx(() {
                                // Explicitly access the observable to ensure GetX tracks it
                                final _ =
                                    CurrencyService.to.currentLocation.value;

                                if (effectiveYuanPrice == 0) {
                                  return Container(
                                    width: 50.w,
                                    height: 14.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  );
                                }

                                final localPrice = CurrencyService.to
                                    .convertFromYuan(effectiveYuanPrice);
                                return Text(
                                  localPrice
                                      .toStringAsFixed(localPrice < 100 ? 2 : 0)
                                      .replaceAllMapped(
                                        RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
                                        (Match m) => "${m[1]},",
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black, // Secondary Black
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                  ),
                                );
                              }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
