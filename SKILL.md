---
name: proxy-pick
description: 在本机装有 clash-pick 命令时，用它切换/查看代理节点。当用户说"切代理/换个节点/代理太慢/给我找个快的节点/看看现在用的什么节点/代理能通吗"，或网络请求超时、访问境外服务失败需要换线路时使用。包含健康检查、延迟测速、自动切换最快节点、按需求推荐节点。
---

# proxy-pick

> 基于本机 `clash-pick` 命令的代理节点管理 Skill。`clash-pick` 是一个操作 Clash Verge (mihomo) 的 CLI：刷新延迟、选出最快节点并切换。

## 前置检查

使用前必须确认 `clash-pick` 存在。以下任一条件不满足时，直接告诉用户"未检测到 clash-pick，请先安装"并停止，不要尝试替代方案：

```bash
command -v clash-pick
```

`clash-pick` 依赖：
- Clash Verge (mihomo) 正在运行，且 unix socket 位于 `/run/clash-verge-service/users/<uid>/verge-mihomo.sock`
- 当前用户有权限访问该 socket

## 核心命令

```bash
clash-pick                    # 刷新默认组(快速机场)测速，自动切换到最快节点
clash-pick --list             # 只测速并列出排名，不切换
clash-pick --group 漏网之鱼   # 指定代理组（支持模糊匹配，如 --group 漏网）
clash-pick --top 5            # 只显示前 5 名
```

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

- `clash-pick` 只操作 **Clash Verge (mihomo)**，不适用于 Clash for Windows / ClashX / Surge / V2Ray 等其他客户端。
- 它只能切换节点，不能修改订阅、添加节点、改路由规则。
- `--group` 只做模糊匹配（如 `--group 漏网` 匹配 `漏网之鱼`），如果匹配不到会列出所有可选组名。
- 测速目标固定为 `http://www.gstatic.com/generate_204`，超时 3 秒；国内直连快的节点不代表访问特定境外服务也快。
- 切换节点只影响**系统代理流量**，不走代理的进程不受影响。

## 安装 clash-pick

如果用户还没有 `clash-pick`，提供本 Skill 自带的实现：

```bash
# 1. 复制脚本到 PATH
sudo cp templates/clash-pick /usr/local/bin/clash-pick
sudo chmod +x /usr/local/bin/clash-pick

# 2. 确认 Clash Verge 的 socket 路径
#    默认是 /run/clash-verge-service/users/1000/verge-mihomo.sock
#    如果不是 1000，改成当前用户的 uid:
#    id -u
```

脚本零依赖，只需要系统有 `curl` 和 `python3`。
