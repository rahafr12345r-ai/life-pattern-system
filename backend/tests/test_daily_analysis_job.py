from datetime import date

from app.daily_analysis_job import _observation_from_document


class FakeDocument:
    id = "daily-1"

    def to_dict(self):
        return {"date": None, "mood": "Low", "sleepHours": 5.5, "activitySteps": 1200}


def test_daily_document_is_converted_to_observation():
    observation = _observation_from_document(FakeDocument())
    assert observation is not None
    assert observation.day == date.today()
    assert observation.mood == "Low"
    assert observation.sleep_hours == 5.5
    assert observation.steps == 1200
