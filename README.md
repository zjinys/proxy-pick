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

Skill **自包含**：自带的 `templates/clash-pick` 脚本会被 AI 直接调用，不需要预装任何命令。脚本零依赖，只需要系统有 `python3` 和 `curl`。

脚本会自动探测 `/run/clash-verge-service/users/*/verge-mihomo.sock`。探测不到时可用环境变量指定：

```bash
export CLASH_PICK_SOCK=/path/to/verge-mihomo.sock   # unix socket
export CLASH_PICK_API=http://127.0.0.1:9097          # 或 HTTP API
```

### 可选：安装为系统命令

想直接在终端里敲 `clash-pick`：

```bash
sudo cp templates/clash-pick /usr/local/bin/clash-pick
sudo chmod +x /usr/local/bin/clash-pick
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
clash-pick                    # 测速默认组(快速机场)，自动切换到最快节点
clash-pick --list             # 只测速并列排名，不切换
clash-pick --group 漏网之鱼   # 指定代理组（模糊匹配）
clash-pick --top 5            # 只显示前 5 名
```

## 要求

- Clash Verge (mihomo) 运行中
- Python 3
- curl

## 环境变量

| 变量 | 用途 |
|---|---|
| `CLASH_PICK_SOCK` | 覆盖 mihomo unix socket 路径（默认自动探测） |
| `CLASH_PICK_API` | 改用 HTTP API，如 `http://127.0.0.1:9097` |

## License

MIT
