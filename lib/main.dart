import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'routes/app_pages.dart';
import 'core/constants/colors.dart';
import 'modules/auth/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Simple network debug check (Skipped on Web as dart:io is not supported)
  if (!kIsWeb) {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        debugPrint('Network check: Connected to internet');
      }
    } on SocketException catch (_) {
      debugPrint('Network check: No internet connection or DNS failed');
    } catch (e) {
      debugPrint('Network check error: $e');
    }
  } else {
    debugPrint('Network check: Skipped on Web platform');
  }

  runApp(const Cliq2ChinaApp());
}

class Cliq2ChinaApp extends StatelessWidget {
  const Cliq2ChinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cliq2China',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      initialRoute: kIsWeb ? Routes.landing : AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
    );
  }
}
