from fastapi import APIRouter
from src.schema import ImageRequest, AnalysisResponse
from src.controller import process_face_analysis

face_analyzer_route = APIRouter(
    prefix="/api/v0.1.0",
    tags=["face_analyzer"]
)


@face_analyzer_route.post("/face-analyzer", response_model=AnalysisResponse)
def analyze_facial_expression(request: ImageRequest):
    """
    Takes an image URL, analyzes facial expressions via DeepFace, 
    and returns stress levels and 3D UI directives for the astronaut's dashboard.
    """
    result_data = process_face_analysis(request.url)
    
    return {"data": result_data}