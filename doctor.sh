#!/usr/bin/env bash
set -euo pipefail
CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
KIT_HOME="${AI_DEV_KIT_HOME:-$HOME/.local/share/ai-dev-kit}"
errors=0

if [[ -f "$KIT_HOME/VERSION" ]]; then
  echo "kit: ai-dev-kit $(cat "$KIT_HOME/VERSION")"
else
  echo "kit: VERSION missing at $KIT_HOME — rerun install.sh"
  errors=$((errors+1))
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "MISSING: python3 (required by ai-dev-project-index, ai-dev-project-rules, ai-dev-query)"
  errors=$((errors+1))
fi

for kind in agents skills; do
  count=0
  while IFS= read -r link; do
    count=$((count+1))
    if [[ ! -e "$link" ]]; then
      echo "BROKEN: $link -> $(readlink "$link")"
      errors=$((errors+1))
    fi
  done < <(find "$CURSOR_HOME/$kind" -maxdepth 1 -type l -name 'ai-dev-*' 2>/dev/null)
  echo "$kind: $count linked"
done

printf '\nCommands:\n'
for cmd in ai-dev ai-dev-init ai-dev-project-index ai-dev-project-rules ai-dev-query; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '  OK: %s -> %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf '  MISSING: %s (ensure ~/.local/bin is in PATH)\n' "$cmd"
    errors=$((errors+1))
  fi
done

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v python3 >/dev/null 2>&1 && [[ -f "$ROOT/tools/measure-context.py" ]]; then
  printf '\nAlways-on context budget (kit templates):\n'
  if ! python3 "$ROOT/tools/measure-context.py" --templates 2>/dev/null | tail -3; then
    echo "  WARNING: always-on template context exceeds the token budget"
  fi
fi
if command -v python3 >/dev/null 2>&1 && [[ -f "$ROOT/tools/lint_kit.py" ]]; then
  printf '\nKit content lint:\n'
  python3 "$ROOT/tools/lint_kit.py" | sed 's/^/  /' || errors=$((errors+1))
fi

if [[ $errors -eq 0 ]]; then
  echo "ai-dev-kit installation is healthy."
else
  echo "ai-dev-kit installation has $errors problem(s)."
  exit 1
fi
