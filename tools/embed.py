#!/usr/bin/env python3
"""Builds a semantic index of knowledge/*.md using Ollama embeddings.

Requires Ollama running locally with an embedding model pulled, e.g.:
    ollama pull nomic-embed-text

Usage:
    python tools/embed.py
    python tools/embed.py --model nomic-embed-text
"""
import argparse
import json
import os
import re
import sys
import time

import requests

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KNOW = os.path.join(ROOT, "knowledge")
OUT = os.path.join(KNOW, "vectors.json")
OLLAMA = "http://localhost:11434"


def chunk(text: str, size: int = 600) -> list[str]:
    # Split on blank lines first, then hard-cut long blocks.
    blocks = [b.strip() for b in re.split(r"\n\s*\n", text) if b.strip()]
    out = []
    for b in blocks:
        if len(b) <= size:
            out.append(b)
        else:
            for i in range(0, len(b), size):
                out.append(b[i:i + size])
    return out


def embed(text: str, model: str) -> list[float]:
    r = requests.post(OLLAMA + "/api/embeddings", json={"model": model, "prompt": text}, timeout=60)
    r.raise_for_status()
    return r.json()["embedding"]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", default="nomic-embed-text")
    args = ap.parse_args()

    # Check Ollama.
    try:
        requests.get(OLLAMA + "/api/tags", timeout=5).raise_for_status()
    except Exception as e:
        print("Ollama not reachable at", OLLAMA, ":", e, file=sys.stderr)
        return 1

    entries = []
    for fn in sorted(os.listdir(KNOW)):
        if not fn.endswith(".md") or fn == "vectors.json":
            continue
        path = os.path.join(KNOW, fn)
        with open(path, "r", encoding="utf-8", errors="replace") as fh:
            text = fh.read()
        # Cap very large articles to keep indexing tractable.
        if len(text) > 20000:
            text = text[:20000] + "\n\n[... truncated ...]"
        chunks = chunk(text)
        print("Indexing %s (%d chunks)..." % (fn, len(chunks)), flush=True)
        for ci, c in enumerate(chunks):
            try:
                v = embed(c, args.model)
            except Exception as e:
                print("Embed failed for", fn, ":", e, file=sys.stderr)
                continue
            entries.append({"file": fn, "text": c, "vector": v})
            time.sleep(0.05)

    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump({"model": args.model, "entries": entries}, fh)
    print("Indexed %d chunks from %d files -> %s" % (len(entries), len(set(e["file"] for e in entries)), OUT))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
