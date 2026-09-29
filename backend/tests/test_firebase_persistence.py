from datetime import date

from app.analysis_models import BehavioralAnalysisResponse
from app.firebase_persistence import build_analysis_documents


def result(*, alert: bool) -> BehavioralAnalysisResponse:
    return BehavioralAnalysisResponse(
        score=70 if alert else 0,
        level="high" if alert else "low",
        factors=["Short sleep recorded on 2 day(s)"] if alert else [],
        recommendation="Review the pattern with your care team." if alert else "Continue your routine.",
        observation_count=2,
        should_create_alert=alert,
        alert_severity="warning" if alert else "info",
        alert_title="Behavioral pattern needs review" if alert else None,
        alert_message="Repeated changes detected." if alert else None,
    )


def test_high_result_uses_stable_daily_alert_id():
    documents = build_analysis_documents(user_id="patient-1", assessment_day=date(2026, 9, 30), result=result(alert=True))
    assert "risk_assessments/patient-1/daily/2026-09-30" in documents
    assert "alerts/patient-1_2026-09-30_behavioral_review" in documents
    assert documents["alerts/patient-1_2026-09-30_behavioral_review"]["read"] is False


def test_low_result_does_not_create_alert_document():
    documents = build_analysis_documents(user_id="patient-1", assessment_day=date(2026, 9, 30), result=result(alert=False))
    assert list(documents) == ["risk_assessments/patient-1/daily/2026-09-30"]
