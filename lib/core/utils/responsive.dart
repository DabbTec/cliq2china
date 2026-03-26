import 'package:get/get.dart';

/// A utility class for building responsive UI.
/// Instead of hardcoding pixels, use these extensions to scale values
/// based on the device screen size.
class Responsive {
  /// The design width used in your UI design (e.g., Figma design width)
  static const double designWidth = 375.0;
  static const double designHeight = 812.0;

  /// Scales the given value based on the current screen width.
  static double setWidth(double width) {
    return (Get.width * width) / designWidth;
  }

  /// Scales the given value based on the current screen height.
  static double setHeight(double height) {
    return (Get.height * height) / designHeight;
  }

  /// Scales font size based on the screen width to maintain readability.
  static double setSp(double fontSize) {
    return setWidth(fontSize);
  }
}

extension ResponsiveDouble on num {
  /// Returns a responsive width value. Example: 20.w
  double get w => Responsive.setWidth(toDouble());

  /// Returns a responsive height value. Example: 50.h
  double get h => Responsive.setHeight(toDouble());

  /// Returns a responsive font size. Example: 16.sp
  double get sp => Responsive.setSp(toDouble());
}
