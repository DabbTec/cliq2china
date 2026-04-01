import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/category_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../seller_controller.dart';
import '../../auth/auth_controller.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../core/utils/currency_service.dart';
import '../../../routes/app_pages.dart';

class AddProductView extends StatefulWidget {
  final ProductModel? product;
  const AddProductView({super.key, this.product});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final SellerController controller = Get.find<SellerController>();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _uploadService = Get.find<ImageUploadService>();
  final _productRepository = ProductRepository();

  bool get isEditMode => widget.product != null;

  // Basic Info Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Pricing & Inventory Controllers
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _minQtyController = TextEditingController();

  final RxString _selectedCategory = CategoryConstants.categoryNames.first.obs;
  final List<String> _categories = CategoryConstants.categoryNames;
  final RxString _productStatus = 'active'.obs;

  final RxList<File> _selectedFiles = <File>[].obs;
  final RxList<String> _existingImageUrls = <String>[].obs;
  final RxBool _isPublishing = false.obs;

  // Added: Reactive variables for base price section
  final RxDouble _localPrice = 0.0.obs;
  final RxInt _minQty = 1.obs;
  final RxDouble _yuanValue = 0.0.obs;
  final RxBool _isAutoDetecting = false.obs;

  // Variants State
  final RxList<ProductVariant> _variants = <ProductVariant>[].obs;

  // MOQ Tiers State
  final RxList<MOQTier> _moqTiers = <MOQTier>[].obs;
  final RxBool _hasTiers = false.obs;

  @override
  void initState() {
    super.initState();

    if (isEditMode && widget.product != null) {
      _titleController.text = widget.product!.name;
      _descController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _minQtyController.text = (widget.product!.minQty ?? 1).toString();
      _selectedCategory.value = CategoryConstants.normalizeCategory(
        widget.product!.category,
      );
      _productStatus.value = widget.product!.status ?? 'active';

      if (widget.product?.galleryUrls != null) {
        _existingImageUrls.assignAll(widget.product!.galleryUrls);
      }

      if (widget.product?.variants != null) {
        _variants.assignAll(widget.product!.variants!);
      }

      if (widget.product?.moqTiers != null) {
        _hasTiers.value = true;
        _moqTiers.assignAll(widget.product!.moqTiers!);
      }

      _fetchLatestDetails();
    } else {
      // Default values for new product
      _priceController.text = '0';
      _stockController.text = '0';
      _minQtyController.text = '1';
    }

    // Add listeners
    _priceController.addListener(_updateBasePrices);
    _minQtyController.addListener(_updateBasePrices);

    // Initial calculation
    _updateBasePrices();
  }

