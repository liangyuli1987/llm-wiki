#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_SKILL="$ROOT/claude-plugin/skills/wiki-manager"
LOCAL_HELPER="$ROOT/scripts/llm-wiki"
TARGET_PLUGIN="$ROOT/plugins/llm-wiki-dsh"
TARGET_SKILL="$TARGET_PLUGIN/skills/wiki"

for required in "$SOURCE_SKILL/SKILL.md" "$LOCAL_HELPER"; do
  if [ ! -e "$required" ]; then
    echo "Missing source file: $required" >&2
    exit 1
  fi
done

rm -rf "$TARGET_SKILL"
mkdir -p "$TARGET_SKILL"
cp -R "$SOURCE_SKILL/." "$TARGET_SKILL/"
mkdir -p "$TARGET_SKILL/bin"
cp "$LOCAL_HELPER" "$TARGET_SKILL/bin/llm-wiki"
chmod 0755 "$TARGET_SKILL/bin/llm-wiki"

python3 - "$TARGET_SKILL/SKILL.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
start = text.find("---\n")
end = text.find("\n---\n", start + 4)
if start != 0 or end == -1:
    raise SystemExit(f"Unexpected frontmatter in {path}")

frontmatter = """---
name: wiki
description: >
  Manage LLM-compiled wikis in DeepSeek Harness: ingest/import, shape Ideas,
  track inventory and datasets, compile/query/lint/audit, research/plan,
  manage sessions, private adapters, personal specialists, and outputs.
  Use for wiki workflows, knowledge-base management, source ingestion,
  compilation, provenance, audits, and /wiki-style requests.
---
"""
text = frontmatter + text[end + 5 :]

replacements = [
    (
        "You manage an LLM-compiled knowledge base. Source documents are ingested into `raw/`, then incrementally compiled into a wiki of interconnected markdown articles. Claude Code is both the compiler and the query engine — no Obsidian, no external tools.\n",
        "You manage an LLM-compiled knowledge base. Source documents are ingested into `raw/`, then incrementally compiled into a wiki of interconnected markdown articles. DeepSeek Harness is both the compiler and the query engine.\n\n## DeepSeek Harness Notes\n\nThis directory is a native filesystem skill bundle. Invoke it as `/wiki`, or let the harness load it from a matching request. Treat `/wiki:*` examples as workflow shorthand under the loaded `/wiki` skill. The deterministic helper is bundled at `bin/llm-wiki` inside this skill; use it instead of assuming a global executable.\n",
    ),
    (
        "**Dual-linking for Obsidian + Claude.** Cross-references use both `[[wikilink]]` (for Obsidian graph view) and standard markdown `[text](path)` (for Claude navigation) on the same line: `[[slug|Name]] ([Name](../category/slug.md))`. Bidirectional when it makes sense.",
        "**Dual-linking for Obsidian + DeepSeek Harness.** Cross-references use both `[[wikilink]]` (for Obsidian graph view) and standard markdown `[text](path)` (for harness navigation) on the same line: `[[slug|Name]] ([Name](../category/slug.md))`. Bidirectional when it makes sense.",
    ),
    (
        "When this skill activates outside of an explicit `/wiki:*` command:",
        "When this skill activates outside of an explicit `/wiki` invocation:",
    ),
    (
        '4. If no relevant content → answer normally, optionally suggest: "This could be added to your wiki with `/wiki:ingest`"',
        '4. If no relevant content → answer normally, optionally suggest: "This could be added to your wiki; invoke `/wiki` and ask to ingest it."',
    ),
    (
        'Track uncompiled sources by comparing `raw/_index.md` ingestion dates against the last compile date in `_index.md`. If 5+ uncompiled sources exist after an ingestion, suggest: "You have N uncompiled sources. Run `/wiki:compile` to integrate them."',
        'Track uncompiled sources by comparing `raw/_index.md` ingestion dates against the last compile date in `_index.md`. If 5+ uncompiled sources exist after an ingestion, suggest: "You have N uncompiled sources. Invoke `/wiki` and ask to compile them."',
    ),
    (
        "Multiple Claude Code sessions can safely read and write to the same wiki simultaneously. No locks are needed.",
        "Multiple DeepSeek Harness sessions can safely read and write to the same wiki simultaneously. No locks are needed.",
    ),
]
for old, new in replacements:
    if old not in text:
        raise SystemExit(f"Expected text not found in {path}: {old[:80]!r}")
    text = text.replace(old, new)

with path.open("w", encoding="utf-8", newline="\n") as handle:
    handle.write(text)
PY

cat > "$TARGET_PLUGIN/README.md" <<'EOF'
# llm-wiki for DeepSeek Harness

This generated package provides the `/wiki` filesystem skill for DeepSeek
Harness. Install it with `scripts/install-deepseek-harness.sh`; the installer
copies the self-contained bundle to `${DSH_HOME:-~/.dsh}/skills/wiki`.

DeepSeek Harness is still a developer preview. This integration deliberately
uses only its documented filesystem-skill contract and does not install a
custom runtime plugin. If session hooks are desired, use the harness's official
Codex-hook compatibility bridge separately.
EOF

echo "Synced DeepSeek Harness skill from Claude source."
echo "Target: $TARGET_SKILL"
