#!/usr/bin/env bash
# skill-models.sh — determine the recommended model tier for each skill.
#
# Reads each skill's SKILL.md to find dispatched agents, then maps those
# agents to their tiers (powerful/default/lite) and recommends a tier
# for the skill based on the most demanding agent it uses.
#
# Usage:
#   ./scripts/skill-models.sh              # report all skills
#   ./scripts/skill-models.sh --json       # machine-readable output
#   ./scripts/skill-models.sh --update      # update plugin-pi/skills with model frontmatter
#
# The agent tier mapping mirrors update-pi-models.sh and must be kept in sync.

set -euo pipefail

REPO_ROOT="$(pwd)"
SKILLS_DIR="$REPO_ROOT/plugin/skills"
JSON_MODE=false
UPDATE_MODE=false

for arg in "$@"; do
  case "$arg" in
    --json)   JSON_MODE=true ;;
    --update) UPDATE_MODE=true ;;
    *)        echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

# ── Agent tier mapping (must match update-pi-models.sh) ──────────────────────

agent_tier() {
  case "$1" in
    # powerful — deep reasoning, architecture, synthesis
    adversarial-security-analyst|data-engineer|devops-engineer|\
    information-architect|junior-developer|project-manager|software-architect|\
    system-architect|user-experience-designer)
      echo "powerful" ;;
    # default — balanced analysis, validation, investigation
    adversarial-validator|behavioral-analyst|concurrency-analyst|\
    edge-case-explorer|evidence-based-investigator|gap-analyzer|\
    research-analyst|risk-analyst|\
    structural-analyst|test-engineer)
      echo "default" ;;
    # lite — scanning, indexing, simple tasks
    codebase-explorer|content-auditor|project-scanner)
      echo "lite" ;;
    *)
      echo "unknown" ;;
  esac
}

# ── Determine skill tier from its dispatched agents ────────────────────────────
# A skill's tier is the highest tier among its dispatched agents.
# Skills that dispatch no agents are "none" (they run on the parent model).

skill_tier_from_agents() {
  local skill_dir="$1"
  local skill_md="$skill_dir/SKILL.md"

  if [ ! -f "$skill_md" ]; then
    echo "none"
    return
  fi

  # Extract backtick-quoted agent names (canonical dispatch pattern)
  local agents
  agents=$(grep -oE '`[a-z]+-[a-z-]+`' "$skill_md" 2>/dev/null | sed 's/`//g' | sort -u || true)

  # Filter out non-agent backtick patterns. Keep only names in the agent tier mapping.
  local highest="none"
  local tier
  for agent in $agents; do
    tier=$(agent_tier "$agent")
    case "$tier" in
      powerful) highest="powerful" ;;
      default)  [ "$highest" != "powerful" ] && highest="default" ;;
      lite)     [ "$highest" = "none" ] && highest="lite" ;;
    esac
  done

  echo "$highest"
}

# ── Skill complexity heuristic ────────────────────────────────────────────────
# Override the agent-based tier for skills that are primarily orchestration
# heavy even if they use lower-tier agents for support tasks.

skill_tier_override() {
  case "$1" in
    # These skills do deep multi-round synthesis and need powerful models
    iterative-plan-review)  echo "powerful" ;;
    plan-a-feature)         echo "powerful" ;;
    plan-implementation)    echo "powerful" ;;
    plan-a-phased-build)   echo "powerful" ;;
    # Investigation and research need reasoning depth
    investigate)            echo "powerful" ;;
    research)                echo "powerful" ;;
    # Code review and architecture need strong analysis
    code-review)            echo "powerful" ;;
    architectural-analysis)  echo "powerful" ;;
    gap-analysis)            echo "default" ;;
    *)                       echo "" ;;
  esac
}

# ── Compute final tier ────────────────────────────────────────────────────────

skill_tier() {
  local skill_name="$1"
  local override
  override=$(skill_tier_override "$skill_name")
  if [ -n "$override" ]; then
    echo "$override"
    return
  fi
  local skill_dir="$SKILLS_DIR/$skill_name"
  skill_tier_from_agents "$skill_dir"
}

