import statistics
from groq import Groq
from src.config import get_settings

settings = get_settings()

if hasattr(settings, 'groq_api_key') and settings.groq_api_key:
    groq_client = Groq(api_key=settings.groq_api_key)
else:
    groq_client = None

def generate_weekly_report(payload: dict) -> dict:
    data = payload['data']
    records = data['daily_records']
    
    # ---------------------------------------------------------
    # 1. Calculations
    # ---------------------------------------------------------
    heart_rates = [day['heart_rate'] for day in records]
    sleep_hours = [day['sleep_hours'] for day in records]
    exercises = [day['exercise_minutes'] for day in records]
    fatigues = [day['fatigue_level'] for day in records]
    mental_states = [day['mental_status'] for day in records]
    
    avg_hr = round(sum(heart_rates) / len(heart_rates), 1)
    avg_sleep = round(sum(sleep_hours) / len(sleep_hours), 1)
    total_exercise = sum(exercises)
    max_fatigue = max(fatigues)
    
    # the mental health status
    try:
        predominant_mental = statistics.mode(mental_states)
    except statistics.StatisticsError:
        predominant_mental = mental_states[-1] 

    averages = {
        "avg_heart_rate": avg_hr,
        "avg_sleep_hours": avg_sleep,
        "total_exercise_minutes": total_exercise,
        "highest_fatigue_level": max_fatigue,
        "predominant_mental_status": predominant_mental
    }

    # ---------------------------------------------------------
    # 2. Report Generation with groq
    # ---------------------------------------------------------
    ai_summary = "AI analysis unavailable. Please check Groq API Key configuration."
    care_plan = ["Ensure minimum 2 hours of daily exercise.", "Maintain 8 hours of sleep."]

    if groq_client:
        prompt = f"""
        You are the Chief Medical Officer AI for a deep space mission. 
        Analyze the following weekly vital averages for Astronaut {data['astronaut']} (Week {data['mission_week']}):
        - Avg Heart Rate: {avg_hr} bpm
        - Avg Sleep: {avg_sleep} hours/day
        - Total Weekly Exercise: {total_exercise} minutes (Target: 420+ mins)
        - Max Fatigue Level (1-10): {max_fatigue}
        - Predominant Mental State: {predominant_mental}

        Task 1: Write a concise, professional medical summary (3-4 sentences) evaluating their overall physical and mental readiness.
        Task 2: Provide 3 short, actionable care plan recommendations for the next week.

        Format your response EXACTLY like this:
        SUMMARY: [Your medical summary here]
        RECOMMENDATIONS:
        - [Rec 1]
        - [Rec 2]
        - [Rec 3]
        """
        
        try:
            chat_completion = groq_client.chat.completions.create(
                messages=[
                    {
                        "role": "user",
                        "content": prompt,
                    }
                ],
                model="qwen/qwen3.8-27b",
                temperature=0.2,
            )
            
            response_text = chat_completion.choices[0].message.content
            
            if "SUMMARY:" in response_text and "RECOMMENDATIONS:" in response_text:
                parts = response_text.split("RECOMMENDATIONS:")
                ai_summary = parts[0].replace("SUMMARY:", "").strip()
                
                raw_recs = parts[1].strip().split('\n')
                care_plan = [rec.strip("- *").strip() for rec in raw_recs if rec.strip()]
        except Exception as e:
            ai_summary = f"LLM Generation failed: {str(e)}"

    # ---------------------------------------------------------
    # 3. Return Results
    # ---------------------------------------------------------
    return {
        "astronaut": data['astronaut'],
        "mission_week": data['mission_week'],
        "weekly_averages": averages,
        "ai_medical_summary": ai_summary,
        "care_plan_recommendations": care_plan
    }