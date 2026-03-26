import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  // Pricing & Inventory Controllers
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  final RxList<File> _selectedFiles = <File>[].obs;
  final RxList<String> _existingImageUrls = <String>[].obs;
  final RxBool _isPublishing = false.obs;

  late final RxString _selectedCategory;
  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home Goods',
    'Beauty',
    'Toys',
  ];
  late final RxString _productStatus;

  // Variants State
  final RxList<ProductVariant> _variants = <ProductVariant>[].obs;
  final RxBool _hasVariants = false.obs;

  // MOQ Tiers State
  final RxList<MOQTier> _moqTiers = <MOQTier>[].obs;
  final RxBool _hasTiers = false.obs;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.name ?? '');
    _descController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '0',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '0',
    );

    _selectedCategory = (widget.product?.category ?? 'Electronics').obs;
    _productStatus = (widget.product?.status ?? 'active').obs;

    if (isEditMode && widget.product?.galleryUrls != null) {
      _existingImageUrls.assignAll(widget.product!.galleryUrls);
    }

    if (isEditMode && widget.product?.variants != null) {
      _hasVariants.value = true;
      _variants.assignAll(widget.product!.variants!);
    }

    if (isEditMode && widget.product?.moqTiers != null) {
      _hasTiers.value = true;
      _moqTiers.assignAll(widget.product!.moqTiers!);
    }

    if (isEditMode) {
      _fetchLatestDetails();
    }
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
        _selectedCategory.value = latestProduct.category;
        _productStatus.value = latestProduct.status ?? 'active';

        _existingImageUrls.assignAll(latestProduct.galleryUrls);
        if (latestProduct.variants != null) {
          _hasVariants.value = true;
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
    }
  }

  void _removeImage(int index, {bool isExisting = false}) {
    if (isExisting) {
      _existingImageUrls.removeAt(index);
    } else {
      _selectedFiles.removeAt(index);
    }
  }

  void _updateTotalStockFromVariants() {
    if (_variants.isEmpty) return;
    int total = 0;
    for (var v in _variants) {
      total += v.stock ?? 0;
    }
    _stockController.text = total.toString();
  }

  void _addPricingTier() {
    final minQtyController = TextEditingController(text: '1');
    final maxQtyController = TextEditingController();
    final priceController = TextEditingController(text: '0');

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
                    'New MOQ Tier',
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
                label: 'Price per Unit (CNY)',
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
              SizedBox(height: 32.h),
              PrimaryButton(
                text: 'Add MOQ Tier',
                color: Colors.black,
                textColor: Colors.white,
                onPressed: () {
                  final priceText = priceController.text.trim();
                  final minQtyText = minQtyController.text.trim();
                  final maxQtyText = maxQtyController.text.trim();

                  final price = double.tryParse(priceText) ?? 0;
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

                  if (price <= 0) {
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

                  // Add to list
                  _moqTiers.add(
                    MOQTier(
                      minQty: minQty,
                      maxQty: maxQty,
                      pricePerUnit: price,
                    ),
                  );

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

  void _addVariant() {
    String type = 'Color';
    final valueController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();

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
                    'New Variant',
                    style: AppTypography.h2.copyWith(color: Colors.black),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              DropdownButtonFormField<String>(
                initialValue: type,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Variant Type',
                  labelStyle: const TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                items: ['Color', 'Size', 'Weight', 'Material', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => type = v!,
              ),
              SizedBox(height: 20.h),
              CustomTextFieldBeautiful(
                controller: valueController,
                labelText: 'Value',
                hintText: 'e.g. Red, XL, 500g',
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: NumericStepInputBeautiful(
                      label: 'Price (Optional)',
                      controller: priceController,
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
              PrimaryButton(
                text: 'Add Variant',
                color: Colors.black,
                textColor: Colors.white,
                onPressed: () {
                  if (valueController.text.isNotEmpty) {
                    _variants.add(
                      ProductVariant(
                        type: type,
                        value: valueController.text,
                        price: double.tryParse(priceController.text),
                        stock: int.tryParse(stockController.text),
                      ),
                    );
                    _updateTotalStockFromVariants();
                    Get.back();
                  }
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
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
                  ),
                  _buildImageUploader(),
                  SizedBox(height: 32.h),
                  _buildSectionHeader(
                    'GENERAL INFORMATION',
                    Icons.info_outline_rounded,
                  ),
                  _buildBasicInfoSection(),
                  SizedBox(height: 32.h),
                  _buildSectionHeader(
                    'PRICING & INVENTORY',
                    Icons.inventory_2_outlined,
                  ),
                  _buildPricingInventorySection(),
                  SizedBox(height: 32.h),
                  _buildSectionHeader(
                    'MOQ PRICING (OPTIONAL)',
                    Icons.layers_outlined,
                  ),
                  _buildPricingTiersSection(),
                  SizedBox(height: 32.h),
                  _buildSectionHeader('PRODUCT VARIANTS', Icons.style_outlined),
                  _buildVariantsSection(),
                  SizedBox(height: 48.h),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, left: 4.w),
      child: Row(
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
            labelText: 'Product Title',
            validator: (v) => v!.isEmpty ? 'Title is required' : null,
          ),
          SizedBox(height: 16.h),
          _buildCategoryDropdown(),
          SizedBox(height: 16.h),
          CustomTextFieldBeautiful(
            controller: _descController,
            hintText: 'Detailed product description...',
            labelText: 'Description',
            maxLines: 4,
            validator: (v) => v!.isEmpty ? 'Description is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingInventorySection() {
    final RxDouble yuanValue = 0.0.obs;

    void convertToYuan(String localPrice) {
      final price = double.tryParse(localPrice) ?? 0;
      yuanValue.value = CurrencyService.to.convertToYuan(price);
    }

    _priceController.addListener(() => convertToYuan(_priceController.text));

    return _buildCard(
      child: Column(
        children: [
          Obx(
            () => CustomTextFieldBeautiful(
              labelText:
                  'Base Price (${CurrencyService.to.localCurrencySymbol})',
              controller: _priceController,
              hintText: 'e.g. 50000',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (_hasTiers.value && _moqTiers.isNotEmpty) return null;
                return v!.isEmpty || v == '0' ? 'Price required' : null;
              },
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 18.sp,
                      ),
                      SizedBox(width: 10.w),
                      Flexible(
                        child: Text(
                          'Equivalent to: ¥${yuanValue.value.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Current Rate: 1 CNY = ${CurrencyService.to.exchangeRateToYuan.toStringAsFixed(2)} ${CurrencyService.to.localCurrencyCode}',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          NumericStepInputBeautiful(
            label: 'Total Stock',
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
                      'Enable MOQ Discounts',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: _hasTiers.value,
                  activeTrackColor: Colors.black,
                  activeThumbColor: Colors.white,
                  onChanged: (v) => _hasTiers.value = v,
                ),
              ],
            ),
            if (_hasTiers.value) ...[
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
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      title: Text(
                        'Buy ${tier.minQty}${tier.maxQty != null ? ' - ${tier.maxQty}' : '+'} units',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Wholesale Price: ¥${tier.pricePerUnit}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _moqTiers.removeAt(index),
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
                          'Add Variants',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: _hasVariants.value,
                      activeTrackColor: Colors.black,
                      activeThumbColor: Colors.white,
                      onChanged: (v) => _hasVariants.value = v,
                    ),
                  ],
                ),
                if (_hasVariants.value) ...[
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
                          title: Text(
                            '${variant.type}: ${variant.value}',
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
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _variants.removeAt(index);
                              _updateTotalStockFromVariants();
                            },
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
    return Obx(
      () => DropdownButtonFormField<String>(
        initialValue: _selectedCategory.value,
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: 'Category',
          labelStyle: AppTypography.bodySmall.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
    );
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
        final productData = {
          'name': _titleController.text,
          'description': _descController.text,
          'price': _priceController.text.isEmpty
              ? 0.0
              : double.parse(_priceController.text),
          'currency':
              CurrencyService.to.localCurrencyCode, // NEW: Local currency
          'stock': int.parse(_stockController.text),
          'category': _selectedCategory.value,
          'image_url': finalGalleryUrls.first,
          'gallery_urls': finalGalleryUrls,
          'seller_id': sellerId,
          'status': _productStatus.value,
          if (_hasVariants.value)
            'variants': _variants.map((v) => v.toJson()).toList(),
          if (_hasTiers.value)
            'moq_tiers': _moqTiers.map((t) => t.toJson()).toList(),
        };

        if (isEditMode) {
          await controller.updateProduct(widget.product!.id, productData);
        } else {
          final newProduct = ProductModel(
            id: '', // Backend generates UUID
            name: _titleController.text,
            description: _descController.text,
            price: _priceController.text.isEmpty
                ? 0.0
                : double.parse(_priceController.text),
            currency:
                CurrencyService.to.localCurrencyCode, // NEW: Local currency
            stock: int.parse(_stockController.text),
            category: _selectedCategory.value,
            imageUrl: finalGalleryUrls.first,
            galleryUrls: finalGalleryUrls,
            sellerId: sellerId,
            status: _productStatus.value,
            variants: _hasVariants.value ? _variants.toList() : null,
            moqTiers: _hasTiers.value ? _moqTiers.toList() : null,
          );
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
