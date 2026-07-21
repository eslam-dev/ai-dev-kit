#!/usr/bin/env bash
set -euo pipefail
CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
errors=0
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
if [[ $errors -eq 0 ]]; then
  echo "Cursor global integration is healthy."
else
  exit 1
fi


printf '\nCommands:\n'
for cmd in ai-dev ai-dev-init ai-dev-project-index ai-dev-project-rules; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '  OK: %s -> %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf '  MISSING: %s (ensure ~/.local/bin is in PATH)\n' "$cmd"
  fi
done
