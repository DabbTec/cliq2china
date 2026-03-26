import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/loan.dart';

class LoanRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<LoanModel>> getLoans(String userId) async {
    final response = await _apiService.get(
      ApiEndpoints.loanHistory,
      queryParameters: {'user_id': userId},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => LoanModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch loan history');
    }
  }

  Future<void> applyForLoan(LoanModel loan) async {
    final response = await _apiService.post(
      ApiEndpoints.loans,
      data: loan.toJson(),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to apply for loan');
    }
  }
}
