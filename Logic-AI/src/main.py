from fastapi import FastAPI
from src.routes import face_analyzer_route, overall_router, reporter_router

app = FastAPI()

# App routes
app.include_router(face_analyzer_route)
app.include_router(overall_router)
app.include_router(reporter_router)