import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/cache/cache_helper.dart';
import '../../core/function/navigation.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/bio_orbit_colors.dart';
import '../orbit_hub/view/bio_orbit_layout.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // إذا كان الأندرويد قد أعاد تشغيل التطبيق أثناء التقاط صورة بالكاميرا، انتقل فوراً بدون انتظار 3 ثوانٍ
    final bool isReturningFromCamera =
        CacheHelper.pendingCameraCapture &&
        CacheHelper.accessToken != null &&
        (CacheHelper.crewName?.isNotEmpty ?? false);

    Timer(
      Duration(milliseconds: isReturningFromCamera ? 50 : 2800),
      _navigateNext,
    );
  }

  void _navigateNext() {
    if (!mounted) return;
    final hasSession =
        CacheHelper.accessToken != null &&
        (CacheHelper.crewName?.isNotEmpty ?? false);

    if (hasSession) {
      AppNavigator.pushReplacement(context, const BioOrbitLayout());
    } else {
      AppNavigator.pushReplacement(context, const RoleSelectionScreen());
    }
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? savedName = CacheHelper.crewName;
    final String savedRole = CacheHelper.crewRole;
    final bool hasSavedCrew =
        CacheHelper.accessToken != null && (savedName?.isNotEmpty ?? false);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: SpaceMedicalGridPainter()),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 210.r,
                  height: 210.r,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) {
                          final scale = 0.88 + (_pulseController.value * 0.22);
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 170.r,
                              height: 170.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    BioOrbitColors.orbitalCyan.withOpacity(
                                      0.28,
                                    ),
                                    BioOrbitColors.boneAiPurple.withOpacity(
                                      0.12,
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      RotationTransition(
                        turns: _orbitController,
                        child: Container(
                          width: 185.r,
                          height: 185.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: BioOrbitColors.orbitalCyan.withOpacity(
                                0.55,
                              ),
                              width: 2,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 14.r,
                              height: 14.r,
                              decoration: const BoxDecoration(
                                color: BioOrbitColors.medicalPulseGreen,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: BioOrbitColors.medicalPulseGreen,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 112.r,
                        height: 112.r,
                        decoration: BoxDecoration(
                          color: BioOrbitColors.spaceCardBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: BioOrbitColors.medicalPulseGreen,
                            width: 2.2,
                          ),
                        ),
                        child: Icon(
                          Icons.monitor_heart_rounded,
                          size: 56.r,
                          color: BioOrbitColors.orbitalCyan,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'BioOrbit',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: BioOrbitColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: Text(
                    AppStrings.tr(context, 'app_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BioOrbitColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(height: 28.h),
                SizedBox(
                  height: 55.h,
                  width: 280.w,
                  child: AnimatedBuilder(
                    animation: _orbitController,
                    builder: (_, __) {
                      return CustomPaint(
                        painter: EcgWavePainter(phase: _orbitController.value),
                      );
                    },
                  ),
                ),
                SizedBox(height: 28.h),
                if (hasSavedCrew)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: BioOrbitColors.spaceCardBg,
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(
                        color: BioOrbitColors.medicalPulseGreen,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: BioOrbitColors.medicalPulseGreen,
                          size: 20.r,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          '${AppStrings.tr(context, 'welcome_back')} $savedName (${savedRole == 'Doctor' ? 'Space Doctor' : 'Astronaut'})',
                          style: TextStyle(
                            color: BioOrbitColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SpaceMedicalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = BioOrbitColors.orbitalCyan.withOpacity(0.05)
      ..strokeWidth = 1;

    const double step = 36;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final starPaint = Paint()..color = Colors.white.withOpacity(0.45);
    final rnd = math.Random(42);
    for (int i = 0; i < 45; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final r = rnd.nextDouble() * 1.8 + 0.5;
      canvas.drawCircle(Offset(dx, dy), r, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EcgWavePainter extends CustomPainter {
  final double phase;
  EcgWavePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BioOrbitColors.medicalPulseGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    final midY = size.height / 2;
    path.moveTo(0, midY);

    for (double x = 0; x <= size.width; x += 3) {
      final normalized = ((x / size.width) + phase) % 1.0;
      double y = midY;
      if (normalized > 0.40 && normalized < 0.44) {
        y = midY - 8;
      } else if (normalized >= 0.44 && normalized < 0.47) {
        y = midY + 10;
      } else if (normalized >= 0.47 && normalized < 0.51) {
        y = midY - 24;
      } else if (normalized >= 0.51 && normalized < 0.55) {
        y = midY + 16;
      } else if (normalized >= 0.55 && normalized < 0.62) {
        y = midY - 6;
      }
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant EcgWavePainter oldDelegate) =>
      oldDelegate.phase != phase;
}
