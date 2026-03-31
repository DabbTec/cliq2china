import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/currency_service.dart';
import '../buyer_controller.dart';

class CheckoutView extends GetView<BuyerController> {
  const CheckoutView({super.key});

  void _showPaymentPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 24.h),
            _buildPaymentOption(
              'OPay',
              'https://play-lh.googleusercontent.com/6_S9CH_9jz9Z_zq_zq_zq_zq_zq_zq_zq_zq_zq_zq_zq_zq_zq_zq_zq_zq_zq_zq',
              isSelected: true,
            ),
            SizedBox(height: 16.h),
            _buildPaymentOption(
              'Bank Transfer',
              null,
              icon: Icons.account_balance_outlined,
              isSelected: false,
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    String? logoUrl, {
    IconData? icon,
    bool isSelected = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16.r),
        border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
      ),
      child: Row(
        children: [
          if (logoUrl != null)
            Image.network(
              logoUrl,
              width: 32.w,
              height: 32.w,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.payment, size: 24.sp),
            )
          else if (icon != null)
            Icon(icon, color: Colors.black, size: 24.sp),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
          ),
          const Spacer(),
          if (isSelected)
            Icon(Icons.check_circle, color: Colors.black, size: 20.sp),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Order Confirmation',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Shipping Address
            _buildSectionTitle('Shipping Address'),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.black,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Home Address',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          '123 Main Street, Lagos, Nigeria',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey, size: 20.sp),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // 2. Items
            _buildSectionTitle('Items'),
            SizedBox(height: 12.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.cartItems
                  .where((i) => i.isSelected.value)
                  .length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final item = controller.cartItems
                    .where((i) => i.isSelected.value)
                    .toList()[index];
                final product = item.product;
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        width: 60.w,
                        height: 60.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Quantity: ${item.quantity.value}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '¥ ${(controller.calculateTieredPrice(product, item.quantity.value) * item.quantity.value).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 32.h),

            // 3. Payment Method
            _buildSectionTitle('Payment Method'),
            SizedBox(height: 12.h),
            InkWell(
              onTap: () => _showPaymentPicker(context),
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.black,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'OPay',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey, size: 20.sp),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // 4. Order Summary
            _buildSectionTitle('Order Summary'),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Obx(() {
                final yuanTotal = controller.totalAmountYuan;
                final localTotal = CurrencyService.to.convertFromYuan(
                  yuanTotal,
                );
                final symbol = CurrencyService.to.localCurrencySymbol;

                return Column(
                  children: [
                    _buildSummaryRow(
                      'Subtotal (Yuan)',
                      '¥ ${yuanTotal.toStringAsFixed(0)}',
                    ),
                    SizedBox(height: 8.h),
                    _buildSummaryRow(
                      'Shipping Fee',
                      'FREE',
                      valueColor: Colors.green,
                    ),
                    Divider(height: 24.h),
                    _buildSummaryRow(
                      'Total Amount',
                      '$symbol ${localTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                      isTotal: true,
                    ),
                  ],
                );
              }),
            ),
            SizedBox(height: 100.h), // Space for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(24.w),
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
              Expanded(
                child: Obx(() {
                  final yuanTotal = controller.totalAmountYuan;
                  final localTotal = CurrencyService.to.convertFromYuan(
                    yuanTotal,
                  );
                  final symbol = CurrencyService.to.localCurrencySymbol;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                      Text(
                        '$symbol ${localTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              SizedBox(width: 16.w),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar(
                        'Processing',
                        'Redirecting to OPay...',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.black,
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      'Pay Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w900,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
            color: isTotal ? Colors.black : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20.sp : 14.sp,
            fontWeight: FontWeight.w900,
            color: valueColor ?? (isTotal ? Colors.black : Colors.black),
          ),
        ),
      ],
    );
  }
}
