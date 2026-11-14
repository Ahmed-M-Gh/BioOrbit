const express = require("express");

const {
  receiveWeeklyReport,
  getMyWeeklyReports,
} = require("../controllers/weeklyReportController");

const { protect, authorize } = require("../middlewares/authMiddleware");

const router = express.Router();

// Receive AI Weekly Report
router.post("/receive", receiveWeeklyReport);

// Get Astronaut Weekly Reports
router.get("/me", protect, authorize("astro"), getMyWeeklyReports);

module.exports = router;
