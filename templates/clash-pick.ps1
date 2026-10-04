# clash-pick.ps1 — Windows 版 clash-pick
# 刷新 Clash Verge (mihomo) 代理节点延迟，选最快的设为当前。
# 仅依赖 Windows 自带 PowerShell，无需 Python。
#
# 用法:
#   powershell -ExecutionPolicy Bypass -File clash-pick.ps1            # 测速默认组并切最快
#   powershell -ExecutionPolicy Bypass -File clash-pick.ps1 -List      # 只测速不切换
#   powershell -ExecutionPolicy Bypass -File clash-pick.ps1 -Group 漏网之鱼 -Top 5
#
# 环境变量:
#   CLASH_PICK_API     外部控制器地址，如 http://127.0.0.1:9097
#   CLASH_PICK_SECRET  外部控制器密钥（对应 mihomo 配置的 secret）
param(
  [string]$Group = "",
  [switch]$List,
  [int]$Top = 10
)

# 常见的默认代理组名关键词，按优先级排列
$DefaultGroupHints = @("节点选择", "快速机场", "proxy", "select", "节点", "机场")

$ErrorActionPreference = "Stop"
$TestUrl  = "http://www.gstatic.com/generate_204"
$TimeoutMs = 3000
$Secret   = $env:CLASH_PICK_SECRET

function Get-Headers {
  $h = @{}
  if ($Secret) { $h["Authorization"] = "Bearer $Secret" }
  return $h
}

function Find-ApiBase {
  if ($env:CLASH_PICK_API) { return $env:CLASH_PICK_API.TrimEnd("/") }
  foreach ($port in @(9097, 9090)) {  # Clash Verge 默认 9097，mihomo 默认 9090
    try {
      $r = Invoke-RestMethod -Uri "http://127.0.0.1:$port/version" -Headers (Get-Headers) -TimeoutSec 2
      if ($r.version) { return "http://127.0.0.1:$port" }
    } catch { }
  }
  Write-Host "找不到 mihomo API。请检查："
  Write-Host "  - Clash Verge 正在运行"
  Write-Host "  - 打开 Clash Verge → 设置 → 外部控制器，把地址填入 CLASH_PICK_API（如 http://127.0.0.1:9097）"
  Write-Host "  - 若设了密钥，填入 CLASH_PICK_SECRET"
  exit 1
}

function Invoke-Mihomo($Path, $Method = "GET", $Body = $null) {
  $params = @{
    Uri = "$script:ApiBase$Path"
    Method = $Method
    Headers = (Get-Headers)
    TimeoutSec = 10
  }
  if ($Body) {
    $params.Body = ($Body | ConvertTo-Json -Compress)
    $params.ContentType = "application/json"
  }
  try {
    return Invoke-RestMethod @params
  } catch {
    Write-Host "API 调用失败 ($Method $Path): $($_.Exception.Message)"
    exit 1
  }
}

$script:ApiBase = Find-ApiBase

$proxies = (Invoke-Mihomo "/proxies").proxies

# 找 Selector 组（支持模糊匹配）
$groups = @{}
foreach ($p in $proxies.PSObject.Properties) {
  if ($p.Value.type -eq "Selector") { $groups[$p.Name] = $p.Value }
}
$groupName = $null
if ($Group -eq "") {
  # 未指定组：优先匹配常见组名，否则取第一个 Selector 组
  foreach ($hint in $DefaultGroupHints) {
    foreach ($name in $groups.Keys) {
      if ($name.ToLower().Contains($hint.ToLower())) { $groupName = $name; break }
    }
    if ($groupName) { break }
  }
  if (-not $groupName) {
    foreach ($name in $groups.Keys) { $groupName = $name; break }
  }
  if (-not $groupName) {
    Write-Host "没有找到任何 Selector 类型的代理组，请检查 Clash 配置"
    exit 1
  }
} elseif ($groups.ContainsKey($Group)) {
  $groupName = $Group
} else {
  foreach ($name in $groups.Keys) {
    if ($name.ToLower().Contains($Group.ToLower())) { $groupName = $name; break }
  }
}
if (-not $groupName) {
  Write-Host "找不到组 '$Group'，可选: $($groups.Keys -join ', ')"
  exit 1
}
$current = $groups[$groupName].now

# 收集真实节点（排除组、信息节点）
$skipTypes = @("Selector", "URLTest", "Fallback", "Direct", "Reject")
$skipWords = @("订阅", "流量", "到期", "下载", "官网")
$nodes = @()
foreach ($name in $groups[$groupName].all) {
  $node = $proxies.PSObject.Properties[$name].Value
  if ($node -and $skipTypes -notcontains $node.type) {
    $skip = $false
    foreach ($w in $skipWords) { if ($name.Contains($w)) { $skip = $true; break } }
    if (-not $skip) { $nodes += $name }
  }
}

Write-Host "组: $groupName  当前: $current  候选节点: $($nodes.Count)"
Write-Host "测速中 ($TestUrl, timeout=${TimeoutMs}ms)..."

$results = @()
foreach ($name in $nodes) {
  $enc = [uri]::EscapeDataString($name)
  $url = [uri]::EscapeDataString($TestUrl)
  $delay = 0
  try {
    $r = Invoke-RestMethod -Uri "$script:ApiBase/proxies/$enc/delay?url=$url&timeout=$TimeoutMs" -Headers (Get-Headers) -TimeoutSec 10
    if ($r.delay) { $delay = [int]$r.delay }
  } catch { $delay = 0 }
  $results += [pscustomobject]@{ Delay = $delay; Name = $name }
}

$alive = @($results | Where-Object { $_.Delay -gt 0 } | Sort-Object Delay)
$dead  = @($results | Where-Object { $_.Delay -eq 0 })

Write-Host ""
Write-Host "可用 $($alive.Count) / 超时 $($dead.Count):"
$i = 0
foreach ($r in $alive | Select-Object -First $Top) {
  $i++
  $marker = if ($r.Name -eq $current) { " ← 当前" } else { "" }
  Write-Host ("  {0,2}. {1,5}ms  {2}{3}" -f $i, $r.Delay, $r.Name, $marker)
}
if ($dead.Count -gt 0) {
  $shown = ($dead | Select-Object -First 5 | ForEach-Object { $_.Name }) -join ", "
  $more = if ($dead.Count -gt 5) { " ..." } else { "" }
  Write-Host "  ✗ 超时: $shown$more"
}

if ($alive.Count -eq 0) { Write-Host "`n没有可用节点！"; exit 1 }
if ($List) { exit 0 }

$best = $alive[0]
if ($best.Name -eq $current) {
  Write-Host "`n当前节点已是最快 ($($best.Delay)ms)，不切换"
  exit 0
}
$encGroup = [uri]::EscapeDataString($groupName)
Invoke-Mihomo "/proxies/$encGroup" "PUT" @{ name = $best.Name } | Out-Null
Write-Host "`n已切换: $current → $($best.Name) ($($best.Delay)ms)"
