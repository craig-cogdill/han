#!/usr/bin/env bash
# build-pi-plugin.sh — generate plugin-pi/ from the upstream plugin/ directory.
#
# Run this from the repository root:
#   ./scripts/build-pi-plugin.sh
#
# When upstream (Claude Code) updates arrive, pull them into main, then:
#   git merge main          # or: git rebase main
#   ./scripts/build-pi-plugin.sh
#   git add plugin-pi/
#   git commit -m "rebuild plugin-pi from upstream <version>"
#
# What this script does:
#   1. Copies han.core/skills/ and han.core/agents/ into plugin-pi/
#   2. Copies han.core/references/ into plugin-pi/ (cross-skill reference files)
#   3. Agent .md files are copied verbatim — pi-subagents supports the "model:"
#      frontmatter field and resolves bare aliases (opus/sonnet/haiku) natively.
#   4. Transforms skill SKILL.md files for pi.dev compatibility:
#      - Replaces "Agent" with "subagent" in allowed-tools frontmatter
#      - Replaces Agent tool references in skill bodies with subagent tool
#      - Replaces run_in_background: true with async: true
#      - Replaces model override strings in skill bodies
#      - Replaces /code-review with /skill:code-review in gh-pr-review
#
# Known limitation: skills that call ${CLAUDE_SKILL_DIR}/scripts/*.sh use a
# Claude Code-specific environment variable. These script calls are left as-is;
# pi.dev users will need to ensure CLAUDE_SKILL_DIR is set to the skill's
# directory, or manually update those references.

set -euo pipefail

REPO_ROOT="$(pwd)"
PLUGIN_SRC="${REPO_ROOT}/han.core"
PLUGIN_PI="${REPO_ROOT}/plugin-pi"

echo "Building plugin-pi from han.core/ ..."

# ── Step 1: Copy skills, agents, and references ───────────────────────────────

rm -rf "${PLUGIN_PI}/skills" "${PLUGIN_PI}/agents" "${PLUGIN_PI}/references"
cp -r "${PLUGIN_SRC}/skills"     "${PLUGIN_PI}/skills"
cp -r "${PLUGIN_SRC}/agents"     "${PLUGIN_PI}/agents"
cp -r "${PLUGIN_SRC}/references" "${PLUGIN_PI}/references"

# ── Step 1b: Sync version from plugin/.claude-plugin/plugin.json ─────────────

UPSTREAM_VERSION="$(python3 -c "import json,sys; print(json.load(open('${PLUGIN_SRC}/.claude-plugin/plugin.json'))['version'])")"
perl -i -pe "s/\"version\": \"[^\"]+\"/\"version\": \"${UPSTREAM_VERSION}\"/" "${PLUGIN_PI}/package.json"

# ── Step 2: Transform agent files ────────────────────────────────────────────
# Agents are individual .md files in plugin-pi/agents/.

find "${PLUGIN_PI}/agents" -name "*.md" | while read -r f; do
  # Remove the "model:" frontmatter line so pi-subagents falls back to the
  # agentOverrides in the user's settings.json rather than trying to resolve
  # Claude Code model aliases (opus, sonnet, haiku) which aren't valid outside Anthropic.
  sed -i '' '/^model:/d' "$f"
done

# ── Step 3: Transform skill SKILL.md files ───────────────────────────────────

find "${PLUGIN_PI}/skills" -name "SKILL.md" | while read -r f; do

  # 3a. Replace "Agent" with "subagent" on the allowed-tools frontmatter line.
  #     Handles Agent appearing anywhere in the list (start, middle, or end).
  #     Uses perl for \b word-boundary support (BSD sed on macOS does not support \b).
  perl -i -pe 's/\bAgent\b/subagent/g if /^allowed-tools:/' "$f"

  # 3b. Replace backtick-quoted Agent tool references in the body.
  #     e.g.: `Agent` tool → `subagent` tool
  sed -i '' 's/`Agent` tool/`subagent` tool/g' "$f"

  # 3c. Replace unquoted "Agent tool" phrases in the body.
  #     e.g.: "single Agent tool call" → "single subagent tool call"
  #           "a single Agent tool call" → "a single subagent tool call"
  #           "to the Agent tool" → "to the subagent tool"
  #           "using the Agent tool" → "using the subagent tool"
  #     Uses sed word-boundary lookalike via space/punctuation context.
  #     Pattern avoids replacing "Agent findings", "Agent config", etc.
  sed -i '' 's/Agent tool/subagent tool/g' "$f"

  # 3d. Replace hyphenated "Agent-tool" phrase.
  #     e.g.: "Agent-tool message" → "subagent tool message"
  sed -i '' 's/Agent-tool/subagent tool/g' "$f"

  # 3e. Replace background dispatch parameter.
  #     Claude Code: run_in_background: true
  #     pi-subagents: async: true
  sed -i '' 's/run_in_background: true/async: true/g' "$f"

  # Model override strings in skill bodies (e.g. model: "sonnet") are left as-is.
  # pi-subagents resolves bare aliases against the configured provider.
done

# ── Step 4: Skill-specific patches ───────────────────────────────────────────

# gh-pr-review invokes /code-review by slash command; update to pi.dev syntax.
GH_PR_REVIEW="${PLUGIN_PI}/skills/gh-pr-review/SKILL.md"
if [ -f "$GH_PR_REVIEW" ]; then
  sed -i '' 's|/code-review|/skill:code-review|g' "$GH_PR_REVIEW"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo "Done. Generated files:"
echo "  ${PLUGIN_PI}/skills/  ($(find "${PLUGIN_PI}/skills" -name 'SKILL.md' | wc -l | tr -d ' ') skills)"
echo "  ${PLUGIN_PI}/agents/  ($(find "${PLUGIN_PI}/agents" -name '*.md'    | wc -l | tr -d ' ') agents)"
echo "  ${PLUGIN_PI}/references/  ($(find "${PLUGIN_PI}/references" -name '*.md' | wc -l | tr -d ' ') reference files)"
echo ""
echo "Install in pi.dev with:"
echo "  pi install ${PLUGIN_PI}"
