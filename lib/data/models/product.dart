import '../../core/utils/currency_service.dart';

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
  final String? material;
  final Map<String, dynamic>? attributes; // NEW: Extra flexible attributes
  final String? status; // 'active', 'draft', 'archived'
  final String? currency; // NEW: Seller's local currency code
  final int? minQty; // NEW: Minimum order quantity at root level
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

  double get effectiveYuan {
    if (moqTiers != null && moqTiers!.isNotEmpty) {
      final firstTier = moqTiers!.first;
      // Prioritize total tier price from backend
      if (firstTier.yuanPrice != null && firstTier.yuanPrice! > 0) {
        return firstTier.yuanPrice!;
      }
      return firstTier.pricePerUnit * firstTier.minQty;
    }

    // Fallback to unit price multiplied by root-level MOQ
    double unitYuan = price;
    if (displayYuan != null && displayYuan! > 0) {
      unitYuan = displayYuan!;
    } else if (originalPriceYuan != null && originalPriceYuan! > 0) {
      unitYuan = originalPriceYuan!;
    } else {
      final code = currency?.toUpperCase();
      if (code != null && code.isNotEmpty && code != 'CNY') {
        final rate = CurrencyService.to.rates[code]?.rateToYuan;
        if (rate != null && rate > 0) {
          unitYuan = price / rate;
        }
      }
    }

    if (minQty != null && minQty! > 1) {
      return unitYuan * minQty!;
    }
    return unitYuan;
  }

  double get effectiveLocal {
    if (moqTiers != null && moqTiers!.isNotEmpty) {
      final firstTier = moqTiers!.first;
      // Prioritize total tier price from backend
      if (firstTier.localPrice != null && firstTier.localPrice! > 0) {
        return firstTier.localPrice!;
      }
      return CurrencyService.to.convertFromYuan(effectiveYuan);
    }

    // Fallback to total price based on effectiveYuan (which handles minQty)
    if (displayPrice != null && displayPrice! > 0) {
      if (minQty != null && minQty! > 1) {
        return displayPrice! * minQty!;
      }
      return displayPrice!;
    }

    if (currency != null &&
        currency!.isNotEmpty &&
        currency!.toUpperCase() != 'CNY') {
      if (minQty != null && minQty! > 1) {
        return price * minQty!;
      }
      return price;
    }

    return CurrencyService.to.convertFromYuan(effectiveYuan);
  }

  String get effectiveSymbol =>
      displaySymbol ?? CurrencyService.to.localCurrencySymbol;

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
    this.material,
    this.attributes,
    this.status = 'active',
    this.currency,
    this.minQty,
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
      weight:
          (json['weight'] as num?)?.toDouble() ??
          (json['attributes']?['weight'] as num?)?.toDouble(),
      material: json['material'] ?? json['attributes']?['material'],
      attributes: json['attributes'] != null
          ? Map<String, dynamic>.from(json['attributes'])
          : null,
      status: json['status'] ?? 'active',
      currency: json['currency'],
      minQty: json['min_qty'] ?? json['moq'],
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
    final bool isNotYuan = currency != null && currency!.toUpperCase() != 'CNY';

    return {
      'id': id,
      'name': name,
      'description': description,
      'price': isNotYuan ? CurrencyService.to.convertToYuan(price) : price,
      'local_price': price, // Send local price as a backup/reference
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
      'status': status,
      'currency': currency,
      'min_qty': minQty,
      // BACKEND INSTRUCTION: Fields like material, brand, or weight can be sent directly at the top level.
      if (weight != null) 'weight': weight,
      if (material != null) 'material': material,
      ...?attributes,
      if (variants != null)
        'variants': List<dynamic>.from(
          variants!.map((x) {
            final vJson = x.toJson();
            if (isNotYuan && x.price != null) {
              vJson['price'] = CurrencyService.to.convertToYuan(x.price!);
              vJson['local_price'] = x.price;
            }
            return vJson;
          }),
        ),
      if (moqTiers != null)
        'moq_tiers': List<dynamic>.from(
          moqTiers!.map((x) {
            final tJson = x.toJson();
            // BACKEND INSTRUCTION: price_per_unit should be sent in Yuan (CNY)
            if (isNotYuan) {
              tJson['price_per_unit'] = CurrencyService.to.convertToYuan(
                x.pricePerUnit,
              );
              tJson['local_price'] = x.pricePerUnit;
            }
            return tJson;
          }),
        ),
      if (store != null) 'store': store!.toJson(),
      if (seller != null) 'seller': seller!.toJson(),
    };
  }
}

class MOQTier {
  final int minQty;
  final int? maxQty;
  final double
  pricePerUnit; // This should be treated as the price in the seller's currency
  final double? localPrice; // Real local price from backend
  final double? yuanPrice; // Real yuan price from backend

