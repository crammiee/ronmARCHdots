## Code conventions

- JSDoc every function that takes parameters and/or returns a value — document `@param` and `@returns` with their types, even for simple functions.
- No `any` — everything must be properly typed.

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
