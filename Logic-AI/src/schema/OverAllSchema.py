from pydantic import BaseModel, Field
from typing import Dict, List

# ==========================================
# 1. Request Schemas 
# ==========================================
class BloodPressure(BaseModel):
    systolic: int
    diastolic: int

class FaceAnalyzerData(BaseModel):
    dominant_emotion: str
    stress_score_percentage: float
    mental_status: str
    raw_emotions: Dict[str, float]

class VitalsPayload(BaseModel):
    astronaut: str
    bloodPressure: BloodPressure
    heartRate: int
    bloodSugar: int
    bodyTemperature: float
    sleepHours: float
    fatigueLevel: int
    face_Analyzer: FaceAnalyzerData 
    exercise_minutes: int = Field(...)
    days_in_space: int = Field(...)

class VitalsRequest(BaseModel):
    data: VitalsPayload

# ==========================================
# 2. Response Schemas 
# ==========================================
class UI3DLayers(BaseModel):
    nerve_color: str
    muscle_color: str
    bone_color: str

class UIDirectives(BaseModel):
    layers: UI3DLayers = Field(alias="3d_layers")
    recommended_actions: List[str] 

class RiskBreakdown(BaseModel):
    cardio_systemic_risk: bool
    musculoskeletal_risk: str
    mental_psychological_risk: str

class VitalsResponseData(BaseModel):
    astronaut: str
    overall_status: str
    ui_directives: UIDirectives
    risk_breakdown: RiskBreakdown

class VitalsResponse(BaseModel):
    status: str = "success"
    data: VitalsResponseData