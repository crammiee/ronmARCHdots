# Replicating this Claude Code setup on a new device

This machine runs three tools together: `rtk` (Bash output compaction),
`code-review-graph` (per-project MCP, no setup needed beyond `uvx` — see each
project's own `.mcp.json`), and the `context-mode` plugin (WebFetch/Read/Grep/
Agent hooks + FTS5/sandbox). `rtk` owns `Bash` exclusively; `context-mode`'s
own `hooks.json` ships with `Bash` in its matcher list and must be patched
after every install/upgrade, or it collides with rtk.

`~/.claude/settings.json` (rtk hook, context-mode's `enabledPlugins` +
`extraKnownMarketplaces` entries) is dotfile-tracked and restores automatically.
The steps below are everything dotfiles can't capture.

## One-time per device

1. Install `rtk`:
   ```
   cargo install --git https://github.com/rtk-ai/rtk
   ```
2. Make sure `uv`/`uvx` is installed (system package manager — it's what
   `code-review-graph` runs through; no separate config needed once present).
3. Start Claude Code, then run:
   ```
   /plugin marketplace add mksglu/context-mode
   /plugin install context-mode@context-mode
   /reload-plugins
   ```
   (the marketplace/enabled-plugin entries may already be present from
   dotfiles — run these anyway, they're idempotent, and installation is what
   actually fetches the plugin's files into `~/.claude/plugins/cache/`.)
4. Patch out the `Bash` matcher so context-mode doesn't collide with rtk:
   ```
   node ~/.claude/scripts/fix-context-mode-hooks.mjs
   /reload-plugins
   ```
5. Recreate the two user-scoped MCP servers that live in `~/.claude.json`
   (not dotfile-tracked — that file is mostly per-machine session state):
   ```json
   "figma": { "type": "http", "url": "https://mcp.figma.com/mcp" },
   "playwright": {
     "type": "stdio", "command": "npx",
     "args": ["@playwright/mcp@latest", "--browser", "chromium"]
   }
   ```
   (drop the `--executable-path` playwright arg unless the same Chromium
   cache path exists on the new device — otherwise let it resolve the
   default.)

## After every `context-mode` upgrade (`/ctx-upgrade` or reinstall)

Upgrades resync `hooks.json` from the package template and silently restore
the `Bash` matcher. Re-run:
```
node ~/.claude/scripts/fix-context-mode-hooks.mjs
/reload-plugins
```

## Before every dotfiles commit

Check `settings.json` for hardcoded absolute paths before committing — the
plugin-install process rewrote the cache-heal hook's `$HOME/...` to a literal
`/home/<user>/...` once already during setup (cause not fully isolated —
possibly Claude Code's own hook-normalization, not just context-mode's).
`$HOME`/`~` are what make this file portable across devices/users; a literal
path baked in for one machine's username breaks it on another.
```
grep -n "/home/$(whoami)" ~/.claude/settings.json
```
Should return nothing. If it doesn't, swap the literal path back for `$HOME`.

## Verifying

- `ctx_doctor` (MCP tool or `/context-mode:ctx-doctor`) — but cross-check its
  hook-registration claims against the actual files; it has given at least
  one false positive before.
- `rtk --version` and a plain `git status` in any repo (should route through
  rtk transparently).
