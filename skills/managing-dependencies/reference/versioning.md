# Versioning & Lockfile Reference

## Version Constraints (Application Projects)

**Pin exact, lock always, update deliberately.** You are building applications, not libraries.

| Ecosystem | Pin exact | Lockfile | Frozen install command |
|-----------|-----------|----------|----------------------|
| npm | `1.0.0` | `package-lock.json` | `npm ci` |
| pip (pip-tools) | `==1.0.0` | `requirements.txt` | `pip install -r requirements.txt` |
| pip (poetry) | pinned in lock | `poetry.lock` | `poetry install --no-update` |
| pip (uv) | pinned in lock | `uv.lock` | `uv sync --frozen` |
| Go | `v1.2.3` | `go.sum` | `go mod verify` |

## Lockfile Practices

Always commit lockfiles. Always install from lockfile in CI.

**Detect ecosystem:**
- `package-lock.json` / `yarn.lock` / `pnpm-lock.yaml` / `bun.lock` → npm
- `poetry.lock` / `uv.lock` / `requirements.txt` with hashes → pip
- `go.sum` → Go

**Frozen install commands (CI):**
```bash
npm ci                    # not npm install
pip install --require-hashes -r requirements.txt
uv sync --frozen
go mod verify
```

**Regenerate on conflict** (never manually merge lockfiles):
```bash
# npm
rm package-lock.json && npm install

# Poetry
rm poetry.lock && poetry lock

# uv
rm uv.lock && uv lock

# Go
rm go.sum && go mod tidy
```

## Review Lockfile Changes

- Watch for changes to `resolved` / `integrity` fields (lockfile injection)
- Unexpected registry URL changes are red flags
- Large diffs can hide malicious additions — review line by line

## License Check

```bash
# npm
npx license-checker --summary

# pip
pip-licenses

# Go
go-licenses ./...
```

**Safe:** MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC, Unlicense
**Review needed:** LGPL, MPL-2.0
**Copyleft (affects distribution):** GPL, AGPL
**No license = not open source** — do not use.

## Automated Updates

| Tool | Platform | Best for |
|------|----------|----------|
| Dependabot | GitHub only | Simple needs, free |
| Renovate | Multi-platform | Complex configs, monorepos |

**Safe auto-merge criteria** (all must apply):
- Patch updates only
- Dev dependencies only
- Established, trusted packages
- All CI checks pass
- Package available 3+ days

**Never auto-merge:** Major versions, production deps, new packages, security-sensitive packages (crypto, auth).

Example Renovate config:
```json
{
  "packageRules": [
    {
      "matchUpdateTypes": ["patch"],
      "matchDepTypes": ["devDependencies"],
      "automerge": true,
      "minimumReleaseAge": "3 days"
    }
  ]
}
```

## GitHub Actions Versioning

Pin actions to commit SHA, not tags:

```yaml
# Bad - tag can be moved
- uses: actions/checkout@v4

# Good - immutable reference
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
```

Use Dependabot or Renovate to keep pinned SHAs updated.