# ── Report mode ────────────────────────────────────────────────────────────────

if [ "$JSON_MODE" = true ]; then
  echo "{"
  first=true
  for skill_dir in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    tier=$(skill_tier "$skill_name")
    if [ "$first" = true ]; then first=false; else echo ","; fi
    printf '  "%s": "%s"' "$skill_name" "$tier"
  done
  echo ""
  echo "}"
  exit 0
fi

# ── Human-readable report ─────────────────────────────────────────────────────

printf "%-30s %-10s %s\n" "SKILL" "TIER" "DISPATCHED AGENTS"
printf "%-30s %-10s %s\n" "─────" "────" "─────────────────"

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name=$(basename "$skill_dir")
  tier=$(skill_tier "$skill_name")

  # Collect agent names for display
  raw_agents=$(grep -oE '`[a-z]+-[a-z-]+`' "$skill_dir/SKILL.md" 2>/dev/null | sed 's/`//g' | sort -u || true)
  agents=$(echo "$raw_agents" | while read -r agent; do
        [ -z "$agent" ] && continue
        at=$(agent_tier "$agent")
        if [ "$at" != "unknown" ]; then echo "$agent"; fi
      done | tr '\n' ',' | sed 's/,$//;s/,/, /g')

  printf "%-30s %-10s %s\n" "$skill_name" "$tier" "$agents"
done

echo ""
echo "Tier guide:"
echo "  powerful — deep reasoning, synthesis, multi-round orchestration"
echo "  default  — balanced analysis, validation, investigation"
echo "  lite     — scanning, indexing, simple formatting"
echo "  none     — no agent dispatch (runs on parent model)"

# ── Update mode ───────────────────────────────────────────────────────────────

if [ "$UPDATE_MODE" = true ]; then
  echo ""
  echo "Updating plugin-pi/skills with model tier frontmatter..."

  SKILLS_PI_DIR="$REPO_ROOT/plugin-pi/skills"
  updated=0

  for skill_dir in "$SKILLS_PI_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"
    tier=$(skill_tier "$skill_name")

    if [ ! -f "$skill_md" ]; then
      echo "  ⚠ $skill_name: no SKILL.md, skipping"
      continue
    fi

    if [ "$tier" = "none" ]; then
      # Remove any existing model: line from frontmatter
      if grep -q '^model:' "$skill_md"; then
        sed -i '' '/^model:/d' "$skill_md"
        echo "  − $skill_name: removed model (no agent dispatch)"
        updated=$((updated + 1))
      else
        echo "  · $skill_name: no model needed (no agent dispatch)"
      fi
      continue
    fi

    # Map tier to environment variable
    case "$tier" in
      powerful) model_var="POWERFUL_MODEL" ;;
      default)  model_var="DEFAULT_MODEL" ;;
      lite)     model_var="LITE_MODEL" ;;
      *)        model_var="" ;;
    esac
    model=""
    if [ -n "$model_var" ]; then
      eval "model=\"\${$model_var:-}\""
    fi

    if [ -z "$model" ]; then
      # Without env vars, write the tier as a placeholder
      model="$tier"
    fi

    # Upsert model: line in YAML frontmatter
    awk -v m="model: $model" '
      BEGIN { in_fm=0; inserted=0 }
      /^---$/ {
        if (!in_fm) { in_fm=1; print; next }
        if (!inserted) { print m; inserted=1 }
      }
      /^model:/ { next }
      { print }
    ' "$skill_md" > "$skill_md.tmp" && mv "$skill_md.tmp" "$skill_md"

    echo "  + $skill_name: model=$model (tier=$tier)"
    updated=$((updated + 1))
  done

  echo ""
  echo "Updated $updated skill(s)."
  echo ""
  echo "To resolve tier placeholders to actual models, set environment variables:"
  echo "  POWERFUL_MODEL  — model for powerful-tier skills"
  echo "  DEFAULT_MODEL   — model for default-tier skills"
  echo "  LITE_MODEL       — model for lite-tier skills"
  echo ""
  echo "Example: POWERFUL_MODEL=opencode-go/qwen3.6-plus ./scripts/skill-models.sh --update"
fi