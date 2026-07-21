#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
BACKUP="$CURSOR_HOME/ai-dev-kit-backup-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$CURSOR_HOME/agents" "$CURSOR_HOME/skills"

mkdir -p "$HOME/.local/bin" "$HOME/.local/share/ai-dev-kit/bin"
for cmd in ai-dev ai-dev-init ai-dev-project-index ai-dev-project-rules; do
  cp "$ROOT/bin/$cmd" "$HOME/.local/share/ai-dev-kit/bin/$cmd"
  chmod +x "$HOME/.local/share/ai-dev-kit/bin/$cmd"
  ln -sfn "$HOME/.local/share/ai-dev-kit/bin/$cmd" "$HOME/.local/bin/$cmd"
done

rm -rf "$HOME/.local/share/ai-dev-kit/project-rules-optional"
cp -r "$ROOT/source/project-rules-optional" "$HOME/.local/share/ai-dev-kit/project-rules-optional"

install_links() {
  local src_dir="$1" target_dir="$2" prefix="$3"
  shopt -s nullglob
  local -A valid_names=()
  for src in "$src_dir"/*; do
    local name base target
    base="$(basename "$src")"
    name="${prefix}${base}"
    valid_names["$name"]=1
    target="$target_dir/$name"

    if [[ -e "$target" || -L "$target" ]]; then
      if [[ -L "$target" && "$(readlink -f "$target" 2>/dev/null || true)" == "$(readlink -f "$src")" ]]; then
        continue
      fi
      mkdir -p "$BACKUP/$(basename "$target_dir")"
      mv "$target" "$BACKUP/$(basename "$target_dir")/$name"
    fi
    ln -s "$src" "$target"
  done

  # Clean up symlinks left behind by a source that was since renamed or removed
  # (e.g. a skill/agent directory renamed upstream) instead of leaving them broken.
  for target in "$target_dir/$prefix"*; do
    [[ -L "$target" ]] || continue
    local name
    name="$(basename "$target")"
    if [[ -z "${valid_names[$name]:-}" ]]; then
      mkdir -p "$BACKUP/$(basename "$target_dir")"
      mv "$target" "$BACKUP/$(basename "$target_dir")/$name"
    fi
  done
}

install_links "$ROOT/source/agents" "$CURSOR_HOME/agents" "ai-dev-"
install_links "$ROOT/source/skills" "$CURSOR_HOME/skills" "ai-dev-"

RULES_FILE="$ROOT/USER_RULES.txt"
COPIED=false
if command -v wl-copy >/dev/null 2>&1; then
  timeout 2 wl-copy < "$RULES_FILE" && COPIED=true
elif command -v xclip >/dev/null 2>&1; then
  timeout 2 xclip -selection clipboard < "$RULES_FILE" && COPIED=true
elif command -v xsel >/dev/null 2>&1; then
  timeout 2 xsel --clipboard --input < "$RULES_FILE" && COPIED=true
fi

printf '\nInstalled globally in Cursor:\n'
printf '  Agents: %s/agents/ai-dev-*\n' "$CURSOR_HOME"
printf '  Skills: %s/skills/ai-dev-*\n' "$CURSOR_HOME"
printf '\nRestart Cursor.\n'
printf 'Open Cursor Settings > Rules > User Rules and paste USER_RULES.txt once.\n'
if [[ "$COPIED" == true ]]; then
  printf 'The User Rules text is already copied to your clipboard.\n'
else
  printf 'User Rules file: %s\n' "$RULES_FILE"
fi
printf '\nCommands installed:\n  ai-dev (runs the three below in sequence)\n  ai-dev-init\n  ai-dev-project-index\n  ai-dev-project-rules\n'
printf '\nProject adapters, the local index, and project rules are created automatically on first agent task, or manually with: ai-dev .\n'
