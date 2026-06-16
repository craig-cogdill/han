#!/usr/bin/env bash
# update-pi-models.sh — write model: frontmatter into plugin-pi/agents/ by reading
# the model alias from each source agent in plugin/agents/ and mapping it to the
# configured provider model via env vars.
#
# Maps: opus → POWERFUL_MODEL, sonnet → DEFAULT_MODEL, haiku → LITE_MODEL
#
# Run from the repository root:
#   ./scripts/update-pi-models.sh
#
# Requires POWERFUL_MODEL, DEFAULT_MODEL, and LITE_MODEL to be set in the environment.
# Add them to ~/.zshenv:
#   export POWERFUL_MODEL="google/gemini-2.5-pro"
#   export DEFAULT_MODEL="google/gemini-2.5-flash"
#   export LITE_MODEL="google/gemini-2.5-flash-lite"
#
# Accepts any pi-compatible model identifier: provider/modelId or fuzzy name.
# Re-run whenever you change the env vars to apply the new models.

set -euo pipefail

REPO_ROOT="$(pwd)"
AGENTS_DIR="$REPO_ROOT/plugin-pi/agents"
SRC_AGENTS_DIR="$REPO_ROOT/han.core/agents"

POWERFUL="${POWERFUL_MODEL:?POWERFUL_MODEL is not set}"
DEFAULT="${DEFAULT_MODEL:?DEFAULT_MODEL is not set}"
LITE="${LITE_MODEL:?LITE_MODEL is not set}"

if [ ! -d "$AGENTS_DIR" ]; then
  echo "Error: $AGENTS_DIR not found. Run 'mise run build' first." >&2
  exit 1
fi

if [ ! -d "$SRC_AGENTS_DIR" ]; then
  echo "Error: $SRC_AGENTS_DIR not found" >&2
  exit 1
fi

# Upsert model: line in YAML frontmatter. Removes any existing model: line,
# then injects the new one immediately before the closing ---.
set_model() {
  local file="$1" model="$2"
  awk -v m="model: $model" '
    BEGIN { in_fm=0; inserted=0 }
    /^---$/ {
      if (!in_fm) { in_fm=1; print; next }
      if (!inserted) { print m; inserted=1 }
    }
    /^model:/ { next }
    { print }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

updated=0
skipped=0

for file in "$AGENTS_DIR"/*.md; do
  name="$(basename "$file" .md)"
  src_file="$SRC_AGENTS_DIR/$name.md"

  if [ ! -f "$src_file" ]; then
    echo "Warning: no source agent found for '$name', skipping" >&2
    skipped=$((skipped + 1))
    continue
  fi

  alias="$(awk 'BEGIN{c=0} /^---$/{c++; if(c==2) exit} c==1 && /^model:/{print $2}' "$src_file")"

  if [ -z "$alias" ]; then
    echo "Warning: no model: frontmatter in source agent '$name', skipping" >&2
    skipped=$((skipped + 1))
    continue
  fi

  case "$alias" in
    opus)   model="$POWERFUL" ;;
    sonnet) model="$DEFAULT" ;;
    haiku)  model="$LITE" ;;
    *)
      echo "Warning: unknown model alias '$alias' in '$name', skipping" >&2
      skipped=$((skipped + 1))
      continue
      ;;
  esac

  set_model "$file" "$model"
  updated=$((updated + 1))
done

echo "Updated $updated agent(s) in $AGENTS_DIR"
[ "$skipped" -gt 0 ] && echo "Skipped $skipped agent(s)"
echo "  opus   (powerful): $POWERFUL"
echo "  sonnet (default):  $DEFAULT"
echo "  haiku  (lite):     $LITE"
