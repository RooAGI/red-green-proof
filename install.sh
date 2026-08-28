#!/usr/bin/env bash
# Install the red-green-proof skill for Claude Code and/or Codex.
#
#   ./install.sh                 # both, user-level (~/.claude, ~/.codex)
#   ./install.sh --claude        # Claude Code only
#   ./install.sh --codex         # Codex only
#   ./install.sh --project DIR   # install into DIR/.claude/skills (repo-local)
#   ./install.sh --link          # symlink instead of copy (edits track this repo)
#   ./install.sh --uninstall     # remove what this script installed

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAME="red-green-proof"

DO_CLAUDE=0
DO_CODEX=0
LINK=0
UNINSTALL=0
PROJECT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --claude)    DO_CLAUDE=1; shift ;;
    --codex)     DO_CODEX=1; shift ;;
    --link)      LINK=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    --project)   PROJECT_DIR="${2:?--project needs a directory}"; DO_CLAUDE=1; shift 2 ;;
    -h|--help)   sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

# default: both
if [[ $DO_CLAUDE -eq 0 && $DO_CODEX -eq 0 ]]; then
  DO_CLAUDE=1
  DO_CODEX=1
fi

place() { # place <src-file> <dest-file>
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  if [[ $LINK -eq 1 ]]; then
    ln -s "$src" "$dest"
    echo "  linked  $dest"
  else
    cp "$src" "$dest"
    echo "  copied  $dest"
  fi
}

if [[ $DO_CLAUDE -eq 1 ]]; then
  if [[ -n "$PROJECT_DIR" ]]; then
    CLAUDE_DIR="$PROJECT_DIR/.claude/skills/$NAME"
  else
    CLAUDE_DIR="$HOME/.claude/skills/$NAME"
  fi
  if [[ $UNINSTALL -eq 1 ]]; then
    rm -rf "$CLAUDE_DIR"
    echo "Claude Code: removed $CLAUDE_DIR"
  else
    echo "Claude Code -> $CLAUDE_DIR"
    place "$SRC/SKILL.md" "$CLAUDE_DIR/SKILL.md"
    echo "  invoke with: /$NAME"
  fi
fi

if [[ $DO_CODEX -eq 1 ]]; then
  CODEX_PROMPT="$HOME/.codex/prompts/$NAME.md"
  if [[ $UNINSTALL -eq 1 ]]; then
    rm -f "$CODEX_PROMPT"
    echo "Codex: removed $CODEX_PROMPT"
  else
    echo "Codex -> $CODEX_PROMPT"
    place "$SRC/prompts/$NAME.md" "$CODEX_PROMPT"
    echo "  invoke with: /$NAME"
  fi
fi

echo "done."
