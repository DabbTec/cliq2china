import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/widgets/buttons.dart';
import '../onboarding_controller.dart';
import '../../../routes/app_pages.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    // If on Web, redirect to Landing Page immediately
    if (kIsWeb) {
      Future.microtask(() => Get.offAllNamed(Routes.landing));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: controller.skip,
                child: Text('Skip', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.onboardingData.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  final data = controller.onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: data['image']!,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          fadeOutDuration: Duration.zero,
                          fadeInDuration: Duration.zero,
                          httpHeaders: const {
                            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                          },
                          // No visible loading indicator for a cleaner look
                          placeholder: (context, url) => const SizedBox(
                            height: 300,
                            width: double.infinity,
                          ),
                          errorWidget: (context, url, error) => const SizedBox(
                            height: 300,
                            width: double.infinity,
                            child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          data['title']!,
                          style: AppTypography.h1.copyWith(color: AppColors.primary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data['description']!,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      controller.onboardingData.length,
                      (index) => Obx(() => Container(
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: controller.currentPage.value == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: controller.currentPage.value == index ? AppColors.primary : AppColors.grey300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )),
                    ),
                  ),
                  Obx(() => controller.currentPage.value == controller.onboardingData.length - 1
                      ? SizedBox(
                          width: 140,
                          child: PrimaryButton(
                            text: 'Get Started',
                            onPressed: controller.skip,
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: controller.next,
                            icon: const Icon(Icons.arrow_forward, color: Colors.white),
                          ),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
