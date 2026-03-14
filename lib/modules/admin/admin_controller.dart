import 'package:get/get.dart';

class AdminController extends GetxController {
  var isLoading = false.obs;
  var totalUsers = 150.obs;
  var totalSellers = 45.obs;
  var pendingSellers = 12.obs;
  var pendingLoans = 8.obs;
  var totalOrders = 340.obs;
  var revenue = 1500000.0.obs;

  var users = [].obs;
  var sellers = [].obs;
  var loans = [].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() {
    // Mock loading
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
    });
  }
}
