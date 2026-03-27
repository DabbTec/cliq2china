import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class CartItem {
  final ProductModel product;
  RxInt quantity;
  RxBool isSelected;

  CartItem({required this.product, int quantity = 1, bool isSelected = true})
    : quantity = quantity.obs,
      isSelected = isSelected.obs;
}

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
    {'name': 'Electronics', 'icon': 'phone_android'},
    {'name': 'Fashion', 'icon': 'checkroom'},
    {'name': 'Home', 'icon': 'home'},
    {'name': 'Beauty', 'icon': 'face'},
    {'name': 'Toys', 'icon': 'toys'},
  ].obs;

  final isLoading = false.obs;
  final RxInt currentIndex = 0.obs;
  final RxInt storeTabIndex = 0.obs;
  final RxBool swipeHintShown = false.obs;
  final RxBool affiliateModalShown = false.obs;

  // Scroll State for Header
  final ScrollController scrollController = ScrollController();

  // Search State
  final RxString searchQuery = ''.obs;
  final RxList<ProductModel> searchSuggestions = <ProductModel>[].obs;
  final RxList<ProductModel> searchResults = <ProductModel>[].obs;
  final RxBool isSearching = false.obs;

  // Wishlist State
  final RxList<ProductModel> wishlistItems = <ProductModel>[].obs;
  final RxSet<String> selectedWishlistIds = <String>{}.obs;
  final RxBool isWishlistSelectionMode = false.obs;

  bool get isAllWishlistSelected =>
      wishlistItems.isNotEmpty &&
      selectedWishlistIds.length == wishlistItems.length;

  // Cart State
  final RxList<CartItem> cartItems = <CartItem>[].obs;

  double get totalAmountYuan => cartItems
      .where((item) => item.isSelected.value)
      .fold(
        0,
        (sum, item) =>
            sum +
            (calculateTieredPrice(item.product, item.quantity.value) *
                item.quantity.value),
      );

  double get totalAmount =>
      totalAmountYuan; // For backward compatibility if needed

  int get selectedCount =>
      cartItems.where((item) => item.isSelected.value).length;

  @override
  void onInit() {
    super.onInit();
    loadProducts();

    // Check for index argument to change page (e.g., to cart)
    final dynamic args = Get.arguments;
    if (args != null && args is Map && args.containsKey('index')) {
      currentIndex.value = args['index'] as int;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void updateSearchSuggestions(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchSuggestions.clear();
      return;
    }
    // Simple client-side suggestion based on loaded products
    searchSuggestions.assignAll(
      products
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .take(5)
          .toList(),
    );
  }

  Future<void> executeSearch(String query) async {
    isSearching.value = true;
    await searchProducts(query);
    isSearching.value = false;
  }

  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
    searchSuggestions.clear();
  }

  Future<void> searchProducts(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.assignAll(products);
      return;
    }

    isLoading.value = true;
    try {
      final results = await _productRepository.getProducts(search: query);
      searchResults.assignAll(results);
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProducts({String? category}) async {
    isLoading.value = true;
    try {
      final allProducts = await _productRepository.getProducts(
        category: category,
      );

      if (allProducts.isEmpty) {
        products.clear();
        searchResults.clear();
        featuredProducts.clear();
      } else {
        products.assignAll(allProducts);
        searchResults.assignAll(allProducts); // Initial state
        featuredProducts.assignAll(allProducts.take(6).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  // Store Methods
  List<ProductModel> getProductsBySeller(String sellerId) {
    return products.where((p) => p.sellerId == sellerId).toList();
  }

  // Wishlist Methods
  void toggleWishlist(ProductModel product) {
    final index = wishlistItems.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      wishlistItems.removeAt(index);
    } else {
      wishlistItems.add(product);
    }
  }

  bool isProductInWishlist(String productId) {
    return wishlistItems.any((item) => item.id == productId);
  }

  void toggleWishlistSelectionMode() {
    isWishlistSelectionMode.value = !isWishlistSelectionMode.value;
    if (!isWishlistSelectionMode.value) {
      selectedWishlistIds.clear();
    }
  }

  void toggleWishlistItemSelection(String productId) {
    if (selectedWishlistIds.contains(productId)) {
      selectedWishlistIds.remove(productId);
    } else {
      selectedWishlistIds.add(productId);
    }

    if (selectedWishlistIds.isNotEmpty) {
      isWishlistSelectionMode.value = true;
    }
  }

  void toggleSelectAllWishlist() {
    if (isAllWishlistSelected) {
      selectedWishlistIds.clear();
    } else {
      selectedWishlistIds.addAll(wishlistItems.map((item) => item.id));
    }
  }

  void removeSelectedWishlistItems() {
    if (selectedWishlistIds.isEmpty) return;

    wishlistItems.removeWhere((item) => selectedWishlistIds.contains(item.id));
    selectedWishlistIds.clear();
    isWishlistSelectionMode.value = false;
    Get.snackbar('Removed', 'Items removed from wishlist');
  }

  void addToCart(ProductModel product, {int? quantity}) {
    final existingIndex = cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    // Calculate effective MOQ
    int effectiveMOQ = 1;
    if (product.moqTiers != null && product.moqTiers!.isNotEmpty) {
      effectiveMOQ = product.moqTiers!.first.minQty;
    }

    final targetQty = quantity ?? effectiveMOQ;

    if (existingIndex >= 0) {
      if (cartItems[existingIndex].quantity.value < product.stock) {
        if (quantity != null) {
          cartItems[existingIndex].quantity.value = quantity;
        } else {
          cartItems[existingIndex].quantity.value++;
        }
      } else {
        Get.snackbar(
          'Stock Limit',
          'Only ${product.stock} items available',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      if (product.stock >= targetQty) {
        cartItems.add(CartItem(product: product, quantity: targetQty));
        if (targetQty > 1 && quantity == null) {
          Get.snackbar(
            'Quantity Adjusted',
            'Added minimum quantity required: $effectiveMOQ',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else if (product.stock > 0) {
        Get.snackbar(
          'Stock Alert',
          'Stock (${product.stock}) is less than requested quantity ($targetQty)',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Out of Stock',
          'This product is currently unavailable',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  bool get isAllCartSelected =>
      cartItems.isNotEmpty && cartItems.every((item) => item.isSelected.value);

  void toggleSelectAllCart() {
    final newValue = !isAllCartSelected;
    for (var item in cartItems) {
      item.isSelected.value = newValue;
    }
  }

  void toggleSelection(int index) {
    cartItems[index].isSelected.value = !cartItems[index].isSelected.value;
  }

  void removeFromCart(int index) {
    cartItems.removeAt(index);
  }

  void removeSelectedCartItems() {
    cartItems.removeWhere((item) => item.isSelected.value);
    Get.snackbar('Removed', 'Selected items removed from cart');
  }

  void addToWishlist(ProductModel product) {
    if (!wishlistItems.any((item) => item.id == product.id)) {
      wishlistItems.add(product);
      Get.snackbar(
        'Success',
        'Added to wishlist',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void incrementQuantity(int index) {
    if (cartItems[index].quantity.value < cartItems[index].product.stock) {
      cartItems[index].quantity.value++;
    } else {
      Get.snackbar(
        'Stock Limit',
        'Only ${cartItems[index].product.stock} items available',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void decrementQuantity(int index) {
    final item = cartItems[index];

    // Calculate effective MOQ
    int effectiveMOQ = 1;
    if (item.product.moqTiers != null && item.product.moqTiers!.isNotEmpty) {
      effectiveMOQ = item.product.moqTiers!.first.minQty;
    }

    if (item.quantity.value > effectiveMOQ) {
      item.quantity.value--;
    } else {
      Get.snackbar(
        'Minimum Order',
        'The minimum order for this item is $effectiveMOQ items',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // PDV Helpers
  double calculateTieredPrice(ProductModel product, int qty) {
    if (product.moqTiers == null || product.moqTiers!.isEmpty) {
      return product.effectiveYuan;
    }

    for (var tier in product.moqTiers!) {
      if (qty >= tier.minQty && (tier.maxQty == null || qty <= tier.maxQty!)) {
        return tier.pricePerUnit;
      }
    }
    return (product.displayYuan != null && product.displayYuan! > 0)
        ? product.displayYuan!
        : (product.originalPriceYuan ?? product.price);
  }

  CartItem? findCartItem(String productId) {
    try {
      return cartItems.firstWhereOrNull((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  void updateQuantityByProduct(ProductModel product, int delta) {
    final existingIndex = cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    // Calculate effective MOQ
    int effectiveMOQ = 1;
    if (product.moqTiers != null && product.moqTiers!.isNotEmpty) {
      effectiveMOQ = product.moqTiers!.first.minQty;
    }

    if (existingIndex >= 0) {
      if (delta > 0) {
        if (cartItems[existingIndex].quantity.value < product.stock) {
          cartItems[existingIndex].quantity.value++;
        } else {
          Get.snackbar(
            'Stock Limit',
            'Only ${product.stock} items available',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else if (cartItems[existingIndex].quantity.value > effectiveMOQ) {
        cartItems[existingIndex].quantity.value--;
      } else {
        cartItems.removeAt(existingIndex);
      }
    } else if (delta > 0) {
      if (product.stock >= effectiveMOQ) {
        cartItems.add(CartItem(product: product, quantity: effectiveMOQ));
      } else {
        Get.snackbar(
          'Out of Stock',
          'Insufficient stock for minimum order',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
