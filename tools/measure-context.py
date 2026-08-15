#!/usr/bin/env python3
"""Measure the always-on AI context cost of a project (or of the kit's templates).

Usage:
  tools/measure-context.py [project]              # measure a seeded project
  tools/measure-context.py --templates [dir]      # measure the kit template library
  tools/measure-context.py [project] --sample app/Http/Controllers/UserController.php

Reports bytes and estimated tokens (bytes/4) for:
  - every alwaysApply: true rule (always in context);
  - the adapter files (CLAUDE.md, AGENTS.md, copilot-instructions.md);
  - rules whose globs attach to a sample file edit.
Exits 1 when the always-on estimate exceeds the budget (default 2000 tokens).
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

BUDGET_TOKENS = 2000
ADAPTERS = ["CLAUDE.md", "AGENTS.md", ".github/copilot-instructions.md"]


def tokens(n_bytes: int) -> int:
    return n_bytes // 4


def frontmatter(text: str) -> dict[str, str]:
    m = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
    if not m:
        return {}
    out: dict[str, str] = {}
    for line in m.group(1).splitlines():
        if ":" in line:
            key, _, value = line.partition(":")
            out[key.strip()] = value.strip().strip('"').strip("'")
    return out


def glob_to_regex(pattern: str) -> re.Pattern:
    # Expand one level of {a,b} braces, then translate ** / * / ? to regex.
    patterns = [pattern]
    m = re.search(r"\{([^}]*)\}", pattern)
    if m:
        patterns = [pattern[:m.start()] + alt + pattern[m.end():] for alt in m.group(1).split(",")]
    parts = []
    for pat in patterns:
        rx = ""
        i = 0
        while i < len(pat):
            c = pat[i]
            if pat[i:i + 3] == "**/":
                rx += "(?:.*/)?"
                i += 3
            elif pat[i:i + 2] == "**":
                rx += ".*"
                i += 2
            elif c == "*":
                rx += "[^/]*"
                i += 1
            elif c == "?":
                rx += "[^/]"
                i += 1
            else:
                rx += re.escape(c)
                i += 1
        parts.append(rx)
    return re.compile("^(?:" + "|".join(parts) + ")$")


def rule_files(base: Path):
    for path in sorted(base.rglob("*.mdc")):
        text = path.read_text(encoding="utf-8", errors="replace")
        yield path, frontmatter(text), len(text.encode("utf-8"))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("project", nargs="?", default=".")
    ap.add_argument("--templates", nargs="?", const="", metavar="DIR",
                    help="measure the kit template library instead of a project")
    ap.add_argument("--sample", default="app/Http/Controllers/UserController.php",
                    help="sample edited file for glob-attachment simulation")
    ap.add_argument("--budget", type=int, default=BUDGET_TOKENS)
    args = ap.parse_args()

    if args.templates is not None:
        base = Path(args.templates) if args.templates else \
            Path(__file__).resolve().parent.parent / "source" / "project-rules-optional" / "default"
        adapters: list[Path] = []
        label = f"templates: {base}"
    else:
        project = Path(args.project).resolve()
        base = project / ".cursor" / "rules"
        adapters = [project / a for a in ADAPTERS]
        label = f"project: {project}"

    if not base.is_dir():
        print(f"no rules directory at {base}")
        sys.exit(1)

    always_bytes = 0
    adapter_bytes = 0
    attached_bytes = 0
    print(f"Context measurement — {label}\n")
    print("Always-on rules (alwaysApply: true):")
    for path, meta, size in rule_files(base):
        if meta.get("alwaysApply") == "true":
            always_bytes += size
            print(f"  {size:>6} B ~{tokens(size):>5} tok  {path.relative_to(base)}")

    for adapter in adapters:
        if adapter.exists():
            size = len(adapter.read_bytes())
            adapter_bytes += size
            print(f"  {size:>6} B ~{tokens(size):>5} tok  {adapter.name} (adapter, not budgeted)")

    print(f"\nGlob-attached rules for a sample edit of `{args.sample}`:")
    for path, meta, size in rule_files(base):
        if meta.get("alwaysApply") == "true" or not meta.get("globs"):
            continue
        for glob in meta["globs"].split(","):
            if glob_to_regex(glob.strip()).match(args.sample):
                attached_bytes += size
                print(f"  {size:>6} B ~{tokens(size):>5} tok  {path.relative_to(base)}")
                break

    total_always = tokens(always_bytes)
    grand = always_bytes + adapter_bytes + attached_bytes
    print(f"\nAlways-on rules:      {always_bytes} B ~{total_always} tokens (budgeted)")
    if adapter_bytes:
        print(f"Adapters:             {adapter_bytes} B ~{tokens(adapter_bytes)} tokens")
    print(f"Sample-edit attached: {attached_bytes} B ~{tokens(attached_bytes)} tokens")
    print(f"Sample-edit total:    {grand} B ~{tokens(grand)} tokens")

    if total_always > args.budget:
        print(f"\nBUDGET EXCEEDED: always-on rules ~{total_always} tokens > {args.budget}")
        sys.exit(1)
    print(f"\nWithin budget ({args.budget} tokens of always-on rules).")


if __name__ == "__main__":
    main()
