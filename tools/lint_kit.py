#!/usr/bin/env python3
"""Static lint for the kit's own content — templates, agents, skills.

Checks (no LLM, runs in seconds):
  - every .mdc template has valid frontmatter (description, alwaysApply,
    globs when not always-on), parseable YAML-lite;
  - every skill dir has SKILL.md with name/description frontmatter,
    name matches the directory, kebab-case <=64 chars, description <=1024;
  - every agent .md has a title;
  - no dangling references: skill/agent names mentioned in kit content exist;
  - template library stays inside the always-on token budget (via
    measure-context.py's logic being separate; here we only assert structure).
Exit 1 on any finding.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TEMPLATES = ROOT / "source" / "project-rules-optional" / "default"
SKILLS = ROOT / "source" / "skills"
AGENTS = ROOT / "source" / "agents"

NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
findings: list[str] = []


def frontmatter(text: str) -> dict[str, str] | None:
    m = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
    if not m:
        return None
    out = {}
    for line in m.group(1).splitlines():
        if ":" in line:
            key, _, value = line.partition(":")
            out[key.strip()] = value.strip().strip('"').strip("'")
    return out


def lint_templates() -> None:
    for path in sorted(TEMPLATES.rglob("*.mdc")):
        rel = path.relative_to(TEMPLATES)
        text = path.read_text(encoding="utf-8", errors="replace")
        meta = frontmatter(text)
        if meta is None:
            findings.append(f"template {rel}: missing/invalid frontmatter")
            continue
        if not meta.get("description"):
            findings.append(f"template {rel}: missing description")
        if meta.get("alwaysApply") not in {"true", "false"}:
            findings.append(f"template {rel}: alwaysApply must be true|false")
        if meta.get("alwaysApply") == "false" and not meta.get("globs") and "when" not in meta.get("description", "").lower() and "apply" not in meta.get("description", "").lower():
            findings.append(f"template {rel}: not always-on but has neither globs nor a trigger-style description")
        if "<" in meta.get("description", "") and ">" in meta.get("description", ""):
            findings.append(f"template {rel}: description contains markup")
        body = text.split("---", 2)[-1]
        if not re.search(r"(?m)^# ", body):
            findings.append(f"template {rel}: body has no # title")
        if len(text.encode()) > 4096:
            findings.append(f"template {rel}: over 4KB — split or compress")


def lint_skills() -> set[str]:
    names = set()
    for skill_dir in sorted(p for p in SKILLS.iterdir() if p.is_dir()):
        md = skill_dir / "SKILL.md"
        if not md.exists():
            findings.append(f"skill {skill_dir.name}: missing SKILL.md")
            continue
        meta = frontmatter(md.read_text(encoding="utf-8", errors="replace"))
        if meta is None:
            findings.append(f"skill {skill_dir.name}: missing frontmatter")
            continue
        name = meta.get("name", "")
        names.add(name)
        if name != skill_dir.name:
            findings.append(f"skill {skill_dir.name}: frontmatter name '{name}' != directory (dead identity)")
        if not NAME_RE.match(name or "") or len(name) > 64:
            findings.append(f"skill {skill_dir.name}: name must be kebab-case <=64 chars")
        desc = meta.get("description", "")
        if not desc:
            findings.append(f"skill {skill_dir.name}: missing description")
        elif len(desc) > 1024:
            findings.append(f"skill {skill_dir.name}: description over 1024 chars")
    return names


def lint_agents() -> set[str]:
    names = set()
    for path in sorted(AGENTS.glob("*.md")):
        names.add(path.stem)
        text = path.read_text(encoding="utf-8", errors="replace")
        if not re.search(r"(?m)^# ", text):
            findings.append(f"agent {path.name}: no # title")
    return names


def lint_references(skills: set[str], agents: set[str]) -> None:
    """Backtick-quoted kebab-case identifiers must resolve to a real skill/agent."""
    known = skills | agents
    # Non-skill/agent identifiers legitimately used in content.
    allowed = {
        "ai-dev", "ai-dev-init", "ai-dev-project-index", "ai-dev-project-rules",
        "ai-dev-query", "run-project-team", "route-task",
    } | known
    pattern = re.compile(r"`([a-z][a-z0-9]+(?:-[a-z0-9]+){1,5})`")
    scan = list(AGENTS.glob("*.md")) + list(SKILLS.rglob("SKILL.md")) + list(TEMPLATES.rglob("*.mdc"))
    suspects: dict[str, list[str]] = {}
    for path in scan:
        text = path.read_text(encoding="utf-8", errors="replace")
        for m in pattern.finditer(text):
            token = m.group(1)
            # Only enforce tokens that LOOK like kit skill/agent names:
            # engineer/agent/reviewer/team suffixes or exact near-misses.
            if token in allowed:
                continue
            if re.search(r"(engineer|agent|reviewer|developer|tester|lead|architect|maintainer|router|cto)$", token) \
               or token.replace("-", "") in {k.replace("-", "") for k in known}:
                suspects.setdefault(token, []).append(str(path.relative_to(ROOT)))
    for token, paths in sorted(suspects.items()):
        findings.append(f"dangling reference `{token}` in: {', '.join(sorted(set(paths))[:3])}")


def main() -> None:
    lint_templates()
    skills = lint_skills()
    agents = lint_agents()
    lint_references(skills, agents)
    if findings:
        print(f"{len(findings)} finding(s):")
        for f in findings:
            print(f"  - {f}")
        sys.exit(1)
    print(f"kit lint clean: {len(list(TEMPLATES.rglob('*.mdc')))} templates, {len(skills)} skills, {len(agents)} agents.")


if __name__ == "__main__":
    main()
