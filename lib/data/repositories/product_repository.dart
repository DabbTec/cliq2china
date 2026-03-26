import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/product.dart';

class ProductRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<ProductModel>> getProducts({
    String? category,
    String? sellerId,
    String? search,
    String? status,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (category != null) queryParams['category'] = category;
    if (sellerId != null) queryParams['seller_id'] = sellerId;
    if (search != null) queryParams['search'] = search;
    if (status != null) queryParams['status'] = status;

    final response = await _apiService.get(
      ApiEndpoints.products,
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<ProductModel> getProductDetail(String id) async {
    final response = await _apiService.get('${ApiEndpoints.products}$id/');
    final data = response.data;
    if (data is Map && data.containsKey('product')) {
      return ProductModel.fromJson(data['product']);
    }
    return ProductModel.fromJson(data);
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    final response = await _apiService.post(
      ApiEndpoints.products,
      data: product.toJson(),
    );

    // Handle both direct object and wrapped {"product": {...}} responses
    final data = response.data;
    if (data is Map && data.containsKey('product')) {
      return ProductModel.fromJson(data['product']);
    } else if (data is Map && data.containsKey('data')) {
      return ProductModel.fromJson(data['data']);
    }
    return ProductModel.fromJson(data);
  }

  Future<ProductModel> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.put(
      '${ApiEndpoints.products}$id/',
      data: data,
    );
    final responseData = response.data;
    if (responseData is Map && responseData.containsKey('product')) {
      return ProductModel.fromJson(responseData['product']);
    }
    return ProductModel.fromJson(responseData);
  }

  Future<void> deleteProduct(String id) async {
    await _apiService.delete('${ApiEndpoints.products}$id/');
  }

  Future<Map<String, dynamic>> bulkDeleteProducts(List<String> ids) async {
    final response = await _apiService.post(
      ApiEndpoints.bulkDeleteProducts,
      data: {'product_ids': ids},
    );
    return response.data;
  }
}
