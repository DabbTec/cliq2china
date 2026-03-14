class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final String status; // 'pending', 'processing', 'shipped', 'delivered'
  final DateTime createdAt;
  final String address;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.address,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
      total: (json['total'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'total': total,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'address': address,
    };
  }
}

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'],
      name: json['name'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'image_url': imageUrl,
    };
  }
}
