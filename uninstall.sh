#!/usr/bin/env bash
set -euo pipefail
CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
find "$CURSOR_HOME/agents" -maxdepth 1 -type l -name 'ai-dev-*' -delete 2>/dev/null || true
find "$CURSOR_HOME/skills" -maxdepth 1 -type l -name 'ai-dev-*' -delete 2>/dev/null || true
echo "Removed global Cursor agents and skills. User Rules must be removed manually from Cursor Settings."


rm -f "$HOME/.local/bin/ai-dev" "$HOME/.local/bin/ai-dev-init" "$HOME/.local/bin/ai-dev-project-index" "$HOME/.local/bin/ai-dev-project-rules"
rm -rf "$HOME/.local/share/ai-dev-kit"
