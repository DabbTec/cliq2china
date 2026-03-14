import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../admin_controller.dart';

class AdminDashboard extends GetView<AdminController> {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdminController());
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile ? AppBar(title: const Text('Admin Panel')) : null,
      drawer: isMobile ? Drawer(child: _buildSidebar(isMobile: true)) : null,
      body: Row(
        children: [
          // Sidebar (only for desktop)
          if (!isMobile) _buildSidebar(isMobile: false),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isMobile),
                  const SizedBox(height: 32),
                  _buildStatsGrid(isMobile),
                  const SizedBox(height: 32),
                  _buildRecentActivities(isMobile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar({required bool isMobile}) {
    return Container(
      width: isMobile ? double.infinity : 260,
      color: Colors.white,
      child: Column(
        children: [
          if (!isMobile)
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  Text('Admin Panel', style: AppTypography.h3.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          if (!isMobile) const Divider(),
          _sidebarItem(Icons.dashboard, 'Dashboard', true),
          _sidebarItem(Icons.people, 'Users', false),
          _sidebarItem(Icons.store, 'Sellers', false),
          _sidebarItem(Icons.account_balance_wallet, 'Loans', false),
          _sidebarItem(Icons.shopping_bag, 'Products', false),
          _sidebarItem(Icons.report, 'Disputes', false),
          const Spacer(),
          _sidebarItem(Icons.settings, 'Settings', false),
          _sidebarItem(Icons.logout, 'Logout', false),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? AppColors.primary : AppColors.textSecondary),
        title: Text(label, style: AppTypography.bodyMedium.copyWith(
          color: isActive ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        )),
        onTap: () {},
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard Overview', style: isMobile ? AppTypography.h3 : AppTypography.h2),
              Text('Welcome back, Admin!', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        if (!isMobile)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text('March 2026', style: AppTypography.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white)),
            ],
          ),
      ],
    );
  }

  Widget _buildStatsGrid(bool isMobile) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: isMobile ? 16 : 24,
      mainAxisSpacing: isMobile ? 16 : 24,
      childAspectRatio: isMobile ? 1.4 : 1.8,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _adminStatCard('Total Users', controller.totalUsers.value.toString(), Icons.people, Colors.blue),
        _adminStatCard('Active Sellers', controller.totalSellers.value.toString(), Icons.store, Colors.green),
        _adminStatCard('Pending Loans', controller.pendingLoans.value.toString(), Icons.account_balance_wallet, Colors.orange),
        _adminStatCard('Revenue', '\$${controller.revenue.value.toStringAsFixed(0)}', Icons.trending_up, Colors.purple),
      ],
    );
  }

  Widget _adminStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: AppTypography.h2),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(bool isMobile) {
    final content = [
      Expanded(
        flex: isMobile ? 0 : 2,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Orders', style: AppTypography.h3),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Order #8293${index + 1}', style: AppTypography.bodyMedium),
                  subtitle: Text('Buyer: John Doe', style: AppTypography.bodySmall),
                  trailing: Text('\$250.00', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(width: isMobile ? 0 : 24, height: isMobile ? 24 : 0),
      Expanded(
        flex: isMobile ? 0 : 1,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pending Approvals', style: AppTypography.h3),
              const SizedBox(height: 16),
              _approvalItem('Vendor A', 'Seller Application'),
              _approvalItem('Vendor B', 'Seller Application'),
              _approvalItem('Loan #882', 'Loan Request'),
            ],
          ),
        ),
      ),
    ];

    if (isMobile) {
      return Column(children: content.map((e) => e is Expanded ? e.child : e).toList());
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content,
    );
  }

  Widget _approvalItem(String name, String type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              Text(type, style: AppTypography.bodySmall),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(60, 30),
            ),
            child: const Text('Review', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
