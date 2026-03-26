class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final double? originalPriceYuan;
  final String imageUrl;
  final List<String> galleryUrls;
  final String category;
  final double rating;
  final int stock;
  final String sellerId;
  final List<Map<String, dynamic>> reviews;
  final String? sku;
  final double? weight;
  final String? status; // 'active', 'draft', 'archived'
  final String? currency; // NEW: Seller's local currency code
  final List<ProductVariant>? variants;
  final List<MOQTier>? moqTiers;

  // Optimized backend pre-calculated fields
  final double? displayPrice;
  final double? displayYuan;
  final String? displaySymbol;
  final String? displayCurrency;

  // New nested data from backend
  final StoreInfo? store;
  final SellerInfo? seller;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    this.originalPriceYuan,
    required this.imageUrl,
    this.galleryUrls = const [],
    required this.category,
    this.rating = 0.0,
    required this.stock,
    required this.sellerId,
    this.reviews = const [],
    this.sku,
    this.weight,
    this.status = 'active',
    this.currency,
    this.variants,
    this.moqTiers,
    this.displayPrice,
    this.displayYuan,
    this.displaySymbol,
    this.displayCurrency,
    this.store,
    this.seller,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(), // UUID to String
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      originalPriceYuan: (json['original_price_yuan'] as num?)?.toDouble(),
      imageUrl: json['image_url'],
      galleryUrls: List<String>.from(json['gallery_urls'] ?? []),
      category: json['category'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      sellerId: json['seller_id']?.toString() ?? '', // UUID to String
      reviews: List<Map<String, dynamic>>.from(json['reviews'] ?? []),
      sku: json['sku'],
      weight: (json['weight'] as num?)?.toDouble(),
      status: json['status'] ?? 'active',
      currency: json['currency'],
      displayPrice: (json['display_price'] as num?)?.toDouble(),
      displayYuan: (json['display_yuan'] as num?)?.toDouble(),
      displaySymbol: json['display_symbol'],
      displayCurrency: json['display_currency'],
      variants: json['variants'] != null
          ? List<ProductVariant>.from(
              json['variants'].map((x) => ProductVariant.fromJson(x)),
            )
          : null,
      moqTiers: (json['moq_tiers'] != null || json['pricing_tiers'] != null)
          ? List<MOQTier>.from(
              (json['moq_tiers'] ?? json['pricing_tiers']).map(
                (x) => MOQTier.fromJson(x),
              ),
            )
          : null,
      store: json['store'] != null ? StoreInfo.fromJson(json['store']) : null,
      seller: json['seller'] != null
          ? SellerInfo.fromJson(json['seller'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'original_price_yuan': originalPriceYuan,
      'image_url': imageUrl,
      'gallery_urls': galleryUrls,
      'category': category,
      'rating': rating,
      'stock': stock,
      'seller_id': sellerId,
      'reviews': reviews,
      'sku': sku,
      'weight': weight,
      'status': status,
      'currency': currency,
      if (variants != null)
        'variants': List<dynamic>.from(variants!.map((x) => x.toJson())),
      if (moqTiers != null)
        'moq_tiers': List<dynamic>.from(moqTiers!.map((x) => x.toJson())),
      if (store != null) 'store': store!.toJson(),
      if (seller != null) 'seller': seller!.toJson(),
    };
  }
}

class MOQTier {
  final int minQty;
  final int? maxQty;
  final double pricePerUnit;

  MOQTier({required this.minQty, this.maxQty, required this.pricePerUnit});

  factory MOQTier.fromJson(Map<String, dynamic> json) {
    return MOQTier(
      minQty: json['min_qty'],
      maxQty: json['max_qty'],
      pricePerUnit: (json['price_per_unit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_qty': minQty,
      if (maxQty != null) 'max_qty': maxQty,
      'price_per_unit': pricePerUnit,
    };
  }
}

class ProductVariant {
  final String type; // e.g. 'Color', 'Size'
  final String value;
  final double? price;
  final int? stock;

  ProductVariant({
    required this.type,
    required this.value,
    this.price,
    this.stock,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      type: json['type'],
      value: json['value'],
      price: (json['price'] as num?)?.toDouble(),
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      if (price != null) 'price': price,
      if (stock != null) 'stock': stock,
    };
  }
}

class StoreInfo {
  final String name;
  final String? logoUrl;

  StoreInfo({required this.name, this.logoUrl});

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(name: json['name'] ?? '', logoUrl: json['logo_url']);
  }

  Map<String, dynamic> toJson() => {'name': name, 'logo_url': logoUrl};
}

class SellerInfo {
  final String name;
  final String? phone;

  SellerInfo({required this.name, this.phone});

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(name: json['name'] ?? '', phone: json['phone']);
  }

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone};
}
