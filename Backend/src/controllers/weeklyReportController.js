const mongoose = require("mongoose");
const WeeklyReport = require("../models/WeeklyReport");
const User = require("../models/User");

const receiveWeeklyReport = async (req, res) => {
  try {
    const { status, data } = req.body;

    // Validate main response
    if (status !== "success" || !data || typeof data !== "object") {
      return res.status(400).json({
        success: false,
        message: "Invalid weekly AI report format",
      });
    }

    const {
      astronaut,
      mission_week,
      weekly_averages,
      ai_medical_summary,
      care_plan_recommendations,
    } = data;

    // Validate required fields
    if (
      !astronaut ||
      !mongoose.Types.ObjectId.isValid(astronaut) ||
      !Number.isInteger(mission_week) ||
      mission_week < 0 ||
      !weekly_averages ||
      typeof weekly_averages !== "object" ||
      typeof ai_medical_summary !== "string" ||
      !ai_medical_summary.trim() ||
      !Array.isArray(care_plan_recommendations) ||
      !care_plan_recommendations.every((item) => typeof item === "string")
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid weekly AI report data",
      });
    }

    const {
      avg_heart_rate,
      avg_sleep_hours,
      total_exercise_minutes,
      highest_fatigue_level,
      predominant_mental_status,
    } = weekly_averages;

    const numericValues = [
      avg_heart_rate,
      avg_sleep_hours,
      total_exercise_minutes,
      highest_fatigue_level,
    ];

    if (
      numericValues.some(
        (value) => typeof value !== "number" || !Number.isFinite(value),
      ) ||
      typeof predominant_mental_status !== "string"
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid weekly averages",
      });
    }

    // Verify astronaut exists
    const astronautUser = await User.findOne({
      _id: astronaut,
      role: "astro",
    });

    if (!astronautUser) {
      return res.status(404).json({
        success: false,
        message: "Astronaut not found",
      });
    }

    // Save or update weekly report
    const report = await WeeklyReport.findOneAndUpdate(
      {
        astronaut,
        missionWeek: mission_week,
      },
      {
        $set: {
          weeklyAverages: {
            avgHeartRate: avg_heart_rate,
            avgSleepHours: avg_sleep_hours,
            totalExerciseMinutes: total_exercise_minutes,
            highestFatigueLevel: highest_fatigue_level,
            predominantMentalStatus: predominant_mental_status,
          },
          aiMedicalSummary: ai_medical_summary,
          carePlanRecommendations: care_plan_recommendations,
        },
      },
      {
        new: true,
        upsert: true,
        runValidators: true,
        setDefaultsOnInsert: true,
      },
    );

    return res.status(200).json({
      success: true,
      message: "Weekly AI report saved successfully",
      data: report,
    });
  } catch (error) {
    console.error("Receive Weekly Report Error:", error);

    if (error.name === "ValidationError" || error.name === "CastError") {
      return res.status(400).json({
        success: false,
        message: "Invalid weekly report data",
      });
    }

    return res.status(500).json({
      success: false,
      message: "Failed to save weekly report",
    });
  }
};

const getMyWeeklyReports = async (req, res) => {
  try {
    const reports = await WeeklyReport.find({
      astronaut: req.user._id,
    })
      .sort({ missionWeek: -1 })
      .lean();

    return res.status(200).json({
      success: true,
      message: "Weekly reports retrieved successfully",
      totalReports: reports.length,
      data: reports,
    });
  } catch (error) {
    console.error("Get Weekly Reports Error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to retrieve weekly reports",
    });
  }
};

module.exports = {
  receiveWeeklyReport,
    getMyWeeklyReports,
};
