import 'package:get/get.dart';
import '../../data/models/loan.dart';
import '../../data/repositories/loan_repository.dart';

class LoanController extends GetxController {
  final LoanRepository _loanRepository = LoanRepository();
  final RxList<LoanModel> loans = <LoanModel>[].obs;
  final isLoading = false.obs;
  final availableCredit = 1500000.00.obs;

  @override
  void onInit() {
    super.onInit();
    loadLoans();
  }

  Future<void> loadLoans() async {
    isLoading.value = true;
    try {
      final all = await _loanRepository.getLoans('u1');
      loans.assignAll(all);
    } finally {
      isLoading.value = false;
    }
  }

  void applyForLoan(double amount, String purpose) async {
    isLoading.value = true;
    try {
      final loan = LoanModel(
        id: 'L${loans.length + 1}',
        userId: 'u1',
        amount: amount,
        purpose: purpose,
        status: 'applied',
        appliedDate: DateTime.now(),
      );
      await _loanRepository.applyForLoan(loan);
      loans.insert(0, loan);
      Get.back();
      Get.snackbar('Success', 'Loan application submitted successfully');
    } finally {
      isLoading.value = false;
    }
  }
}
