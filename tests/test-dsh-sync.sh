#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$ROOT/plugins/llm-wiki-dsh/skills/wiki"

before="$(mktemp -d)"
home="$(mktemp -d)"
trap 'rm -rf "$before" "$home"' EXIT
cp -R "$ROOT/plugins/llm-wiki-dsh/." "$before/"

"$ROOT/scripts/sync-dsh-plugin.sh" >/dev/null
diff -ru "$before" "$ROOT/plugins/llm-wiki-dsh" >/dev/null

python3 - "$TARGET" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])
text = (root / "SKILL.md").read_text(encoding="utf-8")
assert text.startswith("---\n")
assert "\nname: wiki\n" in text
assert "DeepSeek Harness Notes" in text
assert "Claude Code is both" not in text
assert (root / "references" / "refresh.md").is_file()
assert (root / "bin" / "llm-wiki").is_file()
PY

"$ROOT/scripts/install-deepseek-harness.sh" --dsh-home "$home" --verify >/dev/null
test -f "$home/skills/wiki/.llm-wiki-managed"
test -f "$home/skills/wiki/SKILL.md"
test -x "$home/skills/wiki/bin/llm-wiki"

echo "PASS: DeepSeek Harness skill sync and isolated install"
