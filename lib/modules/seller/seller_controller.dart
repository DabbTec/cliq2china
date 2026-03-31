import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../auth/auth_controller.dart';

class SellerController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final AuthController _authController = Get.find<AuthController>();
  final RxList<ProductModel> myProducts = <ProductModel>[].obs;
  final RxInt currentTabIndex = 1.obs; // Default to Home (index 1)
  final RxString selectedStatus = 'active'.obs; // 'active', 'archived', 'draft'
  final RxList<String> selectedProductIds = <String>[].obs;
  final RxBool isSettingsMode = false.obs;
  final RxBool isLoading = false.obs;

  // Menu Expansion State
  final RxBool isOrdersExpanded = false.obs;

  // Orders (To be fetched from API later)
  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;

  // Search Logic
  final RxString searchQuery = ''.obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  void updateSearch(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredProducts.assignAll(myProducts);
    } else {
      filteredProducts.assignAll(
        myProducts
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadMyProducts();
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  void setStatus(String status) {
    selectedStatus.value = status;
    selectedProductIds.clear();
    loadMyProducts();
  }

  void toggleSelection(String id) {
    if (selectedProductIds.contains(id)) {
      selectedProductIds.remove(id);
    } else {
      selectedProductIds.add(id);
    }
  }

  Future<void> loadMyProducts() async {
    isLoading.value = true;
    try {
      final sellerId = _authController.user.value?.id;
      if (sellerId == null) return;

      final all = await _productRepository.getProducts(
        sellerId: sellerId,
        status: selectedStatus.value,
      );
      myProducts.assignAll(all);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct(ProductModel product) async {
    isLoading.value = true;
    try {
      final newProduct = await _productRepository.addProduct(product);
      if (selectedStatus.value == newProduct.status) {
        myProducts.insert(0, newProduct);
      }
      Get.back();
      Get.snackbar(
        'Success',
        'Product "${newProduct.name}" added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final updatedProduct = await _productRepository.updateProduct(id, data);

      // Update local list
      final index = myProducts.indexWhere((p) => p.id == id);
      if (index != -1) {
        if (selectedStatus.value == updatedProduct.status) {
          myProducts[index] = updatedProduct;
        } else {
          myProducts.removeAt(index);
        }
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Product updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProductStatus(String id, String newStatus) async {
    isLoading.value = true;
    try {
      await _productRepository.updateProduct(id, {'status': newStatus});
      // Refresh list as the product should move to another tab
      await loadMyProducts();
      Get.snackbar(
        'Status Updated',
        'Product status changed to $newStatus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    isLoading.value = true;
    try {
      await _productRepository.deleteProduct(id);
      myProducts.removeWhere((p) => p.id == id);
      Get.snackbar(
        'Deleted',
        'Product deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bulkDelete() async {
    if (selectedProductIds.isEmpty) return;

    isLoading.value = true;
    try {
      final result = await _productRepository.bulkDeleteProducts(
        selectedProductIds,
      );
      myProducts.removeWhere((p) => selectedProductIds.contains(p.id));
      final count = selectedProductIds.length;
      selectedProductIds.clear();

      Get.snackbar(
        'Bulk Delete Success',
        result['message'] ?? 'Successfully deleted $count products',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
      );
    } catch (e) {
      Get.snackbar('Error', 'Bulk delete failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
