# han — pi.dev plugin

Evidence-based planning, investigation, code review, and documentation skills for software projects.

## Prerequisites

- [pi.dev](https://pi.dev) coding agent
- [pi-subagents](https://github.com/nicobailon/pi-subagents) extension (required for agent dispatch)

Install pi-subagents first:

```
pi install npm:pi-subagents
```

## Install

```
pi install git:github.com/<your-fork>/han/plugin-pi
```

Or from a local clone:

```
pi install /path/to/han/plugin-pi
```

## Skills

| Slash command | What it does |
|---|---|
| `/skill:investigate` | Evidence-based bug and failure investigation with adversarial validation |
| `/skill:code-review` | Comprehensive code review of the current branch or specified files |
| `/skill:gh-pr-review` | Run `/skill:code-review` and post results as GitHub PR comments |
| `/skill:plan-a-feature` | Spec a feature from scratch through an evidence-based interview |
| `/skill:plan-implementation` | Turn a feature spec into a concrete implementation plan |
| `/skill:plan-a-phased-build` | Split a large spec into independently demoable vertical phases |
| `/skill:iterative-plan-review` | Stress-test an existing plan through multiple review passes |
| `/skill:architectural-analysis` | Deep architectural analysis: coupling, data flow, concurrency, risk |
| `/skill:gap-analysis` | Compare two artifacts (spec vs. implementation) and report gaps |
| `/skill:test-planning` | Produce a prioritized test plan for a branch or directory |
| `/skill:project-discovery` | Scan the repo for languages, frameworks, tooling, and structure |
| `/skill:project-documentation` | Create and maintain feature and component documentation |
| `/skill:coding-standard` | Create or update coding standards from existing patterns |
| `/skill:architectural-decision-record` | Create, extract, or convert ADRs |
| `/skill:update-pr-description` | Generate a PR description from the current branch's changes |

## Model configuration

Pi-subagents cannot receive model preferences from a package install. You must add the
`subagents.agentOverrides` block to your own settings file manually.

**Project-level** (applies only in this repo): `.pi/settings.json`
**Global** (applies everywhere): `~/.pi/agent/settings.json`

The agents are tiered by the reasoning demands of their role. Replace each placeholder
with the equivalent model from your provider:

```json
{
  "subagents": {
    "agentOverrides": {
      "adversarial-security-analyst": { "model": "your-powerful-model" },
      "data-engineer":                { "model": "your-powerful-model" },
      "devops-engineer":              { "model": "your-powerful-model" },
      "project-manager":              { "model": "your-powerful-model" },
      "system-architect":             { "model": "your-powerful-model" },
      "test-engineer":                { "model": "your-powerful-model" },

      "adversarial-validator":        { "model": "your-default-model" },
      "behavioral-analyst":           { "model": "your-default-model" },
      "concurrency-analyst":          { "model": "your-default-model" },
      "edge-case-explorer":           { "model": "your-default-model" },
      "evidence-based-investigator":  { "model": "your-default-model" },
      "gap-analyzer":                 { "model": "your-default-model" },
      "information-architect":        { "model": "your-default-model" },
      "junior-developer":             { "model": "your-default-model" },
      "risk-analyst":                 { "model": "your-default-model" },
      "software-architect":           { "model": "your-default-model" },
      "structural-analyst":           { "model": "your-default-model" },
      "user-experience-designer":     { "model": "your-default-model" },

      "codebase-explorer":            { "model": "your-fast-model" },
      "content-auditor":              { "model": "your-fast-model" },
      "project-scanner":              { "model": "your-fast-model" }
    }
  }
}
```

## Updating from upstream

When the upstream Claude Code plugin receives updates:

```bash
git merge main          # or: git rebase main
./scripts/build-pi-plugin.sh
git add plugin-pi/
git commit -m "rebuild plugin-pi from upstream <version>"
```

Then reinstall in pi to pick up the changes:

```bash
# If installed from git (no version ref pinned):
pi update
```

If you installed from a local path, no reinstall is needed — pi references the
directory directly, so changes to plugin-pi/ are picked up automatically.
