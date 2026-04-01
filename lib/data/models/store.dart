class StoreModel {
  final String id;
  final String sellerId;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String? status; // 'active', 'pending', 'suspended'
  final Map<String, dynamic>? metadata;
  final String? address;
  final String? phone;
  final String? email;
  final double? rating;

  StoreModel({
    required this.id,
    required this.sellerId,
    required this.name,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.status,
    this.metadata,
    this.address,
    this.phone,
    this.email,
    this.rating,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id']?.toString() ?? '',
      sellerId: json['seller_id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logo_url'],
      bannerUrl: json['banner_url'],
      status: json['status'],
      metadata: json['metadata'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      rating: _toDouble(json['rating']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'name': name,
      if (description != null) 'description': description,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (bannerUrl != null) 'banner_url': bannerUrl,
      if (status != null) 'status': status,
      if (metadata != null) 'metadata': metadata,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (rating != null) 'rating': rating,
    };
  }
}
