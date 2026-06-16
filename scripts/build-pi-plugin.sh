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
#   1. Copies skills from han.core, han.coding, han.planning, han.github,
#      and han.reporting into plugin-pi/skills/ (full han meta-plugin bundle);
#      copies han.core/agents/ and han.core/references/ into plugin-pi/
#   2. Agent .md files are copied verbatim — pi-subagents supports the "model:"
#      frontmatter field and resolves bare aliases (opus/sonnet/haiku) natively.
#   3. Transforms skill SKILL.md files for pi.dev compatibility:
#      - Replaces "Agent" with "subagent" in allowed-tools frontmatter
#      - Replaces Agent tool references in skill bodies with subagent tool
#      - Replaces run_in_background: true with async: true
#      - Removes the Claude Code-only Skill tool from allowed-tools
#      - Replaces /code-review with /skill:code-review in post-code-review-to-pr
#
# Known limitation: the following skills invoke shell scripts via
# ${CLAUDE_SKILL_DIR}/scripts/, which is a Claude Code-specific env var.
# Pi sets no equivalent, so these script calls will not resolve at runtime:
#   code-review          detect-review-context.sh
#   tdd                  detect-tdd-context.sh
#   refactor             detect-refactor-context.sh
#   test-planning        detect-test-context.sh
#   post-code-review-to-pr  pr-metadata.sh, create-review-tempfile.sh,
#                           post-pr-comment.sh, post-pr-review.sh
#   work-items-to-issues    publish-work-items.sh
#   html-summary            inline-mermaid.sh
# If pi exposes a skill-directory variable in the future, add a transform here.

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

# Copy skills from the rest of the han meta-plugin bundle (han.coding,
# han.planning, han.github, han.reporting). Each skill directory is
# self-contained with its own references/ so no plugin-level references need
# to be merged.
for plugin in han.coding han.planning han.github han.reporting; do
  if [ -d "${REPO_ROOT}/${plugin}/skills" ]; then
    cp -r "${REPO_ROOT}/${plugin}/skills"/. "${PLUGIN_PI}/skills/"
  fi
done

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

  # 3f. Remove the Claude Code-only Skill tool from allowed-tools.
  #     pi has no Skill tool; the transform handles Skill in any list position.
  perl -i -pe 'if (/^allowed-tools:/) { s/,\s*Skill\b//g; s/\bSkill\b,\s*//g }' "$f"

  # Model override strings in skill bodies (e.g. model: "sonnet") are left as-is.
  # pi-subagents resolves bare aliases against the configured provider.
done

# ── Step 4: Skill-specific patches ───────────────────────────────────────────

# post-code-review-to-pr invokes /code-review by slash command; update to pi.dev syntax.
POST_CODE_REVIEW="${PLUGIN_PI}/skills/post-code-review-to-pr/SKILL.md"
if [ -f "$POST_CODE_REVIEW" ]; then
  sed -i '' 's|/code-review|/skill:code-review|g' "$POST_CODE_REVIEW"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo "Done. Generated files:"
echo "  ${PLUGIN_PI}/skills/  ($(find "${PLUGIN_PI}/skills" -name 'SKILL.md' | wc -l | tr -d ' ') skills)"
echo "  ${PLUGIN_PI}/agents/  ($(find "${PLUGIN_PI}/agents" -name '*.md'    | wc -l | tr -d ' ') agents)"
echo "  ${PLUGIN_PI}/references/  ($(find "${PLUGIN_PI}/references" -name '*.md' | wc -l | tr -d ' ') reference files)"
echo ""
echo "Install in pi.dev with:"
echo "  pi install ${PLUGIN_PI}"
