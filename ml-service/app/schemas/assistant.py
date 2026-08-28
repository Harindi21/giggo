from pydantic import BaseModel, Field


class AskRequest(BaseModel):
    question: str = Field(min_length=1, max_length=1000)
    top_k: int | None = Field(default=None, ge=1, le=20)


class CitationOut(BaseModel):
    slug: str
    title: str


class AskResponse(BaseModel):
    answer: str
    grounded: bool  # False = refusal (nothing relevant in the Knowledge Hub)
    citations: list[CitationOut] = []
    retrieved_chunks: int
    backend: str
