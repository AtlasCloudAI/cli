# 用 Atlas 和你的 AI 助手一起创作

用自然语言描述需求，让 Agent 通过 Atlas 找模型、检查参数、生成内容并交付文件。
从产品图、参考图编辑、图片动画、配音、3D 资产，或指定模型的聊天与分析开始。

## 选择接入方式

| 你怎么使用 | 选择 | 当前支持 |
|---|---|---|
| Claude Code、Codex 等能运行终端命令的 Agent | **CLI + Atlas skill，推荐** | 公开安装 atlas，登录后安装 skill 入口 |
| 终端、脚本或 CI | **CLI** | 使用命令和 --json，不必安装 skill |
| 已有本地 MCP 环境、能访问源码的开发者 | **实验性 MCP** | 单独构建 atlas-mcp，仅支持本地 stdio |

CLI 执行操作，Skill 指导 Agent 完成任务，MCP 向客户端提供工具。无需同时接入两套。
Atlas 当前没有在此提供公共远程 MCP 地址，网页聊天产品不能通过填写 URL 连接本地 stdio 服务。

## 三步开始

**第一步，安装 CLI。** macOS / Linux：

```sh
curl -fsSL https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.sh | sh
```

Windows PowerShell：

```powershell
irm https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.ps1 | iex
```

也可以使用 `npm install -g atlascloud-cli`。用 `atlas version --json` 确认安装；
安装脚本提示 PATH 缺失时，按提示添加目录后继续。

**第二步，检查登录；没有登录时完成授权。**

```sh
atlas auth status --json
atlas auth login
```

`auth status` 只看本地 token、不调服务端。只有 `status` 为 `logged_in` 才表示
access token 仍有效；`expired` 或 `refresh_required` 需要重新登录。

日常使用优先复用 OAuth 登录，无需把 API key 交给 Agent。出错时先运行
`atlas doctor --json`。生产账号登录成功不代表每个供应商都可用；不要为了绕过供应商
错误切换 dev 环境或覆盖原有凭据。

**第三步，按你使用的 Agent 选择一条安装命令。**

```sh
atlas skills install --agent claude
atlas skills install --agent codex
```

默认写入 `~/.claude/skills/atlas/SKILL.md` 或 `~/.codex/skills/atlas/SKILL.md`；
Codex 配置了 `CODEX_HOME` 时使用其 `skills/atlas/SKILL.md`。
项目级安装或其他支持 Markdown skills 的工具，可指定其 skills 父目录：

```sh
atlas skills install --dir .claude/skills
```

命令会显示实际位置和下一步，不覆盖不同内容的已有文件。安装后新开 Agent 会话。
安装 skill 不代表已经登录，也不会提交付费生成任务。

## 复制给 Agent 帮你配置

> 请帮我配置 AtlasCloud。先检查 atlas 是否已安装；未安装时使用官方安装方式。
> 检查 `atlas auth status --json`，仅当 `status` 为 `logged_in` 时复用现有登录；
> `expired` / `refresh_required` / `not_logged_in` 时引导我完成 `atlas auth login`。
> 为我当前使用的 Claude Code 或 Codex 安装 atlas skill；无法确定工具时先问我。
> 最后读取 `atlas skills read atlas --raw` 验证指南可用，告诉我是否需要新开会话。
> 配置过程不要生成付费内容。

## 从一个具体任务开始

| 你可以这样说 | Agent 应完成的事 |
|---|---|
| 用 Atlas 给这件产品做一张电商图，保留包装和 logo，先给模型与费用估算 | 找支持参考图的模型、检查参数并估价，不擅自省略参考图 |
| 用我指定的 MODEL 生成一张横版海报，保存到当前项目 | 保留模型选择、验证参数、生成并检查实际文件 |
| 用 Atlas 把这张图做成 5 秒竖屏视频，镜头缓慢推进 | 核实能力、传入参考图、提交一次、等待并交付 |
| 这个 Atlas 任务 ID 等待超时了，继续查，不要重新生成 | 查询原 prediction ID，不重复提交和扣费 |
| 用 Atlas 给这段话配音，先看看有哪些可用模型 | 查询音频能力与 voice 参数，按授权范围执行 |
| 用 Atlas 的 MODEL 分析这张图片 | 核实多模态能力，把实际图片传给指定模型 |

将 MODEL 换成真实模型 ID。不指定模型时，Agent 会查询实时 catalog 并说明选择理由。
具体参数、价格和可用能力以当前账号返回的信息为准。授权生成会产生模型调用费用；
可以明确预算、数量、尺寸及是否允许迭代。

交付应包含模型、任务状态和真实文件路径或远程链接。任务 ID 只表示已提交；等待超时
不等于任务失败；远程生成成功也不等于文件已经保存到本地。

## 更新之后

入口只引导 Agent 读取 CLI 内的指南。CLI 更新后，下次 Atlas 任务会读取新版流程；
已加载的会话上下文不会自动替换。原生安装遵循 CLI 自动更新策略，npm/Homebrew
仍由包管理器更新。无需每次复制整套 skill 文档。

## 开发者的本地 MCP 接入

需要源码访问权限，公开 CLI 安装包不包含 atlas-mcp：

```sh
make build-mcp
./bin/atlas-mcp auth login --device
```

CLI 和 MCP 使用独立凭据存储，CLI 已登录不代表 MCP 已登录。支持 stdio 的客户端
可以使用以下配置，将路径换成实际绝对路径；配置文件位置取决于客户端：

```json
{
  "mcpServers": {
    "atlas": {
      "command": "/absolute/path/to/atlas-mcp",
      "args": ["serve", "--stdio"]
    }
  }
}
```

连接后先使用 `atlas_skill_list`，再通过 `atlas_skill_read` 的 `target: "atlas"`
读取指南，按需加载 reference。读取技能不要求模型认证。实际模型操作遵循 MCP
暴露的 tool schema，不要把 CLI 参数直接当作 MCP 参数。HTTP transport 尚未实现。
