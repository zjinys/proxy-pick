# proxy-pick

一个 Agent Skill，让 AI 编码助手通过本机的 `clash-pick` 命令管理 Clash Verge 代理节点。

## 功能

- **自动选最快节点**：`clash-pick` 一键测速并切换
- **节点健康检查**：列出所有节点的延迟和可用状态
- **多代理组支持**：通过 `--group` 切换不同订阅/策略组
- **地区感知**：AI 能根据你的需求（如"要美国节点"）在速度和地区之间给出建议

## 安装

### 1. 安装 clash-pick 命令

```bash
sudo cp templates/clash-pick /usr/local/bin/clash-pick
sudo chmod +x /usr/local/bin/clash-pick
```

确认你的 Clash Verge socket 路径：

```bash
# 默认 uid=1000
ls /run/clash-verge-service/users/1000/verge-mihomo.sock

# 如果 uid 不是 1000，先查自己的 uid
id -u
# 然后修改 /usr/local/bin/clash-pick 里的 SOCK 变量
```

### 2. 安装 Skill

```bash
npx skills add zjinys/proxy-pick
```

或者手动复制到你的 Agent skills 目录。

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

## License

MIT
