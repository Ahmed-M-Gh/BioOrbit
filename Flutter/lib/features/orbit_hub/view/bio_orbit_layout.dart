import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/cache/cache_helper.dart';
import '../../../core/function/navigation.dart';
import '../../../core/function/responsive_utils.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/theme/bio_orbit_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../intro/role_selection_screen.dart';
import '../cubit/bio_orbit_cubit.dart';
import '../cubit/bio_orbit_state.dart';

class BioOrbitLayout extends StatefulWidget {
  const BioOrbitLayout({super.key});

  @override
  State<BioOrbitLayout> createState() => _BioOrbitLayoutState();
}

class _BioOrbitLayoutState extends State<BioOrbitLayout>
    with WidgetsBindingObserver {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = CacheHelper.savedTabIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<BioOrbitCubit>();
      cubit.checkAndRecoverCameraImage();
      cubit.fetchMyRecordsAndWeeklyReports(showBanner: false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<BioOrbitCubit>().checkAndRecoverCameraImage();
      if (CacheHelper.savedTabIndex == 2 && _currentIndex != 2) {
        setState(() {
          _currentIndex = 2;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = CacheHelper.crewRole;
    final name = CacheHelper.crewName ?? 'Crew';

    final tabs = const [
      VitalsMicrogravityTab(),
      PsychSleepTab(),
      PhotoAiScannerTab(),
      DoctorAstroReportsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.monitor_heart_rounded,
              color: BioOrbitColors.medicalPulseGreen,
              size: 22.r,
            ),
            SizedBox(width: 8.w),
            Text(
              'BioOrbit',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: BioOrbitColors.orbitalCyan.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: BioOrbitColors.orbitalCyan),
                ),
                child: Text(
                  '$name • $role',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: BioOrbitColors.orbitalCyan,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.tr(context, 'refresh_reports'),
            onPressed: () =>
                context.read<BioOrbitCubit>().fetchMyRecordsAndWeeklyReports(),
            icon: Icon(
              Icons.sync_rounded,
              color: BioOrbitColors.medicalPulseGreen,
              size: 22.r,
            ),
          ),
          IconButton(
            tooltip: AppStrings.tr(context, 'change_lang'),
            onPressed: () => context.read<LocaleCubit>().toggleLanguage(),
            icon: Icon(
              Icons.translate_rounded,
              color: BioOrbitColors.orbitalCyan,
              size: 22.r,
            ),
          ),
        ],
      ),
      body: BlocBuilder<BioOrbitCubit, BioOrbitState>(
        builder: (context, state) {
          return Column(
            children: [
              if (state.isLoadingInitialData)
                const LinearProgressIndicator(
                  color: BioOrbitColors.orbitalCyan,
                  backgroundColor: BioOrbitColors.spaceSecondaryBg,
                ),
              if (state.statusBanner != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  color: state.isErrorBanner
                      ? BioOrbitColors.emergencyRed.withOpacity(0.2)
                      : BioOrbitColors.medicalPulseGreen.withOpacity(0.18),
                  child: Row(
                    children: [
                      Icon(
                        state.isErrorBanner
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline_rounded,
                        color: state.isErrorBanner
                            ? BioOrbitColors.emergencyRed
                            : BioOrbitColors.medicalPulseGreen,
                        size: 18.r,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          state.statusBanner!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: tabs[_currentIndex]),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: BioOrbitColors.spaceSecondaryBg,
          border: Border(
            top: BorderSide(
              color: BioOrbitColors.orbitalCyan.withOpacity(0.18),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _CenteredBottomNavItem(
                  index: 0,
                  currentIndex: _currentIndex,
                  icon: Icons.favorite_border_rounded,
                  selectedIcon: Icons.favorite_rounded,
                  activeColor: BioOrbitColors.medicalPulseGreen,
                  label: AppStrings.tr(context, 'tab_vitals'),
                  onTap: _onTabSelected,
                ),
                _CenteredBottomNavItem(
                  index: 1,
                  currentIndex: _currentIndex,
                  icon: Icons.nights_stay_outlined,
                  selectedIcon: Icons.nights_stay_rounded,
                  activeColor: BioOrbitColors.boneAiPurple,
                  label: AppStrings.tr(context, 'tab_psych'),
                  onTap: _onTabSelected,
                ),
                _CenteredBottomNavItem(
                  index: 2,
                  currentIndex: _currentIndex,
                  icon: Icons.face_retouching_natural_rounded,
                  selectedIcon: Icons.face_retouching_natural_rounded,
                  activeColor: BioOrbitColors.orbitalCyan,
                  label: AppStrings.isAr(context) ? 'قياسات الوجه' : 'Face AI',
                  onTap: _onTabSelected,
                ),
                _CenteredBottomNavItem(
                  index: 3,
                  currentIndex: _currentIndex,
                  icon: Icons.assignment_ind_outlined,
                  selectedIcon: Icons.assignment_ind_rounded,
                  activeColor: BioOrbitColors.warningAmber,
                  label: AppStrings.isAr(context) ? 'التقارير' : 'Reports',
                  onTap: _onTabSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTabSelected(int idx) {
    CacheHelper.setSavedTabIndex(idx);
    setState(() => _currentIndex = idx);
  }
}

class _CenteredBottomNavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData selectedIcon;
  final Color activeColor;
  final String label;
  final ValueChanged<int> onTap;

  const _CenteredBottomNavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.selectedIcon,
    required this.activeColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == currentIndex;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(14.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withOpacity(0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? activeColor : BioOrbitColors.textSecondary,
                size: 22.r,
              ),
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? activeColor
                      : BioOrbitColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 1: Official BioOrbit_4.json Vitals (`heartRate`, `bloodPressure`, `bloodSugar`, `bodyTemperature`)
// ============================================================================
class VitalsMicrogravityTab extends StatelessWidget {
  const VitalsMicrogravityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = AppStrings.isAr(context);

    return BlocBuilder<BioOrbitCubit, BioOrbitState>(
      builder: (context, state) {
        final cubit = context.read<BioOrbitCubit>();

        return RefreshIndicator(
          color: BioOrbitColors.orbitalCyan,
          onRefresh: () => cubit.fetchMyRecordsAndWeeklyReports(),
          child: ListView(
            padding: ResponsiveUtils.screenPadding,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                margin: EdgeInsets.only(bottom: 14.h),
                decoration: BoxDecoration(
                  color: BioOrbitColors.spaceSecondaryBg,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: BioOrbitColors.orbitalCyan.withOpacity(0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_done_rounded,
                      color: BioOrbitColors.orbitalCyan,
                      size: 20.r,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        state.myRecords.isNotEmpty
                            ? (isAr
                                  ? 'القراءات مسحوبة مباشرة من السيرفر (${state.myRecords.length} سجلات محفوظة).'
                                  : 'Readings synced directly from Backend (${state.myRecords.length} saved records).')
                            : (isAr
                                  ? 'أدخل القراءات الحيوية واضغط حفظ لإرسالها إلى السيرفر.'
                                  : 'Adjust vital readings and tap Save to send to Backend.'),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: BioOrbitColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _SectionHeader(
                title: AppStrings.tr(context, 'vitals_header'),
                icon: Icons.monitor_heart_rounded,
                color: BioOrbitColors.medicalPulseGreen,
              ),
              SizedBox(height: 10.h),
              _VitalControlCard(
                title: AppStrings.tr(context, 'heart_rate'),
                valueDisplay: '${state.heartRate} BPM',
                isNormal: state.heartRate >= 55 && state.heartRate <= 100,
                accentColor: BioOrbitColors.medicalPulseGreen,
                onDecrement: () => cubit.updateHeartRate(state.heartRate - 2),
                onIncrement: () => cubit.updateHeartRate(state.heartRate + 2),
                presets: const [65, 75, 85, 100],
                onPresetSelected: (v) => cubit.updateHeartRate(v.toInt()),
              ),
              SizedBox(height: 12.h),
              _BloodPressureCard(
                systolic: state.systolic,
                diastolic: state.diastolic,
                onChanged: (sys, dia) =>
                    cubit.updateBloodPressure(systolic: sys, diastolic: dia),
              ),
              SizedBox(height: 12.h),
              _VitalControlCard(
                title: AppStrings.tr(context, 'blood_sugar'),
                valueDisplay: '${state.bloodSugar.toInt()} mg/dL',
                isNormal: state.bloodSugar >= 70 && state.bloodSugar <= 125,
                accentColor: BioOrbitColors.orbitalCyan,
                onDecrement: () => cubit.updateBloodSugar(state.bloodSugar - 5),
                onIncrement: () => cubit.updateBloodSugar(state.bloodSugar + 5),
                presets: const [85, 95, 110, 130],
                onPresetSelected: (v) => cubit.updateBloodSugar(v.toDouble()),
              ),
              SizedBox(height: 12.h),
              _VitalControlCard(
                title: AppStrings.tr(context, 'body_temp'),
                valueDisplay: '${state.bodyTemperature.toStringAsFixed(1)} °C',
                isNormal:
                    state.bodyTemperature >= 36.1 &&
                    state.bodyTemperature <= 37.4,
                accentColor: BioOrbitColors.medicalPulseGreen,
                onDecrement: () =>
                    cubit.updateBodyTemp(state.bodyTemperature - 0.1),
                onIncrement: () =>
                    cubit.updateBodyTemp(state.bodyTemperature + 0.1),
                presets: const [36.5, 36.8, 37.0, 37.5],
                onPresetSelected: (v) => cubit.updateBodyTemp(v.toDouble()),
              ),
              SizedBox(height: 20.h),
              CustomButton(
                text: AppStrings.tr(context, 'save_vitals_btn'),
                icon: Icons.cloud_upload_rounded,
                backgroundColor: BioOrbitColors.medicalPulseGreen,
                isLoading: state.isSubmitting,
                onPressed: () => cubit.createHealthRecordOnBackend(),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }
}

class _VitalControlCard extends StatelessWidget {
  final String title;
  final String valueDisplay;
  final bool isNormal;
  final Color accentColor;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final List<num> presets;
  final ValueChanged<num> onPresetSelected;

  const _VitalControlCard({
    required this.title,
    required this.valueDisplay,
    required this.isNormal,
    required this.accentColor,
    required this.onDecrement,
    required this.onIncrement,
    required this.presets,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isNormal
        ? BioOrbitColors.medicalPulseGreen
        : BioOrbitColors.warningAmber;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    isNormal
                        ? AppStrings.tr(context, 'status_normal')
                        : AppStrings.tr(context, 'status_warning'),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: BioOrbitColors.spaceSecondaryBg,
                  ),
                  onPressed: onDecrement,
                  icon: Icon(
                    Icons.remove,
                    color: BioOrbitColors.orbitalCyan,
                    size: 20.r,
                  ),
                ),
                Text(
                  valueDisplay,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: BioOrbitColors.spaceSecondaryBg,
                  ),
                  onPressed: onIncrement,
                  icon: Icon(
                    Icons.add,
                    color: BioOrbitColors.orbitalCyan,
                    size: 20.r,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: presets.map((preset) {
                return ActionChip(
                  backgroundColor: BioOrbitColors.spaceSecondaryBg,
                  side: BorderSide(color: accentColor.withOpacity(0.4)),
                  label: Text(
                    preset.toString(),
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  onPressed: () => onPresetSelected(preset),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BloodPressureCard extends StatelessWidget {
  final int systolic;
  final int diastolic;
  final void Function(int sys, int dia) onChanged;

  const _BloodPressureCard({
    required this.systolic,
    required this.diastolic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNormal =
        systolic >= 95 && systolic <= 130 && diastolic >= 60 && diastolic <= 85;
    final statusColor = isNormal
        ? BioOrbitColors.medicalPulseGreen
        : BioOrbitColors.warningAmber;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.tr(context, 'blood_pressure'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    isNormal
                        ? AppStrings.tr(context, 'status_normal')
                        : AppStrings.tr(context, 'status_warning'),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Systolic',
                      style: TextStyle(
                        color: BioOrbitColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => onChanged(systolic - 2, diastolic),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(
                          '$systolic',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: BioOrbitColors.orbitalCyan,
                          ),
                        ),
                        IconButton(
                          onPressed: () => onChanged(systolic + 2, diastolic),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ],
                ),
                Text('/', style: TextStyle(fontSize: 26.sp)),
                Column(
                  children: [
                    Text(
                      'Diastolic',
                      style: TextStyle(
                        color: BioOrbitColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => onChanged(systolic, diastolic - 2),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(
                          '$diastolic',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: BioOrbitColors.medicalPulseGreen,
                          ),
                        ),
                        IconButton(
                          onPressed: () => onChanged(systolic, diastolic + 2),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Wrap(
              spacing: 8.w,
              children: [
                ActionChip(
                  label: Text('115 / 75', style: TextStyle(fontSize: 12.sp)),
                  onPressed: () => onChanged(115, 75),
                ),
                ActionChip(
                  label: Text('120 / 80', style: TextStyle(fontSize: 12.sp)),
                  onPressed: () => onChanged(120, 80),
                ),
                ActionChip(
                  label: Text('130 / 85', style: TextStyle(fontSize: 12.sp)),
                  onPressed: () => onChanged(130, 85),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 2: Official BioOrbit_4.json Sleep & Fatigue (`sleepHours`, `fatigueLevel`)
// ============================================================================
class PsychSleepTab extends StatelessWidget {
  const PsychSleepTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = AppStrings.isAr(context);

    return BlocBuilder<BioOrbitCubit, BioOrbitState>(
      builder: (context, state) {
        final cubit = context.read<BioOrbitCubit>();

        return ListView(
          padding: ResponsiveUtils.screenPadding,
          children: [
            _SectionHeader(
              title: isAr
                  ? 'مؤشرات النوم والإرهاق (BioOrbit Health Record)'
                  : 'Sleep & Fatigue Telemetry (BioOrbit Health Record)',
              icon: Icons.nights_stay_rounded,
              color: BioOrbitColors.boneAiPurple,
            ),
            SizedBox(height: 12.h),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppStrings.tr(context, 'sleep_hours'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        Text(
                          '${state.sleepHours} h',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: BioOrbitColors.orbitalCyan,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: state.sleepHours.clamp(1.0, 12.0),
                      min: 1,
                      max: 12,
                      divisions: 22,
                      activeColor: BioOrbitColors.orbitalCyan,
                      onChanged: cubit.updateSleepHours,
                    ),
                    Wrap(
                      spacing: 8.w,
                      children: [6, 7, 8, 9].map((h) {
                        return ActionChip(
                          label: Text(
                            '$h h',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          onPressed: () => cubit.updateSleepHours(h.toDouble()),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppStrings.tr(context, 'fatigue_level'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        Text(
                          '${state.fatigueLevel} / 10',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: state.fatigueLevel <= 5
                                ? BioOrbitColors.medicalPulseGreen
                                : BioOrbitColors.warningAmber,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: state.fatigueLevel.toDouble().clamp(1.0, 10.0),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: state.fatigueLevel <= 5
                          ? BioOrbitColors.medicalPulseGreen
                          : BioOrbitColors.warningAmber,
                      onChanged: (v) => cubit.updateFatigueLevel(v.round()),
                    ),
                    Wrap(
                      spacing: 8.w,
                      children: [2, 3, 5, 7].map((f) {
                        return ActionChip(
                          label: Text(
                            '$f / 10',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          onPressed: () => cubit.updateFatigueLevel(f),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            CustomButton(
              text: AppStrings.tr(context, 'save_vitals_btn'),
              icon: Icons.cloud_upload_rounded,
              backgroundColor: BioOrbitColors.orbitalCyan,
              isLoading: state.isSubmitting,
              onPressed: () => cubit.createHealthRecordOnBackend(),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// TAB 3: AI Facial Landmarks & Measurements Scanner (`Upload Image` + `Image To AI` + `Matrics To AI`)
// ============================================================================
class PhotoAiScannerTab extends StatelessWidget {
  const PhotoAiScannerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BioOrbitCubit, BioOrbitState>(
      builder: (context, state) {
        final cubit = context.read<BioOrbitCubit>();
        final isAr = AppStrings.isAr(context);

        return ListView(
          padding: ResponsiveUtils.screenPadding,
          children: [
            _SectionHeader(
              title: isAr
                  ? 'ماسح قياسات الوجه بالذكاء الاصطناعي (Facial Biometrics AI)'
                  : 'AI Facial Biometrics & Measurements Scanner',
              icon: Icons.face_retouching_natural_rounded,
              color: BioOrbitColors.orbitalCyan,
            ),
            SizedBox(height: 12.h),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    Container(
                      height: 235.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: BioOrbitColors.spaceSecondaryBg,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: BioOrbitColors.orbitalCyan.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (state.selectedImageBytes != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14.r),
                              child: Image.memory(
                                state.selectedImageBytes!,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                                cacheWidth: 600,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    isAr
                                        ? 'تعذر عرض معاينة الصورة'
                                        : 'Could not preview photo',
                                  ),
                                ),
                              ),
                            )
                          else if (state.uploadedImageUrl != null &&
                              state.uploadedImageUrl!.startsWith('http'))
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14.r),
                              child: Image.network(
                                state.uploadedImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox(),
                              ),
                            )
                          else
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.face_retouching_natural_rounded,
                                  size: 56.r,
                                  color: BioOrbitColors.orbitalCyan,
                                ),
                                SizedBox(height: 10.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  child: Text(
                                    isAr
                                        ? 'التقط صورة الوجه فقط بالكاميرا الأمامية أو المعرض ليتم إرسالها للـ AI ليقوم بقياس ملامح الوجه'
                                        : 'Capture a face photo from camera or gallery to send to the AI model for facial measurements',
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      color: BioOrbitColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          IgnorePointer(
                            child: CustomPaint(
                              painter: FacialBiometricFramePainter(
                                hasImage: state.selectedImageBytes != null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.uploadedImageUrl != null &&
                        state.uploadedImageUrl!.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: BioOrbitColors.spaceSecondaryBg,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: BioOrbitColors.orbitalCyan.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.link_rounded,
                              size: 16.r,
                              color: BioOrbitColors.orbitalCyan,
                            ),
                            SizedBox(width: 6.w),
                            Flexible(
                              child: SelectableText(
                                state.uploadedImageUrl!,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: BioOrbitColors.orbitalCyan,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: state.isSubmitting
                                ? null
                                : () => cubit.pickMedicalImage(
                                    ImageSource.camera,
                                  ),
                            icon: Icon(Icons.camera_front_rounded, size: 18.r),
                            label: Text(
                              isAr ? 'تصوير الوجه' : 'Face Camera',
                              style: TextStyle(fontSize: 13.sp),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: state.isSubmitting
                                ? null
                                : () => cubit.pickMedicalImage(
                                    ImageSource.gallery,
                                  ),
                            icon: Icon(Icons.photo_library_rounded, size: 18.r),
                            label: Text(
                              AppStrings.tr(context, 'pick_gallery'),
                              style: TextStyle(fontSize: 13.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),
            CustomButton(
              text: isAr
                  ? 'إرسال صورة الوجه للـ AI لقياسها وتحليل الـ ECG'
                  : 'Send Face Photo to AI for Measurement & ECG Analysis',
              icon: Icons.center_focus_strong_rounded,
              backgroundColor: BioOrbitColors.boneAiPurple,
              foregroundColor: Colors.white,
              isLoading: state.isSubmitting,
              onPressed: () => cubit.runFullAiSpaceDiagnosisPipeline(),
            ),
            SizedBox(height: 18.h),

            if (state.facialMeasurements.hasMeasurements ||
                state.aiImageAnalysis != null)
              Card(
                margin: EdgeInsets.only(bottom: 12.h),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.face_retouching_natural_rounded,
                            color: BioOrbitColors.orbitalCyan,
                            size: 22.r,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              isAr
                                  ? 'قياسات الوجه من موديل الـ AI (Image To AI)'
                                  : 'AI Facial Measurements (Image To AI)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: BioOrbitColors.orbitalCyan,
                                fontSize: 14.5.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      if (state.facialMeasurements.summaryStatus.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10.r),
                          margin: EdgeInsets.only(bottom: 10.h),
                          decoration: BoxDecoration(
                            color: BioOrbitColors.medicalPulseGreen.withOpacity(
                              0.12,
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: BioOrbitColors.medicalPulseGreen
                                  .withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            state.facialMeasurements.summaryStatus,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.bold,
                              color: BioOrbitColors.medicalPulseGreen,
                            ),
                          ),
                        ),
                      if (state.facialMeasurements.measurements.isNotEmpty)
                        ...state.facialMeasurements.measurements.entries.map(
                          (entry) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      color: BioOrbitColors.textSecondary,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child: Text(
                                    entry.value,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: BioOrbitColors.textPrimary,
                                      fontSize: 13.5.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (state.aiImageAnalysis != null)
                        Text(
                          state.aiImageAnalysis!,
                          style: TextStyle(height: 1.5, fontSize: 13.5.sp),
                        ),
                    ],
                  ),
                ),
              ),

            if (state.aiMetricsAnalysis != null)
              _AiOutputCard(
                title: isAr
                    ? 'تحليل تخطيط القلب (ECG) والحالة الحيوية (Matrics To AI)'
                    : 'ECG Waveform & Vital Status Explanation (Matrics To AI)',
                content: state.aiMetricsAnalysis!,
                accent: BioOrbitColors.medicalPulseGreen,
              ),
            if (state.weeklyReport.aiMedicalSummary.isNotEmpty)
              _AiOutputCard(
                title: isAr
                    ? 'التقرير الطبي الأسبوعي (7 records to AI)'
                    : 'Weekly AI Medical Summary (7 records to AI)',
                content: state.weeklyReport.aiMedicalSummary,
                accent: BioOrbitColors.boneAiPurple,
              ),
            if (state.weeklyReport.carePlanRecommendations.isNotEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.tr(context, 'care_plan'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: BioOrbitColors.warningAmber,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      ...state.weeklyReport.carePlanRecommendations.map(
                        (rec) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: BioOrbitColors.medicalPulseGreen,
                                size: 18.r,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  rec,
                                  style: TextStyle(fontSize: 13.5.sp),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class FacialBiometricFramePainter extends CustomPainter {
  final bool hasImage;
  const FacialBiometricFramePainter({required this.hasImage});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BioOrbitColors.orbitalCyan.withOpacity(hasImage ? 0.55 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final center = Offset(size.width / 2, size.height / 2);
    final rx = size.width * 0.26;
    final ry = size.height * 0.36;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      paint,
    );

    final axisPaint = Paint()
      ..color = BioOrbitColors.medicalPulseGreen.withOpacity(
        hasImage ? 0.45 : 0.18,
      )
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(center.dx - rx * 0.75, center.dy - ry * 0.2),
      Offset(center.dx + rx * 0.75, center.dy - ry * 0.2),
      axisPaint,
    );
    canvas.drawLine(
      Offset(center.dx - rx * 0.45, center.dy + ry * 0.42),
      Offset(center.dx + rx * 0.45, center.dy + ry * 0.42),
      axisPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - ry * 0.85),
      Offset(center.dx, center.dy + ry * 0.85),
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(covariant FacialBiometricFramePainter oldDelegate) =>
      oldDelegate.hasImage != hasImage;
}

class _AiOutputCard extends StatelessWidget {
  final String title;
  final String content;
  final Color accent;

  const _AiOutputCard({
    required this.title,
    required this.content,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.health_and_safety_rounded,
                  color: accent,
                  size: 22.r,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accent,
                      fontSize: 14.5.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(content, style: TextStyle(height: 1.5, fontSize: 13.5.sp)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 4: Space Doctor Link, Live Backend History & Weekly Reports
// ============================================================================
class DoctorAstroReportsTab extends StatefulWidget {
  const DoctorAstroReportsTab({super.key});

  @override
  State<DoctorAstroReportsTab> createState() => _DoctorAstroReportsTabState();
}

class _DoctorAstroReportsTabState extends State<DoctorAstroReportsTab> {
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = AppStrings.isAr(context);

    return BlocBuilder<BioOrbitCubit, BioOrbitState>(
      builder: (context, state) {
        final cubit = context.read<BioOrbitCubit>();
        final report = state.weeklyReport;

        return RefreshIndicator(
          color: BioOrbitColors.orbitalCyan,
          onRefresh: () => cubit.fetchMyRecordsAndWeeklyReports(),
          child: ListView(
            padding: ResponsiveUtils.screenPadding,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _SectionHeader(
                      title: AppStrings.tr(context, 'weekly_averages'),
                      icon: Icons.analytics_rounded,
                      color: BioOrbitColors.orbitalCyan,
                    ),
                  ),
                  IconButton(
                    tooltip: AppStrings.tr(context, 'refresh_reports'),
                    onPressed: () => cubit.fetchMyRecordsAndWeeklyReports(),
                    icon: Icon(
                      Icons.sync_rounded,
                      color: BioOrbitColors.medicalPulseGreen,
                      size: 22.r,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: report.hasBackendData
                      ? Column(
                          children: [
                            _MetricRow(
                              label: isAr
                                  ? 'متوسط نبض القلب'
                                  : 'Avg Heart Rate',
                              value:
                                  '${report.avgHeartRate.toStringAsFixed(0)} BPM',
                              color: BioOrbitColors.medicalPulseGreen,
                            ),
                            const Divider(),
                            _MetricRow(
                              label: isAr
                                  ? 'متوسط ساعات النوم'
                                  : 'Avg Sleep Hours',
                              value:
                                  '${report.avgSleepHours.toStringAsFixed(1)} h',
                              color: BioOrbitColors.orbitalCyan,
                            ),
                            const Divider(),
                            _MetricRow(
                              label: isAr
                                  ? 'إجمالي التمارين الأسبوعية'
                                  : 'Total Weekly Exercise',
                              value: '${report.totalExerciseMinutes} min',
                              color: BioOrbitColors.boneAiPurple,
                            ),
                            const Divider(),
                            _MetricRow(
                              label: isAr ? 'أعلى مستوى إرهاق' : 'Peak Fatigue',
                              value: '${report.highestFatigueLevel} / 10',
                              color: BioOrbitColors.warningAmber,
                            ),
                            const Divider(),
                            _MetricRow(
                              label: isAr ? 'الحالة الذهنية' : 'Mental Status',
                              value: report.predominantMentalStatus.isNotEmpty
                                  ? report.predominantMentalStatus
                                  : '--',
                              color: BioOrbitColors.medicalPulseGreen,
                            ),
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: Text(
                            isAr
                                ? 'لا توجد تقارير أسبوعية مسجلة في السيرفر حتى الآن. قم بحفظ قراءاتك أو اضغط زر التحديث.'
                                : 'No weekly reports found on server yet. Save your readings or tap refresh.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: BioOrbitColors.textSecondary,
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(height: 18.h),
              _SectionHeader(
                title: isAr
                    ? 'سجل القراءات المحفوظة في الباك إند (${state.myRecords.length})'
                    : 'Saved Backend Health Records (${state.myRecords.length})',
                icon: Icons.history_edu_rounded,
                color: BioOrbitColors.boneAiPurple,
              ),
              SizedBox(height: 10.h),
              if (state.myRecords.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Text(
                      isAr
                          ? 'لم يتم تسجيل قراءات سابقة على الباك إند لهذا الحساب.'
                          : 'No health records saved on the Backend for this account yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: BioOrbitColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ...state.myRecords
                    .take(5)
                    .map(
                      (rec) => Card(
                        margin: EdgeInsets.only(bottom: 8.h),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: BioOrbitColors.medicalPulseGreen
                                .withOpacity(0.18),
                            child: Icon(
                              Icons.favorite_rounded,
                              color: BioOrbitColors.medicalPulseGreen,
                              size: 18.r,
                            ),
                          ),
                          title: Text(
                            'HR: ${rec.heartRate} BPM • BP: ${rec.systolic}/${rec.diastolic}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5.sp,
                            ),
                          ),
                          subtitle: Text(
                            'Sugar: ${rec.bloodSugar.toInt()} mg/dL • Temp: ${rec.bodyTemperature}°C • Sleep: ${rec.sleepHours}h',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 18.h),
              _SectionHeader(
                title: AppStrings.tr(context, 'doctor_notes_title'),
                icon: Icons.forum_rounded,
                color: BioOrbitColors.medicalPulseGreen,
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _noteCtrl,
                      decoration: InputDecoration(
                        hintText: AppStrings.tr(context, 'add_note_hint'),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BioOrbitColors.orbitalCyan,
                      foregroundColor: BioOrbitColors.spaceDeepBg,
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 16.h,
                      ),
                    ),
                    onPressed: () {
                      cubit.addDoctorAstroNote(_noteCtrl.text);
                      _noteCtrl.clear();
                    },
                    child: Text(
                      AppStrings.tr(context, 'send_note'),
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ...state.doctorAstroNotes.map(
                (note) => Card(
                  margin: EdgeInsets.only(bottom: 8.h),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: note['role'] == 'Doctor'
                          ? BioOrbitColors.medicalPulseGreen.withOpacity(0.2)
                          : BioOrbitColors.orbitalCyan.withOpacity(0.2),
                      child: Icon(
                        note['role'] == 'Doctor'
                            ? Icons.medical_services_rounded
                            : Icons.rocket_launch_rounded,
                        color: note['role'] == 'Doctor'
                            ? BioOrbitColors.medicalPulseGreen
                            : BioOrbitColors.orbitalCyan,
                        size: 20.r,
                      ),
                    ),
                    title: Text(
                      note['sender'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    subtitle: Text(
                      note['note'] ?? '',
                      style: TextStyle(fontSize: 12.5.sp),
                    ),
                    trailing: Text(
                      note['time'] ?? '',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: BioOrbitColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.read<LocaleCubit>().toggleLanguage(),
                      icon: Icon(Icons.language_rounded, size: 18.r),
                      label: Text(
                        AppStrings.tr(context, 'change_lang'),
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BioOrbitColors.emergencyRed,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        context.read<BioOrbitCubit>().clearSessionState();
                        await context.read<AuthCubit>().logout();
                        if (context.mounted) {
                          AppNavigator.pushAndRemoveUntil(
                            context,
                            const RoleSelectionScreen(),
                          );
                        }
                      },
                      icon: Icon(Icons.logout_rounded, size: 18.r),
                      label: Text(
                        AppStrings.tr(context, 'logout'),
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: BioOrbitColors.textSecondary,
              fontSize: 13.sp,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 13.5.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22.r),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
