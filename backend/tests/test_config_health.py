from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_config_health_reports_presence_only(monkeypatch):
    monkeypatch.setenv("FIREBASE_PROJECT_ID", "demo-project")
    monkeypatch.setenv("GOOGLE_APPLICATION_CREDENTIALS", "/secure/service-account.json")
    monkeypatch.setenv("ANALYSIS_INTERNAL_KEY", "secret-value")
    response = client.get("/health/config")
    assert response.status_code == 200
    assert response.json() == {
        "firebase_project_configured": True,
        "firebase_credentials_configured": True,
        "analysis_key_configured": True,
    }
    assert "secret-value" not in response.text
    assert "/secure/service-account.json" not in response.text
