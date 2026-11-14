import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../data/telemetry_model.dart';

class BioOrbitState {
  // الـ 6 قراءات الرسمية المعتمدة في ملف BioOrbit_4.json (Health Records)
  final int heartRate;
  final int systolic;
  final int diastolic;
  final double bloodSugar;
  final double bodyTemperature;
  final double sleepHours;
  final int fatigueLevel;

  // Tab 3: Image & AI Facial Biometrics Measurements (`Image To AI` & `Matrics To AI`)
  final XFile? selectedImage;
  final Uint8List? selectedImageBytes;
  final String? uploadedImageUrl;
  final String? lastRecordId;
  final String? aiMetricsAnalysis;
  final String? aiImageAnalysis;
  final FacialMeasurementsModel facialMeasurements;

  // Tab 4: Weekly Reports & Records from Backend (`Weekly Reports` & `Health Recrods`)
  final WeeklyReportModel weeklyReport;
  final List<HealthRecordModel> myRecords;
  final List<Map<String, String>> doctorAstroNotes;

  // Loading & Sync Flags
  final bool isLoadingInitialData;
  final bool isSubmitting;
  final bool hasSyncedBackendData;
  final String? statusBanner;
  final bool isErrorBanner;

  const BioOrbitState({
    this.heartRate = 75,
    this.systolic = 120,
    this.diastolic = 80,
    this.bloodSugar = 95.0,
    this.bodyTemperature = 36.8,
    this.sleepHours = 8.0,
    this.fatigueLevel = 3,
    this.selectedImage,
    this.selectedImageBytes,
    this.uploadedImageUrl,
    this.lastRecordId,
    this.aiMetricsAnalysis,
    this.aiImageAnalysis,
    this.facialMeasurements = const FacialMeasurementsModel(),
    this.weeklyReport = const WeeklyReportModel(),
    this.myRecords = const [],
    this.doctorAstroNotes = const [],
    this.isLoadingInitialData = false,
    this.isSubmitting = false,
    this.hasSyncedBackendData = false,
    this.statusBanner,
    this.isErrorBanner = false,
  });

  BioOrbitState copyWith({
    int? heartRate,
    int? systolic,
    int? diastolic,
    double? bloodSugar,
    double? bodyTemperature,
    double? sleepHours,
    int? fatigueLevel,
    XFile? selectedImage,
    Uint8List? selectedImageBytes,
    String? uploadedImageUrl,
    String? lastRecordId,
    String? aiMetricsAnalysis,
    String? aiImageAnalysis,
    FacialMeasurementsModel? facialMeasurements,
    WeeklyReportModel? weeklyReport,
    List<HealthRecordModel>? myRecords,
    List<Map<String, String>>? doctorAstroNotes,
    bool? isLoadingInitialData,
    bool? isSubmitting,
    bool? hasSyncedBackendData,
    String? statusBanner,
    bool? isErrorBanner,
  }) {
    return BioOrbitState(
      heartRate: heartRate ?? this.heartRate,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      bodyTemperature: bodyTemperature ?? this.bodyTemperature,
      sleepHours: sleepHours ?? this.sleepHours,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      selectedImage: selectedImage ?? this.selectedImage,
      selectedImageBytes: selectedImageBytes ?? this.selectedImageBytes,
      uploadedImageUrl: uploadedImageUrl ?? this.uploadedImageUrl,
      lastRecordId: lastRecordId ?? this.lastRecordId,
      aiMetricsAnalysis: aiMetricsAnalysis ?? this.aiMetricsAnalysis,
      aiImageAnalysis: aiImageAnalysis ?? this.aiImageAnalysis,
      facialMeasurements: facialMeasurements ?? this.facialMeasurements,
      weeklyReport: weeklyReport ?? this.weeklyReport,
      myRecords: myRecords ?? this.myRecords,
      doctorAstroNotes: doctorAstroNotes ?? this.doctorAstroNotes,
      isLoadingInitialData: isLoadingInitialData ?? this.isLoadingInitialData,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasSyncedBackendData: hasSyncedBackendData ?? this.hasSyncedBackendData,
      statusBanner: statusBanner,
      isErrorBanner: isErrorBanner ?? this.isErrorBanner,
    );
  }
}
