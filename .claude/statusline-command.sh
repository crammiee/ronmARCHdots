#!/bin/bash
# Status line converted from ~/.bashrc PS1='[\u@\h \W]\$ '
# \u -> $(whoami), \h -> $(hostname -s), \W -> basename of cwd
# Trailing \$ prompt character dropped per statusline conversion rules.

input=$(cat)
cwd=$(printf '%s' "$input" | node -e '
  let d = "";
  process.stdin.on("data", c => d += c);
  process.stdin.on("end", () => {
    try {
      const j = JSON.parse(d);
      process.stdout.write(j.workspace?.current_dir ?? j.cwd ?? "");
    } catch {}
  });
')

user=$(whoami)
host=$(uname -n)
dir=$(basename "$cwd")

printf '[%s@%s %s]' "$user" "$host" "$dir"
