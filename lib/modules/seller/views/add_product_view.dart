import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../data/models/product.dart';
import '../seller_controller.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final SellerController controller = Get.find<SellerController>();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();
  final _weightController = TextEditingController();
  final _seoTitleController = TextEditingController();
  final _seoDescController = TextEditingController();

  String _selectedCategory = 'Electronics';
  final List<String> _categories = ['Electronics', 'Fashion', 'Home Goods', 'Beauty', 'Toys'];
  String _productStatus = 'active';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    _weightController.dispose();
    _seoTitleController.dispose();
    _seoDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add New Product', style: AppTypography.h3),
        actions: [
          TextButton(
            onPressed: _saveProduct,
            child: Text('Save', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    title: 'Status',
                    children: [
                      _buildStatusSelector(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Basic Information',
                    children: [
                      CustomTextField(
                        controller: _titleController,
                        hintText: 'e.g. Wireless Noise Cancelling Headphones',
                        labelText: 'Product Title',
                        validator: (v) => v!.isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descController,
                        hintText: 'Describe your product in detail...',
                        labelText: 'Description',
                        maxLines: 5,
                        validator: (v) => v!.isEmpty ? 'Description is required' : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Media',
                    children: [
                      _buildImageUploader(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Pricing & Inventory',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _priceController,
                              hintText: '0.00',
                              labelText: 'Price (₦)',
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Price is required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _stockController,
                              hintText: '0',
                              labelText: 'Stock Quantity',
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Stock is required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _skuController,
                              hintText: 'SKU-12345',
                              labelText: 'SKU (Optional)',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildCategoryDropdown(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Search Engine Listing (SEO)',
                    children: [
                      Text(
                        'Preview: Your product will appear like this in search results.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.grey200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _seoTitleController.text.isEmpty ? 'Product Title' : _seoTitleController.text,
                              style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'https://cliq2china.com/products/${_titleController.text.toLowerCase().replaceAll(' ', '-')}',
                              style: const TextStyle(color: Colors.green, fontSize: 12),
                            ),
                            Text(
                              _seoDescController.text.isEmpty 
                                ? 'Add a meta description to see how this product might appear in search engine results.' 
                                : _seoDescController.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _seoTitleController,
                        hintText: 'SEO Title',
                        labelText: 'Page Title',
                        onChanged: (v) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _seoDescController,
                        hintText: 'Brief summary for search engines',
                        labelText: 'Meta Description',
                        maxLines: 3,
                        onChanged: (v) => setState(() {}),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Publish Product',
                    onPressed: _saveProduct,
                    isLoading: controller.isLoading.value,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      )),
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      children: [
        _statusChip('Active', 'active', Colors.green),
        const SizedBox(width: 12),
        _statusChip('Draft', 'draft', Colors.orange),
        const SizedBox(width: 12),
        _statusChip('Archived', 'archived', Colors.grey),
      ],
    );
  }

  Widget _statusChip(String label, String value, Color color) {
    bool isSelected = _productStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _productStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : AppColors.grey200),
        ),
        child: Row(
          children: [
            if (isSelected) Icon(Icons.check_circle, size: 16, color: color),
            if (isSelected) const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h3),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildImageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _imageBox(isAdd: true),
            const SizedBox(width: 12),
            _imageBox(url: 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=500'),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Add up to 5 images. Recommended size: 800x800px.',
          style: AppTypography.bodySmall,
        ),
      ],
    );
  }

  Widget _imageBox({String? url, bool isAdd = false}) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200, style: BorderStyle.solid),
      ),
      child: isAdd
          ? const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 32)
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(url!, fit: BoxFit.cover),
            ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: _categories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: AppTypography.bodyMedium),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
          ),
        ),
      ],
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _titleController.text,
        description: _descController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        category: _selectedCategory,
        imageUrl: 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=500',
        sellerId: 's1',
        sku: _skuController.text,
        seoTitle: _seoTitleController.text,
        seoDescription: _seoDescController.text,
        status: _productStatus,
      );
      controller.addProduct(product);
    }
  }
}
