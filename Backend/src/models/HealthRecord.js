const mongoose = require("mongoose");

const healthRecordSchema = new mongoose.Schema(
  {
    astronaut: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    bloodPressure: {
      systolic: {
        type: Number,
        required: true,
        min: 40,
        max: 300,
      },

      diastolic: {
        type: Number,
        required: true,
        min: 20,
        max: 200,
      },
    },

    heartRate: {
      type: Number,
      required: true,
      min: 20,
      max: 250,
    },

    bloodSugar: {
      type: Number,
      required: true,
      min: 1,
      max: 1000,
    },

    bodyTemperature: {
      type: Number,
      required: true,
      min: 30,
      max: 45,
    },

    sleepHours: {
      type: Number,
      required: true,
      min: 0,
      max: 24,
    },

    fatigueLevel: {
      type: Number,
      required: true,
      min: 0,
      max: 10,
    },

    image: {
      imageUrl: {
        type: String,
        default: null,
      },

      imageAnalysis: {
        status: {
          type: String,
          enum: ["pending", "completed", "failed"],
          default: "pending",
        },

        dominantEmotion: {
          type: String,
          default: null,
        },

        stressScorePercentage: {
          type: Number,
          default: null,
        },

        mentalStatus: {
          type: String,
          default: null,
        },

        uiDirectives: {
          modelNerveLayerColor: {
            type: String,
            default: null,
          },

          recommendedAction: {
            type: String,
            default: null,
          },
        },

        rawEmotions: {
          angry: { type: Number, default: null },
          disgust: { type: Number, default: null },
          fear: { type: Number, default: null },
          happy: { type: Number, default: null },
          sad: { type: Number, default: null },
          surprise: { type: Number, default: null },
          neutral: { type: Number, default: null },
        },

        analyzedAt: {
          type: Date,
          default: null,
        },
      },

      publicId: {
        type: String,
        default: null,
      },
    },

    aiAnalysis: {
      status: {
        type: String,
        enum: ["pending", "processing", "completed", "failed"],
        default: "pending",
      },

      riskLevel: {
        type: String,
        enum: ["unknown", "low", "medium", "high", "critical"],
        default: "unknown",
      },

      summary: {
        type: String,
        default: null,
      },

      detectedIssues: {
        type: [String],
        default: [],
      },

      recommendations: {
        type: [String],
        default: [],
      },

      analyzedAt: {
        type: Date,
        default: null,
      },
    },
    exerciseMinutes: {
      type: Number,
      required: true,
      min: 0,
      default: 0,
    },

    daysInSpace: {
      type: Number,
      required: true,
      min: 0,
      default: 0,
    },
  },
  {
    timestamps: true,
  },
);

// Optimize astronaut history queries
healthRecordSchema.index({
  astronaut: 1,
  createdAt: -1,
});

const HealthRecord = mongoose.model("HealthRecord", healthRecordSchema);

module.exports = HealthRecord;
