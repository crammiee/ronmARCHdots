# Build/package testing practice

Applies whenever a task involves testing a *built or packaged* artifact — an installer,
a desktop app package (Electron, Tauri, or otherwise), a compiled binary, a container
image — as opposed to just running a dev server or unit tests against source.

## Default to Docker when it's feasible for the platform

Prefer testing the packaged artifact inside Docker rather than only on the local host,
when a Docker-based test can actually exercise something meaningful for that platform.

**Why:** a build that's only ever tested on the developer's own machine hides
environment-specific breakage — host/OS interop quirks (e.g. WSL↔Windows), missing
native dependencies, differing runtime versions — that another collaborator or CI will
hit later. Docker gives every collaborator the same reproducible test environment
regardless of framework.

**How to apply:**
- Add a Dockerfile / docker-compose service that installs deps, runs the build, and
  launches the packaged app (headlessly, e.g. via Xvfb for anything with a GUI) so it
  can be exercised automatically.
- Wire that container up so it's drivable by the framework's own end-to-end testing
  story with Playwright — e.g. Playwright's `_electron` launcher for Electron apps, or
  plain Playwright browser automation if the packaged app exposes a web view/UI. The
  goal is an "agentic testing" path: a command like `docker compose run test` (or
  equivalent) that returns pass/fail without a human driving it.
- Be explicit when a step genuinely can't be tested in Docker at all — most commonly,
  a platform-native installer (Windows NSIS/MSI, macOS pkg/dmg, code signing,
  OS-level install/uninstall/registry behavior) can only be verified on the real
  target OS, not inside a Linux container. Say so rather than silently testing only
  the parts Docker can reach and calling the whole build verified.

## Always keep a human-runnable path too

Agentic/Docker/Playwright coverage does not replace a human actually building and
clicking through the real packaged app before shipping. Alongside any Docker/Playwright
setup, always add plain scripts (e.g. `build`, `start:packaged`, `test:e2e` in
package.json, or the project's equivalent task runner) that let a human reproduce the
same build and run/interact with the actual package themselves — not just read a CI
log.
