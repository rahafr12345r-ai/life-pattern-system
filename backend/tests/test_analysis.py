from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_behavioral_analysis_returns_high_risk_for_repeated_concerns():
    response = client.post(
        "/v1/analysis/behavioral",
        json={
            "observations": [
                {"day": "2026-09-25", "mood": "Low", "sleep_hours": 4.5, "steps": 1200},
                {"day": "2026-09-26", "mood": "Low", "sleep_hours": 5, "steps": 1800},
                {"day": "2026-09-27", "mood": "Okay", "sleep_hours": 5.5, "steps": 2200},
            ]
        },
    )
    assert response.status_code == 200
    body = response.json()
    assert body["level"] == "high"
    assert body["score"] == 84
    assert body["observation_count"] == 3
    assert len(body["factors"]) == 3
    assert body["should_create_alert"] is True
    assert body["alert_severity"] == "warning"
    assert body["alert_title"] == "Behavioral pattern needs review"
    assert body["alert_message"]


def test_behavioral_analysis_returns_low_for_stable_observations():
    response = client.post(
        "/v1/analysis/behavioral",
        json={"observations": [{"day": "2026-09-25", "mood": "Good", "sleep_hours": 8, "steps": 7000}]},
    )
    assert response.status_code == 200
    assert response.json()["level"] == "low"
    assert response.json()["score"] == 0
    assert response.json()["should_create_alert"] is False
    assert response.json()["alert_severity"] == "info"
