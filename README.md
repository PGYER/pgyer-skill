# 蒲公英 (PGYER) Claude Skill

> 蒲公英官方 Claude Code Skill — 让 Claude 帮你做 App 内测分发。

[English version below](#english)

## 这是什么

[蒲公英](https://www.pgyer.com) 是国内最常用的 iOS / Android / HarmonyOS 内测分发平台。
本 skill 让 Claude Code 自动处理蒲公英相关任务：上传安装包、获取下载短链 / 二维码、
查询应用信息和历史版本、生成 CI/CD 模板等。

它**不重复造轮子**：当 [`pgyer-mcp-server`](https://github.com/PGYER/pgyer-mcp-server)
已安装时直接调用官方 MCP；其他场景使用蒲公英官方开源的 shell 脚本和 API。

## 安装

```bash
# 一键安装到 ~/.claude/skills/pgyer
git clone https://github.com/PGYER/pgyer-skill.git
cd pgyer-skill
./install.sh
```

或手动复制到 `~/.claude/skills/pgyer/`。

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
如果还没装，建议执行：

```bash
claude mcp add --transport stdio pgyer \
  --env PGYER_API_KEY=<你的 key> \
  -- npx -y pgyer-mcp-server
```

## 使用示例

配好之后，直接对 Claude 说话即可：

- 「把 `build/release/app.apk` 上传到蒲公英，密码设为 `qa2026`」
- 「我蒲公英上有哪些应用？」
- 「查一下短链 `zhinengshouced` 这个应用的最新版本」
- 「给我的 Android 项目加一个发布到蒲公英的 GitHub Action」

Claude 会自动判断走 MCP 还是 shell 脚本，并把短链、二维码、密码等关键信息整理回来。

## 目录结构

```
pgyer-skill/
├── SKILL.md                  # skill 主体（Claude 启动时读取）
├── reference/
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
├── install.sh
└── README.md (this file)
```

## 反馈与贡献

- 问题报告：https://github.com/PGYER/pgyer-skill/issues
- 相关项目：
  - https://github.com/PGYER/pgyer-mcp-server
  - https://github.com/PGYER/upload-app-api-example
  - https://github.com/PGYER/pgyer-upload-app-action

---

<a id="english"></a>

## English

Official PGYER (蒲公英) Claude Code skill for iOS / Android / HarmonyOS beta
distribution. Wraps the official `pgyer-mcp-server` when installed; falls back
to PGYER's official shell-script upload flow otherwise.

### Quick start

```bash
git clone https://github.com/PGYER/pgyer-skill.git
cd pgyer-skill && ./install.sh
export PGYER_API_KEY=<your key>   # from https://www.pgyer.com/account/api
```

Then ask Claude things like *"Upload `build/app-release.apk` to PGYER with
install password `qa2026`"* or *"List my PGYER apps"*.

### License

MIT (the bundled `scripts/pgyer_upload.sh` retains its upstream license terms
from [`PGYER/upload-app-api-example`](https://github.com/PGYER/upload-app-api-example)).
