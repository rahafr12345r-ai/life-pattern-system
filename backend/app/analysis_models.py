"""Typed contracts for the first deterministic behavioral analysis pass."""

from datetime import date
from typing import Literal

from pydantic import BaseModel, Field


class DailyObservation(BaseModel):
    day: date
    mood: Literal["Good", "Okay", "Low"]
    sleep_hours: float = Field(ge=0, le=24)
    steps: int = Field(ge=0, le=200_000)


class BehavioralAnalysisRequest(BaseModel):
    observations: list[DailyObservation] = Field(min_length=1, max_length=30)


class PersistBehavioralAnalysisRequest(BehavioralAnalysisRequest):
    user_id: str = Field(min_length=1, max_length=128)
    assessment_day: date


class BehavioralAnalysisResponse(BaseModel):
    score: int = Field(ge=0, le=100)
    level: Literal["low", "medium", "high"]
    factors: list[str]
    recommendation: str
    observation_count: int
    should_create_alert: bool
    alert_severity: Literal["info", "warning"]
    alert_title: str | None = None
    alert_message: str | None = None
