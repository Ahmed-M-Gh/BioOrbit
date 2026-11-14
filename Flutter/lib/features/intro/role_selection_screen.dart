import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/function/navigation.dart';
import '../../core/localization/app_strings.dart';
import '../../core/localization/locale_cubit.dart';
import '../../core/theme/bio_orbit_colors.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/view/login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BioOrbit'),
        actions: [
          TextButton.icon(
            onPressed: () => context.read<LocaleCubit>().toggleLanguage(),
            icon: const Icon(Icons.language, color: BioOrbitColors.orbitalCyan),
            label: Text(
              AppStrings.tr(context, 'change_lang'),
              style: const TextStyle(
                color: BioOrbitColors.orbitalCyan,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(22.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 12.h),
              Text(
                AppStrings.tr(context, 'select_role_title'),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: BioOrbitColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                AppStrings.tr(context, 'select_role_sub'),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: BioOrbitColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              _RoleCard(
                roleCode: 'Astro',
                title: AppStrings.tr(context, 'role_astro'),
                description: AppStrings.tr(context, 'role_astro_desc'),
                icon: Icons.rocket_launch_rounded,
                accentColor: BioOrbitColors.orbitalCyan,
              ),
              SizedBox(height: 20.h),
              _RoleCard(
                roleCode: 'Doctor',
                title: AppStrings.tr(context, 'role_doctor'),
                description: AppStrings.tr(context, 'role_doctor_desc'),
                icon: Icons.medical_services_rounded,
                accentColor: BioOrbitColors.medicalPulseGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String roleCode;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const _RoleCard({
    required this.roleCode,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: () async {
        await context.read<AuthCubit>().selectRole(roleCode);
        if (context.mounted) {
          AppNavigator.push(context, const LoginScreen());
        }
      },
      child: Container(
        padding: EdgeInsets.all(22.r),
        decoration: BoxDecoration(
          color: BioOrbitColors.spaceCardBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: accentColor.withOpacity(0.55), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36.r, color: accentColor),
            ),
            SizedBox(width: 18.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: BioOrbitColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: accentColor,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}
