from datetime import date

from app.analysis_models import BehavioralAnalysisRequest
from app.analysis_pipeline import run_daily_analysis


class FakeDocument:
    def __init__(self, store, path):
        self.store = store
        self.path = path

    def collection(self, name):
        return FakeCollection(self.store, f"{self.path}/{name}")

    def document(self, name):
        return FakeDocument(self.store, f"{self.path}/{name}")

    def set(self, payload, merge=True):
        self.store[self.path] = {**self.store.get(self.path, {}), **payload}


class FakeCollection(FakeDocument):
    def document(self, name):
        return FakeDocument(self.store, f"{self.path}/{name}")


class FakeFirestore:
    def __init__(self):
        self.store = {}

    def collection(self, name):
        return FakeCollection(self.store, name)


def test_pipeline_scores_and_persists_high_result_with_alert():
    firestore = FakeFirestore()
    result, persistence = run_daily_analysis(
        user_id="patient-1",
        assessment_day=date(2026, 9, 30),
        payload=BehavioralAnalysisRequest(
            observations=[
                {"day": "2026-09-29", "mood": "Low", "sleep_hours": 4, "steps": 1000},
                {"day": "2026-09-30", "mood": "Low", "sleep_hours": 5, "steps": 1500},
            ]
        ),
        firestore_client=firestore,
    )
    assert result.level == "high"
    assert persistence == {"risk_assessment_saved": True, "alert_created": True}
    assert "risk_assessments/patient-1/daily/2026-09-30" in firestore.store
    assert "alerts/patient-1_2026-09-30_behavioral_review" in firestore.store
