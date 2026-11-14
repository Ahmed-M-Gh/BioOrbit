from fastapi import APIRouter
from src.schema import VitalsRequest, VitalsResponse
from src.controller import analyze_astronaut_vitals

overall_router = APIRouter(prefix="/api/v1/health", tags=["Physical Vitals"])

@overall_router.post("/analyze-vitals", response_model=VitalsResponse)
def handle_vitals_analysis(request: VitalsRequest):
    """
    Analyzes astronaut vitals across 4 phases (Mental, Cardio, Muscle, Bone)
    and returns 3D UI directives with specific actionable recommendations.
    """
    payload_dict = request.model_dump()
    
    result_data = analyze_astronaut_vitals(payload_dict)
    
    return {"data": result_data}