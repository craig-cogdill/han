# han — pi.dev Plugin (Developer Guide)

This guide covers building, configuring, and installing the pi.dev plugin from a local clone. For the user-facing plugin README, see [plugin-pi/README.md](plugin-pi/README.md).

## Key concept: Agent model routing

Han's 22 specialist agents are tiered by reasoning demands:

| Tier | Agents | Reasoning demand |
|------|--------|------------------|
| **powerful** | adversarial-security-analyst, data-engineer, devops-engineer, information-architect, project-manager, software-architect, system-architect, user-experience-designer | Deep analysis, multi-round synthesis, architecture |
| **default** | adversarial-validator, behavioral-analyst, concurrency-analyst, edge-case-explorer, evidence-based-investigator, gap-analyzer, junior-developer, research-analyst, risk-analyst, structural-analyst, test-engineer | Balanced validation, investigation, analysis |
| **lite** | codebase-explorer, content-auditor, project-scanner | Scanning, indexing, formatting |

For agent models to take effect, two things must be in place:

1. **Agent `.md` files must be discoverable** by pi-subagents. After building, run `mise run agents:link` to symlink agents into the global discovery directory.
2. **The `model:` frontmatter must specify a valid provider-qualified model** (e.g. `opencode-go/qwen3.6-plus`) that exists in your pi model registry. If the provider isn't configured, pi-subagents silently falls back to the parent session model.

## mise tasks

### `mise run build`

Generate `plugin-pi/` from the upstream `plugin/` directory, then inject model frontmatter into the agent files. Equivalent to running:

```bash
scripts/build-pi-plugin.sh    # copy + transform from plugin/
scripts/update-pi-models.sh   # inject model: frontmatter into agents
```

The model values come from three environment variables:

| Variable | Maps to tier | Example |
|----------|-------------|---------|
| `POWERFUL_MODEL` | powerful | `opencode-go/qwen3.6-plus` |
| `DEFAULT_MODEL` | default | `opencode-go/glm-5.1` |
| `LITE_MODEL` | lite | `opencode-go/deepseek-v4-flash` |

Set them before running, or add them to your shell profile (`~/.zshenv`, `~/.bashrc`):

```bash
export POWERFUL_MODEL="opencode-go/qwen3.6-plus"
export DEFAULT_MODEL="opencode-go/glm-5.1"
export LITE_MODEL="opencode-go/deepseek-v4-flash"

mise run build
```

Without the environment variables, `update-pi-models.sh` will error with a clear message.

### `mise run agents:link`

Symlink all 22 agent `.md` files from `plugin-pi/agents/` into `~/.pi/agent/agents/` so pi-subagents discovers them from any repo. Uses absolute paths. Idempotent — safe to re-run.

```bash
mise run agents:link
```

Without this step, pi-subagents cannot find han's agents because its discovery path only scans `<cwd>/.pi/agents/` and `~/.pi/agent/agents/` — not installed package directories.

Run this after `mise run build` whenever agent frontmatter changes.

### `mise run agents:unlink`

Remove the symlinks created by `agents:link`. Only removes links pointing back to `plugin-pi/agents/`; won't touch other files in `~/.pi/agent/agents/`.

```bash
mise run agents:unlink
```

### `mise run models:report`

Print a table showing each skill's recommended model tier, based on the most demanding agent it dispatches. Useful for reviewing tier assignments before running `models:update`.

```bash
mise run models:report
```

Example output:

```
SKILL                            TIER       DISPATCHED AGENTS
─────                            ────       ──────────────────
architectural-analysis          powerful   adversarial-security-analyst, ...
investigate                     powerful   adversarial-validator, evidence-based-investigator
project-discovery               lite       project-scanner
stakeholder-summary             none
```

Skills with tier `none` dispatch no agents and run on the parent model.

### `mise run models:update`

Inject `model:` frontmatter into each `plugin-pi/skills/*/SKILL.md` based on the skill's tier. Set environment variables to map tiers to actual models:

```bash
POWERFUL_MODEL=opencode-go/qwen3.6-plus \
DEFAULT_MODEL=opencode-go/glm-5.1 \
LITE_MODEL=opencode-go/deepseek-v4-flash \
mise run models:update
```

