import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class SellerController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final RxList<ProductModel> myProducts = <ProductModel>[].obs;
  final RxInt currentTabIndex = 1.obs; // Default to Home (index 1)
  final RxBool isSettingsMode = false.obs;
  final RxBool isLoading = false.obs;

  // Menu Expansion State
  final RxBool isOrdersExpanded = false.obs;
  final RxBool isProductsExpanded = false.obs;

  // Mock Orders for UI
  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMyProducts();
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  Future<void> loadMyProducts() async {
    isLoading.value = true;
    try {
      final all = await _productRepository.getProducts();
      myProducts.assignAll(all.where((p) => p.sellerId == 's1').toList());
    } finally {
      isLoading.value = false;
    }
  }

  void addProduct(ProductModel product) {
    isLoading.value = true;
    // Simulating API call
    Future.delayed(const Duration(seconds: 1), () {
      myProducts.insert(0, product);
      isLoading.value = false;
      Get.back();
      Get.snackbar(
        'Success', 
        'Product "${product.name}" added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
      );
    });
  }
}
