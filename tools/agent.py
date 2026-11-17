#!/usr/bin/env python3
"""A small autonomous learning agent.

Given a goal, it searches the web (DuckDuckGo, no API key), fetches the top
results, stores them as notes, and rebuilds the semantic index. It is NOT
truly autonomous (it runs when invoked), but it removes the manual URL step.

Usage:
    python tools/agent.py "godot 4 particle systems"
    python tools/agent.py "godot screen shake camera" --limit 3
"""
import argparse
import os
import subprocess
import sys
import time

import requests

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PYTHON = sys.executable


import time


def search_wikipedia(query: str, limit: int) -> list[str]:
    """Free, key-less search via Wikipedia's opensearch API."""
    urls = []
    try:
        r = requests.get(
            "https://en.wikipedia.org/w/api.php",
            params={"action": "opensearch", "search": query, "limit": limit, "namespace": 0, "format": "json"},
            headers={"User-Agent": "learn-bot/1.0"},
            timeout=20,
        )
        r.raise_for_status()
        data = r.json()
        if isinstance(data, list) and len(data) >= 4:
            for u in data[3]:
                if u not in urls:
                    urls.append(u)
    except Exception as e:
        print("Wikipedia search failed:", e, file=sys.stderr)
    return urls[:limit]


def search_ddg(query: str, limit: int) -> list[str]:
    urls = []
    for attempt in range(3):
        try:
            from ddgs import DDGS
            with DDGS() as ddgs:
                for r in ddgs.text(query, max_results=limit):
                    url = r.get("href") or r.get("url")
                    if url and url not in urls:
                        urls.append(url)
                    if len(urls) >= limit:
                        break
            if urls:
                return urls
        except Exception as e:
            print("DDG attempt %d failed: %s" % (attempt + 1, e), file=sys.stderr)
        time.sleep(2 ** attempt)
    return urls


def search(query: str, limit: int) -> list[str]:
    urls = search_wikipedia(query, limit)
    if not urls:
        urls = search_ddg(query, limit)
    return urls


def run_learn(url: str, topic: str) -> bool:
    cmd = [PYTHON, os.path.join(ROOT, "tools", "learn.py"), "--topic", topic, url]
    try:
        subprocess.run(cmd, check=False, capture_output=True, text=True, timeout=60)
        return True
    except Exception as e:
        print("learn failed:", e, file=sys.stderr)
        return False


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("goal")
    ap.add_argument("--limit", type=int, default=4)
    ap.add_argument("--no-embed", action="store_true")
    args = ap.parse_args()

    query = args.goal
    print("Searching:", query)
    # If the goal is actually a URL, learn it directly.
    if args.goal.startswith("http://") or args.goal.startswith("https://"):
        urls = [args.goal]
    else:
        urls = search(query, args.limit)
    print("Found %d urls" % len(urls))
    for u in urls:
        print("  -", u)

    ok = 0
    for u in urls:
        if run_learn(u, args.goal):
            ok += 1
    print("Learned %d/%d" % (ok, len(urls)))

    if not args.no_embed:
        print("Rebuilding embeddings...")
        subprocess.run([PYTHON, os.path.join(ROOT, "tools", "embed.py")], check=False)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
