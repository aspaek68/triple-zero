#!/usr/bin/env python3
"""Fetches a web page (or local file), extracts its text, and stores a
markdown note under knowledge/. Lightweight, no vector DB, no LLM: the
summary is the first ~2000 chars plus headings, which is enough for a
human/agent to skim later.

Usage:
    python tools/learn.py https://docs.godotengine.org/.../nodes.html
    python tools/learn.py --topic "godot signals" https://...
    python tools/learn.py --file C:/path/to/doc.pdf
"""
import argparse
import hashlib
import os
import re
import sys
from datetime import datetime
from urllib.parse import urlparse

import requests
from bs4 import BeautifulSoup

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KNOW = os.path.join(ROOT, "knowledge")


def slugify(text: str) -> str:
    text = re.sub(r"[^a-zA-Z0-9]+", "-", text).strip("-").lower()
    return text[:60] or "note"


def fetch_url(url: str) -> tuple[str, str]:
    r = requests.get(url, timeout=30, headers={"User-Agent": "learn-bot/1.0"})
    r.raise_for_status()
    soup = BeautifulSoup(r.text, "html.parser")
    title = (soup.title.string.strip() if soup.title and soup.title.string else urlparse(url).netloc)
    for tag in soup(["script", "style", "nav", "footer", "header", "aside"]):
        tag.decompose()
    text = soup.get_text("\n", strip=True)
    text = re.sub(r"\n{3,}", "\n\n", text)
    # If the page is JS-rendered and came back nearly empty, render it.
    if len(text) < 500:
        try:
            from playwright.sync_api import sync_playwright
            with sync_playwright() as p:
                browser = p.chromium.launch(headless=True)
                page = browser.new_page()
                page.goto(url, wait_until="networkidle", timeout=30000)
                html = page.content()
                browser.close()
            soup = BeautifulSoup(html, "html.parser")
            if soup.title and soup.title.string:
                title = soup.title.string.strip()
            for tag in soup(["script", "style", "nav", "footer", "header", "aside"]):
                tag.decompose()
            text = re.sub(r"\n{3,}", "\n\n", soup.get_text("\n", strip=True))
        except Exception as e:
            print("Playwright fallback failed: %s" % e, file=sys.stderr)
    return title, text


def fetch_file(path: str) -> tuple[str, str]:
    if path.lower().endswith(".pdf"):
        from pypdf import PdfReader
        reader = PdfReader(path)
        pages = [p.extract_text() or "" for p in reader.pages]
        return os.path.basename(path), "\n\n".join(pages)
    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        return os.path.basename(path), fh.read()


def summarise(text: str, max_chars: int = 2000) -> str:
    if len(text) <= max_chars:
        return text
    # Keep headings-ish lines + a truncated body.
    lines = text.splitlines()
    head = [ln for ln in lines if ln and len(ln) < 80 and ln[0].isupper()][:20]
    body = text[:max_chars]
    return "\n".join(head) + "\n\n---\n\n" + body + "\n\n[... truncated ...]"


def summarize(text: str, topic: str, model: str = "llama3.2") -> str:
    """Uses local Ollama to condense the text into a concise note. Returns
    the original text (truncated) if Ollama is unavailable."""
    try:
        import requests
        prompt = ("Summarise the following text about '%s' into a concise, "
                  "well-structured markdown note (max ~400 words). Keep key "
                  "facts, APIs, and examples. Text:\n\n%s" % (topic, text[:6000]))
        r = requests.post("http://localhost:11434/api/generate",
                          json={"model": model, "prompt": prompt, "stream": False},
                          timeout=120)
        r.raise_for_status()
        out = r.json().get("response", "").strip()
        if out:
            return out
    except Exception as e:
        print("Summarise skipped (%s)" % e, file=sys.stderr)
    return summarise(text, 2000)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("source", nargs="?")
    ap.add_argument("--topic", default="")
    ap.add_argument("--file", default="")
    ap.add_argument("--max", type=int, default=2000)
    ap.add_argument("--summarize", action="store_true", help="Condense with local Ollama")
    args = ap.parse_args()

    if args.file:
        title, text = fetch_file(args.file)
        origin = args.file
    elif args.source:
        title, text = fetch_url(args.source)
        origin = args.source
    else:
        print("Provide a URL or --file.", file=sys.stderr)
        return 2

    topic = args.topic or title
    slug = slugify(topic)
    os.makedirs(KNOW, exist_ok=True)
    out_path = os.path.join(KNOW, slug + ".md")
    # Avoid overwriting: append a hash suffix if needed.
    if os.path.exists(out_path):
        h = hashlib.sha1(origin.encode()).hexdigest()[:6]
        out_path = os.path.join(KNOW, "%s-%s.md" % (slug, h))

    body = summarize(text, topic) if args.summarize else summarise(text, args.max)
    with open(out_path, "w", encoding="utf-8") as fh:
        fh.write("# %s\n\n" % topic)
        fh.write("- **Source**: %s\n" % origin)
        fh.write("- **Fetched**: %s\n\n" % datetime.now().isoformat(timespec="seconds"))
        fh.write(body + "\n")

    print("Saved:", os.path.relpath(out_path, ROOT))
    print("Chars:", len(text))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
