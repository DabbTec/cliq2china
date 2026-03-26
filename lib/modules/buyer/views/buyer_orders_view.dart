import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/currency_service.dart';
import '../buyer_controller.dart';

class BuyerOrdersView extends StatefulWidget {
  const BuyerOrdersView({super.key});

  @override
  State<BuyerOrdersView> createState() => _BuyerOrdersViewState();
}

class _BuyerOrdersViewState extends State<BuyerOrdersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final BuyerController controller;

  final List<String> _tabs = [
    'All',
    'Processing',
    'Shipped',
    'To Receive',
    'Completed',
  ];

  // Mock data for DSers-style operations
  final List<Map<String, dynamic>> _mockOrders = [
    {
      'id': 'C2C-882199',
      'productName': 'Premium Wireless Headphones',
      'image': 'https://picsum.photos/200',
      'price': 129.99,
      'originalPriceYuan': 89.00,
      'quantity': 1,
      'status': 'Processing',
      'statusDetail': 'Awaiting Admin Approval',
      'trackingNumber': 'Pending',
      'estimatedDelivery': 'Calculating...',
      'tab': 'Processing',
      'timeline': [
        {'status': 'Order Placed', 'time': 'Mar 16, 10:30 AM', 'done': true},
        {
          'status': 'Payment Confirmed',
          'time': 'Mar 16, 10:35 AM',
          'done': true,
        },
        {'status': 'Admin Verification', 'time': 'In Progress', 'done': false},
      ],
    },
    {
      'id': 'C2C-112045',
      'productName': '4K Home Cinema Projector',
      'image': 'https://picsum.photos/202',
      'price': 450.00,
      'originalPriceYuan': 320.00,
      'quantity': 1,
      'status': 'Shipped',
      'statusDetail': 'In Transit from China',
      'trackingNumber': 'DS-TRK-9921',
      'estimatedDelivery': 'Mar 25, 2026',
      'tab': 'Shipped',
      'timeline': [
        {'status': 'Order Placed', 'time': 'Mar 12, 09:00 AM', 'done': true},
        {
          'status': 'Shipped from China',
          'time': 'Mar 14, 02:00 PM',
          'done': true,
        },
        {
          'status': 'Arrived at Sorting Center',
          'time': 'Mar 15, 10:00 AM',
          'done': true,
        },
        {
          'status': 'Departed from Sorting Center',
          'time': 'Mar 16, 04:00 PM',
          'done': true,
        },
      ],
    },
    {
      'id': 'C2C-993012',
      'productName': 'Ergonomic Gaming Chair',
      'image': 'https://picsum.photos/203',
      'price': 225.75,
      'originalPriceYuan': 155.00,
      'quantity': 1,
      'status': 'At Hub',
      'statusDetail': 'Arrived at Lagos Pickup Station',
      'trackingNumber': 'C2C-LGS-441',
      'estimatedDelivery': 'Tomorrow',
      'tab': 'To Receive',
      'timeline': [
        {'status': 'Order Placed', 'time': 'Mar 11, 11:00 AM', 'done': true},
        {
          'status': 'Shipped from China',
          'time': 'Mar 13, 09:00 AM',
          'done': true,
        },
        {
          'status': 'Arrived at Lagos Hub',
          'time': 'Mar 16, 08:00 AM',
          'done': true,
        },
        {
          'status': 'Ready for Local Dispatch',
          'time': 'Mar 17, 09:30 AM',
          'done': true,
        },
      ],
    },
    {
      'id': 'C2C-774155',
      'productName': 'Smart Fitness Tracker v4',
      'image': 'https://picsum.photos/204',
      'price': 45.99,
      'originalPriceYuan': 32.00,
      'quantity': 1,
      'status': 'Completed',
      'statusDetail': 'Delivered Successfully',
      'trackingNumber': 'DEL-77415',
      'estimatedDelivery': 'Delivered on Mar 15',
      'tab': 'Completed',
      'timeline': [
        {'status': 'Delivered', 'time': 'Mar 15, 02:30 PM', 'done': true},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<BuyerController>();
    final args = Get.arguments;
    int initialIndex = 0;
    if (args is Map && args.containsKey('initialIndex')) {
      initialIndex = args['initialIndex'] ?? 0;
    }
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: initialIndex.clamp(0, _tabs.length - 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Orders',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.black,
          indicatorWeight: 2,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) => _buildOrdersList(tab)).toList(),
      ),
    );
  }

  Widget _buildOrdersList(String status) {
    final ordersToShow = status == 'All'
        ? _mockOrders
        : _mockOrders.where((o) => o['tab'] == status).toList();

    if (ordersToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80.sp,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            Text(
              'No $status orders',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: ordersToShow.length,
      itemBuilder: (context, index) => _buildOrderCard(ordersToShow[index]),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: ${order['id']}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    order['status'],
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Text(
                  order['status'].toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(order['status']),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.w),
                child: Image.network(
                  order['image'],
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['productName'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (order['originalPriceYuan'] != null) ...[
                          Text(
                            '¥',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(
                                0xFFE53935,
                              ), // Updated to standard Red
                            ),
                          ),
                          Text(
                            '${order['originalPriceYuan'].toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(
                                0xFFE53935,
                              ), // Updated to standard Red
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '≈',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Obx(() {
                          // Ensure GetX tracks location changes
                          final _ = CurrencyService.to.currentLocation.value;
                          final localPrice = order['originalPriceYuan'] != null
                              ? CurrencyService.to.convertFromYuan(
                                  order['originalPriceYuan'],
                                )
                              : order['price'];
                          return Text(
                            '${CurrencyService.to.localCurrencySymbol}${localPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Status',
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                  ),
                  Text(
                    order['statusDetail'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _showTrackingDetails(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                ),
                child: Text(
                  'Track Order',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Processing':
        return Colors.orange;
      case 'Shipped':
        return Colors.blue;
      case 'At Hub':
        return Colors.purple;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showTrackingDetails(Map<String, dynamic> order) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.w),
            topRight: Radius.circular(20.w),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Timeline',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24.h),
            ...List.generate(order['timeline'].length, (index) {
              final item = order['timeline'][index];
              final isLast = index == order['timeline'].length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: item['done'] ? Colors.black : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2.w,
                          height: 30.h,
                          color: item['done'] ? Colors.black : Colors.grey[200],
                        ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['status'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: item['done'] ? Colors.black : Colors.grey,
                          ),
                        ),
                        Text(
                          item['time'],
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
