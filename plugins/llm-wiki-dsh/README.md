# llm-wiki for DeepSeek Harness

This generated package provides the `/wiki` filesystem skill for DeepSeek
Harness. Install it with `scripts/install-deepseek-harness.sh`; the installer
copies the self-contained bundle to `${DSH_HOME:-~/.dsh}/skills/wiki`.

DeepSeek Harness is still a developer preview. This integration deliberately
uses only its documented filesystem-skill contract and does not install a
custom runtime plugin. If session hooks are desired, use the harness's official
Codex-hook compatibility bridge separately.
