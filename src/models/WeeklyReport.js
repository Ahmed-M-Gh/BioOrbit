const mongoose = require("mongoose");

const weeklyReportSchema = new mongoose.Schema(
  {
    astronaut: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    missionWeek: {
      type: Number,
      required: true,
      min: 0,
    },

    weeklyAverages: {
      avgHeartRate: Number,
      avgSleepHours: Number,
      totalExerciseMinutes: Number,
      highestFatigueLevel: Number,
      predominantMentalStatus: String,
    },

    aiMedicalSummary: {
      type: String,
      required: true,
    },

    carePlanRecommendations: {
      type: [String],
      default: [],
    },
  },
  {
    timestamps: true,
  },
);

// One report per astronaut per mission week
weeklyReportSchema.index({ astronaut: 1, missionWeek: 1 }, { unique: true });

module.exports = mongoose.model("WeeklyReport", weeklyReportSchema);
