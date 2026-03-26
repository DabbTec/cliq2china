class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? address;
  final String role; // 'buyer', 'seller', 'admin'
  final String? businessName;
  final String? cacNumber;
  final String? bankDetails;
  final double walletBalance;
  final String? referralCode;
  final bool hasStore;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.address,
    required this.role,
    this.businessName,
    this.cacNumber,
    this.bankDetails,
    this.walletBalance = 0.0,
    this.referralCode,
    this.hasStore = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(), // UUID support
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      role: json['role'],
      businessName: json['business_name'],
      cacNumber: json['cac_number'],
      bankDetails: json['bank_details'],
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      referralCode: json['referral_code'],
      hasStore: json['has_store'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'role': role,
      'business_name': businessName,
      'cac_number': cacNumber,
      'bank_details': bankDetails,
      'wallet_balance': walletBalance,
      'referral_code': referralCode,
      'has_store': hasStore,
    };
  }
}
