"""Orchestrates scoring and idempotent Firebase persistence."""

from datetime import date
from typing import Any

from .analysis_models import BehavioralAnalysisRequest, BehavioralAnalysisResponse
from .analysis_service import analyze_behavior
from .firebase_persistence import persist_analysis


def run_daily_analysis(
    *,
    user_id: str,
    assessment_day: date,
    payload: BehavioralAnalysisRequest,
    firestore_client: Any,
) -> tuple[BehavioralAnalysisResponse, dict[str, Any]]:
    """Analyze observations and persist the assessment and optional alert."""
    result = analyze_behavior(payload)
    persistence = persist_analysis(
        firestore_client=firestore_client,
        user_id=user_id,
        assessment_day=assessment_day,
        result=result,
    )
    return result, persistence
