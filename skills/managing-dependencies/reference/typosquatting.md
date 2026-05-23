# Typosquatting & Slopsquatting Reference

## Typosquatting Patterns

Watch for these when verifying package names:

- **Character substitution**: `djang0` vs `django`, `requets` vs `requests`
- **Character omission**: `loadsh` vs `lodash`, `electon` vs `electron`
- **Homoglyphs**: `pyp1` (one) vs `pypi` (letter i), Cyrillic `а` vs Latin `a`
- **Delimiter variation**: `cross-env` vs `crossenv` vs `cross_env`
- **Scope confusion**: `@angular-devkit/core` vs `@angulardevkit/core`
- **Combosquatting**: `lodash-js`, `axios-api`, `express-utils`
- **Namespace confusion** (Maven): `org.fasterxml` vs `com.fasterxml`

Always copy package names from official docs rather than typing from memory.

## Slopsquatting (AI Hallucinated Packages)

AI coding assistants hallucinate package names regularly. Attackers register these names with malicious code.

Before installing any AI-suggested package:

1. **Verify it exists**: `npm view <package>` or `pip index versions <package>`
2. **Check age and downloads**: Very new + few downloads = suspect
3. **Cross-reference docs**: Does the framework's official docs mention it?
4. **Check for typosquatting**: See patterns above

Hallucinated names are often repeatable across sessions, making them predictable targets for attackers.

## Detection Checklist

When `eval-package` returns yellow or red flags, check:

- [ ] Package name differs from canonical name by 1–2 characters
- [ ] Package name uses unusual delimiters or capitalization
- [ ] Package was registered recently (<90 days)
- [ ] Package has very few downloads relative to its claimed purpose
- [ ] No corresponding repository, or repo created recently
- [ ] Description closely mirrors a popular package
- [ ] Maintainer account has no other packages or activity
