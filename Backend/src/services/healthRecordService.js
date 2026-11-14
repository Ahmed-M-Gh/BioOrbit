const HealthRecord = require("../models/HealthRecord");

const createHealthRecord = async (astronautId, healthData) => {
  const record = await HealthRecord.create({
    ...healthData,
    astronaut: astronautId,
  });

  return record;
};

const getMyHealthRecords = async (astronautId) => {
  const records = await HealthRecord.find({
    astronaut: astronautId,
  })
    .sort({ createdAt: -1 })
    .lean();

  return records;
};

const saveImageAnalysis = async (recordId, astronautId, aiResponse) => {
  const analysis = aiResponse.data;

  const record = await HealthRecord.findOneAndUpdate(
    {
      _id: recordId,
      astronaut: astronautId,
    },
    {
      $set: {
        "imageAnalysis.status": "completed",

        "imageAnalysis.dominantEmotion": analysis.dominant_emotion,

        "imageAnalysis.stressScorePercentage": analysis.stress_score_percentage,

        "imageAnalysis.mentalStatus": analysis.mental_status,

        "imageAnalysis.uiDirectives.modelNerveLayerColor":
          analysis.ui_directives["3d_model_nerve_layer_color"],

        "imageAnalysis.uiDirectives.recommendedAction":
          analysis.ui_directives.recommended_action,

        "imageAnalysis.rawEmotions": analysis.raw_emotions,

        "imageAnalysis.analyzedAt": new Date(),
      },
    },
    {
      new: true,
      runValidators: true,
    },
  );

  if (!record) {
    throw new Error("Health record not found");
  }

  return record;
};

module.exports = {
  createHealthRecord,
  getMyHealthRecords,
  saveImageAnalysis,
};