  void _updateBasePrices() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final qty = int.tryParse(_minQtyController.text) ?? 1;
    _localPrice.value = price;
    _minQty.value = qty;
    _yuanValue.value = CurrencyService.to.convertToYuan(price * qty);
  }

  Future<void> _fetchLatestDetails() async {
    try {
      final latestProduct = await _productRepository.getProductDetail(
        widget.product!.id,
      );
      setState(() {
        _titleController.text = latestProduct.name;
        _descController.text = latestProduct.description;
        _priceController.text = latestProduct.price.toString();
        _stockController.text = latestProduct.stock.toString();
        _minQtyController.text = (latestProduct.minQty ?? 1).toString();
        _selectedCategory.value = CategoryConstants.normalizeCategory(
          latestProduct.category,
        );
        _productStatus.value = latestProduct.status ?? 'active';

        _existingImageUrls.assignAll(latestProduct.galleryUrls);
        if (latestProduct.variants != null) {
          _variants.assignAll(latestProduct.variants!);
        }
        if (latestProduct.moqTiers != null) {
          _hasTiers.value = true;
          _moqTiers.assignAll(latestProduct.moqTiers!);
        }
      });
    } catch (e) {
      debugPrint('Error fetching latest product details: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minQtyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      if (_selectedFiles.length + images.length > 5) {
        Get.snackbar(
          'Limit Exceeded',
          'You can only upload up to 5 images.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      _selectedFiles.addAll(images.map((img) => File(img.path)));

      // FUTURE: AI Vision Integration
      // You can call an API here to analyze the uploaded image
      // and suggest a category based on visual content.
      if (_titleController.text.isEmpty) {
        _autoDetectCategory(); // Try detecting from existing text at least
      }
    }
  }

  void _removeImage(int index, {bool isExisting = false}) {
    if (isExisting) {
      _existingImageUrls.removeAt(index);
    } else {
      _selectedFiles.removeAt(index);
    }
  }

  Future<void> _autoDetectCategory() async {
    _isAutoDetecting.value = true;

    // Simulate AI processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    final text = "${_titleController.text} ${_descController.text}";
    final suggested = CategoryConstants.suggestCategory(text);

    if (suggested.isNotEmpty) {
      _selectedCategory.value = suggested;
      Get.snackbar(
        'Category Detected',
        'We\'ve set the category to "$suggested" based on your product details.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        colorText: AppColors.primary,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Auto-detect',
        'Could not determine category. Please select manually.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    _isAutoDetecting.value = false;
  }

  void _addPricingTier({int? index}) {
    final bool isEdit = index != null;
    final tierToEdit = isEdit ? _moqTiers[index] : null;

    final minQtyController = TextEditingController(
      text: isEdit ? tierToEdit!.minQty.toString() : '1',
    );
    final maxQtyController = TextEditingController(
      text: isEdit ? (tierToEdit!.maxQty?.toString() ?? '') : '',
    );

    // Get current unit price in local currency
    double initialLocalPrice = 0;
    if (isEdit) {
      initialLocalPrice = tierToEdit!.pricePerUnit;
    }
    final priceController = TextEditingController(
      text: isEdit ? initialLocalPrice.toStringAsFixed(0) : '0',
    );

    // ADDED: Reactive variables to track current values and calculate total bundle price.
    final RxInt currentMinQty = (isEdit ? tierToEdit!.minQty : 1).obs;
    final RxDouble currentPrice = initialLocalPrice.obs;

    minQtyController.addListener(() {
      currentMinQty.value = int.tryParse(minQtyController.text) ?? 1;
    });
    priceController.addListener(() {
      currentPrice.value = double.tryParse(priceController.text) ?? 0.0;
    });

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit MOQ Tier' : 'New MOQ Tier',
                    style: AppTypography.h2.copyWith(color: Colors.black),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: NumericStepInputBeautiful(
                      label: 'Min Qty',
                      controller: minQtyController,
                      onIncrement: () {
                        int val = int.tryParse(minQtyController.text) ?? 1;
                        minQtyController.text = (val + 1).toString();
                      },
                      onDecrement: () {
                        int val = int.tryParse(minQtyController.text) ?? 1;
                        if (val > 1) {
                          minQtyController.text = (val - 1).toString();
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max Qty (Optional)',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: maxQtyController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'e.g. 10',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              NumericStepInputBeautiful(
                label:
                    'Price per Unit (${CurrencyService.to.localCurrencyCode})',
                controller: priceController,
                icon: Icons.payments_outlined,
                onIncrement: () {
                  double val = double.tryParse(priceController.text) ?? 0;
                  priceController.text = (val + 1).toStringAsFixed(0);
                },
                onDecrement: () {
                  double val = double.tryParse(priceController.text) ?? 0;
                  if (val > 0) {
                    priceController.text = (val - 1).toStringAsFixed(0);
                  }
                },
              ),
              SizedBox(height: 16.h),
              Obx(() {
                final double price = currentPrice.value;
                final int qty = currentMinQty.value;
                final double totalLocal = price * qty;
                final double equivalentYuan = CurrencyService.to.convertToYuan(
                  totalLocal,
                );

                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Local Price:',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${CurrencyService.to.localCurrencySymbol}${totalLocal.toStringAsFixed(2)}',
                            style: AppTypography.h3.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Equivalent in Yuan:',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            '¥${equivalentYuan.toStringAsFixed(2)}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 32.h),
              PrimaryButton(
                text: isEdit ? 'Update MOQ Tier' : 'Add MOQ Tier',
                color: Colors.black,
                textColor: Colors.white,
                onPressed: () {
                  final priceLocalText = priceController.text.trim();
                  final minQtyText = minQtyController.text.trim();
                  final maxQtyText = maxQtyController.text.trim();

                  final priceLocal = double.tryParse(priceLocalText) ?? 0;
                  final minQty = int.tryParse(minQtyText) ?? 0;
                  final maxQty = maxQtyText.isEmpty
                      ? null
                      : int.tryParse(maxQtyText);

                  if (minQty <= 0) {
                    Get.snackbar(
                      'Invalid Quantity',
                      'Minimum quantity must be at least 1',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.orange.withValues(alpha: 0.1),
                    );
                    return;
                  }

                  if (priceLocal <= 0) {
                    Get.snackbar(
                      'Invalid Price',
                      'Wholesale price must be greater than 0',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.orange.withValues(alpha: 0.1),
                    );
                    return;
                  }

                  if (maxQty != null && maxQty < minQty) {
                    Get.snackbar(
                      'Invalid Range',
                      'Max quantity cannot be less than min quantity',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.orange.withValues(alpha: 0.1),
                    );
                    return;
                  }

                  final newTier = MOQTier(
                    minQty: minQty,
                    maxQty: maxQty,
                    pricePerUnit: priceLocal,
                  );

                  if (isEdit) {
                    _moqTiers[index] = newTier;
                  } else {
                    _moqTiers.add(newTier);
                  }

                  // Sort by minQty
                  _moqTiers.sort((a, b) => a.minQty.compareTo(b.minQty));

                  // Refresh list to ensure UI updates
                  _moqTiers.refresh();

                  Get.back();
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  final List<String> _commonColors = [
    'Red',
    'Blue',
    'Green',
    'Black',
    'White',
    'Yellow',
    'Grey',
    'Brown',
    'Pink',
    'Purple',
  ];
  final List<String> _commonSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'];

  void _addVariant({int? index}) {
    final bool isEdit = index != null;
    final variantToEdit = isEdit ? _variants[index] : null;

    final RxString variantType = (isEdit ? variantToEdit!.type : 'Color').obs;
    final RxString variantValue = (isEdit ? variantToEdit!.value : '').obs;
    final RxString customType = ''.obs;

    final valueController = TextEditingController(
      text: isEdit ? variantToEdit!.value : '',
    );
    final priceController = TextEditingController(
      text: isEdit ? (variantToEdit!.price?.toString() ?? '') : '',
    );
    final stockController = TextEditingController(
      text: isEdit ? (variantToEdit!.stock?.toString() ?? '') : '',
    );
    final descriptionController = TextEditingController(
      text: isEdit ? (variantToEdit!.description ?? '') : '',
    );

    // Image handling for variants
    final RxList<String> existingVariantImages =
        (isEdit ? List<String>.from(variantToEdit!.galleryUrls) : <String>[])
            .obs;
    final RxList<File> newVariantImages = <File>[].obs;
    final RxBool isUploadingImage = false.obs;
    final RxMap<String, String> nestedAttributes =
        (isEdit && variantToEdit!.attributes != null
                ? Map<String, String>.from(variantToEdit!.attributes!)
                : <String, String>{})
            .obs;

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        height: Get.height * 0.9,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Edit Variant' : 'New Variant',
                  style: AppTypography.h2.copyWith(color: Colors.black),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    // Variant Images (Up to 3)
                    Text(
                      'Variant Images (Max 3, at least 1 recommended)',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Obx(
                      () => Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: [
                          // Existing Images
                          ...existingVariantImages.asMap().entries.map((entry) {
                            final int idx = entry.key;
                            final String url = entry.value;
                            return Stack(
                              children: [
                                Container(
                                  width: 80.w,
                                  height: 80.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(url),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () =>
                                        existingVariantImages.removeAt(idx),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 14.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          // New Local Files
                          ...newVariantImages.asMap().entries.map((entry) {
                            final int idx = entry.key;
                            final File file = entry.value;
                            return Stack(
                              children: [
                                Container(
                                  width: 80.w,
                                  height: 80.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    image: DecorationImage(
                                      image: FileImage(file),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => newVariantImages.removeAt(idx),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 14.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          if (existingVariantImages.length +
                                  newVariantImages.length <
                              3)
                            GestureDetector(
                              onTap: () async {
                                final XFile? image = await _imagePicker
                                    .pickImage(source: ImageSource.gallery);
                                if (image != null) {
                                  newVariantImages.add(File(image.path));
                                }
                              },
                              child: Container(
                                width: 80.w,
                                height: 80.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  color: Colors.grey,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Variant Type Dropdown
                    Obx(
                      () => DropdownButtonFormField<String>(
                        initialValue: variantType.value,
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Variant Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ['Color', 'Size', 'Add Other Variant']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) {
                          variantType.value = v!;
                          variantValue.value = '';
                          valueController.clear();
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Custom Type Name
                    Obx(() {
                      if (variantType.value == 'Add Other Variant') {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: CustomTextFieldBeautiful(
                            labelText: 'Custom Type Name',
                            hintText: 'e.g. Plug Type',
                            onChanged: (v) => customType.value = v,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    // Variant Value Selection
                    Obx(() {
                      if (variantType.value == 'Color') {
                        return DropdownButtonFormField<String>(
                          initialValue: variantValue.value.isEmpty
                              ? null
                              : variantValue.value,
                          dropdownColor: Colors.white,
                          hint: const Text('Select Color'),
                          decoration: InputDecoration(
                            labelText: 'Color',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [..._commonColors, 'Others']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) {
                            variantValue.value = v!;
                            if (v != 'Others') valueController.text = v;
                          },
                        );
                      } else if (variantType.value == 'Size') {
                        return DropdownButtonFormField<String>(
                          initialValue: variantValue.value.isEmpty
                              ? null
                              : variantValue.value,
                          dropdownColor: Colors.white,
                          hint: const Text('Select Size'),
                          decoration: InputDecoration(
                            labelText: 'Size',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [..._commonSizes, 'Others']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) {
                            variantValue.value = v!;
                            if (v != 'Others') valueController.text = v;
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    Obx(() {
                      bool showTextField =
                          variantType.value != 'Color' &&
                              variantType.value != 'Size' ||
                          variantValue.value == 'Others';
                      if (showTextField) {
                        return Padding(
                          padding: EdgeInsets.only(top: 16.h),
                          child: CustomTextFieldBeautiful(
                            controller: valueController,
                            labelText: 'Value',
                            hintText: 'e.g. Lime Green, XL, 500g',
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    SizedBox(height: 20.h),

                    // Nested Attributes Section
                    Text(
                      'Additional Attributes (e.g. Color, Size, Plug Type)',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Obx(
                      () => Column(
                        children: [
                          ...nestedAttributes.entries.map((entry) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        border: Border.all(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${entry.key}: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.sp,
                                            ),
                                          ),
                                          Text(
                                            entry.value,
                                            style: TextStyle(fontSize: 13.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        nestedAttributes.remove(entry.key),
                                  ),
                                ],
                              ),
                            );
                          }),
                          OutlinedButton.icon(
                            onPressed: () {
                              final RxString attrName = 'Size'.obs;
                              final RxString attrValue = ''.obs;
                              final nameCtrl = TextEditingController();
                              final valueCtrl = TextEditingController();

                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Add Attribute'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DropdownButtonFormField<String>(
                                        value: attrName.value,
                                        items: ['Size', 'Color', 'Other']
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) {
                                          attrName.value = v!;
                                          if (v == 'Other') {
                                            nameCtrl.clear();
                                          } else {
                                            nameCtrl.text = v;
                                          }
                                        },
                                      ),
                                      Obx(
                                        () => attrName.value == 'Other'
                                            ? TextField(
                                                controller: nameCtrl,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText:
                                                          'Attribute Name',
                                                    ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                      const SizedBox(height: 16),
                                      Obx(() {
                                        if (attrName.value == 'Color') {
                                          return DropdownButtonFormField<
                                            String
                                          >(
                                            value: attrValue.value.isEmpty
                                                ? null
                                                : attrValue.value,
                                            hint: const Text('Select Color'),
                                            items: [..._commonColors, 'Others']
                                                .map(
                                                  (e) => DropdownMenuItem(
                                                    value: e,
                                                    child: Text(e),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (v) {
                                              attrValue.value = v!;
                                              if (v != 'Others') {
                                                valueCtrl.text = v;
                                              } else {
                                                valueCtrl.clear();
                                              }
                                            },
                                          );
                                        } else if (attrName.value == 'Size') {
                                          return DropdownButtonFormField<
                                            String
                                          >(
                                            value: attrValue.value.isEmpty
                                                ? null
                                                : attrValue.value,
                                            hint: const Text('Select Size'),
                                            items: [..._commonSizes, 'Others']
                                                .map(
                                                  (e) => DropdownMenuItem(
                                                    value: e,
                                                    child: Text(e),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (v) {
                                              attrValue.value = v!;
                                              if (v != 'Others') {
                                                valueCtrl.text = v;
                                              } else {
                                                valueCtrl.clear();
                                              }
                                            },
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      }),
                                      Obx(() {
                                        bool showTextField =
                                            (attrName.value != 'Color' &&
                                                attrName.value != 'Size') ||
                                            attrValue.value == 'Others';
                                        if (showTextField) {
                                          return TextField(
                                            controller: valueCtrl,
                                            decoration: const InputDecoration(
                                              labelText: 'Value',
                                              hintText: 'e.g. XL, 500g, Red',
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      }),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final name = nameCtrl.text.trim();
                                        final val = valueCtrl.text.trim();
                                        if (name.isNotEmpty && val.isNotEmpty) {
                                          nestedAttributes[name] = val;
                                          Get.back();
                                        }
                                      },
                                      child: const Text('Add'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Attribute'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Variant Description (New)
                    CustomTextFieldBeautiful(
                      controller: descriptionController,
                      labelText: 'Variant Description (Optional)',
                      hintText: 'e.g. Specific details for this variant...',
                      maxLines: 2,
                    ),
                    SizedBox(height: 20.h),
                    // Price & Stock
                    Row(
                      children: [
                        Expanded(
                          child: NumericStepInputBeautiful(
                            label:
                                'Price (${CurrencyService.to.localCurrencyCode})',
                            controller: priceController,
                            onIncrement: () {
                              double val =
                                  double.tryParse(priceController.text) ?? 0;
                              priceController.text = (val + 1).toStringAsFixed(
                                0,
                              );
                            },
                            onDecrement: () {
                              double val =
                                  double.tryParse(priceController.text) ?? 0;
                              if (val > 0) {
                                priceController.text = (val - 1)
                                    .toStringAsFixed(0);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: NumericStepInputBeautiful(
                            label: 'Stock (Optional)',
                            controller: stockController,
                            onIncrement: () {
                              int val = int.tryParse(stockController.text) ?? 0;
                              stockController.text = (val + 1).toString();
                            },
                            onDecrement: () {
                              int val = int.tryParse(stockController.text) ?? 0;
                              if (val > 0) {
                                stockController.text = (val - 1).toString();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    Obx(
                      () => PrimaryButton(
                        text: isUploadingImage.value
                            ? 'Uploading...'
                            : 'Add Variant',
                        color: Colors.black,
                        textColor: Colors.white,
                        isLoading: isUploadingImage.value,
                        onPressed: () async {
                          String finalValue = valueController.text.trim();
                          if (finalValue.isEmpty) {
                            finalValue = variantValue.value;
                          }

                          if (finalValue.isNotEmpty && finalValue != 'Others') {
                            isUploadingImage.value = true;
                            List<String> uploadedUrls = List<String>.from(
                              existingVariantImages,
                            );

                            if (newVariantImages.isNotEmpty) {
                              try {
                                final result = await _uploadService
                                    .uploadImages(newVariantImages.toList());
                                uploadedUrls.addAll(
                                  List<String>.from(result['image_urls'] ?? []),
                                );
                              } catch (e) {
                                Get.snackbar(
                                  'Upload Error',
                                  'Failed to upload variant images',
                                );
                              }
                            }

                            final priceLocal =
                                double.tryParse(priceController.text) ?? 0;

                            String finalType = variantType.value;
                            if (finalType == 'Add Other Variant') {
                              finalType = customType.value.isEmpty
                                  ? 'Other'
                                  : customType.value;
                            }

                            final newVariant = ProductVariant(
                              type: finalType,
                              value: finalValue,
                              price: priceLocal > 0 ? priceLocal : null,
                              stock: int.tryParse(stockController.text),
                              imageUrl: uploadedUrls.isNotEmpty
                                  ? uploadedUrls.first
                                  : null,
                              galleryUrls: uploadedUrls,
                              description:
                                  descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                              isActive: true,
                              attributes: nestedAttributes.isNotEmpty
                                  ? Map<String, String>.from(nestedAttributes)
                                  : null,
                            );

                            if (isEdit) {
                              _variants[index] = newVariant;
                            } else {
                              _variants.add(newVariant);
                            }
                            isUploadingImage.value = false;
                            Get.back();
                          } else {
                            Get.snackbar(
                              'Required',
                              'Please provide a variant value',
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Product' : 'Create Product',
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 24),
          onPressed: () => Get.back(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Obx(
              () => Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _productStatus.value == 'active'
                      ? Colors.green.withValues(alpha: 0.1)
                      : _productStatus.value == 'draft'
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _productStatus.value == 'active'
                      ? Icons.check_circle_rounded
                      : _productStatus.value == 'draft'
                      ? Icons.edit_document
                      : Icons.archive_rounded,
                  color: _productStatus.value == 'active'
                      ? Colors.green
                      : _productStatus.value == 'draft'
                      ? Colors.orange
                      : Colors.grey,
                  size: 20,
                ),
              ),
            ),
            onSelected: (v) => _productStatus.value = v,
            itemBuilder: (context) => [
              _buildPopupItem(
                'active',
                'Active',
                Icons.check_circle_rounded,
                Colors.green,
              ),
              _buildPopupItem(
                'draft',
                'Draft',
                Icons.edit_document,
                Colors.orange,
              ),
              _buildPopupItem(
                'archived',
                'Archived',
                Icons.archive_rounded,
                Colors.grey,
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'PRODUCT MEDIA',
                    Icons.photo_library_rounded,
                    isCompulsory: true,
                  ),
                  _buildImageUploader(),
                  SizedBox(height: 32.h),
                  _buildSectionHeader(
                    'GENERAL INFORMATION',
                    Icons.info_outline_rounded,
                    isCompulsory: true,
                  ),
                  _buildBasicInfoSection(),
                  SizedBox(height: 32.h),
                  _buildSectionHeader(
                    'PRICING & INVENTORY',
                    Icons.inventory_2_outlined,
                    isCompulsory: true,
                  ),
                  _buildPricingInventorySection(),
                  SizedBox(height: 32.h),
                  _buildSectionHeader(
                    'MOQ PRICING',
                    Icons.layers_outlined,
                    isCompulsory: true,
                  ),
                  _buildPricingTiersSection(),
                  SizedBox(height: 32.h),
                  _buildSectionHeader('PRODUCT VARIANTS', Icons.style_outlined),
                  _buildVariantsSection(),
                  SizedBox(height: 48.h),
                  OutlinedButton.icon(
                    onPressed: _previewProduct,
                    icon: const Icon(Icons.visibility_outlined, size: 20),
                    label: const Text('Preview Product Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      minimumSize: Size(double.infinity, 50.h),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Obx(
                    () => PrimaryButton(
                      text: isEditMode
                          ? 'Update Product'
                          : 'Publish to Marketplace',
                      color: Colors.black,
                      textColor: Colors.white,
                      onPressed: _isPublishing.value
                          ? () {}
                          : () => _saveProduct(),
                      isLoading:
                          controller.isLoading.value || _isPublishing.value,
                    ),
                  ),
                  SizedBox(height: 48.h),
                ],
              ),
            ),
          ),
          Obx(
            () => (controller.isLoading.value || _isPublishing.value)
                ? Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    bool isCompulsory = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, left: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.sp, color: Colors.black),
              SizedBox(width: 12.w),
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 1.5,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          if (isCompulsory)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Compulsory',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    bool isSelected = _productStatus.value == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(color: isSelected ? color : Colors.black87),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(Icons.check, color: color, size: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildCard(
      child: Column(
        children: [
          CustomTextFieldBeautiful(
            controller: _titleController,
            hintText: 'Product name',
            labelText: 'Product Title *',
            validator: (v) => v!.isEmpty ? 'Title is required' : null,
          ),
          SizedBox(height: 16.h),
          _buildCategoryDropdown(),
          SizedBox(height: 16.h),
          CustomTextFieldBeautiful(
            controller: _descController,
            hintText: 'Detailed product description...',
            labelText: 'Description *',
            maxLines: 4,
            validator: (v) => v!.isEmpty ? 'Description is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingInventorySection() {
    return _buildCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Obx(
                  () => CustomTextFieldBeautiful(
                    labelText:
                        'Base Unit Price (${CurrencyService.to.localCurrencySymbol}) *',
                    controller: _priceController,
                    hintText: 'e.g. 50000',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      return v!.isEmpty || v == '0' ? 'Price required' : null;
                    },
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: NumericStepInputBeautiful(
                  label: 'Min Order *',
                  controller: _minQtyController,
                  onIncrement: () {
                    int val = int.tryParse(_minQtyController.text) ?? 1;
                    _minQtyController.text = (val + 1).toString();
                  },
                  onDecrement: () {
                    int val = int.tryParse(_minQtyController.text) ?? 1;
                    if (val > 1) {
                      _minQtyController.text = (val - 1).toString();
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Local Price:',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                      Text(
                        '${CurrencyService.to.localCurrencySymbol}${(_localPrice.value * _minQty.value).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w900,
                          fontSize: 18.sp,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: Colors.black12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Equivalent in Yuan:',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                      Text(
                        '¥${_yuanValue.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w900,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          NumericStepInputBeautiful(
            label: 'Total Stock Available *',
            controller: _stockController,
            icon: Icons.inventory_2_outlined,
            onIncrement: () {
              int val = int.tryParse(_stockController.text) ?? 0;
              _stockController.text = (val + 1).toString();
            },
            onDecrement: () {
              int val = int.tryParse(_stockController.text) ?? 0;
              if (val > 0) _stockController.text = (val - 1).toString();
            },
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTiersSection() {
    return _buildCard(
      child: Obx(
        () => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Wholesale Pricing Tiers',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.black12),
            if (_moqTiers.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.layers_clear_outlined,
                      size: 40,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Set bulk prices to attract wholesale buyers',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12.sp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _moqTiers.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.black12),
                itemBuilder: (context, index) {
                  final tier = _moqTiers[index];
                  final localPrice = tier.pricePerUnit;
                  final totalLocalPrice = localPrice * tier.minQty;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: AppColors.primary,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      'Buy ${tier.minQty}${tier.maxQty != null ? ' - ${tier.maxQty}' : '+'} units',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: RichText(
                      text: TextSpan(
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                        children: [
                          const TextSpan(
                            text: 'Unit: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                '${CurrencyService.to.localCurrencySymbol}${localPrice.toStringAsFixed(2)} ',
                          ),
                          const TextSpan(
                            text: '| Total: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                '${CurrencyService.to.localCurrencySymbol}${totalLocalPrice.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blue,
                          ),
                          onPressed: () => _addPricingTier(index: index),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _moqTiers.removeAt(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              onPressed: _addPricingTier,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add New MOQ Tier'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black12, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                minimumSize: Size(double.infinity, 50.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantsSection() {
    return Column(
      children: [
        _buildCard(
          child: Obx(
            () => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.palette_outlined,
                          size: 16,
                          color: Colors.purple,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Product Variants',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Colors.black12),
                if (_variants.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Column(
                      children: [
                        Icon(
                          Icons.style_outlined,
                          size: 40,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Add colors, sizes or other options',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12.sp,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _variants.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.black12),
                    itemBuilder: (context, index) {
                      final variant = _variants[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child:
                              variant.imageUrl != null &&
                                  variant.imageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: variant.imageUrl!.startsWith('http')
                                      ? CachedNetworkImage(
                                          imageUrl: variant.imageUrl!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                size: 20,
                                                color: Colors.grey,
                                              ),
                                        )
                                      : Image.file(
                                          File(variant.imageUrl!),
                                          fit: BoxFit.cover,
                                        ),
                                )
                              : Icon(
                                  Icons.image_outlined,
                                  size: 20,
                                  color: Colors.grey[400],
                                ),
                        ),
                        title: Text(
                          '${variant.type}: ${variant.value}${variant.attributes != null && variant.attributes!.isNotEmpty ? " (${variant.attributes!.entries.map((e) => "${e.key}: ${e.value}").join(", ")})" : ""}',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          'Price: ${variant.price != null ? '¥${variant.price}' : 'Default'} | Stock: ${variant.stock ?? 'Default'}',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blue,
                              ),
                              onPressed: () => _addVariant(index: index),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _variants.removeAt(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                SizedBox(height: 16.h),
                OutlinedButton.icon(
                  onPressed: _addVariant,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Add New Variant'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black12, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    minimumSize: Size(double.infinity, 50.h),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildImageUploader() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: _imageBox(isAdd: true),
                  ),
                  // Existing Images
                  ...List.generate(_existingImageUrls.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(left: 12.w),
                      child: Stack(
                        children: [
                          _imageBox(url: _existingImageUrls[index]),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () =>
                                  _removeImage(index, isExisting: true),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // Selected Local Files
                  ...List.generate(_selectedFiles.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(left: 12.w),
                      child: Stack(
                        children: [
                          _imageBox(file: _selectedFiles[index]),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          SizedBox(height: 12.h),
          Text(
            'Upload up to 5 images. Recommended size: 800x800px.',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _imageBox({
    String? url,
    File? file,
    bool isAdd = false,
    bool isLoading = false,
  }) {
    return Container(
      height: 90.w,
      width: 90.w,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Stack(
        children: [
          if (isAdd)
            const Center(
              child: Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            )
          else if (file != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(
                file,
                fit: BoxFit.cover,
                width: 90.w,
                height: 90.w,
              ),
            )
          else if (url != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                width: 90.w,
                height: 90.w,
              ),
            ),
          if (isLoading)
            Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Category',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(
              () => TextButton.icon(
                onPressed: _isAutoDetecting.value ? null : _autoDetectCategory,
                icon: _isAutoDetecting.value
                    ? SizedBox(
                        width: 12.w,
                        height: 12.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome, size: 16),
                label: Text(
                  _isAutoDetecting.value ? 'Analyzing...' : 'Auto-detect',
                  style: TextStyle(fontSize: 12.sp),
                ),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Obx(
          () => DropdownButtonFormField<String>(
            value: _selectedCategory.value,
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: _categories
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => _selectedCategory.value = v!,
          ),
        ),
      ],
    );
  }

  void _previewProduct() {
    if (_formKey.currentState!.validate()) {
      // 1. Mandatory MOQ Validation
      if (_moqTiers.isEmpty) {
        Get.snackbar(
          'MOQ Required',
          'Please add at least one wholesale pricing tier',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
        );
        return;
      }

      // 2. Mandatory Stock Validation (Stock must be >= max quantity in tiers)
      final int stock = int.tryParse(_stockController.text) ?? 0;
      int requiredStock = 0;
      for (var tier in _moqTiers) {
        final int tierMax = tier.maxQty ?? tier.minQty;
        if (tierMax > requiredStock) requiredStock = tierMax;
      }

      if (stock < requiredStock) {
        Get.snackbar(
          'Insufficient Stock',
          'Available stock ($stock) must be at least the maximum MOQ quantity ($requiredStock)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          duration: const Duration(seconds: 4),
        );
        return;
      }

      final authController = Get.find<AuthController>();
      final sellerId = authController.user.value?.id;

      final previewProduct = ProductModel(
        id: isEditMode ? widget.product!.id : 'preview',
        name: _titleController.text,
        description: _descController.text,
        price: _priceController.text.isEmpty
            ? 0.0
            : double.parse(_priceController.text),
        currency: CurrencyService.to.localCurrencyCode,
        minQty: int.tryParse(_minQtyController.text) ?? 1,
        stock: int.tryParse(_stockController.text) ?? 0,
        category: _selectedCategory.value,
        imageUrl: _existingImageUrls.isNotEmpty
            ? _existingImageUrls.first
            : (_selectedFiles.isNotEmpty ? _selectedFiles.first.path : ''),
        galleryUrls: [
          ..._existingImageUrls,
          ..._selectedFiles.map((f) => f.path),
        ],
        sellerId: sellerId ?? '',
        status: _productStatus.value,
        variants: _variants.isNotEmpty ? _variants.toList() : null,
        moqTiers: _moqTiers.toList(),
        rating: isEditMode ? widget.product!.rating : 5.0,
      );

      Get.toNamed(
        Routes.productDetails,
        arguments: {'product': previewProduct, 'isPreview': true},
      );
    }
  }

  Future<void> _saveProduct() async {
    if (_selectedFiles.isEmpty && _existingImageUrls.isEmpty) {
      Get.snackbar(
        'Media Required',
        'Please select at least one product image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red[800],
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // 1. Mandatory MOQ Validation
      if (_moqTiers.isEmpty) {
        Get.snackbar(
          'MOQ Required',
          'Please add at least one wholesale pricing tier',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
        );
        return;
      }

      // 2. Mandatory Stock Validation
      final int stock = int.tryParse(_stockController.text) ?? 0;
      int requiredStock = 0;
      for (var tier in _moqTiers) {
        final int tierMax = tier.maxQty ?? tier.minQty;
        if (tierMax > requiredStock) requiredStock = tierMax;
      }

      if (stock < requiredStock) {
        Get.snackbar(
          'Insufficient Stock',
          'Available stock ($stock) must be at least the maximum MOQ quantity ($requiredStock)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          duration: const Duration(seconds: 4),
        );
        return;
      }

      final authController = Get.find<AuthController>();
      final sellerId = authController.user.value?.id;

      if (sellerId == null) {
        Get.snackbar(
          'Session Expired',
          'Please log in again to save product.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      _isPublishing.value = true;
      try {
        List<String> finalGalleryUrls = List<String>.from(_existingImageUrls);

        // Step 1: Upload new images if any
        if (_selectedFiles.isNotEmpty) {
          final uploadResult = await _uploadService.uploadImages(
            _selectedFiles,
          );
          final List<String> newUrls = List<String>.from(
            uploadResult['image_urls'],
          );
          finalGalleryUrls.addAll(newUrls);
        }

        if (finalGalleryUrls.isEmpty) {
          throw Exception('No images available for the product');
        }

        // Step 2: Create/Update product with the URLs
        final newProduct = ProductModel(
          id: isEditMode ? widget.product!.id : '',
          name: _titleController.text,
          description: _descController.text,
          price: _priceController.text.isEmpty
              ? 0.0
              : double.parse(_priceController.text),
          currency: CurrencyService.to.localCurrencyCode,
          minQty: int.tryParse(_minQtyController.text) ?? 1,
          stock: int.parse(_stockController.text),
          category: _selectedCategory.value,
          imageUrl: finalGalleryUrls.first,
          galleryUrls: finalGalleryUrls,
          sellerId: sellerId,
          status: _productStatus.value,
          variants: _variants.isNotEmpty ? _variants.toList() : null,
          moqTiers: _moqTiers.toList(),
        );

        if (isEditMode) {
          // Use the model's toJson() which now handles backend-compliant flattening and Yuan conversion
          await controller.updateProduct(
            widget.product!.id,
            newProduct.toJson(),
          );
        } else {
          await controller.addProduct(newProduct);
        }
      } catch (e) {
        String message = e.toString().replaceAll('Exception: ', '');
        if (message.contains('DioException')) {
          message = 'Network error. Please check your connection.';
        }
        Get.snackbar(
          isEditMode ? 'Update Failed' : 'Upload Failed',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red[800],
        );
      } finally {
        _isPublishing.value = false;
      }
    }
  }
}
