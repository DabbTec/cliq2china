import 'package:get/get.dart';
import '../../data/models/loan.dart';
import '../../data/repositories/loan_repository.dart';
import '../auth/auth_controller.dart';

class LoanController extends GetxController {
  final LoanRepository _loanRepository = LoanRepository();
  final AuthController _authController = Get.find<AuthController>();
  final RxList<LoanModel> loans = <LoanModel>[].obs;
  final isLoading = false.obs;
  final availableCredit = 0.0.obs; // To be fetched from API

  @override
  void onInit() {
    super.onInit();
    if (_authController.user.value != null) {
      loadLoans();
      availableCredit.value = _authController
          .user
          .value!
          .walletBalance; // Using wallet as mock for credit
    }
  }

  Future<void> loadLoans() async {
    if (_authController.user.value == null) return;
    isLoading.value = true;
    try {
      final all = await _loanRepository.getLoans(
        _authController.user.value!.id,
      );
      loans.assignAll(all);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load loans');
    } finally {
      isLoading.value = false;
    }
  }

  void applyForLoan(double amount, String purpose) async {
    if (_authController.user.value == null) return;
    isLoading.value = true;
    try {
      final loan = LoanModel(
        id: '', // Backend UUID
        userId: _authController.user.value!.id,
        amount: amount,
        purpose: purpose,
        status: 'applied',
        appliedDate: DateTime.now(),
      );
      await _loanRepository.applyForLoan(loan);
      await loadLoans(); // Reload to get fresh data
      Get.back();
      Get.snackbar('Success', 'Loan application submitted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit loan application');
    } finally {
      isLoading.value = false;
    }
  }
}
