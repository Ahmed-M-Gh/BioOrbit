const express = require("express");

const {
  createRecord,
  getMyRecords,
  getAIImage,
  getAIMetrics,
  getWeeklyAIRecords,
} = require("../controllers/healthRecordController");

const { uploadAstroImage } = require("../controllers/imageController");

const { protect, authorize } = require("../middlewares/authMiddleware");

const upload = require("../middlewares/uploadMiddleware");

const router = express.Router();

// Create Health Record

// console.log("DEBUG ROUTES:", {
//   createRecord: typeof createRecord,
//   getMyRecords: typeof getMyRecords,
//   protect: typeof protect,
//   authorize: typeof authorize,
//   upload: typeof upload,
//   uploadSingle: typeof upload?.single,
//   uploadAstroImage: typeof uploadAstroImage,
// });

router.post("/", protect, authorize("astro"), createRecord);

// Get My Health Records
router.get("/me", protect, authorize("astro"), getMyRecords);

// Upload Astro Image
router.patch(
  "/:recordId/image",
  protect,
  authorize("astro"),
  upload.single("image"),
  uploadAstroImage,
);
// AI Endpoints
router.get("/:recordId/ai/image", protect, authorize("astro"), getAIImage);
router.get("/:recordId/ai/metrics", protect, authorize("astro"), getAIMetrics);
router.get("/ai/weekly", protect, authorize("astro"), getWeeklyAIRecords);
module.exports = router;
