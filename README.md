# proxy-pick

[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-Standard-blue)](https://agentskills.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

一个 Agent Skill，让 AI 编码助手帮你管理 Clash Verge 代理节点：一键测速、自动切换到最快的节点、检查节点健康状态。**自包含**，装上 Skill 就能用，不需要预装任何命令。

## 功能

- **自动选最快节点**：一键测速并切换
- **节点健康检查**：列出所有节点的延迟和可用状态
- **多代理组支持**：通过 `--group` 切换不同订阅/策略组，不写死组名
- **地区感知**：AI 能根据你的需求（如"要美国节点"）在速度和地区之间给出建议
- **跨平台**：Linux / macOS / Windows 全支持，Windows 没装 Python 也有 PowerShell 版

## 安装

```bash
npx skills add zjinys/proxy-pick
```

Skill 自带脚本，按平台自动选择实现：

| 平台 | 脚本 | 依赖 |
|---|---|---|
| Linux / macOS | `templates/clash-pick` | Python 3 标准库 |
| Windows + Python | `templates/clash-pick` | Python 3 标准库 |
| Windows 无 Python | `templates/clash-pick.ps1` | Windows 自带 PowerShell |

## 使用

对 AI 说：

```
"代理太慢了，帮我换个快的"
"看看现在用的什么节点"
"Google 打不开，是不是节点挂了"
"我要看 Netflix，给我找个美国节点"
```

AI 会自动调用脚本完成测速、切换、报告结果。实际输出长这样：

```
组: 快速机场  当前: 🇯🇵日本 05 | 高级专线  候选节点: 19
测速中 (http://www.gstatic.com/generate_204, timeout=3000ms)...

可用 17 / 超时 2:
   1.    60ms  🇯🇵日本 04 | 高级专线
   2.    74ms  🇯🇵日本 01 | 高级专线
   3.    77ms  🇯🇵日本 09 | 高级专线
   ...
  10.   200ms  🇺🇸美国 02 | 专线
  ✗ 超时: 一元机场.asia, 🇯🇵日本 05 | 高级专线

已切换: 🇯🇵日本 05 | 高级专线 → 🇯🇵日本 04 | 高级专线 (60ms)
```

## 命令参考

```bash
clash-pick                    # 自动选择默认组（匹配 节点选择/快速机场/Proxy 等），测速并切到最快
clash-pick --list             # 只测速并列排名，不切换
clash-pick --group 漏网之鱼   # 指定代理组（模糊匹配，中英文均可）
clash-pick --top 5            # 只显示前 5 名
```

不指定 `--group` 时按 `节点选择` > `快速机场` > `proxy` > `select` > `节点` > `机场` 的优先级自动匹配；都不匹配则取第一个 Selector 组。

想脱离 AI 直接在终端里用，可以把脚本装成系统命令（可选）：

```bash
# Linux / macOS
sudo cp templates/clash-pick /usr/local/bin/clash-pick
sudo chmod +x /usr/local/bin/clash-pick

# Windows：记住路径直接调
powershell -ExecutionPolicy Bypass -File templates\clash-pick.ps1 -List
```

## API 连接

脚本自动探测 mihomo API，一般不需要配置：

- **Linux**：探测 unix socket `/run/clash-verge-service/users/*/verge-mihomo.sock`，失败再探测 `http://127.0.0.1:9097` 和 `:9090`
- **Windows**：探测 `http://127.0.0.1:9097` 和 `:9090`（Clash Verge 默认开启外部控制器）

探测不到时用环境变量指定：

```bash
export CLASH_PICK_API=http://127.0.0.1:9097   # 外部控制器地址
export CLASH_PICK_SECRET=<密钥>               # mihomo secret（如设置了）
export CLASH_PICK_SOCK=/path/to/verge-mihomo.sock  # 仅 Linux/macOS
```

| 变量 | 用途 |
|---|---|
| `CLASH_PICK_SOCK` | 覆盖 mihomo unix socket 路径（仅 Linux/macOS，默认自动探测） |
| `CLASH_PICK_API` | 外部控制器地址，如 `http://127.0.0.1:9097` |
| `CLASH_PICK_SECRET` | 外部控制器密钥（对应 mihomo 配置的 secret） |

## 要求

- Clash Verge (mihomo) 运行中
- Python 3（Linux/macOS/Windows），或 Windows 自带 PowerShell

## License

MIT
