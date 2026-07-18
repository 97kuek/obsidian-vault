## Claude Code Vault Guide

このファイルはClaude Code固有の入口である。まず共通入口の `AGENTS.md` を読み、その作業開始・終了手順に従う。ロック名は `claude` を使う。

## Claude Code固有の規約

- `.claude/commands/*.md` は `docs/workflows/` にある共通手順への薄い入口とする。
- MCPツールが使える場合も、最終的な配置・形式は `docs/standards/` の正本に従う。
- 重い探索だけをサブエージェントへ任せ、通常の検索は `rg` またはMCP検索を使う。
- `.claude/settings.json` のhookは `.obsidian/` 直下の編集保護に使う。
