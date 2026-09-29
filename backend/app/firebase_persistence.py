"""Persistence helpers for analysis results and deduplicated alerts."""

from datetime import date, datetime, timezone
from typing import Any

from .analysis_models import BehavioralAnalysisResponse


def build_analysis_documents(
    *, user_id: str, assessment_day: date, result: BehavioralAnalysisResponse
) -> dict[str, dict[str, Any]]:
    """Build deterministic Firestore documents without connecting to Firebase."""
    day_id = assessment_day.isoformat()
    now = datetime.now(timezone.utc)
    risk_path = f"risk_assessments/{user_id}/daily/{day_id}"
    risk_document = {
        "userId": user_id,
        "day": day_id,
        "score": result.score,
        "level": result.level,
        "factors": result.factors,
        "recommendation": result.recommendation,
        "createdAt": now,
    }
    documents = {risk_path: risk_document}
    if result.should_create_alert:
        alert_id = f"{user_id}_{day_id}_behavioral_review"
        documents[f"alerts/{alert_id}"] = {
            "userId": user_id,
            "title": result.alert_title or "Behavioral pattern needs review",
            "message": result.alert_message or result.recommendation,
            "severity": result.alert_severity,
            "read": False,
            "source": "behavioral_analysis",
            "assessmentDay": day_id,
            "createdAt": now,
        }
    return documents


def persist_analysis(*, firestore_client: Any, user_id: str, assessment_day: date, result: BehavioralAnalysisResponse) -> dict[str, Any]:
    """Write deterministic documents; repeated calls update the same daily records."""
    documents = build_analysis_documents(user_id=user_id, assessment_day=assessment_day, result=result)
    for path, payload in documents.items():
        segments = path.split("/")
        reference = firestore_client.collection(segments[0])
        index = 1
        while index < len(segments):
            reference = reference.document(segments[index])
            index += 1
            if index < len(segments):
                reference = reference.collection(segments[index])
                index += 1
        reference.set(payload, merge=True)
    return {"risk_assessment_saved": True, "alert_created": any(path.startswith("alerts/") for path in documents)}
