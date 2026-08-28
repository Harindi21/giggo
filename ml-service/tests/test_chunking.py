from app.services.assistant.chunking import chunk_text

import pytest


def test_empty_text_yields_no_chunks():
    assert chunk_text("") == []
    assert chunk_text("   \n  ") == []


def test_short_text_is_a_single_normalised_chunk():
    out = chunk_text("Fix   a  leaking\npipe", chunk_size=800)
    assert out == ["Fix a leaking pipe"]


def test_long_text_splits_into_overlapping_chunks():
    text = " ".join(f"word{i}" for i in range(400))  # well over 800 chars
    chunks = chunk_text(text, chunk_size=200, overlap=50)
    assert len(chunks) > 1
    # Every chunk respects the size bound (snapping only ever shrinks it).
    assert all(len(c) <= 200 for c in chunks)
    # Consecutive chunks overlap: the tail of one reappears at the head of the next.
    first_tail = chunks[0].split()[-1]
    assert first_tail in chunks[1].split()


def test_full_text_is_covered_by_the_chunks():
    text = " ".join(f"w{i}" for i in range(300))
    chunks = chunk_text(text, chunk_size=150, overlap=30)
    assert text.split()[0] in chunks[0]
    assert text.split()[-1] in chunks[-1]


def test_invalid_parameters_raise():
    with pytest.raises(ValueError):
        chunk_text("x", chunk_size=0)
    with pytest.raises(ValueError):
        chunk_text("x", chunk_size=100, overlap=100)