Without the environment variables, the tier name (`powerful`, `default`, `lite`) is written as a placeholder.

**Note on skill-level vs. agent-level models.** Both skill SKILL.md and agent `.md` files can specify `model:`. The resolution priority in pi-subagents is:

1. `model:` passed in the tool-call parameters (highest — overrides everything)
2. `model:` from the agent's frontmatter (middle — used if no tool-call override)
3. Parent session model (fallback — used if neither is specified)

### `mise run models:report --json`

Machine-readable JSON output of skill tiers. Not currently wired as a separate task; run the script directly:

```bash
./scripts/skill-models.sh --json
```

## Typical workflows

### First-time setup

```bash
# 1. Set model environment variables (add to ~/.zshenv or ~/.bashrc)
export POWERFUL_MODEL="opencode-go/qwen3.6-plus"
export DEFAULT_MODEL="opencode-go/glm-5.1"
export LITE_MODEL="opencode-go/deepseek-v4-flash"

# 2. Build the plugin and inject models
mise run build

# 3. Symlink agents for pi-subagents discovery
mise run agents:link

# 4. Reinstall the plugin
pi install ./plugin-pi
```

### Updating from upstream

```bash
# 1. Merge upstream changes
git merge main   # or: git rebase main

# 2. Rebuild plugin-pi with current models
mise run build

# 3. Re-symlink agents (picks up any frontmatter changes)
mise run agents:link

# 4. Commit the rebuilt plugin
git add plugin-pi/
git commit -m "rebuild plugin-pi from upstream <version>"
```

### Changing model assignments

Edit the tier mapping in `scripts/update-pi-models.sh` (agents) and `scripts/skill-models.sh` (skills), then:

```bash
mise run build        # rebuild agents with new models
mise run agents:link  # re-symlink
```

## How the pieces fit together

```
plugin/                         ← upstream Claude Code plugin
  ├── agents/                   ← 22 agent .md files (Claude Code model aliases)
  ├── skills/                   ← 20 skill SKILL.md files (Agent tool references)
  └── references/               ← cross-skill reference files

scripts/
  ├── build-pi-plugin.sh        ← copies plugin/ → plugin-pi/, transforms for pi.dev
  ├── update-pi-models.sh       ← injects model: frontmatter into plugin-pi/agents/
  └── skill-models.sh           ← determines skill tiers and injects model: into SKILL.md

mise.toml                       ← task runner for build, link, and model operations

plugin-pi/                      ← generated output (git-tracked, do not edit directly)
  ├── agents/                   ← 22 agent .md files (with pi.dev model frontmatter)
  ├── skills/                   ← 20 skill SKILL.md files (subagent tool references)
  ├── references/               ← cross-skill reference files
  └── package.json              ← pi.dev package manifest

~/.pi/agent/agents/             ← pi-subagents global discovery directory
  ├── adversarial-validator.md  ← symlink → /path/to/han/plugin-pi/agents/adversarial-validator.md
  ├── ...                       ← (22 symlinks total)
  └── project-manager.md        ← symlink → /path/to/han/plugin-pi/agents/project-manager.md
```

## Troubleshooting

**Agents use wrong models.** Check three things:

1. Are the agent symlinks in place? `ls ~/.pi/agent/agents/` should show 22 symlinks pointing to `plugin-pi/agents/`.
2. Do the agent `.md` files have `model:` frontmatter? `head -5 plugin-pi/agents/project-manager.md` should show `model: opencode-go/...`.
3. Is the model provider configured in pi? If `opencode-go` is not in your pi model registry, pi-subagents silently falls back to the parent model. Check your pi auth/model configuration.

**`mise run build` fails with "POWERFUL_MODEL is not set".** Set the three model environment variables before running. See the `mise run build` section above.

**`mise run agents:link` fails with "Operation not permitted".** This task must be run outside of pi's sandbox. Run it from your terminal directly.

**Skills still dispatch agents on the wrong model.** Some skills (plan-a-feature, plan-implementation, plan-a-phased-build, plan-work-items) explicitly pass `model: "sonnet"` in their dispatch instructions, which overrides agent frontmatter. These skill-level overrides are left in place because pi-subagents resolves bare aliases like "sonnet" against your configured provider.