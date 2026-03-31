import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/models/product.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/currency_service.dart';
import '../buyer_controller.dart';
import '../../auth/auth_controller.dart';
import 'buyer_profile_view.dart';
import '../../../core/widgets/cards.dart';
import '../../../routes/app_pages.dart';
import 'package:shimmer/shimmer.dart';

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

class ShiftedCenterDockedLocation extends FloatingActionButtonLocation {
  const ShiftedCenterDockedLocation({this.offset = 0.0});
  final double offset;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX =
        (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2.0;
    final double contentBottom = scaffoldGeometry.contentBottom;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;

    // Center the FAB on the contentBottom (which is the top of the bottom nav)
    final double fabY = contentBottom - fabHeight / 2.0;

    return Offset(fabX, fabY + offset);
  }
}

class HillNotchedShape extends NotchedShape {
  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) return Path()..addRect(host);

    final double r = guest.width / 2.0;
    const double notchMargin = 6.0;
    final double fullRadius = r + notchMargin;

    final double cx = guest.center.dx;
    final double cy = guest.center.dy;

    final double h = (cy - host.top).abs();

    if (h >= fullRadius) return Path()..addRect(host);

    final double dx = math.sqrt(math.max(0, fullRadius * fullRadius - h * h));
    final double x1 = cx - dx;
    final double x2 = cx + dx;

    const double flare = 15.0;

    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(x1 - flare, host.top)
      ..quadraticBezierTo(x1 - 5, host.top, x1, host.top)
      ..arcToPoint(
        Offset(x2, host.top),
        radius: Radius.circular(fullRadius),
        clockwise: true,
      )
      ..quadraticBezierTo(x2 + 5, host.top, x2 + flare, host.top)
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}

class SwipeHintWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onAnimationComplete;

  const SwipeHintWrapper({
    super.key,
    required this.child,
    required this.onAnimationComplete,
  });

  @override
  State<SwipeHintWrapper> createState() => _SwipeHintWrapperState();
}

