import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  var currentPage = 0.obs;

  final onboardingData = [
    {
      'title': 'Welcome to Cliq2China',
      'description':
          'Opening an account is simple. Whether you are a buyer looking for quality or a seller ready to scale, our marketplace is built for you.',
      'image':
          'https://images.weserv.nl/?url=img.freepik.com/free-vector/online-shopping-concept-illustration_114360-1084.jpg',
    },
    {
      'title': 'Secure Payments & Logistics',
      'description':
          'Enjoy peace of mind with our secure payment systems and reliable shipping solutions.',
      'image':
          'https://images.weserv.nl/?url=img.freepik.com/free-vector/payment-information-concept-illustration_114360-2886.jpg',
    },
    {
      'title': 'Easy Shopping Loans',
      'description':
          'Access instant loans to purchase your favorite products directly on the platform. Please note: loans are exclusively for shopping and cannot be withdrawn.',
      'image':
          'https://images.weserv.nl/?url=img.freepik.com/free-vector/credit-score-concept-illustration_114360-2580.jpg',
    },
    {
      'title': 'Bridging Markets: Cliq2China',
      'description':
          'Experience the fastest and most reliable way to connect with the best products from China. Your satisfaction is our priority.',
      'image':
          'https://images.weserv.nl/?url=img.freepik.com/free-vector/global-business-concept-illustration_114360-2581.jpg',
    },
  ];

  @override
  void onReady() {
    super.onReady();
    // Precache onboarding images to prevent loading stuck issues
    for (var data in onboardingData) {
      if (data['image'] != null) {
        precacheImage(
          NetworkImage(
            data['image']!,
            headers: const {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            },
          ),
          Get.context!,
        );
      }
    }
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void next() {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      skip();
    }
  }

  void skip() {
    Get.offAllNamed(Routes.buyerDashboard);
  }
}
