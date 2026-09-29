"""Daily Firestore-backed analysis job for trusted scheduler calls."""

from datetime import date, datetime, timedelta, timezone
from typing import Any

from .analysis_models import BehavioralAnalysisRequest, DailyObservation
from .analysis_pipeline import run_daily_analysis


def _observation_from_document(document: Any) -> DailyObservation | None:
    data = document.to_dict() or {}
    timestamp = data.get("date")
    if hasattr(timestamp, "date"):
        day = timestamp.date()
    else:
        day = date.today()
    mood = data.get("mood")
    if mood not in {"Good", "Okay", "Low"}:
        return None
    return DailyObservation(
        day=day,
        mood=mood,
        sleep_hours=float(data.get("sleepHours") or 0),
        steps=int(data.get("activitySteps") or 0),
    )


def run_daily_analysis_job(*, firestore_client: Any, today: date | None = None) -> dict[str, int]:
    """Analyze each patient using the last seven daily records."""
    analysis_day = today or datetime.now(timezone.utc).date()
    start_day = analysis_day - timedelta(days=6)
    processed = 0
    skipped = 0
    patients = firestore_client.collection("users").where("role", "==", "Patient").stream()
    for patient in patients:
        patient_id = patient.id
        documents = (
            firestore_client.collection("behavioral_data")
            .document(patient_id)
            .collection("daily")
            .where("date", ">=", datetime.combine(start_day, datetime.min.time(), tzinfo=timezone.utc))
            .stream()
        )
        observations = [item for document in documents if (item := _observation_from_document(document)) is not None]
        if not observations:
            skipped += 1
            continue
        run_daily_analysis(
            user_id=patient_id,
            assessment_day=analysis_day,
            payload=BehavioralAnalysisRequest(observations=observations[-7:]),
            firestore_client=firestore_client,
        )
        processed += 1
    return {"processed": processed, "skipped": skipped}
