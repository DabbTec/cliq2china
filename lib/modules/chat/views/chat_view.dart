import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Messages', style: AppTypography.h2.copyWith(color: AppColors.primary))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), radius: 24, child: Icon(Icons.person, color: AppColors.primary)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('China Seller #$index', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Hello! Is this product still available?', style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Text('2:30 PM', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
              ],
            ),
          );
        },
      ),
    );
  }
}
