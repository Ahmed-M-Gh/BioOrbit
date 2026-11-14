import '../../../core/network/endpoints.dart';

/// موديل قياسات الوجه الطبية المستخرجة مباشرة من موديل الـ AI فقط (`GET /health-records/:recordId/ai/image`)
class FacialMeasurementsModel {
  final String summaryStatus;
  final Map<String, String> measurements;

  const FacialMeasurementsModel({
    this.summaryStatus = '',
    this.measurements = const {},
  });

  bool get hasMeasurements =>
      summaryStatus.trim().isNotEmpty || measurements.isNotEmpty;

  /// يتحقق مما إذا كان النص عبارة عن رسالة خطأ تقنية من السيرفر (مثل Health record not found) لمنع عرضه لرائد الفضاء
  static bool isTechnicalErrorText(String text) {
    final lower = text.toLowerCase().trim();
    return lower.contains('not found') ||
        lower.contains('unauthorized') ||
        lower.contains('invalid') ||
        lower.contains('error') ||
        lower.contains('exception') ||
        lower.contains('failed') ||
        lower.contains('cannot ') ||
        lower.contains('null') ||
        lower == 'false' ||
        lower == 'true';
  }

  /// يقرأ قياسات الوجه القادمة من رد الـ AI (`GET /health-records/:recordId/ai/image`) مباشرة مع فلترة أي أخطاء تقنية
  factory FacialMeasurementsModel.fromAiResponse(
    Map<String, dynamic> json, {
    required bool isAr,
  }) {
    if (json['success'] == false || json['status'] == 'error') {
      return const FacialMeasurementsModel();
    }

    final dynamic root =
        json['data'] ??
        json['result'] ??
        json['ai'] ??
        json['imageAnalysis'] ??
        json['facial_measurements'] ??
        json['measurements'] ??
        json['analysis'] ??
        json;

    final Map<String, String> extracted = {};
    String summary = '';

    void parseMap(Map<dynamic, dynamic> mapObj) {
      mapObj.forEach((key, value) {
        final String cleanKey = key.toString();
        final String lowerKey = cleanKey.toLowerCase();
        // تجاهل الحقول التقنية وحقول الحالة
        if (cleanKey == '_id' ||
            cleanKey == 'id' ||
            cleanKey == 'recordId' ||
            cleanKey == 'userId' ||
            cleanKey == '__v' ||
            cleanKey == 'raw' ||
            lowerKey == 'success' ||
            lowerKey == 'statuscode' ||
            lowerKey == 'error' ||
            lowerKey == 'stack') {
          return;
        }
        if (value is Map) {
          parseMap(value);
        } else if (value is List) {
          if (value.isNotEmpty) {
            extracted[_beautifyMetricLabel(cleanKey, isAr)] = value
                .map((e) => e.toString())
                .join(' ، ');
          }
        } else if (value != null && value.toString().trim().isNotEmpty) {
          final valStr = value.toString().trim();
          if (isTechnicalErrorText(valStr)) {
            return;
          }
          if (lowerKey == 'message' ||
              lowerKey == 'summary' ||
              lowerKey == 'status' ||
              lowerKey == 'diagnosis' ||
              lowerKey == 'prediction' ||
              lowerKey == 'result' ||
              lowerKey == 'ai_medical_summary') {
            summary = _simplifyAiSummaryForCrew(valStr, isAr);
          } else {
            extracted[_beautifyMetricLabel(cleanKey, isAr)] =
                _beautifyMetricValue(value);
          }
        }
      });
    }

    if (root is Map) {
      parseMap(root);
    } else if (root is String &&
        root.trim().isNotEmpty &&
        !isTechnicalErrorText(root)) {
      summary = _simplifyAiSummaryForCrew(root.trim(), isAr);
    }

    return FacialMeasurementsModel(
      summaryStatus: summary,
      measurements: extracted,
    );
  }

  static String _simplifyAiSummaryForCrew(String raw, bool isAr) {
    final cleaned = raw.replaceAll(RegExp(r'[\{\}\[\]"]'), '').trim();
    if (cleaned.isEmpty || isTechnicalErrorText(cleaned)) return '';
    return cleaned;
  }

