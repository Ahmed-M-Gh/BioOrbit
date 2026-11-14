const express = require("express");
const cors = require("cors");

const authRoutes = require("./routes/authRoutes");
const healthRecordRoutes = require("./routes/healthRecordRoutes");
const weeklyReportRoutes = require("./routes/weeklyReportRoutes");

const app = express();

app.use(cors());
app.use(express.json());

// Home Route
app.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "BioOrbit API is Running 🚀",
  });
});

// Authentication Routes
app.use("/", authRoutes);

// Health Records Routes
app.use("/health-records", healthRecordRoutes);

// Weekly Reports Routes
app.use("/weekly-reports", weeklyReportRoutes);

module.exports = app;
