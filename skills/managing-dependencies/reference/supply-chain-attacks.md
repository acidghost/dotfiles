# Supply Chain Attack Reference

## Dependency Confusion

When using both public and private registries, attackers can publish public packages matching your internal package names with high version numbers.

**Defenses:**

Use scoped/namespaced packages for internal code:
```bash
# npm - attackers can't register under your scope
@yourcompany/internal-utils

# Configure scope to route to private registry
# .npmrc
@yourcompany:registry=https://your-internal-registry.com
```

For pip, use `--index-url` for private registry, `--extra-index-url` for PyPI:
```bash
# Correct - private registry checked first
pip install --index-url https://private.example.com/simple \
            --extra-index-url https://pypi.org/simple \
            mypackage
```

Defensively register your internal package names on public registries with placeholder packages.

## Lockfile Injection

Attackers compromise a dependency's resolved URL to point to malicious code.

**Detection in PR review:**
- Watch for changes to `resolved` or `integrity` fields in lockfiles
- Unexpected registry URL changes are red flags
- Large diffs can hide malicious additions — review line by line

**Prevention:**
- Always use `npm ci` (not `npm install`) in CI
- Use `--frozen` or `--locked` flags in all ecosystems
- Verify lockfile integrity before building

## Install Scripts

Package managers execute code during install — a common attack vector:

| Ecosystem | Mechanism | Risk |
|-----------|-----------|------|
| npm | `preinstall`, `postinstall`, `install` in package.json | High |
| pip | `setup.py` runs during install | High |
| Ruby | `extconf.rb` for native extensions | Medium |
| Go | No install-time code execution | Low |

**Mitigation for npm:**

```bash
# Install without running scripts, then review
npm install --ignore-scripts

# After reviewing source, run scripts explicitly
npm rebuild
```

For high-security environments, disable install scripts globally and allowlist specific packages.

## Provenance and Attestation

Check if a package has verified build provenance — the published artifact matches the source repo and commit.

```bash
# npm - check for attestation
npm audit signatures

# PyPI - check for Sigstore attestation
curl -s "https://pypi.org/pypi/<package>/json" | jq '.urls[0].digests'

# GitHub Actions - verify with gh
gh attestation verify <artifact> --owner <org>
```

**Trusted publishing** means the package was published directly from CI (GitHub Actions, GitLab CI) without maintainer credentials. npm, PyPI, and RubyGems support this.

## When Vulnerability Has No Patch

First check reachability: is the vulnerable code path actually called by your usage? Many CVEs affect features you don't use.

Options in order of preference:

1. **Override transitive** — Force newer version of vulnerable transitive dependency
2. **Fork and patch** — Apply security fix to fork, reference fork in manifest
3. **Remove dependency** — Find alternative or inline the functionality
4. **Accept risk** — Document why it's not exploitable in your context

## Vendoring

Copy dependencies into your repo for airgapped environments, auditing, or when you need to patch upstream:

```bash
# Go - built-in
go mod vendor
go build -mod=vendor

# Python
pip download -r requirements.txt -d ./vendor
pip install --no-index --find-links=./vendor -r requirements.txt
```

Vendoring trades registry availability risk for increased repo size and manual update burden. Justified for airgapped builds, audited security-critical code, or long-term forks.