  static String _beautifyMetricLabel(String rawKey, bool isAr) {
    final lower = rawKey.toLowerCase().replaceAll('_', ' ').trim();
    final Map<String, List<String>> dictionary = {
      'eye aspect ratio': ['نسبة فتحة العين (EAR)', 'Eye Aspect Ratio (EAR)'],
      'ear': ['نسبة فتحة العين (EAR)', 'Eye Aspect Ratio (EAR)'],
      'mouth aspect ratio': [
        'نسبة فتحة الفم (MAR)',
        'Mouth Aspect Ratio (MAR)',
      ],
      'mar': ['نسبة فتحة الفم (MAR)', 'Mouth Aspect Ratio (MAR)'],
      'facial symmetry': ['تناسق أبعاد الوجه', 'Facial Symmetry'],
      'symmetry': ['تناسق قسمات الوجه', 'Facial Symmetry'],
      'head pose': ['زاوية ميل الرأس', 'Head Pose Angle'],
      'eyelid': ['مستوى ارتخاء الجفن', 'Eyelid Droop / Closure'],
      'blink': ['معدل طرف العين', 'Blink Rate'],
      'fatigue': ['مؤشر إجهاد الوجه', 'Facial Fatigue Score'],
      'stress': ['مؤشر التوتر العضلي للوجه', 'Facial Stress Index'],
      'emotion': ['التعبير الوجهي السائد', 'Facial Expression'],
      'jaw': ['زاوية الفك والذقن', 'Jawline Measurement'],
      'brow': ['مسافة الحاجبين والعين', 'Brow-to-Eye Distance'],
      'face width': ['عرض الوجه البيومتري', 'Biometric Face Width'],
      'face height': ['طول الوجه البيومتري', 'Biometric Face Height'],
      'confidence': ['دقة قياس الـ AI للوجه', 'AI Face Confidence'],
    };

    for (final entry in dictionary.entries) {
      if (lower.contains(entry.key)) {
        return isAr ? entry.value[0] : entry.value[1];
      }
    }

    return rawKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static String _beautifyMetricValue(dynamic val) {
    if (val is double) {
      return val.toStringAsFixed(2);
    }
    return val.toString().replaceAll(RegExp(r'[\{\}\[\]"]'), '').trim();
  }
}

class HealthRecordModel {
  final String? id;
  final int systolic;
  final int diastolic;
  final int heartRate;
  final double bloodSugar;
  final double bodyTemperature;
  final double sleepHours;
  final int fatigueLevel;
  final String? imageUrl;
  final String? createdAt;

  const HealthRecordModel({
    this.id,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.bloodSugar,
    required this.bodyTemperature,
    required this.sleepHours,
    required this.fatigueLevel,
    this.imageUrl,
    this.createdAt,
  });

  /// يطابق حرفياً 100% الـ Body الموجود في `POST /health-records` داخل ملف BioOrbit_4.json فقط
  Map<String, dynamic> toBackendJson() {
    final int safeSys = systolic > 0 ? systolic : 120;
    final int safeDia = diastolic > 0 ? diastolic : 80;
    final int safeHr = heartRate > 0 ? heartRate : 75;
    final num safeSugar = bloodSugar > 0 ? bloodSugar.round() : 95;
    final double safeTemp = bodyTemperature > 0 ? bodyTemperature : 36.8;
    final num safeSleep = sleepHours > 0
        ? (sleepHours % 1 == 0 ? sleepHours.toInt() : sleepHours)
        : 8;
    final int safeFatigue = fatigueLevel > 0 ? fatigueLevel : 3;

    return {
      "bloodPressure": {"systolic": safeSys, "diastolic": safeDia},
      "heartRate": safeHr,
      "bloodSugar": safeSugar,
      "bodyTemperature": safeTemp,
      "sleepHours": safeSleep,
      "fatigueLevel": safeFatigue,
    };
  }

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    final bp = json['bloodPressure'] is Map ? json['bloodPressure'] : {};
    return HealthRecordModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      systolic: _toInt(bp['systolic'] ?? json['systolic'], fallback: 120),
      diastolic: _toInt(bp['diastolic'] ?? json['diastolic'], fallback: 80),
      heartRate: _toInt(json['heartRate'], fallback: 75),
      bloodSugar: _toDouble(json['bloodSugar'], fallback: 95.0),
      bodyTemperature: _toDouble(json['bodyTemperature'], fallback: 36.8),
      sleepHours: _toDouble(json['sleepHours'], fallback: 8.0),
      fatigueLevel: _toInt(json['fatigueLevel'], fallback: 3),
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? json['image'])
          ?.toString(),
      createdAt: (json['createdAt'] ?? json['date'])?.toString(),
    );
  }

  static int _toInt(dynamic val, {int fallback = 0}) {
    if (val is num && val > 0) return val.toInt();
    if (val is String) {
      final parsed = int.tryParse(val);
      if (parsed != null && parsed > 0) return parsed;
    }
    return fallback;
  }

  static double _toDouble(dynamic val, {double fallback = 0.0}) {
    if (val is num && val > 0) return val.toDouble();
    if (val is String) {
      final parsed = double.tryParse(val);
      if (parsed != null && parsed > 0) return parsed;
    }
    return fallback;
  }
}

