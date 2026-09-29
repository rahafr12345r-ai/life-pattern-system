"""Deterministic, explainable behavioral scoring for the MVP."""

from .analysis_models import BehavioralAnalysisRequest, BehavioralAnalysisResponse


def analyze_behavior(request: BehavioralAnalysisRequest) -> BehavioralAnalysisResponse:
    observations = request.observations
    score = 0
    factors: list[str] = []
    low_mood_days = sum(item.mood == "Low" for item in observations)
    short_sleep_days = sum(item.sleep_hours < 6 for item in observations)
    inactive_days = sum(item.steps < 3_000 for item in observations)

    if low_mood_days:
        score += min(45, low_mood_days * 15)
        factors.append(f"Low mood recorded on {low_mood_days} day(s)")
    if short_sleep_days:
        score += min(30, short_sleep_days * 10)
        factors.append(f"Short sleep recorded on {short_sleep_days} day(s)")
    if inactive_days:
        score += min(25, inactive_days * 8)
        factors.append(f"Low activity recorded on {inactive_days} day(s)")

    if score >= 60:
        level = "high"
        recommendation = "Review the recent pattern with your care team and complete daily check-ins."
    elif score >= 30:
        level = "medium"
        recommendation = "Keep tracking sleep, mood, and activity and consider discussing changes with your care team."
    else:
        level = "low"
        recommendation = "Continue your daily check-ins and maintain your usual routine."

    return BehavioralAnalysisResponse(
        score=score,
        level=level,
        factors=factors,
        recommendation=recommendation,
        observation_count=len(observations),
        should_create_alert=level == "high",
        alert_severity="warning" if level == "high" else "info",
        alert_title="Behavioral pattern needs review" if level == "high" else None,
        alert_message=("Repeated changes in mood, sleep, or activity were detected. Review the pattern with your care team." if level == "high" else None),
    )
