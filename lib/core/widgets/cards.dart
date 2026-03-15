import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final double price;
  final String imageUrl;
  final double rating;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final double? originalPrice;
  final int? discountPercentage;
  final String? tag;
  final bool showChoice; // Added showChoice
  final bool showSale; // Added showSale
  final double imageHeight; // Added imageHeight

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.onTap,
    required this.onAddToCart,
    this.originalPrice,
    this.discountPercentage,
    this.tag,
    this.showChoice = false, // Default false
    this.showSale = false, // Default false
    this.imageHeight = 180, // Default height
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.white, // No container border or radius
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Section (Only the image has a border/radius)
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), // Image border radius
                    border: Border.all(color: Colors.grey[200]!, width: 0.5), // Image border
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: imageHeight,
                      placeholder: (context, url) => Container(
                        height: imageHeight,
                        color: Colors.grey[100],
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: imageHeight,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 30),
                      ),
                    ),
                  ),
                ),
                // Pill tag
                if (tag != null)
                  Positioned(
                    left: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tag!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11, // Increased from 9
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // 2. Info Section (No border here)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Increased padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with Choice/Sale Beside it
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        if (showChoice)
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: _buildBadge('Choice', const Color(0xFF1367AF), Colors.white),
                            ),
                          ),
                        if (showSale)
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: _buildBadge('Sale', const Color(0xFFFFEBEE), const Color(0xFFE53935)),
                            ),
                          ),
                        TextSpan(
                          text: title,
                          style: const TextStyle(
                            color: Color(0xFF222222), // Darker for visibility
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            height: 1.2,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Added to cart text
                  const Text(
                    '10000+ added to cart',
                    style: TextStyle(
                      color: Color(0xFF444444), // Darker
                      fontSize: 12, // Increased from 10
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Price Row (NGN format + sold count)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        'NGN',
                        style: TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.w900,
                          fontSize: 12, // Increased from 10
                        ),
                      ),
                      Text(
                        price.toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},"),
                        style: const TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.w900,
                          fontSize: 18, // Increased from 15
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '10K+ sold',
                        style: TextStyle(
                          color: Colors.grey[700], // Darker
                          fontSize: 12, // Increased from 10
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Footer Row (Optional Bundle Deal & Mini Cart)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (tag == 'Choice') // Only show bundle deals for certain items
                        const Text(
                          'Bundle deals >',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13, // Increased from 11
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      
                      // Small Cart Button
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          padding: const EdgeInsets.all(4), // Increased from 2
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black.withValues(alpha: 0.8), width: 1.5), // Bolder border
                            ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 16, // Increased from 12
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Increased padding
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11, // Increased from 9
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