  MOQTier({
    required this.minQty,
    this.maxQty,
    required this.pricePerUnit,
    this.localPrice,
    this.yuanPrice,
  });

  factory MOQTier.fromJson(Map<String, dynamic> json) {
    // Safely extract the exact prices calculated/saved by the backend
    final localP = json['local_price'] ?? json['display_price'];
    final yuanP =
        json['yuan_price'] ?? json['display_yuan'] ?? json['price_per_unit'];

    return MOQTier(
      minQty: json['min_qty'] ?? 1,
      maxQty: json['max_qty'],
      // If we have a local price from backend, use it as the primary unit price for the seller UI
      pricePerUnit:
          (localP as num?)?.toDouble() ??
          CurrencyService.to.convertFromYuan(
            (yuanP as num?)?.toDouble() ?? 0.0,
          ),
      localPrice: (localP as num?)?.toDouble(),
      yuanPrice: (yuanP as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_qty': minQty,
      if (maxQty != null) 'max_qty': maxQty,
      'price_per_unit': pricePerUnit,
      if (localPrice != null) 'local_price': localPrice,
      if (yuanPrice != null) 'yuan_price': yuanPrice,
    };
  }
}

class ProductVariant {
  final String type; // 'Color', 'Size', 'Weight', 'Material', 'Other'
  final String value;
  final double?
  price; // This should be treated as the price in the seller's currency
  final int? stock;
  final String? imageUrl; // Main variant image (Legacy support)
  final List<String> galleryUrls; // New: Supports multiple images per variant
  final String? weight;
  final String? material;
  final String? description; // New: Variant description
  final bool isActive;
  final Map<String, String>?
  attributes; // NEW: Supports nested variants (e.g. Color: Red, Size: XL)

  ProductVariant({
    required this.type,
    required this.value,
    this.price,
    this.stock,
    this.imageUrl,
    this.galleryUrls = const [],
    this.weight,
    this.material,
    this.description,
    this.isActive = true,
    this.attributes,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    // If backend returns a flat structure (e.g. {"color": "Red", "size": "XL", "stock": 10})
    // and missing "type" / "value", we try to extract them.
    String extractedType = json['type'] ?? 'Other';
    String extractedValue = json['value'] ?? '';

    // If still empty, use the first key that isn't a reserved field as type/value
    if (extractedValue.isEmpty) {
      final reservedKeys = [
        'price',
        'local_price',
        'stock',
        'image_url',
        'gallery_urls',
        'weight',
        'material',
        'description',
        'is_active',
        'attributes',
      ];
      final attrKeys = json.keys
          .where((k) => !reservedKeys.contains(k))
          .toList();
      if (attrKeys.isNotEmpty) {
        extractedType = attrKeys.first;
        extractedValue = json[extractedType].toString();
      }
    }

    final localP = json['local_price'] ?? json['display_price'];
    final yuanP = json['price'] ?? json['display_yuan'];

    return ProductVariant(
      type: extractedType,
      value: extractedValue,
      // If we have a local price from backend, use it. Otherwise convert the yuan price.
      price:
          (localP as num?)?.toDouble() ??
          (yuanP != null
              ? CurrencyService.to.convertFromYuan((yuanP as num).toDouble())
              : null),
      stock: json['stock'],
      imageUrl: json['image_url'],
      galleryUrls: List<String>.from(json['gallery_urls'] ?? []),
      weight: json['weight'] ?? json['attributes']?['weight'],
      material: json['material'] ?? json['attributes']?['material'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
      attributes: json['attributes'] != null
          ? Map<String, String>.from(json['attributes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      // Include the type/value as a direct key as well for backend flexibility
      if (type.toLowerCase() != 'other' && value.isNotEmpty)
        type.toLowerCase(): value,
      if (price != null) 'price': price,
      if (stock != null) 'stock': stock,
      if (imageUrl != null) 'image_url': imageUrl,
      'gallery_urls': galleryUrls,
      if (description != null) 'description': description,
      'is_active': isActive,
      // BACKEND INSTRUCTION: Send nested attributes at top level for JSON storage
      if (weight != null) 'weight': weight,
      if (material != null) 'material': material,
      ...?attributes,
    };
  }
}

class StoreInfo {
  final String name;
  final String? logoUrl;
  final Map<String, dynamic>? metadata;

  StoreInfo({required this.name, this.logoUrl, this.metadata});

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      name: json['name'] ?? '',
      logoUrl: json['logo_url'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'logo_url': logoUrl,
    'metadata': metadata,
  };
}

class SellerInfo {
  final String name;
  final String? phone;
  final String? businessName;

  SellerInfo({required this.name, this.phone, this.businessName});

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      name: json['name'] ?? '',
      phone: json['phone'],
      businessName: json['business_name'] ?? json['store_name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'business_name': businessName,
  };
}
