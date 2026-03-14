import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
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
                          fadeInDuration: Duration.zero,
                          fadeOutDuration: Duration.zero,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image,
                            size: 80,
                            color: AppColors.error,
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
