class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> galleryUrls;
  final String category;
  final double rating;
  final int stock;
  final String sellerId;
  final List<Map<String, dynamic>> reviews;
  final String? seoTitle;
  final String? seoDescription;
  final String? sku;
  final double? weight;
  final String? status; // 'active', 'draft', 'archived'

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.galleryUrls = const [],
    required this.category,
    this.rating = 0.0,
    required this.stock,
    required this.sellerId,
    this.reviews = const [],
    this.seoTitle,
    this.seoDescription,
    this.sku,
    this.weight,
    this.status = 'active',
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
      galleryUrls: List<String>.from(json['gallery_urls'] ?? []),
      category: json['category'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      sellerId: json['seller_id'] ?? '',
      reviews: List<Map<String, dynamic>>.from(json['reviews'] ?? []),
      seoTitle: json['seo_title'],
      seoDescription: json['seo_description'],
      sku: json['sku'],
      weight: (json['weight'] as num?)?.toDouble(),
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'gallery_urls': galleryUrls,
      'category': category,
      'rating': rating,
      'stock': stock,
      'seller_id': sellerId,
      'reviews': reviews,
      'seo_title': seoTitle,
      'seo_description': seoDescription,
      'sku': sku,
      'weight': weight,
      'status': status,
    };
  }
}
