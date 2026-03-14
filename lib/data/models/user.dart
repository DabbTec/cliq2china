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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      role: json['role'],
      businessName: json['business_name'],
      cacNumber: json['cac_number'],
      bankDetails: json['bank_details'],
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
    };
  }
}
