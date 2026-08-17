# Instructions for coding agents

I'm a security engineer. Interests:
- fuzzing
- code quality
- supply-chain security

## Coding philosophy (grug-brained)

- Complexity is the apex predator: always the simplest working solution, boring proven tech, no fads.
- 80/20 rule: deliver 80% of the value with 20% of the code — build the simple solution that works,
  skip the bells and whistles unless explicitly asked for.
- Don't abstract early; wait for good cut points (narrow interfaces) to emerge from working code.
- Chesterton's fence: never remove or rewrite code unless you understand why it exists.
- Keep refactors small — the system must work after every step. No big-bang rewrites.
- Testing: integration tests are the sweet spot. When fixing a bug, write a failing
  regression test first. Mock sparingly and only at cut points; keep e2e suites small and green.
- A bit of duplication beats a clever abstraction (DRY in moderation).
- Locality of behavior: put code near the thing it affects.
- Readable over clever: named intermediate results over dense expressions.
- Never optimize without a profile; network calls dwarf CPU cycles.
- Generics and closures like salt: mostly containers and collection operations.

## Workstation layout

My work area is in `~/wa`. My projects are directly under that folder.

I clone open source projects I use or work on into `~/wa/oss`. When asked to
troubleshoot issues in third party software, I might have a clone under there.

## Tooling

- `fd`: alternative to `find`
- `rg`: alternative to `grep`
- `jq` and `yq`: manipulate structured file formats (JSON, YAML, XML, TOML)

When starting (personal) projects:
- `just` as a task runner (alternative to `make`)
- `biome` for linting and formatting web files
- `uv` to manage Python projects and venvs; `ruff` to lint, `ty` to type-check
- `bun` instead of `node` for all-in-one devex
- `go`, `templ`, `htmx` stack for cloud-native apps that need a web ui
  - `golangci-lint` for linting
  - start from [this template](https://github.com/acidghost/go-start)
  - drop `templ` and/or `htmx` if not needed
- `mise` for managing the dev environment and tools

I love building custom tools. Take every occasion to suggest building a tool to
solve a recurring problem, automate boring tasks, or aid development. Examples:
visualizations, wrappers, debuggers, alternative UIs (web or terminal), etc.

## Agent sandboxing

I often run agents under a `nono` sandbox. It uses Seatbelt on macOS and
Landlock on Linux. If running in a sandbox, env variable `NONO_CAP_FILE` gives
you the available capabilities. Sources cloned at `~/wa/oss/nono`.

Under `nono`, network access is mediated by a proxy. Some quirks:
- GitHub:
  - use REST APIs directly via `curl` instead of `gh`
  - often read-only (`HEAD`, `GET`)
  - proxy authenticates for us, no need for `Authorization` header

## Additional resources

- @AGENTS.local.md (if there is one)
