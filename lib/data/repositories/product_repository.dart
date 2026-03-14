import '../models/product.dart';

class ProductRepository {
  Future<List<ProductModel>> getProducts() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(20, (index) {
      String category = index % 3 == 0 ? 'Electronics' : (index % 3 == 1 ? 'Fashion' : 'Home Goods');
      String imageUrl = category == 'Electronics' 
        ? 'https://images.unsplash.com/photo-1498049794561-7780e7231661?q=80&w=500'
        : (category == 'Fashion' 
            ? 'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=500'
            : 'https://images.unsplash.com/photo-1513694203232-719a280e022f?q=80&w=500');

      return ProductModel(
        id: 'p$index',
        name: '$category Item #$index',
        description: 'High-quality $category imported directly from China. Durable and affordable.',
        price: (index + 1) * 15.0,
        imageUrl: imageUrl,
        category: category,
        rating: 4.0 + (index % 10) / 10,
        stock: 10 + index,
        sellerId: 's${index % 3}',
        galleryUrls: [
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=500',
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=500',
        ],
      );
    });
  }

  Future<ProductModel> getProductDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ProductModel(
      id: id,
      name: 'China Smart Gadget',
      description: 'The latest technology from China, perfect for your modern home or business.',
      price: 199.99,
      imageUrl: 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=500',
      category: 'Electronics',
      rating: 4.8,
      stock: 5,
      sellerId: 's1',
      galleryUrls: [
        'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=500',
        'https://images.unsplash.com/photo-1498049794561-7780e7231661?q=80&w=500',
      ],
      reviews: [
        {'user': 'John D.', 'rating': 5, 'comment': 'Excellent quality!'},
        {'user': 'Jane S.', 'rating': 4, 'comment': 'Good value for money.'},
      ],
    );
  }
}
