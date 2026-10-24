---
description: "Check active wiki articles against current sources without mutating raw evidence or claiming automatic verification."
argument-hint: "[<article-path>|--due] [--wiki <name|all>] [--local] [--include-archived]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(ls:*), Bash(wc:*), Bash(date:*), WebFetch, WebSearch, Agent
---

## Your task

Resolve the hub and target wiki with the standard hub-resolution protocol in
`skills/wiki-manager/references/hub-resolution.md`. Refresh targets a topic or
local wiki, not the hub itself. At the hub, ask for a topic unless `--wiki all`
was explicit. Skip archived topics unless `--include-archived` was explicit.

Read and follow these references before checking sources:

1. `skills/wiki-manager/references/refresh.md` — authoritative refresh actions,
   immutable revision rules, and human verification boundary.
2. `skills/wiki-manager/references/wiki-structure.md` — source resolution,
   volatility, and frontmatter contracts.
3. `skills/wiki-manager/references/compilation.md` — bounded article updates.
4. `skills/wiki-manager/references/inventory.md` — durable follow-up only when a
   source gap merits tracking.

Parse `$ARGUMENTS` as described in the refresh reference. Assessment is
read-only. Show the exact source/article decisions first, then apply only the
user-approved actions. Never overwrite a raw file, never set `verified` during
compile or a due scan, and never treat `updated` as human verification.
