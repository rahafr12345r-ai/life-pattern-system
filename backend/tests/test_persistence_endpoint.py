from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


PAYLOAD = {
    "user_id": "patient-1",
    "assessment_day": "2026-09-30",
    "observations": [{"day": "2026-09-30", "mood": "Good", "sleep_hours": 8, "steps": 7000}],
}


def test_persistence_endpoint_is_disabled_without_internal_key(monkeypatch):
    monkeypatch.delenv("ANALYSIS_INTERNAL_KEY", raising=False)
    response = client.post("/v1/analysis/behavioral/persist", json=PAYLOAD)
    assert response.status_code == 503


def test_persistence_endpoint_rejects_wrong_key(monkeypatch):
    monkeypatch.setenv("ANALYSIS_INTERNAL_KEY", "correct-key")
    response = client.post("/v1/analysis/behavioral/persist", headers={"x-analysis-key": "wrong-key"}, json=PAYLOAD)
    assert response.status_code == 401
