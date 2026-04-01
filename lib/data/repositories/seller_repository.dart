import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/seller_stats.dart';
import '../models/store.dart';

class SellerRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // Dashboard Stats
  Future<SellerStatsModel> getStats(String sellerId) async {
    final response = await _apiService.get(
      ApiEndpoints.orderStats,
      queryParameters: {'seller_id': sellerId},
    );
    return SellerStatsModel.fromJson(response.data);
  }

  // Store Setup
  Future<StoreModel> getStore(String sellerId) async {
    final response = await _apiService.get(
      ApiEndpoints.stores,
      queryParameters: {'seller_id': sellerId},
    );

    final data = response.data;
    if (data is List) {
      if (data.isEmpty) {
        throw Exception('Store not found for this seller');
      }
      return StoreModel.fromJson(data[0]);
    } else if (data is Map<String, dynamic>) {
      // If the backend returns a single object instead of a list
      return StoreModel.fromJson(data);
    }

    throw Exception('Unexpected response format from server');
  }

  Future<StoreModel> updateStore(String id, Map<String, dynamic> data) async {
    final response = await _apiService.put(
      '${ApiEndpoints.stores}$id/',
      data: data,
    );
    return StoreModel.fromJson(response.data);
  }

  // Payouts
  Future<List<Map<String, dynamic>>> getPayouts(String sellerId) async {
    final response = await _apiService.get(
      ApiEndpoints.payouts,
      queryParameters: {'seller_id': sellerId},
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> requestPayout(Map<String, dynamic> data) async {
    final response = await _apiService.post(ApiEndpoints.payouts, data: data);
    return response.data;
  }

  // Promotions/Discounts
  Future<List<Map<String, dynamic>>> getPromotions(String sellerId) async {
    final response = await _apiService.get(
      ApiEndpoints.promotions,
      queryParameters: {'seller_id': sellerId},
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createPromotion(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.post(
      ApiEndpoints.promotions,
      data: data,
    );
    return response.data;
  }

  // Verification
  Future<Map<String, dynamic>> getVerification(String sellerId) async {
    final response = await _apiService.get(
      ApiEndpoints.storeVerifications,
      queryParameters: {'seller_id': sellerId},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> submitVerification(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.post(
      ApiEndpoints.storeVerifications,
      data: data,
    );
    return response.data;
  }
}
