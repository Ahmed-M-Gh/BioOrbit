import cv2
import numpy as np
import requests
from deepface import DeepFace
from fastapi import HTTPException

def process_face_analysis(image_url: str) -> dict:
    try:
        # 1. image loading
        response = requests.get(image_url)
        if response.status_code != 200:
            raise HTTPException(status_code=400, detail="Failed to fetch image from URL")
        
        # 2. convert image to CV2 format
        image_array = np.asarray(bytearray(response.content), dtype="uint8")
        img = cv2.imdecode(image_array, cv2.IMREAD_COLOR)

        if img is None:
            raise HTTPException(status_code=400, detail="Invalid image format or unreachable URL")

        # 3. analysis using DeepFace
        analysis_result = DeepFace.analyze(img, actions=['emotion'], enforce_detection=False)
        
        if isinstance(analysis_result, list):
            analysis_result = analysis_result[0]
            
        emotions_dict = analysis_result['emotion']
        dominant_emotion = analysis_result['dominant_emotion']

        # 4. Decision engine (Logic)
        stress_score = emotions_dict.get('sad', 0) + emotions_dict.get('fear', 0) + emotions_dict.get('angry', 0) + emotions_dict.get('disgust', 0)
        
        if stress_score > 60:
            mental_status = "Critical"
            nerve_color = "Red"
        elif stress_score > 30:
            mental_status = "Warning"
            nerve_color = "Yellow"
        else:
            mental_status = "Stable"
            nerve_color = "Green"

        # 5. Return data to Route
        return {
            "dominant_emotion": dominant_emotion,
            "stress_score_percentage": round(stress_score, 2),
            "mental_status": mental_status,
            "ui_directives": {
                "3d_model_nerve_layer_color": nerve_color,
                "recommended_action": "Schedule psychological consultation." if mental_status == "Critical" else "No immediate action required."
            },
            "raw_emotions": emotions_dict
        }

    except HTTPException:
        raise # If any thing goes wrong
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI Analysis failed: {str(e)}")