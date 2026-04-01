import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../data/models/product.dart';
import '../../data/models/seller_stats.dart';
import '../../data/models/store.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/seller_repository.dart';
import '../auth/auth_controller.dart';

class SellerController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final SellerRepository _sellerRepository = SellerRepository();
  final AuthController _authController = Get.find<AuthController>();

  // Product Observables
  final RxList<ProductModel> myProducts = <ProductModel>[].obs;
  final RxInt currentTabIndex = 1.obs; // Default to Home (index 1)
  final RxString selectedStatus = 'active'.obs; // 'active', 'archived', 'draft'
  final RxList<String> selectedProductIds = <String>[].obs;
  final RxBool isSettingsMode = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUpdatingStore = false.obs;

  // Stats & Dashboard
  final Rx<SellerStatsModel?> stats = Rx<SellerStatsModel?>(null);
  final Rx<StoreModel?> store = Rx<StoreModel?>(null);
  final RxList<Map<String, dynamic>> payouts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> promotions = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> verificationStatus = <String, dynamic>{}.obs;

  String get storeName =>
      store.value?.name ??
      _authController.user.value?.businessName ??
      'My Store';

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
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      final sellerId = _authController.user.value?.id;
      if (sellerId == null) {
        debugPrint('⚠️ Cannot load dashboard: Seller ID is null');
        return;
      }

      // Parallel data fetching
      await Future.wait([
        loadMyProducts(),
        loadStats(sellerId),
        loadStore(sellerId),
        loadPayouts(sellerId),
        loadPromotions(sellerId),
        loadVerification(sellerId),
      ]);
    } catch (e) {
      debugPrint('❌ Error loading dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStats(String sellerId) async {
    try {
      final s = await _sellerRepository.getStats(sellerId);
      stats.value = s;
      debugPrint(
        '✅ Stats loaded: ${s.totalProducts} products, ${s.totalOrders} orders',
      );
    } catch (e) {
      debugPrint('❌ Error loading stats: $e');
    }
  }

  Future<void> loadStore(String sellerId) async {
    try {
      final s = await _sellerRepository.getStore(sellerId);
      store.value = s;
    } catch (e) {
      print('Error loading store: $e');
    }
  }

  Future<void> loadPayouts(String sellerId) async {
    try {
      final p = await _sellerRepository.getPayouts(sellerId);
      payouts.assignAll(p);
    } catch (e) {
      print('Error loading payouts: $e');
    }
  }

  Future<void> loadPromotions(String sellerId) async {
    try {
      final p = await _sellerRepository.getPromotions(sellerId);
      promotions.assignAll(p);
    } catch (e) {
      print('Error loading promotions: $e');
    }
  }

  Future<void> loadVerification(String sellerId) async {
    try {
      final v = await _sellerRepository.getVerification(sellerId);
      verificationStatus.assignAll(v);
    } catch (e) {
      print('Error loading verification: $e');
    }
  }

  Future<void> updateStoreInfo(Map<String, dynamic> data) async {
    final sellerId = _authController.user.value?.id;

    if (store.value == null) {
      if (sellerId != null) {
        // Try to reload store data once if it's missing
        await loadStore(sellerId);
      }

      if (store.value == null) {
        Get.snackbar(
          'Error',
          'Store data not found. Please ensure your store is set up properly.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
        return;
      }
    }

    isUpdatingStore.value = true;
    try {
      final updatedStore = await _sellerRepository.updateStore(
        store.value!.id,
        data,
      );
      store.value = updatedStore;
      Get.snackbar(
        'Success',
        'Store updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update store: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
    } finally {
      isUpdatingStore.value = false;
    }
  }

  Future<void> requestNewPayout(Map<String, dynamic> data) async {
    final sellerId = _authController.user.value?.id;
    if (sellerId == null) return;

    isLoading.value = true;
    try {
      await _sellerRepository.requestPayout({...data, 'seller_id': sellerId});
      await loadPayouts(sellerId);
      Get.snackbar('Success', 'Payout requested successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to request payout: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createNewPromotion(Map<String, dynamic> data) async {
    final sellerId = _authController.user.value?.id;
    if (sellerId == null) return;

    isLoading.value = true;
    try {
      await _sellerRepository.createPromotion({...data, 'seller_id': sellerId});
      await loadPromotions(sellerId);
      Get.snackbar('Success', 'Promotion created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create promotion: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitNewVerification(Map<String, dynamic> data) async {
    final sellerId = _authController.user.value?.id;
    if (sellerId == null) return;

    isLoading.value = true;
    try {
      await _sellerRepository.submitVerification({
        ...data,
        'seller_id': sellerId,
      });
      await loadVerification(sellerId);
      Get.snackbar('Success', 'Verification submitted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit verification: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
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
      // Refresh stats to update total products count
      final sellerId = _authController.user.value?.id;
      if (sellerId != null) loadStats(sellerId);

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

      // Refresh stats
      final sellerId = _authController.user.value?.id;
      if (sellerId != null) loadStats(sellerId);

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

      // Refresh stats
      final sellerId = _authController.user.value?.id;
      if (sellerId != null) loadStats(sellerId);

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
