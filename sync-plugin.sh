#!/usr/bin/env bash
# Copy the canonical skill into the Claude Code, Codex, and Agy plugin tree.
#
# SKILL.md at the repo root is the source of truth (it is also the basis for
# the condensed Codex prompt in prompts/). The plugin marketplaces need their
# own copy at plugins/red-green-proof/skills/red-green-proof/SKILL.md. Run this
# after editing the root SKILL.md, and commit both.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_SKILL="$SRC/SKILL.md"
PLUGIN_SKILL="$SRC/plugins/red-green-proof/skills/red-green-proof/SKILL.md"
AGY_SKILL="$SRC/skills/red-green-proof/SKILL.md"

if [[ "${1:-}" == "--check" ]]; then
  if cmp -s "$ROOT_SKILL" "$PLUGIN_SKILL" && cmp -s "$ROOT_SKILL" "$AGY_SKILL"; then
    echo "in sync"
    exit 0
  fi
  echo "OUT OF SYNC: a packaged skill differs from $ROOT_SKILL" >&2
  echo "run ./sync-plugin.sh to update it" >&2
  exit 1
fi

mkdir -p "$(dirname "$PLUGIN_SKILL")"
cp "$ROOT_SKILL" "$PLUGIN_SKILL"
echo "synced  $PLUGIN_SKILL"
mkdir -p "$(dirname "$AGY_SKILL")"
cp "$ROOT_SKILL" "$AGY_SKILL"
echo "synced  $AGY_SKILL"
