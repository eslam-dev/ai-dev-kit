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
  # Plain-string membership set instead of an associative array (`declare -A`
  # needs bash 4+; macOS ships bash 3.2 as /bin/bash, so this must stay 3.2-safe).
  local valid_names=$'\n'
  for src in "$src_dir"/*; do
    local name base target
    base="$(basename "$src")"
    name="${prefix}${base}"
    valid_names="${valid_names}${name}"$'\n'
    target="$target_dir/$name"

    # $src is always an absolute path (built from $ROOT), so a plain `readlink`
    # (no -f) already returns a directly comparable value on both GNU and BSD/macOS.
    if [[ -e "$target" || -L "$target" ]]; then
      if [[ -L "$target" && "$(readlink "$target" 2>/dev/null || true)" == "$src" ]]; then
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
    case "$valid_names" in
      *$'\n'"$name"$'\n'*) ;;
      *)
        mkdir -p "$BACKUP/$(basename "$target_dir")"
        mv "$target" "$BACKUP/$(basename "$target_dir")/$name"
        ;;
    esac
  done
}

install_links "$ROOT/source/agents" "$CURSOR_HOME/agents" "ai-dev-"
install_links "$ROOT/source/skills" "$CURSOR_HOME/skills" "ai-dev-"

RULES_FILE="$ROOT/USER_RULES.txt"
COPIED=false
if command -v pbcopy >/dev/null 2>&1; then
  pbcopy < "$RULES_FILE" && COPIED=true
elif command -v wl-copy >/dev/null 2>&1; then
  timeout 2 wl-copy < "$RULES_FILE" && COPIED=true
elif command -v xclip >/dev/null 2>&1; then
  timeout 2 xclip -selection clipboard < "$RULES_FILE" && COPIED=true
elif command -v xsel >/dev/null 2>&1; then
  timeout 2 xsel --clipboard --input < "$RULES_FILE" && COPIED=true
fi

printf '\nInstall complete — nothing else required.\n'
printf 'Every project gets its rules, agents, and index automatically on first task (or run: ai-dev .).\n'
printf '\nInstalled:\n'
printf '  Agents: %s/agents/ai-dev-*\n' "$CURSOR_HOME"
printf '  Skills: %s/skills/ai-dev-*\n' "$CURSOR_HOME"
printf '  Commands: ai-dev, ai-dev-init, ai-dev-project-index, ai-dev-project-rules\n'

printf '\nIf you use Cursor: restart it to pick up the new agents/skills.\n'

printf '\nOptional, one-time, and global — skip it entirely if you only care about\n'
printf 'per-project rules (already fully automatic, no action needed):\n'
if [[ "$COPIED" == true ]]; then
  printf '  USER_RULES.txt is already on your clipboard. Paste it into Cursor Settings > Rules > User Rules if you want it applied to every project by default.\n'
else
  printf '  Paste %s into Cursor Settings > Rules > User Rules if you want it applied to every project by default.\n' "$RULES_FILE"
fi
