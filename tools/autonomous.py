#!/usr/bin/env python3
"""Autonomous learning agent with a plan -> search -> learn -> verify -> reflect loop.

Uses local Ollama (llama3.2) to plan queries and reflect on progress, and
Wikipedia/DuckDuckGo to fetch sources. Each iteration learns a few pages and
asks the model whether the goal is covered. Embeddings are rebuilt once at end.

Usage:
    python tools/autonomous.py "godot 4 particle systems and VFX"
    python tools/autonomous.py "godot screen shake" --iterations 2 --per-iter 3
"""
import argparse
import json
import os
import re
import subprocess
import sys
import time

import requests

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PYTHON = sys.executable
OLLAMA = "http://localhost:11434"
MODEL = "llama3.2"
SEEN = os.path.join(ROOT, "knowledge", ".seen_urls")


def ollama(prompt: str, json_mode: bool = False, timeout: int = 120) -> str:
    try:
        payload = {"model": MODEL, "prompt": prompt, "stream": False}
        if json_mode:
            payload["format"] = "json"
        r = requests.post(OLLAMA + "/api/generate", json=payload, timeout=timeout)
        r.raise_for_status()
        return r.json().get("response", "").strip()
    except Exception as e:
        print("Ollama error:", e, file=sys.stderr)
        return ""


def clean_query(q: str) -> str:
    q = q.strip().strip("- ").strip("*").strip('"').strip("'").strip()
    q = re.sub(r"^\d+[\.\)]\s*", "", q)
    return q


def plan(goal: str, existing: list[str]) -> list[str]:
    prompt = ("List 4 short search queries (3-6 words each) to learn about: %s\n"
              "Already covered: %s\n"
              "Output one query per line, no numbers, no extra text."
              % (goal, ", ".join(existing[:10]) or "none"))
    raw = ollama(prompt, json_mode=False)
    out = []
    for ln in raw.splitlines():
        ln = clean_query(ln)
        if ln and len(ln) < 80 and " " in ln:
            out.append(ln)
    # Deduplicate while preserving order.
    seen_q = set()
    uniq = []
    for q in out:
        if q.lower() not in seen_q:
            seen_q.add(q.lower())
            uniq.append(q)
    if uniq:
        return uniq[:5]
    return [goal]


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
        except Exception:
            time.sleep(2 ** attempt)
    return urls


def search_wikipedia(query: str, limit: int) -> list[str]:
    urls = []
    try:
        r = requests.get("https://en.wikipedia.org/w/api.php",
                         params={"action": "opensearch", "search": query, "limit": limit, "namespace": 0, "format": "json"},
                         headers={"User-Agent": "learn-bot/1.0"}, timeout=20)
        data = r.json()
        if isinstance(data, list) and len(data) >= 4:
            for u in data[3]:
                if u not in urls:
                    urls.append(u)
    except Exception:
        pass
    return urls[:limit]


def search(query: str, limit: int) -> list[str]:
    urls = search_ddg(query, limit)
    if not urls:
        urls = search_wikipedia(query, limit)
    return urls


def load_seen() -> set:
    if os.path.exists(SEEN):
        with open(SEEN, "r", encoding="utf-8") as fh:
            return set(ln.strip() for ln in fh if ln.strip())
    return set()


def save_seen(seen: set) -> None:
    with open(SEEN, "w", encoding="utf-8") as fh:
        for u in sorted(seen):
            fh.write(u + "\n")


def run_learn(url: str, topic: str) -> bool:
    cmd = [PYTHON, os.path.join(ROOT, "tools", "learn.py"), "--summarize", "--topic", topic, url]
    try:
        subprocess.run(cmd, check=False, capture_output=True, text=True, timeout=180)
        return True
    except Exception as e:
        print("learn failed:", e, file=sys.stderr)
        return False


def count_chunks() -> int:
    try:
        d = json.load(open(os.path.join(ROOT, "knowledge", "vectors.json"), encoding="utf-8"))
        return len(d.get("entries", []))
    except Exception:
        return 0


def reflect(goal: str, learned: list[str]) -> tuple[bool, list[str]]:
    prompt = ("Goal: %s\nNewly learned sources: %s\n"
              "Is the goal sufficiently covered? Reply with YES or NO only."
              % (goal, "; ".join(learned) or "none"))
    raw = ollama(prompt, json_mode=False).upper()
    done = "YES" in raw
    return done, []


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("goal")
    ap.add_argument("--iterations", type=int, default=2)
    ap.add_argument("--per-iter", type=int, default=2)
    ap.add_argument("--max-sources", type=int, default=6)
    args = ap.parse_args()

    existing = []
    try:
        for f in os.listdir(os.path.join(ROOT, "knowledge")):
            if f.endswith(".md"):
                existing.append(f.replace(".md", ""))
    except Exception:
        pass

    seen = load_seen()
    before = count_chunks()
    all_learned = []

    for it in range(1, args.iterations + 1):
        if len(all_learned) >= args.max_sources:
            print("Reached max sources (%d). Stopping." % args.max_sources)
            break
        print("\n=== Iteration %d/%d ===" % (it, args.iterations))
        queries = plan(args.goal, existing)
        print("Plan:", queries)
        if not queries:
            print("No queries planned, stopping.")
            break

        learned_this = []
        for q in queries:
            if len(all_learned) >= args.max_sources:
                break
            print("\n-- Searching:", q)
            urls = search(q, args.per_iter)
            print("   urls:", len(urls))
            for u in urls:
                if len(all_learned) >= args.max_sources:
                    break
                if u in seen:
                    print("   skip (seen):", u)
                    continue
                print("   fetch:", u)
                if run_learn(u, q):
                    learned_this.append(u)
                    all_learned.append(u)
                    seen.add(u)
                    save_seen(seen)
                    time.sleep(1)

        existing = [f.replace(".md", "") for f in os.listdir(os.path.join(ROOT, "knowledge")) if f.endswith(".md")]

        done, _ = reflect(args.goal, learned_this)
        print("Reflect: done=%s" % done)
        if done:
            print("Goal covered. Stopping.")
            break

    print("\nRebuilding embeddings (once at end)...")
    subprocess.run([PYTHON, os.path.join(ROOT, "tools", "embed.py")], check=False,
                   capture_output=True, text=True, timeout=600)
    after = count_chunks()
    print("Chunks: %d -> %d (+%d)" % (before, after, after - before))
    print("\n=== Done. Learned %d sources total. ===" % len(all_learned))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
