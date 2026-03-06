"""
Personality Schemas

Pydantic models for request/response validation in personality endpoints.
"""
from pydantic import BaseModel
from typing import List, Optional


class QuizAnswer(BaseModel):
    question_id: int
    answer: str  # "agree", "neutral", "disagree"


class QuizSubmission(BaseModel):
    user_id: str
    answers: List[QuizAnswer]


class PersonalityScores(BaseModel):
    openness: float
    conscientiousness: float
    extraversion: float
    agreeableness: float
    neuroticism: float


class PersonalityUpdateRequest(BaseModel):
    openness: Optional[float] = None
    conscientiousness: Optional[float] = None
    extraversion: Optional[float] = None
    agreeableness: Optional[float] = None
    neuroticism: Optional[float] = None
