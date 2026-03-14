class LoanModel {
  final String id;
  final String userId;
  final double amount;
  final String purpose;
  final String status; // 'applied', 'under_review', 'approved', 'rejected'
  final DateTime appliedDate;
  final String? documentUrl;
  final List<String> history;

  LoanModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.purpose,
    required this.status,
    required this.appliedDate,
    this.documentUrl,
    this.history = const [],
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'],
      userId: json['user_id'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      purpose: json['purpose'],
      status: json['status'],
      appliedDate: DateTime.parse(json['applied_date']),
      documentUrl: json['document_url'],
      history: List<String>.from(json['history'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'purpose': purpose,
      'status': status,
      'applied_date': appliedDate.toIso8601String(),
      'document_url': documentUrl,
      'history': history,
    };
  }
}
