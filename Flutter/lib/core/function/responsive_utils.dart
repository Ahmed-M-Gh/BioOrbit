import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Helper wrapper around flutter_screenutil for adaptive padding & tablet detection
class ResponsiveUtils {
  static bool get isTablet => 1.sw >= 600;

  static EdgeInsets get screenPadding => EdgeInsets.symmetric(
    horizontal: isTablet ? 0.08.sw : 16.w,
    vertical: 14.h,
  );
}
