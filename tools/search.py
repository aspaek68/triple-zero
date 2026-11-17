#!/usr/bin/env python3
"""Keyword search over the knowledge/ notes. Prints matching files and the
relevant lines. No embeddings, no vector DB: simple, dependency-free.

Usage:
    python tools/search.py "godot signals"
    python tools/search.py --top 5 "particle process material"
"""
import argparse
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KNOW = os.path.join(ROOT, "knowledge")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("query")
    ap.add_argument("--top", type=int, default=8)
    args = ap.parse_args()

    if not os.path.isdir(KNOW):
        print("No knowledge/ folder yet. Run tools/learn.py first.", file=sys.stderr)
        return 1

    terms = [t.lower() for t in re.findall(r"\w+", args.query)]
    if not terms:
        print("Empty query.", file=sys.stderr)
        return 2

    results = []
    for fn in os.listdir(KNOW):
        if not fn.endswith(".md"):
            continue
        path = os.path.join(KNOW, fn)
        with open(path, "r", encoding="utf-8", errors="replace") as fh:
            text = fh.read()
        low = text.lower()
        score = sum(low.count(t) for t in terms)
        if score == 0:
            continue
        # Find the best matching line for a snippet.
        snippet = ""
        for line in text.splitlines():
            if any(t in line.lower() for t in terms):
                snippet = line.strip()[:160]
                break
        results.append((score, fn, snippet))

    results.sort(reverse=True)
    if not results:
        print("No matches.")
        return 0
    for score, fn, snippet in results[:args.top]:
        print("%4d  %s" % (score, fn))
        if snippet:
            print("       " + snippet)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
