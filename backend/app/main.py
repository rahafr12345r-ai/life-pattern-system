"""Entry point for the Life Pattern System FastAPI backend."""

import hmac
import os

from fastapi import FastAPI, Header, HTTPException

from .analysis_models import BehavioralAnalysisRequest, BehavioralAnalysisResponse, PersistBehavioralAnalysisRequest
from .analysis_pipeline import run_daily_analysis
from .analysis_service import analyze_behavior
from .daily_analysis_job import run_daily_analysis_job
from .firebase_client import get_firestore_client

app = FastAPI(
    title="Life Pattern System API",
    version="0.2.0",
    description="Backend foundation for behavioral pattern monitoring.",
)


@app.get("/health", tags=["system"])
def health() -> dict[str, str]:
    """Return a minimal unauthenticated readiness response."""
    return {"status": "ok", "phase": "behavioral-analysis-mvp"}


@app.get("/health/config", tags=["system"])
def configuration_status() -> dict[str, bool]:
    """Report configuration presence without returning secret values."""
    return {
        "firebase_project_configured": bool(os.getenv("FIREBASE_PROJECT_ID")),
        "firebase_credentials_configured": bool(os.getenv("GOOGLE_APPLICATION_CREDENTIALS")),
        "analysis_key_configured": bool(os.getenv("ANALYSIS_INTERNAL_KEY")),
    }


@app.post("/v1/analysis/behavioral", response_model=BehavioralAnalysisResponse, tags=["analysis"])
def behavioral_analysis(payload: BehavioralAnalysisRequest) -> BehavioralAnalysisResponse:
    """Score recent observations with explainable MVP rules."""
    return analyze_behavior(payload)


@app.post("/v1/analysis/behavioral/persist", tags=["analysis"])
def persist_behavioral_analysis(payload: PersistBehavioralAnalysisRequest, x_analysis_key: str | None = Header(default=None)) -> dict[str, object]:
    """Run and persist analysis for trusted internal jobs only."""
    configured_key = os.getenv("ANALYSIS_INTERNAL_KEY")
    if not configured_key:
        raise HTTPException(status_code=503, detail="Internal analysis persistence is not configured")
    if not x_analysis_key or not hmac.compare_digest(x_analysis_key, configured_key):
        raise HTTPException(status_code=401, detail="Unauthorized")
    try:
        result, persistence = run_daily_analysis(
            user_id=payload.user_id,
            assessment_day=payload.assessment_day,
            payload=payload,
            firestore_client=get_firestore_client(),
        )
    except Exception as exc:
        raise HTTPException(status_code=503, detail="Firebase persistence unavailable") from exc
    return {"result": result.model_dump(), "persistence": persistence}


@app.post("/v1/jobs/daily-analysis", tags=["jobs"])
def daily_analysis_job(x_analysis_key: str | None = Header(default=None)) -> dict[str, object]:
    """Run the daily patient analysis from a trusted scheduler."""
    configured_key = os.getenv("ANALYSIS_INTERNAL_KEY")
    if not configured_key:
        raise HTTPException(status_code=503, detail="Internal analysis persistence is not configured")
    if not x_analysis_key or not hmac.compare_digest(x_analysis_key, configured_key):
        raise HTTPException(status_code=401, detail="Unauthorized")
    try:
        summary = run_daily_analysis_job(firestore_client=get_firestore_client())
    except Exception as exc:
        raise HTTPException(status_code=503, detail="Daily analysis job unavailable") from exc
    return {"status": "completed", **summary}