class _SwipeHintWrapperState extends State<SwipeHintWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = TweenSequence<double>([
      // Peak Left
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -30,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      // Back to center
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -30,
          end: 0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 25,
      ),
      // Peak Right
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 30,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      // Back to center
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 30,
          end: 0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 25,
      ),
    ]).animate(_controller);

    // Delay slightly before playing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.forward().then((_) => widget.onAnimationComplete());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: Stack(
            children: [
              // Hint Background Colors
              if (_animation.value < 0)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              if (_animation.value > 0)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.favorite, color: Colors.white),
                  ),
                ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class BuyerDashboard extends GetView<BuyerController> {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BuyerController());

    // Show affiliate modal on first load in this session for logged-in buyers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Get.find<AuthController>();
      if (authController.user.value != null &&
          authController.user.value?.role == 'buyer' &&
          !controller.affiliateModalShown.value) {
        _showAffiliateModal(context);
        controller.affiliateModalShown.value = true;
      }
    });

    return Obx(
      () => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Brightness.dark, // Black icons for white background
          statusBarBrightness: Brightness.light, // For iOS
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset:
              true, // Changed from false to allow content resizing
          appBar: _buildDynamicAppBar(),
          body: _buildBody(context),
          floatingActionButtonLocation: const ShiftedCenterDockedLocation(
            offset: 15,
          ),
          floatingActionButton: MediaQuery.of(context).viewInsets.bottom > 0
              ? null
              : FloatingActionButton(
                  onPressed: () => controller.changePage(4),
                  backgroundColor: Colors.red,
                  elevation: 6,
                  shape: const CircleBorder(),
                  child: Obx(() {
                    final count = controller.cartItems.length;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                      child: Stack(
                        key: ValueKey<int>(count),
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          if (count > 0)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1.5,
                                  ),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
          bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom > 0
              ? null
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: BottomAppBar(
                    padding: EdgeInsets.zero,
                    height: 70,
                    color: Colors.white,
                    elevation: 0,
                    shape: HillNotchedShape(),
                    notchMargin: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          0,
                          Icons.home_outlined,
                          Icons.home,
                          'Home',
                        ),
                        _buildNavItem(
                          1,
                          Icons.category_outlined,
                          Icons.category,
                          'Shop',
                        ),
                        const SizedBox(width: 48),
                        _buildNavItem(
                          2,
                          Icons.favorite_border,
                          Icons.favorite,
                          'Wishlist',
                        ),
                        _buildNavItem(
                          3,
                          Icons.person_outline,
                          Icons.person,
                          'Account',
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    return Obx(() {
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
    });
  }

  void _showAffiliateModal(BuildContext context) {
    const String referralLink = "https://cliq2china.com/join/VIP123";
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF424242), // Lighter grey
                const Color(0xFF212121), // Soft black
                Colors.black,
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Join our Affiliate Program!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Invite friends and earn rewards for every successful referral.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        referralLink,
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          const ClipboardData(text: referralLink),
                        );
                        Get.snackbar(
                          'Copied',
                          'Referral link copied to clipboard!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.white,
                          colorText: Colors.black,
                        );
                      },
                      child: const Icon(
                        Icons.copy,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Implement sharing logic
                        Get.snackbar(
                          'Share',
                          'Sharing feature coming soon!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.white,
                          colorText: Colors.black,
                        );
                      },
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Share Link'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Get.back();
                  controller.changePage(3); // Go to Profile
                },
                child: const Text(
                  'Check it on your profile',
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  PreferredSizeWidget? _buildDynamicAppBar() {
    final current = controller.currentIndex.value;

    // Home view handles its own header via slivers for sticky effect
    if (current == 0) {
      return null;
    }

    // Account view handles its own UI or has no appbar
    if (current == 3) {
      return PreferredSize(
        preferredSize: Size.zero,
        child: const SizedBox.shrink(),
      );
    }

    switch (current) {
      case 1:
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          title: const Text(
            'Categories',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        );
      case 2:
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          title: const Text(
            'Wishlist',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => controller.toggleWishlistSelectionMode(),
              child: Obx(
                () => Text(
                  controller.isWishlistSelectionMode.value
                      ? 'Cancel'
                      : 'Select',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        );
      case 4:
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          title: Obx(
            () => Text(
              'Cart (${controller.cartItems.length})',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => controller.changePage(2),
              icon: const Icon(Icons.favorite_border, color: Colors.black),
            ),
            Obx(
              () => IconButton(
                onPressed: controller.selectedCount == 0
                    ? null
                    : () => controller.removeSelectedCartItems(),
                icon: Icon(
                  Icons.delete_outline,
                  color: controller.selectedCount == 0
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        );
      default:
        return PreferredSize(
          preferredSize: Size.zero,
          child: const SizedBox.shrink(),
        );
    }
  }

  Widget _buildBody(BuildContext context) {
    switch (controller.currentIndex.value) {
      case 0:
        return _buildHomeView(context);
      case 1:
        return _buildCategoriesView();
      case 2:
        return _buildWishlistView();
      case 3:
        return _buildProfileView();
      case 4:
        return _buildCartView();
      default:
        return _buildHomeView(context);
    }
  }

  Widget _buildCartView() {
    return Obx(
      () => controller.cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: controller.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = controller.cartItems[index];
                      final product = item.product;
                      final displayStore =
                          product.store?.name ??
                          product.seller?.businessName ??
                          'Unnamed Store';

                      Widget cartCard = Dismissible(
                        key: Key('cart_${product.id}'),
                        direction: DismissDirection.horizontal,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          color: Colors.green,
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                          ),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            controller.removeFromCart(index);
                            Get.snackbar('Removed', 'Item removed from cart');
                          } else {
                            controller.addToWishlist(product);
                          }
                        },
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            controller.addToWishlist(product);
                            return false; // Don't remove from list
                          }
                          return true; // Allow remove for delete
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        controller.toggleSelection(index),
                                    child: Obx(
                                      () => Icon(
                                        item.isSelected.value
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: item.isSelected.value
                                            ? AppColors.primary
                                            : Colors.grey,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    displayStore,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              if (product.moqTiers != null &&
                                  product.moqTiers!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 34,
                                    top: 4,
                                  ),
                                  child: Obx(
                                    () => _buildPriceDropNudge(
                                      product,
                                      item.quantity.value,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 32),
                                  GestureDetector(
                                    onTap: () => Get.toNamed(
                                      Routes.productDetails,
                                      arguments: {'product': product},
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: product.imageUrl,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        if (product.stock <= 5)
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withValues(
                                                  alpha: 0.8,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                      bottomRight:
                                                          Radius.circular(8),
                                                    ),
                                              ),
                                              child: Text(
                                                'Only ${product.stock} left',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Obx(() {
                                                    // Reactive calculations based on current item quantity
                                                    final currentQty =
                                                        item.quantity.value;
                                                    final unitYuanPrice =
                                                        controller
                                                            .calculateTieredPrice(
                                                              product,
                                                              currentQty,
                                                            );
                                                    final totalYuanPrice =
                                                        unitYuanPrice *
                                                        currentQty;
                                                    final totalLocalPrice =
                                                        CurrencyService.to
                                                            .convertFromYuan(
                                                              totalYuanPrice,
                                                            );

                                                    final displayPriceStr =
                                                        totalLocalPrice
                                                            .toStringAsFixed(0)
                                                            .replaceAllMapped(
                                                              RegExp(
                                                                r"(\d{1,3})(?=(\d{3})+(?!\d))",
                                                              ),
                                                              (Match m) =>
                                                                  "${m[1]},",
                                                            );

                                                    final displayYuanPriceStr =
                                                        totalYuanPrice > 0
                                                        ? totalYuanPrice
                                                              .toStringAsFixed(
                                                                0,
                                                              )
                                                        : '';

                                                    // Ensure GetX tracks location changes
                                                    CurrencyService
                                                        .to
                                                        .currentLocation
                                                        .value;

                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                '¥',
                                                                style: TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .error,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                ),
                                                              ),
                                                              Text(
                                                                displayYuanPriceStr,
                                                                style: TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .error,
                                                                  fontSize: 26,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                '(≈ ',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${CurrencyService.to.localCurrencySymbol}$displayPriceStr',
                                                                style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 22,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                ),
                                                              ),
                                                              Text(
                                                                ')',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              if ((product.moqTiers !=
                                                                          null &&
                                                                      product
                                                                          .moqTiers!
                                                                          .isNotEmpty) ||
                                                                  (product.minQty !=
                                                                          null &&
                                                                      product.minQty! >
                                                                          1))
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets.only(
                                                                        left: 8,
                                                                      ),
                                                                  child: Text(
                                                                    '$currentQty pcs',
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                                  if (product.originalPrice !=
                                                      null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 2,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            '¥${product.originalPrice!.toStringAsFixed(0)}',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey
                                                                  .shade400,
                                                              fontSize: 10,
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            '≈',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey
                                                                  .shade400,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Obx(() {
                                                            // Ensure GetX tracks location changes
                                                            CurrencyService
                                                                .to
                                                                .currentLocation
                                                                .value;
                                                            final localOriginal =
                                                                CurrencyService
                                                                    .to
                                                                    .convertFromYuan(
                                                                      product
                                                                          .originalPrice!,
                                                                    );
                                                            final displayOriginal = localOriginal
                                                                .toStringAsFixed(
                                                                  0,
                                                                )
                                                                .replaceAllMapped(
                                                                  RegExp(
                                                                    r"(\d{1,3})(?=(\d{3})+(?!\d))",
                                                                  ),
                                                                  (Match m) =>
                                                                      "${m[1]},",
                                                                );
                                                            return Text(
                                                              '${CurrencyService.to.localCurrencySymbol}$displayOriginal',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                fontSize: 10,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              ),
                                                            );
                                                          }),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Row(
                                              children: [
                                                Obx(() {
                                                  final isInWishlist =
                                                      controller
                                                          .isProductInWishlist(
                                                            product.id,
                                                          );
                                                  return IconButton(
                                                    onPressed: () => controller
                                                        .toggleWishlist(
                                                          product,
                                                        ),
                                                    icon: Icon(
                                                      isInWishlist
                                                          ? Icons.favorite
                                                          : Icons
                                                                .favorite_border,
                                                      color: isInWishlist
                                                          ? Colors.red
                                                          : Colors.grey,
                                                      size: 18,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                  );
                                                }),
                                                const SizedBox(width: 4),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () => controller
                                                            .decrementQuantity(
                                                              index,
                                                            ),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                              ),
                                                          child: Icon(
                                                            Icons.remove,
                                                            size: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      Obx(
                                                        () => Text(
                                                          '${item.quantity.value}',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () => controller
                                                            .incrementQuantity(
                                                              index,
                                                            ),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                              ),
                                                          child: Icon(
                                                            Icons.add,
                                                            size: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );

                      if (index == 0 && !controller.swipeHintShown.value) {
                        return SwipeHintWrapper(
                          onAnimationComplete: () {
                            controller.swipeHintShown.value = true;
                          },
                          child: cartCard,
                        );
                      }

                      return cartCard;
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => controller.toggleSelectAllCart(),
                        child: Obx(
                          () => Icon(
                            controller.isAllCartSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: controller.isAllCartSelected
                                ? AppColors.primary
                                : Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'All',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      const Spacer(),
                      Obx(() {
                        final yuanTotal = controller.totalAmountYuan;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '¥ ${yuanTotal.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '≈',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Obx(() {
                              // Ensure GetX tracks location changes
                              final _ =
                                  CurrencyService.to.currentLocation.value;
                              final localTotal = CurrencyService.to
                                  .convertFromYuan(yuanTotal);
                              return Text(
                                '${CurrencyService.to.localCurrencySymbol} ${localTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 26,
                                  color: Colors.black,
                                ),
                              );
                            }),
                          ],
                        );
                      }),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => Get.toNamed(Routes.checkout),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: Obx(
                          () => Text(
                            'Checkout (${controller.selectedCount})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
    );
  }

  Widget _buildHomeView(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.products.isEmpty) {
        return _buildShimmer();
      }
      if (controller.products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'No Products Available Yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later or pull down to refresh.',
                style: TextStyle(color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: controller.loadProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Now'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadProducts,
        child: CustomScrollView(
          controller: controller.scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              primary: true,
              elevation: 0,
              automaticallyImplyLeading: false,
              toolbarHeight: 40,
              titleSpacing: 16,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header Logo
                  Image.asset(
                    'assets/images/c2cheader-logo.png',
                    height: 24.h,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                  const Spacer(),
                  // Notification Bell
                  Stack(
                    children: [
                      const Icon(
                        Icons.notifications_none_outlined,
                        color: Colors.black,
                        size: 22,
                      ),
                      Positioned(
                        right: 1,
                        top: 1,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(78),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: GestureDetector(
                        onTap: () => Get.toNamed(Routes.search),
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.grey[600],
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Search products, brands...',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildCategoriesRow(),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildBanners()),
            SliverToBoxAdapter(child: _buildShippingInfo()),
            SliverToBoxAdapter(child: _buildProductsGrid()),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
          ],
        ),
      );
    });
  }

  Widget _buildCategoriesView() {
    final mainCategories = [
      'Home & Office',
      'Phones & Tablets',
      'Fashion',
      'Health & Beauty',
      'Electronics',
      'Computing',
      'Grocery',
      'Garden & Outdoors',
      'Automobile',
      'Sporting Goods',
    ];

    return Row(
      children: [
        Container(
          width: 100,
          color: Colors.white,
          child: ListView.builder(
            itemCount: mainCategories.length,
            itemBuilder: (context, index) {
              final isSelected = index == 0;
              return GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF1F1F1) : Colors.white,
                    border: isSelected
                        ? const Border(
                            left: BorderSide(
                              color: AppColors.primary,
                              width: 4,
                            ),
                          )
                        : null,
                  ),
                  child: Text(
                    mainCategories[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Products',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildCategorySection('Appliances', [
                {
                  'name': 'Large Appliances',
                  'image':
                      'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=200',
                },
                {
                  'name': 'Small Appliances',
                  'image':
                      'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=200',
                },
              ]),
              const SizedBox(height: 12),
              _buildCategorySection('Home & Kitchen', [
                {
                  'name': 'Cookware',
                  'image':
                      'https://images.unsplash.com/photo-1556911229-4d37c9536f75?q=80&w=200',
                },
                {
                  'name': 'Small Appliances',
                  'image':
                      'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=200',
                },
                {
                  'name': 'Bakeware',
                  'image':
                      'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?q=80&w=200',
                },
                {
                  'name': 'Cutlery & Knife Accessories',
                  'image':
                      'https://images.unsplash.com/photo-1591261730799-ee4e6c2d16d7?q=80&w=200',
                },
              ], showSeeAll: true),
              const SizedBox(height: 12),
              _buildCategorySection('Home', [
                {
                  'name': 'Bedding',
                  'image':
                      'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?q=80&w=200',
                },
                {
                  'name': 'Decor',
                  'image':
                      'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?q=80&w=200',
                },
                {
                  'name': 'Furniture',
                  'image':
                      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=200',
                },
              ]),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(
    String title,
    List<Map<String, String>> items, {
    bool showSeeAll = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (showSeeAll)
                Text(
                  'See All',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const Divider(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: items[index]['image'] ?? '',
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index]['name'] ?? 'Category',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.black87),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWishlistTab(
                  'All items (${controller.wishlistItems.length})',
                  true,
                ),
                if (controller.isWishlistSelectionMode.value)
                  GestureDetector(
                    onTap: () => controller.toggleSelectAllWishlist(),
                    child: Row(
                      children: [
                        const Text(
                          'Select All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Checkbox(
                          value: controller.isAllWishlistSelected,
                          onChanged: (v) =>
                              controller.toggleSelectAllWishlist(),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.wishlistItems.isEmpty) {
              return const Center(child: Text('Your wishlist is empty'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.wishlistItems.length,
              itemBuilder: (context, index) {
                final product = controller.wishlistItems[index];
                final isSelected = controller.selectedWishlistIds.contains(
                  product.id,
                );

                return GestureDetector(
                  onTap: () {
                    if (controller.isWishlistSelectionMode.value) {
                      controller.toggleWishlistItemSelection(product.id);
                    } else {
                      Get.toNamed(
                        Routes.productDetails,
                        arguments: {'product': product},
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    color: Colors.transparent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.isWishlistSelectionMode.value) ...[
                          Checkbox(
                            value: isSelected,
                            onChanged: (v) => controller
                                .toggleWishlistItemSelection(product.id),
                            activeColor: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                        ],
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
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
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _formatPrice(product.effectiveYuan),
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '≈',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Obx(() {
                                      final localPrice = product.effectiveLocal;
                                      return Text(
                                        '${CurrencyService.to.localCurrencySymbol}${_formatPrice(localPrice)}',
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
                                  Expanded(
                                    child: SizedBox(
                                      height: 32,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            controller.addToCart(product),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Add to cart',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () =>
                                        controller.toggleWishlist(product),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
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
              },
            );
          }),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildWishlistTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isSelected
            ? const Border(bottom: BorderSide(color: Colors.black, width: 2))
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    return const BuyerProfileView();
  }

  Widget _buildCategoriesRow() {
    return Container(
      height: 32, // Reduced from 36
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTabItem(
            'Discover',
            isSelected: true,
            onTap: () => controller.loadProducts(),
          ),
          _buildTabItem(
            'New Arrivals',
            onTap: () => controller.loadProducts(category: 'New'),
          ),
          _buildTabItem(
            'Best Sellers',
            onTap: () => controller.loadProducts(category: 'Best'),
          ),
          _buildTabItem(
            'Premium',
            onTap: () => controller.loadProducts(category: 'Premium'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    String text, {
    bool isSelected = false,
    bool isSpecial = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 15), // Reduced from 20
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14, // Reduced from 15
                fontWeight: isSelected || isSpecial
                    ? FontWeight.w900
                    : FontWeight.w500,
                color: isSpecial
                    ? AppColors.primary
                    : (isSelected ? Colors.black : Colors.grey[600]),
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 1), // Reduced from 2
                height: 1.5, // Reduced from 2
                width: 12, // Reduced from 14
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ), // Reduced from 12
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Free shipping',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Limited-time offer',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
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
                const Icon(
                  Icons.assignment_return_outlined,
                  color: Colors.black87,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery guarantee',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Refund for any issue',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
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
    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          0,
          12,
          12,
        ), // Top padding 0, Horizontal reduced to 12
        child: Container(
          height: 125, // Increased from 100
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (controller.banners.isNotEmpty)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.4,
                    child: CachedNetworkImage(
                      imageUrl: controller.banners[0],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.auto_awesome,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SEASONAL SALE',
                            style: TextStyle(
                              color: Colors.amber[200],
                              letterSpacing: 2,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Up to 70% Off',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Direct from China',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Shop Now',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildProductsGrid() {
    return Obx(() {
      final List<Widget> leftColumn = [];
      final List<Widget> rightColumn = [];

      final productsToDisplay = controller.searchResults;

      if (productsToDisplay.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Text(
              'No products found matching your search.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        );
      }

      for (int i = 0; i < productsToDisplay.length; i++) {
        final product = productsToDisplay[i];
        final double imageHeight = (i % 3 == 0)
            ? 220.0
            : (i % 2 == 0 ? 160.0 : 190.0);
        final String trendingStatus = (i % 5 == 0)
            ? '🔥 Trending Item'
            : (i % 3 == 0 ? '💎 Premium Choice' : '✨ Recommended for you');
        final double basePrice = product.price;
        final double? originalPrice = product.originalPrice;

        final card = Padding(
          padding: const EdgeInsets.all(4.0),
          child: ProductCard(
            title: product.name,
            price: basePrice,
            originalPriceYuan: product.originalPriceYuan,
            minQty: product.minQty,
            moqTiers: product.moqTiers,
            displayPrice: product.displayPrice,
            displayYuan: product.displayYuan,
            displaySymbol: product.displaySymbol,
            originalPrice: originalPrice,
            imageUrl: product.imageUrl,
            imageHeight: imageHeight,
            rating: product.rating,
            stock: product.stock,
            trendingStatus: trendingStatus,
            showSuperDeal: i % 3 == 0,
            isInCart: controller.cartItems.any(
              (item) => item.product.id == product.id,
            ),
            isInWishlist: controller.isProductInWishlist(product.id),
            onTap: () => Get.toNamed(
              Routes.productDetails,
              arguments: {'product': product},
            ),
            onAddToCart: () => controller.addToCart(product),
            onToggleWishlist: () => controller.toggleWishlist(product),
            storeName:
                product.store?.name ??
                product.seller?.businessName ??
                'Unnamed Store',
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
    });
  }

  Widget _buildPriceDropNudge(ProductModel product, int currentQty) {
    if (product.moqTiers == null || product.moqTiers!.isEmpty) {
      return const SizedBox();
    }

    // Find the next tier
    final sortedTiers = List<MOQTier>.from(product.moqTiers!)
      ..sort((a, b) => a.minQty.compareTo(b.minQty));

    MOQTier? nextTier;
    for (var tier in sortedTiers) {
      if (tier.minQty > currentQty) {
        nextTier = tier;
        break;
      }
    }

    if (nextTier == null) return const SizedBox();

    final diff = nextTier.minQty - currentQty;
    final currentUnitPrice = controller.calculateTieredPrice(
      product,
      currentQty,
    );

    double nextUnitPrice = nextTier.pricePerUnit;
    if (nextTier.yuanPrice != null && nextTier.yuanPrice! > 0) {
      nextUnitPrice = nextTier.yuanPrice! / nextTier.minQty;
    }

    final unitPriceDrop = currentUnitPrice - nextUnitPrice;
    if (unitPriceDrop <= 0) return const SizedBox();

    // Calculate total savings on the new total quantity
    final totalSavingsYuan = unitPriceDrop * nextTier.minQty;
    final totalSavingsLocal = CurrencyService.to.convertFromYuan(
      totalSavingsYuan,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_down, size: 14.sp, color: Colors.red),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              'Add $diff more to save ¥${totalSavingsYuan.toStringAsFixed(0)} (≈ ${CurrencyService.to.localCurrencySymbol}${totalSavingsLocal.toStringAsFixed(0)}) in total',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300] ?? Colors.grey,
      highlightColor: Colors.grey[100] ?? Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              height: 50,
              color: Colors.white,
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 80,
                  color: Colors.white,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => Container(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
