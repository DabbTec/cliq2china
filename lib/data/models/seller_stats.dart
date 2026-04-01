class SellerStatsModel {
  final double totalSales;
  final int totalOrders;
  final int totalProducts;
  final int totalCustomers;
  final List<MonthlySales> salesChart;
  final List<Map<String, dynamic>> recentActivities;

  SellerStatsModel({
    required this.totalSales,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalCustomers,
    required this.salesChart,
    required this.recentActivities,
  });

  factory SellerStatsModel.fromJson(Map<String, dynamic> json) {
    return SellerStatsModel(
      totalSales: _toDouble(json['total_sales']),
      totalOrders: _toInt(json['total_orders']),
      totalProducts: _toInt(json['total_products']),
      totalCustomers: _toInt(json['total_customers']),
      salesChart:
          (json['sales_chart'] as List?)
              ?.map((e) => MonthlySales.fromJson(e))
              .toList() ??
          [],
      recentActivities:
          (json['recent_activities'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class MonthlySales {
  final String month;
  final double amount;

  MonthlySales({required this.month, required this.amount});

  factory MonthlySales.fromJson(Map<String, dynamic> json) {
    return MonthlySales(
      month: json['month'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
