# proxy-pick

一个 Agent Skill，让 AI 编码助手通过本机的 `clash-pick` 命令管理 Clash Verge 代理节点。

## 功能

- **自动选最快节点**：`clash-pick` 一键测速并切换
- **节点健康检查**：列出所有节点的延迟和可用状态
- **多代理组支持**：通过 `--group` 切换不同订阅/策略组
- **地区感知**：AI 能根据你的需求（如"要美国节点"）在速度和地区之间给出建议

## 安装

```bash
npx skills add zjinys/proxy-pick
```

Skill **自包含**：自带跨平台脚本，不需要预装任何命令：

| 平台 | 脚本 | 依赖 |
|---|---|---|
| Linux / macOS | `templates/clash-pick` | Python 3 标准库 |
| Windows + Python | `templates/clash-pick` | Python 3 标准库 |
| Windows 无 Python | `templates/clash-pick.ps1` | Windows 自带 PowerShell |

API 自动探测：Linux 探测 unix socket（`/run/clash-verge-service/users/*/verge-mihomo.sock`），Windows/兜底探测 `http://127.0.0.1:9097` 和 `:9090`。探测不到时可用环境变量指定：

```bash
export CLASH_PICK_API=http://127.0.0.1:9097   # 外部控制器地址
export CLASH_PICK_SECRET=<密钥>               # mihomo secret（如设置了）
export CLASH_PICK_SOCK=/path/to/verge-mihomo.sock  # 仅 Linux/macOS
```

### 可选：安装为系统命令

想直接在终端里敲 `clash-pick`：

```bash
sudo cp templates/clash-pick /usr/local/bin/clash-pick
sudo chmod +x /usr/local/bin/clash-pick
```

Windows 直接用：

```powershell
powershell -ExecutionPolicy Bypass -File templates\clash-pick.ps1 -List
```

## 使用

对 AI 说：

```
"代理太慢了，帮我换个快的"
"看看现在用的什么节点"
"Google 打不开，是不是节点挂了"
"我要看 Netflix，给我找个美国节点"
```

AI 会自动调用 `clash-pick` 完成测速、切换、报告结果。

## clash-pick 命令参考

```bash
clash-pick                    # 自动选择默认组（匹配 节点选择/快速机场/Proxy 等），测速并切到最快
clash-pick --list             # 只测速并列排名，不切换
clash-pick --group 漏网之鱼   # 指定代理组（模糊匹配，中英文均可）
clash-pick --top 5            # 只显示前 5 名
```

不指定 `--group` 时按 `节点选择` > `快速机场` > `proxy` > `select` > `节点` > `机场` 的优先级自动匹配；都不匹配则取第一个 Selector 组。

## 要求

- Clash Verge (mihomo) 运行中
- Linux/macOS/Windows 有 Python 3，或 Windows 自带 PowerShell

## 环境变量

| 变量 | 用途 |
|---|---|
| `CLASH_PICK_SOCK` | 覆盖 mihomo unix socket 路径（仅 Linux/macOS，默认自动探测） |
| `CLASH_PICK_API` | 外部控制器地址，如 `http://127.0.0.1:9097` |
| `CLASH_PICK_SECRET` | 外部控制器密钥（对应 mihomo 配置的 secret） |

## License

MIT
