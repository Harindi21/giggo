"""Select the answer backend from config, with a safe default (ADR-0013).

Default ``local`` is the keyless extractive answerer. A hosted LLM backend is the
swap-in; until one is wired we log and fall back to extractive, so the assistant
always answers rather than erroring - mirroring the sentiment/embedding seams.
"""

from __future__ import annotations

import logging

from app.core.config import settings

from .base import Answerer
from .extractive import LocalExtractiveAnswerer

logger = logging.getLogger(__name__)

_LOCAL_BACKENDS = {"local", "extractive", "local-extractive"}


def build_answerer(backend: str | None = None) -> Answerer:
    backend = (backend or settings.assistant_backend or "local").lower()
    if backend in _LOCAL_BACKENDS:
        return LocalExtractiveAnswerer()
    # Hosted LLM backends are not wired yet; fall back rather than fail.
    logger.warning(
        "Assistant backend %r is not available yet; using the local extractive answerer.",
        backend,
    )
    return LocalExtractiveAnswerer()


_answerer: Answerer | None = None


def get_answerer() -> Answerer:
    global _answerer
    if _answerer is None:
        _answerer = build_answerer()
    return _answerer
