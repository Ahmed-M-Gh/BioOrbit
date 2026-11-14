# 🌌 BioOrbit: Autonomous Health Monitoring System for Deep Space Missions

## 🚀 The Challenge
Long-duration space missions expose astronauts to severe hazards: microgravity, radiation, and isolation. In deep space, real-time communication with Earth is impossible. Astronauts must rely on themselves to monitor their physical and mental health, predict risks, and take immediate action. 

**BioOrbit** is a standalone, AI-powered health monitoring ecosystem designed specifically for the NASA Space Apps Challenge to solve this critical autonomy problem.

---

## 💡 Our Solution: BioOrbit
BioOrbit is a dual-interface software ecosystem (Mobile App for Astronauts + Web Dashboard for the Crew Medical Officer) that gathers vital signs, analyzes mental states via AI, and provides actionable, space-specific medical guidance through an interactive 3D interface.

### 🔑 Key Features

#### 1. 🧑‍🚀 The Astronaut Interface (Built with Flutter)
A daily companion on the astronaut's personal tablet, designed for quick data entry and immediate feedback.
* **Streamlined Data Entry:** Astronauts input daily vitals (Blood Pressure, Heart Rate, Blood Sugar, Temperature, Sleep duration) and an fatigue scale (0-10).
* **AI Facial Analysis for Mental Health:** The astronaut takes a quick selfie. Our AI model analyzes facial micro-expressions to assess mood and stress levels, supplementing a short psychological questionnaire.
* **Interactive 3D Body Mapping:** The core visual tool. A 3D human model with three toggleable layers: **Muscle, Nerve, and Bone**.
  * **Color-Coded Status:** Green (Healthy), Yellow (Warning - e.g., early bone density loss), Red (Critical).
  * **Actionable Guidance:** Clicking a yellow/red zone reveals the space-related cause (e.g., "Microgravity-induced muscle atrophy") and assigns a specific countermeasure (e.g., "Add 20 mins to ARED resistance training today").

#### 2. 👨‍⚕️ The Medical Officer Dashboard (Built with Web/Frontend tech)
A comprehensive control center for the ship's doctor to monitor the entire crew's health trends.
* **Holistic Crew Overview:** Displays the real-time health status of all astronauts on board.
* **Predictive AI Alerts:** Analyzes historical data to predict upcoming crises. (e.g., "Alert: Astronaut X's sleep and stress data indicate a high probability of a panic attack or severe fatigue in the next 48 hours").
* **Automated Weekly Reports:** Generates detailed health trend reports for each crew member to aid the Medical Officer in mission planning and task assignment.

---

## 🛠️ Tech Stack
* **Mobile App (Astronaut UI):** Flutter, Dart
* **Web Dashboard (Medical UI):** [Insert your FrontEnd Tech: e.g., React, Vue, HTML/CSS/JS]
* **3D Visualization:** [Insert tool used: e.g., Three.js, Flutter 3D packages]
* **AI/Machine Learning:** [Insert AI tools: e.g., Python, TensorFlow/PyTorch, OpenCV for facial analysis]
* **Database:** Local Database (SQLite / Hive) for autonomous offline operation in space.

---

## 🎯 How it Addresses NASA's Hazards
* **Gravity Fields:** Monitors and maps bone/muscle degradation via the 3D model.
* **Isolation/Confinement:** Actively tracks mental health through AI facial analysis and mood surveys to prevent behavioral crises.
* **Distance from Earth:** Operates entirely offline with a local database, ensuring 100% autonomy without waiting for Ground Control.

---

## 👥 The Team
* **[Name]** - AI Engineer
* **[Name]** - UI/UX Designer
* **[Name]** - Flutter Developer
* **[Name]** - FrontEnd Developer