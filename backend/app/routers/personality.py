from fastapi import APIRouter, HTTPException, status, Depends, Header
from pydantic import BaseModel
from typing import List, Optional, Dict
from ..database import SupabaseDB

router = APIRouter()


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


# Big 5 Questions mapping - each question maps to a trait and direction
# Positive questions: higher score means higher trait value
# Negative questions: higher score means lower trait value (reverse scored)
QUIZ_QUESTIONS = {
    1: {"trait": "openness", "direction": "positive", 
        "text": "I enjoy visiting new places and experiencing different cultures when I travel."},
    2: {"trait": "conscientiousness", "direction": "positive",
        "text": "I prefer trips that include museums, heritage sites, or other local experiences."},
    3: {"trait": "openness", "direction": "positive",
        "text": "I like my trips to be well organized with clear schedules and plans."},
    4: {"trait": "conscientiousness", "direction": "positive",
        "text": "I prefer following a planned itinerary rather than deciding activities spontaneously."},
    5: {"trait": "extraversion", "direction": "positive",
        "text": "I enjoy social activities such as events, nightlife, or group entertainment while traveling."},
    6: {"trait": "extraversion", "direction": "positive",
        "text": "I like traveling with others and participating in lively or group based activities."},
    7: {"trait": "agreeableness", "direction": "positive",
        "text": "I prefer travel activities that help everyone in the group feel comfortable and relaxed."},
    8: {"trait": "agreeableness", "direction": "positive",
        "text": "I enjoy calm experiences such as nature, food tasting, or wellness activities."},
    9: {"trait": "neuroticism", "direction": "negative",
        "text": "I feel more comfortable visiting places that are familiar, safe, and predictable."},
    10: {"trait": "neuroticism", "direction": "negative",
        "text": "I prefer avoiding risky or stressful travel situations."}
}


def calculate_personality_scores(answers: List[QuizAnswer]) -> PersonalityScores:
    """
    Calculate Big 5 personality scores from quiz answers
    Scores range from 0.0 (low) to 1.0 (high)
    """
    # Initialize scores for each trait
    trait_scores = {
        "openness": [],
        "conscientiousness": [],
        "extraversion": [],
        "agreeableness": [],
        "neuroticism": []
    }
    
    # Convert answers to numerical scores
    answer_map = {
        "agree": 1.0,
        "neutral": 0.5,
        "disagree": 0.0
    }
    
    for answer in answers:
        question = QUIZ_QUESTIONS.get(answer.question_id)
        if not question:
            continue
            
        trait = question["trait"]
        direction = question["direction"]
        score = answer_map.get(answer.answer.lower(), 0.5)
        
        # Reverse score for negative questions
        if direction == "negative":
            score = 1.0 - score
            
        trait_scores[trait].append(score)
    
    # Calculate average score for each trait
    final_scores = {}
    for trait, scores in trait_scores.items():
        if scores:
            final_scores[trait] = sum(scores) / len(scores)
        else:
            final_scores[trait] = 0.5  # Default to neutral if no answers
    
    return PersonalityScores(**final_scores)


@router.get("/questions")
async def get_quiz_questions():
    """
    Get all personality quiz questions
    """
    questions = []
    for q_id, q_data in sorted(QUIZ_QUESTIONS.items()):
        questions.append({
            "id": q_id,
            "text": q_data["text"]
        })
    
    return {
        "questions": questions,
        "total": len(questions)
    }


@router.post("/submit", response_model=PersonalityScores)
async def submit_quiz(submission: QuizSubmission):
    """
    Submit quiz answers and calculate personality scores
    Updates the user's profile with calculated scores
    Also saves individual answers to personality_answers table
    """
    try:
        # Validate that we have answers
        if not submission.answers:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No answers provided"
            )
        
        # Calculate personality scores
        scores = calculate_personality_scores(submission.answers)
        
        # Update user profile with personality scores
        db = SupabaseDB()
        update_data = {
            "openness": scores.openness,
            "conscientiousness": scores.conscientiousness,
            "extraversion": scores.extraversion,
            "agreeableness": scores.agreeableness,
            "neuroticism": scores.neuroticism
        }
        
        response = db.client.table("profiles").update(update_data).eq("id", submission.user_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User profile not found"
            )
        
        # Save individual answers to personality_answers table
        try:
            # First, delete old answers for this user
            db.client.table("personality_answers").delete().eq("user_id", submission.user_id).execute()
            
            # Insert new answers
            answers_to_insert = []
            for answer in submission.answers:
                question = QUIZ_QUESTIONS.get(answer.question_id)
                if question:
                    # Convert answer to value (agree=2, neutral=1, disagree=0)
                    answer_value = 2 if answer.answer.lower() == "agree" else (1 if answer.answer.lower() == "neutral" else 0)
                    
                    answers_to_insert.append({
                        "user_id": submission.user_id,
                        "question_id": answer.question_id,
                        "question_text": question["text"],
                        "answer_value": answer_value
                    })
            
            if answers_to_insert:
                db.client.table("personality_answers").insert(answers_to_insert).execute()
        except Exception as e:
            # Log but don't fail if personality_answers save fails
            print(f"Warning: Failed to save personality answers: {str(e)}")
        
        return scores
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to submit quiz: {str(e)}"
        )


@router.put("/update/{user_id}", response_model=PersonalityScores)
async def update_personality_scores(user_id: str, scores: PersonalityUpdateRequest):
    """
    Update personality scores for a user
    Allows partial updates - only provided fields will be updated
    """
    try:
        db = SupabaseDB()
        
        # Build update data with only provided fields
        update_data = {}
        if scores.openness is not None:
            update_data["openness"] = scores.openness
        if scores.conscientiousness is not None:
            update_data["conscientiousness"] = scores.conscientiousness
        if scores.extraversion is not None:
            update_data["extraversion"] = scores.extraversion
        if scores.agreeableness is not None:
            update_data["agreeableness"] = scores.agreeableness
        if scores.neuroticism is not None:
            update_data["neuroticism"] = scores.neuroticism
        
        if not update_data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No personality scores provided for update"
            )
        
        # Update profile
        response = db.client.table("profiles").update(update_data).eq("id", user_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User profile not found"
            )
        
        # Return updated scores
        profile = response.data[0]
        return PersonalityScores(
            openness=profile.get("openness", 0.5),
            conscientiousness=profile.get("conscientiousness", 0.5),
            extraversion=profile.get("extraversion", 0.5),
            agreeableness=profile.get("agreeableness", 0.5),
            neuroticism=profile.get("neuroticism", 0.5)
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update personality scores: {str(e)}"
        )


@router.get("/scores/{user_id}", response_model=PersonalityScores)
async def get_personality_scores(user_id: str):
    """
    Get personality scores for a user
    """
    try:
        db = SupabaseDB()
        
        response = db.client.table("profiles").select(
            "openness, conscientiousness, extraversion, agreeableness, neuroticism"
        ).eq("id", user_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User profile not found"
            )
        
        profile = response.data[0]
        
        return PersonalityScores(
            openness=profile.get("openness", 0.5),
            conscientiousness=profile.get("conscientiousness", 0.5),
            extraversion=profile.get("extraversion", 0.5),
            agreeableness=profile.get("agreeableness", 0.5),
            neuroticism=profile.get("neuroticism", 0.5)
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get personality scores: {str(e)}"
        )
