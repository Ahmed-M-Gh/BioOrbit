from pydantic import BaseModel, Field

# ==========================================
# 1. Request Schema
# ==========================================
class ImageRequest(BaseModel):
    url: str = Field(..., description="The direct URL of the astronaut's face image")

# ==========================================
# 2. Response Schemas (Nested objects)
# ==========================================
class UIDirectives(BaseModel):
    model_nerve_layer_color: str = Field(alias="3d_model_nerve_layer_color") 
    recommended_action: str

class RawEmotions(BaseModel):
    angry: float
    disgust: float
    fear: float
    happy: float
    sad: float
    surprise: float
    neutral: float

class DataPayload(BaseModel):
    dominant_emotion: str
    stress_score_percentage: float
    mental_status: str
    ui_directives: UIDirectives
    raw_emotions: RawEmotions

class AnalysisResponse(BaseModel):
    data: DataPayload