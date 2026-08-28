from fastapi import APIRouter, Depends

from app.core.security import require_api_key
from app.schemas.assistant import AskRequest, AskResponse, CitationOut
from app.services.assistant.pipeline import answer_question
from app.services.assistant.retrieval import Retriever, get_retriever

router = APIRouter(prefix="/assistant", tags=["assistant"])


def retriever_dependency() -> Retriever:
    # Indirected so tests can override it with a fake retriever (no DB in CI).
    return get_retriever()


@router.post("/ask", response_model=AskResponse)
async def ask(
    payload: AskRequest,
    retriever: Retriever = Depends(retriever_dependency),
    _=Depends(require_api_key),
):
    answer, retrieved = answer_question(
        payload.question, retriever=retriever, top_k=payload.top_k
    )
    return AskResponse(
        answer=answer.text,
        grounded=answer.grounded,
        citations=[CitationOut(slug=c.slug, title=c.title) for c in answer.citations],
        retrieved_chunks=retrieved,
        backend=answer.backend,
    )
