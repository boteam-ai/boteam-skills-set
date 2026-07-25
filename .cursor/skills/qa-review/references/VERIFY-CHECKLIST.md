# Verify Checklist — command detection matrix

Reference for [../SKILL.md](../SKILL.md) step 2. Detect in this order; stop at the first
match per row. Prefer whatever `AGENTS.md` already records over re-deriving it.

## Detection matrix

| Signal | Language/stack | Default commands |
|--------|-----------------|-------------------|
| `package.json` + `pnpm-lock.yaml` | Node (pnpm) | `pnpm lint`, `pnpm typecheck`, `pnpm test`, `pnpm build` |
| `package.json` + `yarn.lock` | Node (yarn) | `yarn lint`, `yarn typecheck`, `yarn test`, `yarn build` |
| `package.json` + `package-lock.json` | Node (npm) | `npm run lint`, `npm run typecheck`, `npm test`, `npm run build` |
| `package.json` + `bun.lockb` | Node (bun) | `bun run lint`, `bun run typecheck`, `bun test`, `bun run build` |
| `pyproject.toml` / `requirements.txt` | Python | `ruff check .` (or `flake8`), `pytest` |
| `go.mod` | Go | `go vet ./...`, `go test ./...`, `go build ./...` |
| `Cargo.toml` | Rust | `cargo clippy`, `cargo test`, `cargo build` |
| `Gemfile` | Ruby | `bundle exec rubocop`, `bundle exec rspec` |
| `composer.json` | PHP | `composer test` (or `phpunit`) |
| `playwright.config.*` | Any (UI) | `npx playwright test` (or the project's own script that wraps it) |

Only include a command in the resolved list if its manifest/script actually exists —
never invent a command that isn't defined in the project (e.g. don't assume `npm run lint`
exists without checking `package.json` `scripts.lint`).

If a project script exists but its exact invocation is ambiguous (e.g. multiple test
scripts), prefer the one named `test`, `test:unit`, or `ci` in that order.

## Evidence output template

Each command's evidence block should look like this — no exceptions, no summarizing away
the actual output:

```text
$ pnpm test
exit 0
... (last 20 lines of real output) ...

$ pnpm build
exit 1
... (last 20 lines, including the actual error) ...
```

## Banned phrases (never accept these as a completion claim)

If the implementing agent's own turn (not this skill) reports readiness using any of
these without attached command evidence, treat it as unverified and re-run through
`/qa-review`:

- "everything is checked" / "checked and it's ready"
- "should work" / "should be fine"
- "looks good" (without a diff/screenshot backing it)
- "QA done" / "QA passed" (without the commands run)
- "no issues found" (without having actually run anything)

## Division of labor with gstack `/qa`

| | `/qa-review` (this skill) | gstack `/qa` |
|---|---|---|
| Scope | lint/test/build/typecheck + optional single-page UI smoke | full systematic browser exploration across the app |
| Fixes code | never | yes, with atomic commits per fix |
| Speed | seconds to ~1 min | minutes (5-15+) |
| When to use | after every implementation, as the default gate | when the user explicitly wants deep interactive QA or a health-score report |

Use `/qa-review` first. If it passes but the user still wants a thorough interactive pass
(especially for UI-heavy features), hand off to gstack `/qa` or `/qa-only`.
