import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'routes/app_pages.dart';
import 'core/constants/colors.dart';
import 'modules/auth/auth_controller.dart';
import 'core/utils/currency_service.dart';
import 'core/services/token_service.dart';
import 'core/services/api_service.dart';
import 'core/services/image_upload_service.dart';
import 'core/services/app_update_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch any unhandled errors to prevent silent crashes
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  runApp(const Cliq2ChinaApp());
}

class Cliq2ChinaApp extends StatelessWidget {
  const Cliq2ChinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
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
            Get.put(TokenService());
            Get.put(ApiService());
            Get.put(CurrencyService());
            Get.put(ImageUploadService());
            Get.put(AppUpdateService());
            Get.put(AuthController());
          }),
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          defaultTransition: Transition.fade,
        );
      },
    );
  }
}
