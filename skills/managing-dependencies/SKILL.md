---
name: managing-dependencies
description: "Use when adding, updating, or evaluating npm/pip/go dependencies. Triggers on: npm install, pip install, go get, adding packages to manifests, reviewing lockfile changes, comparing package alternatives, or assessing package trustworthiness."
license: CC0-1.0
compatibility: Any agent with Python 3.10+
metadata:
  author: andrew
  version: "2.0"
---

# Managing Dependencies

Script: `scripts/eval-package`
Reference: `reference/typosquatting.md`, `reference/supply-chain-attacks.md`, `reference/api-reference.md`, `reference/versioning.md`

## Principles

- **Do not hallucinate package names.** Verify every package exists before suggesting it.
- **Stdlib first.** If the language provides it, don't add a dependency.
- **20–50 lines of your own code beats a dependency** for simple needs.
- **When in doubt, don't add.** PRs that remove dependencies are usually good PRs.
- **Application mindset:** pin exact, lock always, update deliberately.

## Decision Flow

### Step 1: Is a dependency necessary?

Before adding anything, check in order:

1. **Standard library** — Does the language already provide this?
2. **Existing dependencies** — Does something already installed do this?
3. **Inline it** — Can you write 20–50 lines instead?

If any of these work, stop. No dependency needed.

### Step 2: Quick evaluate

Run the evaluation script silently:

```
scripts/eval-package <npm|pip|go> <package-name> [--version <ver>]
```

**Do not surface output unless risk flags are found.**

### Step 3: Risk verdict

The script returns a verdict based on cumulative scoring:

| Verdict | Condition | Action |
|---------|-----------|--------|
| ✅ **PASS** | 0–1 yellow flags, no reds | Proceed silently |
| ⚠️ **REVIEW** | 2+ yellow flags, no reds | Surface flags, explain risk, ask user to confirm |
| 🚫 **ESCALATE** | Any red flag | Present alternatives or require explicit override |

**Scoring thresholds:**

| Signal | 🟢 | 🟡 | 🔴 |
|--------|---|----|----|
| Package age | >1 year | 90 days–1 year | <90 days |
| Last release | <1 year ago | 1–2 years ago | >2 years ago |
| Maintainers | 3+ | 2 | 1 |
| Dependent repos | 5,000+ | 500–5,000 | <500 |
| Versions | 10+ | 3–9 | 1 |
| Advisories | 0 | 1–2 | 3+ |
| Archived | — | — | Auto-red |
| OpenSSF score | 7+ | 4–6.9 | <4 |

**Additional escalation triggers** (always check regardless of score):
- Install scripts detected with suspicious patterns → flag to user
- Typosquatting match → block (see `reference/typosquatting.md`)
- Known slopsquatting pattern (AI-hallucinated name) → block

If ESCALATE, check `reference/supply-chain-attacks.md` for mitigation options and suggest alternatives.

### Step 4: Install safely

- **npm:** `npm install --ignore-scripts <package>` — always. Review source, then `npm rebuild` if safe
- **pip:** `pip install <package>` (or add to pyproject.toml/requirements.txt)
- **Go:** `go get <package>@<version>`
- **Always:** pin the version, commit the lockfile
- **Clarify** if a dependency is dev-only (`--save-dev`, `[project.optional-dependencies]`, dev container group)

## Audit Existing Dependencies

For npm: `npm audit`
For pip: `pip-audit`
For Go: `govulncheck ./...`

If vulnerability found with no patch:
1. Check reachability — is the vulnerable code path actually used?
2. See `reference/supply-chain-attacks.md` for remediation options

## When to Consult Reference Docs

The agent should load these on-demand when a specific concern surfaces:

| Situation | Reference |
|-----------|-----------|
| Package name looks suspicious or could be a typo | `reference/typosquatting.md` |
| Install scripts, lockfile injection, dependency confusion | `reference/supply-chain-attacks.md` |
| Need API details or threshold definitions | `reference/api-reference.md` |
| Version pinning, lockfiles, license checks, auto-updates | `reference/versioning.md` |
