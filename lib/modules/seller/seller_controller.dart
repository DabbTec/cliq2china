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
  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[
    {
      'id': '#1027',
      'customer': 'Eje Abraham',
      'items': 3,
      'time': '11:54 PM',
      'amount': 8000.0,
      'status': 'Unfulfilled',
      'paymentStatus': 'Payment pending',
      'type': 'Local Delivery',
      'date': 'March 1'
    },
    {
      'id': '#1026',
      'customer': 'Olaniyan Abiodun',
      'items': 4,
      'time': '2:12 PM',
      'amount': 4000.0,
      'status': 'Archived',
      'paymentStatus': 'Paid',
      'type': 'Pickup in store',
      'date': 'February 12'
    },
  ].obs;

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
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );
    });
  }
}
