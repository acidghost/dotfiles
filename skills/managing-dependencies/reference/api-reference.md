# API Reference

## ecosyste.ms

```bash
curl -s "https://packages.ecosyste.ms/api/v1/registries/<registry>/packages/<package>" | jq
```

**Registries:** `npmjs.org`, `pypi.org`, `rubygems.org`, `crates.io`, `proxy.golang.org`, `nuget.org`, `repo1.maven.org`

**Key fields:**

| Field | Description |
|-------|-------------|
| `dependent_repos_count` | Repos depending on this package |
| `dependent_packages_count` | Packages depending on this package |
| `latest_release_number` | Current latest version |
| `latest_release_published_at` | Date of latest release |
| `first_release_published_at` | Date of first release |
| `maintainers` | Array of maintainer objects |
| `repository_url` | Source repository |
| `normalized_licenses` | Array of license identifiers |
| `advisories` | Array of security advisories |
| `versions_count` | Total published versions |
| `repo_metadata.archived` | Whether repo is archived |

### Risk Thresholds

| Field | 🟢 Green | 🟡 Yellow | 🔴 Red |
|-------|----------|-----------|--------|
| `first_release_published_at` | >1 year ago | 90 days–1 year | <90 days |
| `latest_release_published_at` | <1 year ago | 1–2 years ago | >2 years ago |
| `maintainers` (length) | 3+ | 2 | 1 |
| `dependent_repos_count` | 5,000+ | 500–5,000 | <500 |
| `versions_count` | 10+ | 3–9 | 1 |
| `advisories` (length) | 0 | 1–2 | 3+ |
| `repo_metadata.archived` | false | — | true |

### Development Distribution Score

Found at `.repo_metadata.metadata.development_distribution_score`. Measures commit distribution across contributors (0–1).

- **<0.15** — Single contributor dominance (high bus factor)
- **0.15–0.5** — Moderate distribution
- **>0.5** — Well distributed

## OpenSSF Scorecard API

```bash
curl -s "https://api.scorecard.dev/projects/github.com/<owner>/<repo>" | jq '{
  score: .score,
  maintained: (.checks[] | select(.name == "Maintained") | .score),
  dangerous_workflow: (.checks[] | select(.name == "Dangerous-Workflow") | .score),
  code_review: (.checks[] | select(.name == "Code-Review") | .score)
}'
```

Human-readable: `https://ossf.github.io/scorecard-visualizer/#/projects/github.com/<owner>/<repo>`

### Scorecard Risk Thresholds

| Check | 🟢 Green | 🟡 Yellow | 🔴 Red |
|-------|----------|-----------|--------|
| Overall score | 7+ | 4–6.9 | <4 |
| Maintained | — | — | <3 = escalate |
| Dangerous-Workflow | — | — | <3 = escalate |

Score below 5 warrants closer inspection, though small or mature projects often score lower without being risky.

## deps.dev API

Alternative for dependency graph analysis:

```bash
curl -s "https://api.deps.dev/v3/systems/<ecosystem>/packages/<package>" | jq
```

**Ecosystems:** `npm`, `pypi`, `cargo`, `go`, `maven`, `nuget`

## Package-Specific Verification

```bash
# npm - verify package exists and view metadata
npm view <package>

# pip - check available versions
pip index versions <package>

# Go - check module at proxy
curl -s "https://proxy.golang.org/<module>/@v/list"
```
