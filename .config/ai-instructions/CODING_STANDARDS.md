## Code conventions

- JSDoc every function that takes parameters and/or returns a value — document `@param` and `@returns` with their types, even for simple functions.
- **Don't blindly mirror the surrounding file's comment density.** When extending a file that already over-comments (e.g. a comment on every schema/interface field restating its name), judge each new comment on its own merit instead of copy-pasting the existing pattern. Keep a comment only if it conveys something the identifier/type doesn't already say (a non-obvious constraint, an edge case, what a `null`/sentinel value specifically means). Drop it if it's just the field name in prose. This applies to JSDoc, schema/property comments, and inline comments alike — and overrides "even for simple functions" above when a function's own name and signature already make its behavior obvious.
- No `any` — everything must be properly typed.
- **Side-effect logging** — code that performs I/O, network calls, IPC, process spawning, or external state mutation logs at the point the effect happens, using the project's structured logger (not `console.log`) where one exists. Log level by severity: debug for routine operations, info for lifecycle milestones, warn/error for failures. Applies to applications and long-running services; skip for trivial scripts.

## Commit conventions

- Conventional commits format (`feat:`, `fix:`, `refactor:`, etc.).
- No `Co-authored-by: Claude` trailer.
- Describe what actually changed, not a milestone/stage label — "finished stage 1" tells a reader nothing about what happened. Keep the subject line short; put specifics in the body if needed.

## Engineering principles

- **SOLID**, **DRY**, **KISS**, **SoC** — standard, apply throughout.
- **YAGNI** — no speculative features; build only what the current task needs.
- **BDUF, scoped to architecture only** — think through module boundaries, interfaces, and DB/schema shape before coding to avoid painful rework. This does not override YAGNI on feature scope — only the *shape* of what you're building gets upfront thought, not speculative features.

## Testing approach

Follow the testing pyramid, not strict TDD:

- Lots of fast **unit tests** on business logic (services, calculations, validation).
- Fewer **integration tests** for DB/Redis interactions.
- A thin layer of **e2e tests** on critical flows (auth, signup).
- Write tests alongside or right after the implementation, not necessarily before — reserve test-first for gnarly or bug-prone logic where nailing the spec first genuinely helps.
- Prioritize coverage on business logic and critical paths over trivial code (simple getters, DTO mapping).
