import 'package:flutter/material.dart';

class CategoryConstants {
  static const List<Map<String, dynamic>> categories = [
    {'name': 'Electronics & Gadgets', 'icon': Icons.phone_android},
    {'name': 'Fashion & Apparel', 'icon': Icons.checkroom},
    {'name': 'Home & Kitchen', 'icon': Icons.home},
    {'name': 'Beauty & Personal Care', 'icon': Icons.face},
    {'name': 'Health & Wellness', 'icon': Icons.health_and_safety},
    {'name': 'Toys & Games', 'icon': Icons.toys},
    {'name': 'Sports & Outdoors', 'icon': Icons.sports_basketball},
    {'name': 'Baby & Maternity', 'icon': Icons.child_care},
    {'name': 'Automotive Parts', 'icon': Icons.directions_car},
    {'name': 'Industrial & Scientific', 'icon': Icons.precision_manufacturing},
    {'name': 'Arts & Crafts', 'icon': Icons.palette},
    {'name': 'Office Supplies', 'icon': Icons.business_center},
    {'name': 'Pet Supplies', 'icon': Icons.pets},
    {'name': 'Grocery & Gourmet Food', 'icon': Icons.restaurant},
    {'name': 'Tools & Home Improvement', 'icon': Icons.build},
    {'name': 'Jewelry & Watches', 'icon': Icons.watch},
    {'name': 'Musical Instruments', 'icon': Icons.music_note},
    {'name': 'Books & Media', 'icon': Icons.menu_book},
    {'name': 'Computers & Accessories', 'icon': Icons.computer},
    {'name': 'Mobile Phones & Tablets', 'icon': Icons.tablet_android},
    {'name': 'Video Games & Consoles', 'icon': Icons.videogame_asset},
    {'name': 'Garden & Outdoor', 'icon': Icons.park},
    {'name': 'Furniture', 'icon': Icons.chair},
    {'name': 'Electrical Equipment', 'icon': Icons.electrical_services},
    {'name': 'Machinery & Tools', 'icon': Icons.settings},
    {'name': 'Building Materials', 'icon': Icons.foundation},
    {'name': 'Lights & Lighting', 'icon': Icons.lightbulb},
    {'name': 'Security & Protection', 'icon': Icons.security},
    {'name': 'Packaging & Printing', 'icon': Icons.inventory},
    {'name': 'Shoes & Accessories', 'icon': Icons.shopping_bag},
    {'name': 'Bags, Cases & Boxes', 'icon': Icons.work},
    {'name': 'Gifts & Crafts', 'icon': Icons.card_giftcard},
    {'name': 'Service Equipment', 'icon': Icons.miscellaneous_services},
    {'name': 'Real Estate', 'icon': Icons.real_estate_agent},
    {'name': 'Energy & Solar', 'icon': Icons.solar_power},
    {'name': 'Environmental Protection', 'icon': Icons.eco},
    {'name': 'Chemicals', 'icon': Icons.science},
    {'name': 'Rubber & Plastics', 'icon': Icons.layers},
    {'name': 'Fabric & Textile Raw Materials', 'icon': Icons.texture},
    {'name': 'Business Services', 'icon': Icons.handshake},
  ];

  static const Map<String, List<String>> categoryKeywords = {
    'Electronics & Gadgets': [
      'phone',
      'laptop',
      'camera',
      'headphones',
      'gadget',
      'charger',
      'usb',
      'bluetooth',
    ],
    'Fashion & Apparel': [
      'shirt',
      'dress',
      'pants',
      'clothing',
      'wear',
      'cotton',
      'silk',
      'jacket',
      'coat',
    ],
    'Home & Kitchen': [
      'blender',
      'table',
      'chair',
      'kitchen',
      'cooking',
      'home',
      'decor',
      'furniture',
      'bed',
    ],
    'Beauty & Personal Care': [
      'makeup',
      'skin',
      'hair',
      'cream',
      'lotion',
      'perfume',
      'beauty',
      'soap',
    ],
    'Shoes & Accessories': [
      'shoe',
      'sneaker',
      'boot',
      'sandal',
      'watch',
      'belt',
      'scarf',
      'sunglasses',
    ],
    'Bags, Cases & Boxes': [
      'bag',
      'handbag',
      'backpack',
      'wallet',
      'case',
      'suitcase',
      'box',
    ],
    'Automotive Parts': [
      'car',
      'tire',
      'engine',
      'brake',
      'motor',
      'vehicle',
      'parts',
      'accessories',
    ],
    'Sports & Outdoors': [
      'gym',
      'sport',
      'yoga',
      'running',
      'football',
      'hiking',
      'outdoor',
      'camping',
    ],
    'Real Estate': [
      'house',
      'apartment',
      'land',
      'property',
      'building',
      'rent',
      'sale',
    ],
    'Energy & Solar': [
      'solar',
      'panel',
      'battery',
      'inverter',
      'energy',
      'power',
      'generator',
    ],
    'Pet Supplies': [
      'dog',
      'cat',
      'pet',
      'food',
      'leash',
      'collar',
      'aquarium',
      'bird',
    ],
    'Musical Instruments': [
      'guitar',
      'piano',
      'drum',
      'violin',
      'music',
      'instrument',
      'keyboard',
    ],
    'Industrial & Scientific': [
      'machine',
      'industrial',
      'tool',
      'lab',
      'scientific',
      'equipment',
    ],
  };

  static List<String> get categoryNames =>
      categories.map((c) => c['name'] as String).toList();

  static String normalizeCategory(String? name) {
    if (name == null || name.isEmpty) return categoryNames.first;

    final names = categoryNames;
    if (names.contains(name)) return name;

    // Mapping old categories to new ones
    final Map<String, String> mapping = {
      'Electronics': 'Electronics & Gadgets',
      'Fashion': 'Fashion & Apparel',
      'Home Goods': 'Home & Kitchen',
      'Home': 'Home & Kitchen',
      'Beauty': 'Beauty & Personal Care',
      'Toys': 'Toys & Games',
    };

    return mapping[name] ?? names.first;
  }

  static String suggestCategory(String text) {
    final lowerText = text.toLowerCase();
    for (var entry in categoryKeywords.entries) {
      for (var keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          return entry.key;
        }
      }
    }
    return '';
  }
}
