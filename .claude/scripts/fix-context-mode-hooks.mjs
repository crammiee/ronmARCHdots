#!/usr/bin/env node
// Removes the "Bash" PreToolUse matcher from the installed context-mode
// plugin's hooks.json so it doesn't collide with rtk's own PreToolUse:Bash
// hook (rtk owns Bash exclusively in this setup; context-mode covers
// WebFetch/Read/Grep/Agent instead). Idempotent — safe to re-run after
// every `/ctx-upgrade`, `/plugin update`, or fresh `/plugin install`, since
// those resync hooks.json from the package template and silently restore
// the Bash matcher.
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { resolve } from "node:path";
import { homedir } from "node:os";

const registryPath = resolve(homedir(), ".claude", "plugins", "installed_plugins.json");
if (!existsSync(registryPath)) {
  console.error("fix-context-mode-hooks: no installed_plugins.json found — is the plugin installed?");
  process.exit(1);
}

const registry = JSON.parse(readFileSync(registryPath, "utf-8"));
const entries = registry.plugins?.["context-mode@context-mode"] ?? [];
if (entries.length === 0) {
  console.error("fix-context-mode-hooks: context-mode@context-mode not found in installed_plugins.json");
  process.exit(1);
}

let changedAny = false;
for (const entry of entries) {
  const hooksPath = resolve(entry.installPath, "hooks", "hooks.json");
  if (!existsSync(hooksPath)) {
    console.warn(`fix-context-mode-hooks: no hooks.json at ${hooksPath}, skipping`);
    continue;
  }
  const manifest = JSON.parse(readFileSync(hooksPath, "utf-8"));
  const preToolUse = manifest.hooks?.PreToolUse ?? [];
  const before = preToolUse.length;
  manifest.hooks.PreToolUse = preToolUse.filter((h) => h.matcher !== "Bash");
  const after = manifest.hooks.PreToolUse.length;

  if (after < before) {
    writeFileSync(hooksPath, JSON.stringify(manifest, null, 2) + "\n", "utf-8");
    console.log(`fix-context-mode-hooks: removed Bash matcher from ${hooksPath}`);
    changedAny = true;
  } else {
    console.log(`fix-context-mode-hooks: ${hooksPath} already clean, no Bash matcher present`);
  }
}

if (changedAny) {
  console.log("fix-context-mode-hooks: run /reload-plugins to apply");
}
