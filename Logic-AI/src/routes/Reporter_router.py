from fastapi import APIRouter
from src.schema import WeeklyReportRequest, WeeklyReportResponse
from src.controller import generate_weekly_report

reporter_router = APIRouter(prefix="/api/v1/health", tags=["Medical Dashboard"])

@reporter_router.post("/weekly-report", response_model=WeeklyReportResponse)
def handle_weekly_report(request: WeeklyReportRequest):
    """
    Analyzes 7-day astronaut vitals, calculates averages, 
    and generates an LLM-based medical summary via Groq (Llama3).
    """
    payload_dict = request.model_dump()
    
    result_data = generate_weekly_report(payload_dict)
    
    return {"data": result_data}