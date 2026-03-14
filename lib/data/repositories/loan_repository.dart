import '../models/loan.dart';

class LoanRepository {
  Future<List<LoanModel>> getLoans(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      LoanModel(
        id: 'L1',
        userId: userId,
        amount: 500000,
        purpose: 'Inventory Purchase',
        status: 'approved',
        appliedDate: DateTime.now().subtract(const Duration(days: 30)),
        history: ['Applied: Jan 10', 'Under Review: Jan 12', 'Approved: Jan 15'],
      ),
      LoanModel(
        id: 'L2',
        userId: userId,
        amount: 250000,
        purpose: 'Shipping Fees',
        status: 'under_review',
        appliedDate: DateTime.now().subtract(const Duration(days: 5)),
        history: ['Applied: Mar 5', 'Under Review: Mar 6'],
      ),
    ];
  }

  Future<void> applyForLoan(LoanModel loan) async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
