#!/usr/bin/env python3
"""Semantic search over knowledge/ using Ollama embeddings + cosine similarity.

Usage:
    python tools/semsearch.py "how do godot particles work"
    python tools/semsearch.py --top 3 "post processing bloom"
"""
import argparse
import json
import math
import os
import sys

import requests

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KNOW = os.path.join(ROOT, "knowledge")
OUT = os.path.join(KNOW, "vectors.json")
OLLAMA = "http://localhost:11434"


def cosine(a, b):
    dot = sum(x * y for x, y in zip(a, b))
    na = math.sqrt(sum(x * x for x in a))
    nb = math.sqrt(sum(x * x for x in b))
    if na == 0 or nb == 0:
        return 0.0
    return dot / (na * nb)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("query")
    ap.add_argument("--top", type=int, default=5)
    ap.add_argument("--model", default=None)
    args = ap.parse_args()

    if not os.path.exists(OUT):
        print("No vectors.json. Run tools/embed.py first.", file=sys.stderr)
        return 1
    with open(OUT, "r", encoding="utf-8") as fh:
        data = json.load(fh)
    model = args.model or data["model"]
    entries = data["entries"]

    r = requests.post(OLLAMA + "/api/embeddings", json={"model": model, "prompt": args.query}, timeout=60)
    r.raise_for_status()
    qv = r.json()["embedding"]

    scored = sorted(entries, key=lambda e: cosine(qv, e["vector"]), reverse=True)
    for e in scored[:args.top]:
        print("%.3f  %s" % (cosine(qv, e["vector"]), e["file"]))
        print("       " + e["text"].replace("\n", " ")[:200])
        print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
