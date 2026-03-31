import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerNotificationsView extends StatelessWidget {
  const SellerNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildNotificationSection('Order Alerts', [
            _notificationItem(
              'New Orders',
              'Notify when a customer buys',
              true,
            ),
            _notificationItem(
              'Order Updates',
              'Status changes and shipping',
              true,
            ),
          ]),
          const SizedBox(height: 32),
          _buildNotificationSection('Store Performance', [
            _notificationItem(
              'Weekly Reports',
              'Store analytics summary',
              false,
            ),
            _notificationItem(
              'Inventory Alerts',
              'Low stock notifications',
              true,
            ),
          ]),
          const SizedBox(height: 32),
          _buildNotificationSection('Marketing', [
            _notificationItem('Promotions', 'Campaigns and discounts', false),
            _notificationItem('News & Updates', 'Platform announcements', true),
          ]),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _notificationItem(String title, String subtitle, bool isEnabled) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Switch.adaptive(
        value: isEnabled,
        onChanged: (val) {},
        activeTrackColor: Colors.black,
      ),
    );
  }
}