class WeeklyReportModel {
  final String astronautId;
  final int missionWeek;
  final String aiMedicalSummary;
  final double avgHeartRate;
  final double avgSleepHours;
  final int totalExerciseMinutes;
  final int highestFatigueLevel;
  final String predominantMentalStatus;
  final List<String> carePlanRecommendations;

  const WeeklyReportModel({
    this.astronautId = EndPoints.defaultAstronautId,
    this.missionWeek = 1,
    this.aiMedicalSummary = '',
    this.avgHeartRate = 0,
    this.avgSleepHours = 0,
    this.totalExerciseMinutes = 0,
    this.highestFatigueLevel = 0,
    this.predominantMentalStatus = '',
    this.carePlanRecommendations = const [],
  });

  bool get hasBackendData =>
      avgHeartRate > 0 ||
      avgSleepHours > 0 ||
      aiMedicalSummary.trim().isNotEmpty ||
      carePlanRecommendations.isNotEmpty;

  /// يطابق 100% هيكل `POST /weekly-reports/receive` في ملف BioOrbit_4.json
  Map<String, dynamic> toReceiveEndpointBody() {
    return {
      "status": "success",
      "data": {
        "astronaut": astronautId.isNotEmpty
            ? astronautId
            : EndPoints.defaultAstronautId,
        "mission_week": missionWeek,
        "weekly_averages": {
          "avg_heart_rate": avgHeartRate.round(),
          "avg_sleep_hours": avgSleepHours.round(),
          "total_exercise_minutes": totalExerciseMinutes,
          "highest_fatigue_level": highestFatigueLevel,
          "predominant_mental_status": predominantMentalStatus.isNotEmpty
              ? predominantMentalStatus
              : "Stable",
        },
        "ai_medical_summary": aiMedicalSummary.isNotEmpty
            ? aiMedicalSummary
            : "The astronaut's weekly health indicators are stable.",
        "care_plan_recommendations": carePlanRecommendations.isNotEmpty
            ? carePlanRecommendations
            : [
                "Maintain regular sleep schedule",
                "Continue daily exercise",
                "Monitor fatigue levels",
              ],
      },
    };
  }

  factory WeeklyReportModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> root = json['data'] is Map<String, dynamic>
        ? json['data']
        : (json['report'] is Map<String, dynamic> ? json['report'] : json);

    final Map<String, dynamic> avg =
        root['weekly_averages'] is Map<String, dynamic>
        ? root['weekly_averages']
        : (root['averages'] is Map<String, dynamic> ? root['averages'] : {});

    final List<dynamic> rawCare = root['care_plan_recommendations'] is List
        ? root['care_plan_recommendations']
        : (root['recommendations'] is List ? root['recommendations'] : []);

    return WeeklyReportModel(
      astronautId:
          (root['astronaut'] ?? root['userId'] ?? EndPoints.defaultAstronautId)
              .toString(),
      missionWeek: HealthRecordModel._toInt(root['mission_week'], fallback: 1),
      aiMedicalSummary:
          (root['ai_medical_summary'] ??
                  root['summary'] ??
                  root['analysis'] ??
                  root['message'] ??
                  '')
              .toString(),
      avgHeartRate: HealthRecordModel._toDouble(
        avg['avg_heart_rate'] ?? root['avg_heart_rate'] ?? root['heartRate'],
      ),
      avgSleepHours: HealthRecordModel._toDouble(
        avg['avg_sleep_hours'] ?? root['avg_sleep_hours'] ?? root['sleepHours'],
      ),
      totalExerciseMinutes: HealthRecordModel._toInt(
        avg['total_exercise_minutes'] ?? root['total_exercise_minutes'],
      ),
      highestFatigueLevel: HealthRecordModel._toInt(
        avg['highest_fatigue_level'] ??
            root['highest_fatigue_level'] ??
            root['fatigueLevel'],
      ),
      predominantMentalStatus:
          (avg['predominant_mental_status'] ??
                  root['predominant_mental_status'] ??
                  root['status'] ??
                  '')
              .toString(),
      carePlanRecommendations: rawCare
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList(),
    );
  }
}
