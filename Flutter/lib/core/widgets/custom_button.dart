import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/bio_orbit_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor = BioOrbitColors.orbitalCyan,
    this.foregroundColor = BioOrbitColors.spaceDeepBg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 4,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 22.r,
                width: 22.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: foregroundColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20.r),
                    SizedBox(width: 10.w),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
