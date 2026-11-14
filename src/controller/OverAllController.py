def analyze_astronaut_vitals(payload: dict) -> dict:
    data = payload['data']
    
    # ---------------------------------------------------------
    # Phase 1: Nerve & Mental 
    # ---------------------------------------------------------
    mental_status = data['face_Analyzer']['mental_status']
    emotion = data['face_Analyzer']['dominant_emotion']
    
    if mental_status == "Critical":
        nerve_color = "Red"
        mental_risk = f"High ({emotion.capitalize()} Alert)"
    elif mental_status == "Warning" or data['sleepHours'] < 5:
        nerve_color = "Yellow"
        mental_risk = "Medium (Stress/Fatigue)"
    else:
        nerve_color = "Green"
        mental_risk = "Low"

    # ---------------------------------------------------------
    # Phase 2: Cardio & Vitals 
    # ---------------------------------------------------------
    bp_sys = data['bloodPressure']['systolic']
    hr = data['heartRate']
    temp = data['bodyTemperature']
    
    cardio_risk = bool(bp_sys > 140 or hr > 100 or temp > 38.0)

    # ---------------------------------------------------------
    # Phase 3: Musculoskeletal 
    # ---------------------------------------------------------
    exercise = data['exercise_minutes']
    days = data['days_in_space']
    
    # العضلات
    if exercise < 20 or data['fatigueLevel'] > 7:
        muscle_color = "Red"
    elif exercise < 45:
        muscle_color = "Yellow"
    else:
        muscle_color = "Green"
        
    # العظام
    if days > 90 and exercise < 60:
        bone_color = "Red"
    elif days > 30 and exercise < 45:
        bone_color = "Yellow"
    else:
        bone_color = "Green"
        
    musculoskeletal_risk = "High" if "Red" in [muscle_color, bone_color] else "Medium" if "Yellow" in [muscle_color, bone_color] else "Low"

    # ---------------------------------------------------------
    # Phase 4: Synthesis & Action 
    # ---------------------------------------------------------
    if "Red" in [nerve_color, muscle_color, bone_color] or cardio_risk:
        overall_status = "Critical"
    elif "Yellow" in [nerve_color, muscle_color, bone_color]:
        overall_status = "Warning"
    else:
        overall_status = "Stable"

    actions = []
    
    if cardio_risk:
        actions.append("Cardio: Abnormal vitals detected. Administer emergency meds and report to Medical Officer.")
        
    if nerve_color == "Red":
        actions.append(f"Nerves: Critical psychological stress ({emotion}) detected. Suspend external tasks and rest.")
    elif nerve_color == "Yellow":
        actions.append("Nerves: Mild stress or sleep deprivation. Increase rest hours.")
        
    if muscle_color == "Red":
        actions.append("Muscles: Severe degradation risk. Proceed to ARED device for 60 mins of mandatory resistance training.")
    elif muscle_color == "Yellow":
        actions.append("Muscles: Early signs of atrophy. Ensure minimum 45 mins of daily exercise.")
        
    if bone_color == "Red":
        actions.append("Bones: High bone density loss detected. Increase Calcium intake and load-bearing exercises.")
    elif bone_color == "Yellow":
        actions.append("Bones: Moderate density loss. Maintain consistent resistance training.")

    if not actions:
        actions.append("All systems nominal. Continue standard mission protocols.")

    return {
        "astronaut": data['astronaut'],
        "overall_status": overall_status,
        "ui_directives": {
            "3d_layers": {
                "nerve_color": nerve_color,
                "muscle_color": muscle_color,
                "bone_color": bone_color
            },
            "recommended_actions": actions
        },
        "risk_breakdown": {
            "cardio_systemic_risk": cardio_risk,
            "musculoskeletal_risk": musculoskeletal_risk,
            "mental_psychological_risk": mental_risk
        }
    }