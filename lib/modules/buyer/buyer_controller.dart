import 'package:get/get.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class BuyerController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  final RxList<String> banners = <String>[
    'https://images.unsplash.com/photo-1607082349566-187342175e2f?q=80&w=1000',
    'https://images.unsplash.com/photo-1607082350899-7e105aa886ae?q=80&w=1000',
    'https://images.unsplash.com/photo-1557821552-17105176677c?q=80&w=1000',
  ].obs;
  
  final categories = [
    {'name': 'Super Deals', 'icon': 'flash_on'},
    {'name': 'Electronics', 'icon': 'phone_android'},
    {'name': 'Fashion', 'icon': 'checkroom'},
    {'name': 'Home', 'icon': 'home'},
    {'name': 'Beauty', 'icon': 'face'},
    {'name': 'Toys', 'icon': 'toys'},
  ].obs;
  
  final isLoading = false.obs;
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      final allProducts = await _productRepository.getProducts();
      products.assignAll(allProducts);
      featuredProducts.assignAll(allProducts.take(6).toList());
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products');
    } finally {
      isLoading.value = false;
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
  }
}
