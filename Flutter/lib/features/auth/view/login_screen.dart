import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/function/navigation.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/theme/bio_orbit_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../orbit_hub/cubit/bio_orbit_cubit.dart';
import '../../orbit_hub/view/bio_orbit_layout.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Empty controllers so the user types their own username and password after logout
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: BioOrbitColors.warningAmber,
          content: Text(
            AppStrings.isAr(context)
                ? 'يرجى إدخال اسم المستخدم وكلمة المرور أولاً'
                : 'Please enter your username and password first',
            style: const TextStyle(
              color: BioOrbitColors.spaceDeepBg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      return;
    }

    final success = await context.read<AuthCubit>().loginOrRegister(
      username: username,
      password: password,
      isRegister: _isRegisterMode,
    );

    if (success && mounted) {
      context.read<BioOrbitCubit>().initializeDashboard();
      AppNavigator.pushAndRemoveUntil(context, const BioOrbitLayout());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isDoctor = authState.role == 'Doctor';
        final accent = isDoctor
            ? BioOrbitColors.medicalPulseGreen
            : BioOrbitColors.orbitalCyan;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isRegisterMode
                  ? AppStrings.tr(context, 'register_title')
                  : AppStrings.tr(context, 'login_title'),
            ),
            actions: [
              TextButton(
                onPressed: () => context.read<LocaleCubit>().toggleLanguage(),
                child: Text(
                  AppStrings.tr(context, 'change_lang'),
                  style: const TextStyle(color: BioOrbitColors.orbitalCyan),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 14.h,
                    horizontal: 18.w,
                  ),
                  decoration: BoxDecoration(
                    color: BioOrbitColors.spaceSecondaryBg,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: accent.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isDoctor
                            ? Icons.medical_services_rounded
                            : Icons.rocket_launch_rounded,
                        color: accent,
                        size: 22.r,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        isDoctor
                            ? AppStrings.tr(context, 'role_doctor')
                            : AppStrings.tr(context, 'role_astro'),
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28.h),
                TextField(
                  controller: _usernameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: AppStrings.tr(context, 'username'),
                    hintText: AppStrings.isAr(context)
                        ? 'أدخل اسم المستخدم الخاص بك'
                        : 'Enter your username',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: AppStrings.tr(context, 'password'),
                    hintText: AppStrings.isAr(context)
                        ? 'أدخل كلمة المرور'
                        : 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (authState.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BioOrbitColors.emergencyRed.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: BioOrbitColors.emergencyRed),
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: const TextStyle(
                        color: BioOrbitColors.emergencyRed,
                      ),
                    ),
                  ),
                CustomButton(
                  text: _isRegisterMode
                      ? AppStrings.tr(context, 'register_btn')
                      : AppStrings.tr(context, 'login_btn'),
                  isLoading: authState.isLoading,
                  backgroundColor: accent,
                  onPressed: _submit,
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () {
                    context.read<AuthCubit>().clearError();
                    setState(() {
                      _isRegisterMode = !_isRegisterMode;
                    });
                  },
                  child: Text(
                    _isRegisterMode
                        ? AppStrings.tr(context, 'switch_to_login')
                        : AppStrings.tr(context, 'switch_to_register'),
                    style: const TextStyle(color: BioOrbitColors.orbitalCyan),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
