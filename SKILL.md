---
name: proxy-pick
description: 切换/查看 Clash Verge (mihomo) 代理节点。当用户说"切代理/换个节点/代理太慢/给我找个快的节点/看看现在用的什么节点/代理能通吗"，或网络请求超时、访问境外服务失败需要换线路时使用。包含健康检查、延迟测速、自动切换最快节点、按需求推荐节点。
---

# proxy-pick

> 管理 Clash Verge (mihomo) 代理节点：刷新延迟、选出最快节点并切换。**自包含**，不依赖用户预装任何命令。

## 脚本定位（每次使用前先执行）

按平台从本 Skill 的 `templates/`（与本文件同目录）选实现：

| 平台 | 调用形式 |
|---|---|
| Linux / macOS | `python3 <skill目录>/templates/clash-pick --list` |
| Windows + Python | `python <skill目录>\templates\clash-pick --list` |
| Windows 无 Python | `powershell -ExecutionPolicy Bypass -File <skill目录>\templates\clash-pick.ps1 -List` |

若 `command -v clash-pick` 有输出，也可直接用 `clash-pick`。以下文档里的 `clash-pick ...` 一律替换为按上表选出的调用形式。

两个实现都只依赖平台自带运行时（Python 3 标准库 / Windows 自带 PowerShell），不需要 curl、pip 包等任何额外安装。注意 PowerShell 版参数是 `-List`、`-Group`、`-Top`（单横线）。

## 前置要求

- Clash Verge (mihomo) 正在运行
- 能找到 API，按平台自动探测：
  - **Linux**：自动探测 `/run/clash-verge-service/users/*/verge-mihomo.sock`，失败再探测 `http://127.0.0.1:9097` 和 `:9090`
  - **Windows**：探测 `http://127.0.0.1:9097` 和 `:9090`（Clash Verge 默认开启外部控制器 9097）
- 探测失败时按报错提示设置环境变量：`CLASH_PICK_API`（如 `http://127.0.0.1:9097`）、`CLASH_PICK_SECRET`（外部控制器密钥）、`CLASH_PICK_SOCK`（仅 Linux/macOS 的 socket 路径）

如果 API 连不上，直接把脚本报错原样告诉用户并停止，不要尝试其他代理方案。

## 核心命令

```bash
clash-pick                    # 自动选择默认组（匹配 节点选择/快速机场/Proxy 等常见组名），测速并切到最快
clash-pick --list             # 只测速并列出排名，不切换
clash-pick --group 漏网之鱼   # 指定代理组（模糊匹配，如 --group 漏网；也匹配英文如 --group proxy）
clash-pick --top 5            # 只显示前 5 名
```

不指定 `--group` 时按优先级匹配常见组名（`节点选择` > `快速机场` > `proxy` > `select` > `节点` > `机场`），都不匹配则取第一个 Selector 组——用户的配置叫什么名字都能跑。

输出解读：
- `可用 N / 超时 M` — 有效节点数 / 测速超时的节点数
- 列表按延迟升序，`← 当前` 标记当前使用的节点
- `✗ 超时:` 后面的节点当前不可用
- 切换成功会打印 `已切换: <旧> → <新> (<延迟>ms)`
- 如果当前节点已经最快，会打印 `当前节点已是最快，不切换`

## 触发场景与操作

| 用户意图 | 推荐操作 |
|---|---|
| "代理太慢" / "帮我换个快的" | 直接跑 `clash-pick` 自动切最快 |
| "看看有哪些节点" / "现在用什么节点" | `clash-pick --list`，报告当前节点和排名 |
| "我要看 Netflix / 需要美国节点" | `clash-pick --list`，从结果里挑地区匹配的节点；如需切换，用 `clash-pick --group <组名>` 前先确认组名，或建议用户手动在 Clash Verge 里选 |
| "Google 打不开" / "GitHub 超时" | 先 `clash-pick --list` 看当前节点是否超时；若当前节点超时则跑 `clash-pick` 切换；若节点正常，说明不是代理问题 |
| "换成日本/香港/美国节点" | `clash-pick --list` 后，若最快节点不符合地区需求，告知用户当前最快的是哪个、目标地区最快的是哪个，由用户决定是否牺牲速度换地区 |

## 边界

- 只支持 **Clash Verge (mihomo)**，不适用于 Clash for Windows / ClashX / Surge / V2Ray 等其他客户端。
- 只能切换节点，不能修改订阅、添加节点、改路由规则。
- `--group` 只做模糊匹配（如 `--group 漏网` 匹配 `漏网之鱼`），匹配不到会列出所有可选组名；组特别多时最好显式指定 `--group`，避免自动选中不想要的组。
- 测速目标固定为 `http://www.gstatic.com/generate_204`，超时 3 秒；对 gstatic 快的节点不代表访问特定境外服务也快。
- 切换节点只影响**走系统代理的流量**，不走代理的进程不受影响。

## 可选：安装为系统命令

如果用户想直接在终端里用：

```bash
# Linux / macOS
sudo cp templates/clash-pick /usr/local/bin/clash-pick
sudo chmod +x /usr/local/bin/clash-pick
```

Windows 无需安装，直接记住 ps1/py 路径即可。这是可选项——Skill 本身不需要这一步。
