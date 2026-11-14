const healthRecordService = require("../services/healthRecordService");

const createRecord = async (req, res) => {
  try {
    const {
      bloodPressure,
      heartRate,
      bloodSugar,
      bodyTemperature,
      sleepHours,
      fatigueLevel,
      exerciseMinutes,
      daysInSpace,
    } = req.body;

    if (
      !bloodPressure ||
      typeof bloodPressure !== "object" ||
      Array.isArray(bloodPressure) ||
      bloodPressure.systolic == null ||
      bloodPressure.diastolic == null ||
      heartRate == null ||
      bloodSugar == null ||
      bodyTemperature == null ||
      sleepHours == null ||
      fatigueLevel == null ||
      exerciseMinutes == null ||
      daysInSpace == null
    ) {
      return res.status(400).json({
        success: false,
        message: "All health metrics are required",
      });
    }

    if (
      typeof exerciseMinutes !== "number" ||
      !Number.isInteger(exerciseMinutes) ||
      exerciseMinutes < 0 ||
      typeof daysInSpace !== "number" ||
      !Number.isInteger(daysInSpace) ||
      daysInSpace < 0
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Exercise minutes and days in space must be non-negative integers",
      });
    }

    const values = [
      bloodPressure.systolic,
      bloodPressure.diastolic,
      heartRate,
      bloodSugar,
      bodyTemperature,
      sleepHours,
      fatigueLevel,
      exerciseMinutes,
      daysInSpace,
    ];

    if (
      values.some(
        (value) => typeof value !== "number" || !Number.isFinite(value),
      )
    ) {
      return res.status(400).json({
        success: false,
        message: "All health metrics must be valid numbers",
      });
    }

    const record = await healthRecordService.createHealthRecord(req.user._id, {
      bloodPressure,
      heartRate,
      bloodSugar,
      bodyTemperature,
      sleepHours,
      fatigueLevel,
      exerciseMinutes,
      daysInSpace,
    });

    return res.status(201).json({
      success: true,
      message: "Health record created successfully",
      data: record,
    });
  } catch (error) {
    if (error.name === "ValidationError") {
      return res.status(400).json({
        success: false,
        message: "Invalid health data",
        errors: Object.values(error.errors).map((item) => item.message),
      });
    }

    console.error("Create Health Record Error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

const getMyRecords = async (req, res) => {
  try {
    const records = await healthRecordService.getMyHealthRecords(req.user._id);

    return res.status(200).json({
      success: true,
      message: "Health records retrieved successfully",
      totalRecords: records.length,
      data: records,
    });
  } catch (error) {
    console.error("Get My Records Error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

const HealthRecord = require("../models/HealthRecord");

// Get Image URL for AI
const getAIImage = async (req, res) => {
  try {
    const record = await HealthRecord.findOne({
      _id: req.params.recordId,
      astronaut: req.user._id,
    }).select("image.imageUrl");

    if (!record) {
      return res.status(404).json({
        success: false,
        message: "Health record not found",
      });
    }

    if (!record.image?.imageUrl) {
      return res.status(404).json({
        success: false,
        message: "No image uploaded",
      });
    }

    return res.status(200).json({
      success: true,
      data: {
        recordId: record._id,
        imageUrl: record.image.imageUrl,
      },
    });
  } catch (error) {
    console.error("Get AI Image Error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

// Get Health Metrics for AI
const getAIMetrics = async (req, res) => {
  try {
    const record = await HealthRecord.findOne({
      _id: req.params.recordId,
      astronaut: req.user._id,
    }).select(
      "bloodPressure heartRate bloodSugar bodyTemperature sleepHours fatigueLevel exerciseMinutes daysInSpace",
    );

    if (!record) {
      return res.status(404).json({
        success: false,
        message: "Health record not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: {
        recordId: record._id,
        bloodPressure: record.bloodPressure,
        heartRate: record.heartRate,
        bloodSugar: record.bloodSugar,
        bodyTemperature: record.bodyTemperature,
        sleepHours: record.sleepHours,
        fatigueLevel: record.fatigueLevel,
        exerciseMinutes: record.exerciseMinutes,
        daysInSpace: record.daysInSpace,
      },
    });
  } catch (error) {
    console.error("Get AI Metrics Error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};


const getWeeklyAIRecords = async (req, res) => {
  try {
    const records = await HealthRecord.find({
      astronaut: req.user._id,
    })
      .sort({ createdAt: -1 })
      .limit(7)
      .lean();

    if (records.length !== 7) {
      return res.status(400).json({
        success: false,
        message: "Exactly 7 health records are required",
        availableRecords: records.length,
        requiredRecords: 7,
      });
    }

    // Oldest to newest
    records.reverse();

    const dailyRecords = records.map((record, index) => ({
      day_number: index + 1,
      blood_pressure_systolic: record.bloodPressure.systolic,
      heart_rate: record.heartRate,
      sleep_hours: record.sleepHours,
      fatigue_level: record.fatigueLevel,
      exercise_minutes: record.exerciseMinutes,
      mental_status: record.imageAnalysis?.mentalStatus || "Pending",
    }));

    return res.status(200).json({
      data: {
        astronaut: String(req.user._id),
        daily_records: dailyRecords,
      },
    });
  } catch (error) {
    console.error("Get Weekly AI Records Error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};


module.exports = {
  createRecord,
  getMyRecords,
  getAIImage,
  getAIMetrics,
  getWeeklyAIRecords,
};
