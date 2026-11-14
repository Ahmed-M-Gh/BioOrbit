from pydantic import BaseModel, Field
from typing import List

# ==========================================
# 1. Request Schemas 
# ==========================================
class DailyMetric(BaseModel):
    day_number: int = Field(..., description="Day 1 to 7")
    blood_pressure_systolic: int
    heart_rate: int
    sleep_hours: float
    fatigue_level: int
    exercise_minutes: int
    mental_status: str = Field(..., description="Stable, Warning, or Critical")

class WeeklyReportPayload(BaseModel):
    astronaut: str
    mission_week: int = Field(..., description="Current week number in the mission")
    daily_records: List[DailyMetric] = Field(..., min_length=1, max_length=7)

class WeeklyReportRequest(BaseModel):
    data: WeeklyReportPayload

# ==========================================
# 2. Response Schemas 
# ==========================================
class WeeklyAverages(BaseModel):
    avg_heart_rate: float
    avg_sleep_hours: float
    total_exercise_minutes: int
    highest_fatigue_level: int
    predominant_mental_status: str

class WeeklyReportData(BaseModel):
    astronaut: str
    mission_week: int
    weekly_averages: WeeklyAverages
    ai_medical_summary: str = Field(..., description="LLM-generated medical summary text")
    care_plan_recommendations: List[str] = Field(..., description="Actionable plan for the next week")

class WeeklyReportResponse(BaseModel):
    status: str = "success"
    data: WeeklyReportData