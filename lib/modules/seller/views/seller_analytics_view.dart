import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../seller_controller.dart';
import '../../../core/utils/currency_service.dart';

class SellerAnalyticsView extends GetView<SellerController> {
  const SellerAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Store Analytics',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeFilter(),
              const SizedBox(height: 24),
              _buildMainMetrics(),
              const SizedBox(height: 32),
              const Text(
                'SALES OVERVIEW',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              _buildChartPlaceholder(),
              const SizedBox(height: 32),
              _buildTopProducts(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTimeFilter() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip('Last 7 Days', true),
          _filterChip('Last 30 Days', false),
          _filterChip('Last 6 Months', false),
          _filterChip('All Time', false),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMainMetrics() {
    final stats = controller.stats.value;
    final salesYuan = stats?.totalSales ?? 0.0;
    final localSales = CurrencyService.to.convertFromYuan(salesYuan);

    return Column(
      children: [
        _metricRow(
          'Total Revenue',
          '${CurrencyService.to.localCurrencySymbol}${localSales.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
          '+12.5%',
          Colors.green,
        ),
        const SizedBox(height: 16),
        _metricRow(
          'Total Orders',
          '${stats?.totalOrders ?? 0}',
          '+5.2%',
          Colors.green,
        ),
        const SizedBox(height: 16),
        _metricRow(
          'Total Products',
          '${stats?.totalProducts ?? 0}',
          '${stats?.totalCustomers ?? 0} Customers',
          Colors.blue,
        ),
      ],
    );
  }

  Widget _metricRow(
    String label,
    String value,
    String change,
    Color changeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              change,
              style: TextStyle(
                color: changeColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    final chartData = controller.stats.value?.salesChart ?? [];
    if (chartData.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(Icons.show_chart, size: 60, color: Colors.grey),
        ),
      );
    }
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: chartData.map((data) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 20,
                height: (data.amount / 1000) * 100, // Very simple scaling
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              Text(
                data.month,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopProducts() {
    final products = controller.myProducts.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TOP PRODUCTS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        if (products.isEmpty)
          const Text('No products found')
        else
          ...products.map(
            (p) => _productItem(
              p.name,
              'Active',
              '¥${p.price.toStringAsFixed(2)}',
            ),
          ),
      ],
    );
  }

  Widget _productItem(String name, String sales, String revenue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sales,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(revenue, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
