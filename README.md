# 蒲公英 (PGYER) Agent Skill

[![skills.sh](https://skills.sh/b/PGYER/pgyer-skill)](https://skills.sh/PGYER/pgyer-skill)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> 蒲公英官方 Agent Skill —— 让 AI 帮你做 App 内测分发。支持 Claude Code、Cursor、Windsurf、Codex、OpenCode 等 50+ AI agent。

[English version below](#english)

## 这是什么

[蒲公英](https://www.pgyer.com) 是国内最常用的 iOS / Android / HarmonyOS 内测分发平台。
本 skill 让你的 AI agent 自动处理蒲公英相关任务：上传安装包、获取下载短链 / 二维码、
查询应用信息和历史版本、生成 CI/CD 模板等。

它**不重复造轮子**：当 [`pgyer-mcp-server`](https://github.com/PGYER/pgyer-mcp-server)
已安装时直接调用官方 MCP；其他场景使用蒲公英官方开源的 shell 脚本和 API。

## 安装

### 推荐方式：通过 `skills` CLI

[`skills`](https://github.com/vercel-labs/skills) 是开放 agent skill 生态的官方 CLI，支持 Claude Code、Cursor、Windsurf、Codex、OpenCode、Gemini 等 50+ 个 agent。

```bash
# 安装到当前项目（与代码一起 commit，团队共用）
npx skills add PGYER/pgyer-skill

# 安装到全局（你的所有项目都能用）
npx skills add PGYER/pgyer-skill -g

# 指定目标 agent（不指定时会自动检测当前环境）
npx skills add PGYER/pgyer-skill -g -a claude-code
npx skills add PGYER/pgyer-skill -g -a cursor
npx skills add PGYER/pgyer-skill -g -a codex
```

### 备选：手动安装（不想用 npx 的话）

```bash
git clone https://github.com/PGYER/pgyer-skill.git
cd pgyer-skill
./install.sh        # 安装到 ~/.claude/skills/pgyer（仅 Claude Code）
```

或直接复制整个目录到目标 agent 对应的 skills 路径。

## 配置 API Key

在 [蒲公英 API 页面](https://www.pgyer.com/account/api) 获取你的 API Key，
然后任选一种方式配置：

**方式 1：环境变量（推荐用于 CI）**

```bash
export PGYER_API_KEY=<你的 key>
```

**方式 2：本地配置文件（推荐用于个人电脑）**

```bash
mkdir -p ~/.pgyer && chmod 700 ~/.pgyer
echo 'api_key=<你的 key>' > ~/.pgyer/config
chmod 600 ~/.pgyer/config
```

## 可选：安装官方 MCP Server

skill 在 MCP server 存在时优先调用它，体验更顺滑。
常见 agent 的一键安装命令：

```bash
# Claude Code
claude mcp add --transport stdio pgyer \
  --env PGYER_API_KEY=<你的 key> \
  -- npx -y pgyer-mcp-server

# Codex CLI
codex mcp add pgyer --env PGYER_API_KEY=<你的 key> -- npx -y pgyer-mcp-server

# VSCode
code --add-mcp '{"name":"pgyer","command":"npx","args":["-y","pgyer-mcp-server"],"env":{"PGYER_API_KEY":"<你的 key>"}}'
```

其他 agent（Cursor / Windsurf / Cline / Continue 等）的 MCP 配置方法见
[`docs/use-with-other-agents.md`](docs/use-with-other-agents.md)。

## 使用示例

配好之后，直接对你的 AI agent 说话即可：

- 「把 `build/release/app.apk` 上传到蒲公英，密码设为 `qa2026`」
- 「我蒲公英上有哪些应用？」
- 「查一下短链 `zhinengshouced` 这个应用的最新版本」
- 「给我的 Android 项目加一个发布到蒲公英的 GitHub Action」

agent 会自动判断走 MCP 还是 shell 脚本，并把短链、二维码、密码等关键信息整理回来。

## 目录结构

```
pgyer-skill/
├── SKILL.md                  # skill 主体（agent 启动时读取）
├── references/
│   ├── mcp-tools.md          # MCP 工具参数与限制
│   ├── api-cheatsheet.md     # 蒲公英 HTTP API 速查
│   └── troubleshooting.md    # 常见错误码、网络问题、排查思路
├── scripts/
│   ├── pgyer_upload.sh       # 官方上传脚本（含署名，来自 upload-app-api-example）
│   ├── UPSTREAM-README.md
│   └── README.md
├── examples/                # CI/CD 模板，按平台 × OS 组织
│   ├── github-actions/
│   │   ├── android.yml
│   │   ├── ios.yml
│   │   └── harmony.yml
│   ├── gitlab-ci/
│   │   ├── android.yml
│   │   └── ios.yml
│   └── fastlane/
│       └── README.md        # 指向官方 fastlane-plugin-pgyer
├── docs/
│   └── use-with-other-agents.md  # 在 Cursor / Windsurf / Codex 等其他 agent 中使用
├── tests/
│   └── scenarios.md         # 路由回归测试（修改 SKILL.md / references/ 后跑一次）
├── install.sh               # 备选安装脚本（仅 Claude Code；推荐用 npx skills add）
└── README.md (this file)
```

## 反馈与贡献

- 问题报告：https://github.com/PGYER/pgyer-skill/issues
- 改了 `SKILL.md` / `references/`？请跑一遍 [`tests/scenarios.md`](tests/scenarios.md) 里的 10 个路由回归测试，确保没破坏决策逻辑。
- 相关项目：
  - https://github.com/PGYER/pgyer-mcp-server
  - https://github.com/PGYER/upload-app-api-example
  - https://github.com/PGYER/pgyer-upload-app-action

---

<a id="english"></a>

## English

Official PGYER (蒲公英) **Agent Skill** for iOS / Android / HarmonyOS beta
distribution. Works with Claude Code, Cursor, Windsurf, Codex CLI, OpenCode,
Gemini, and 50+ other AI agents via the open
[`skills`](https://github.com/vercel-labs/skills) CLI. Wraps the official
`pgyer-mcp-server` when installed; falls back to PGYER's official
shell-script upload flow otherwise.

### Quick start

```bash
# Install via the open skills CLI (recommended — works for 50+ agents)
npx skills add PGYER/pgyer-skill -g

# Set your API key (one of)
export PGYER_API_KEY=<your key>   # from https://www.pgyer.com/account/api
# or
echo 'api_key=<your key>' > ~/.pgyer/config && chmod 600 ~/.pgyer/config
```

Then ask your agent things like *"Upload `build/app-release.apk` to PGYER
with install password `qa2026`"* or *"List my PGYER apps"*.

### Using this skill in other AI agents

`npx skills add` covers most agents out of the box. For deeper guidance
(per-tool MCP config locations, custom Anthropic Agent SDK setups, manual
installs without the CLI), see
[`docs/use-with-other-agents.md`](docs/use-with-other-agents.md).

### License

MIT (the bundled `scripts/pgyer_upload.sh` retains its upstream license terms
from [`PGYER/upload-app-api-example`](https://github.com/PGYER/upload-app-api-example)).
