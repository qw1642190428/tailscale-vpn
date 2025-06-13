#!/usr/bin/env bash
set -e

# 请替换为你生成的 Reusable Ephemeral Auth Key
AUTHKEY="tskey-auth-kzfTtbX8aZ11CNTRL-g5R7W3PUQ2Si6m5ZJEqM2Sdu6kq3a9rk?ephemeral=true&reusable=true"

# 安装 Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# 后台启动 tailscaled 使用内存模式（无需磁盘）
nohup sudo tailscaled --state=mem: >/var/log/tailscaled.log 2>&1 &

# 等待 daemon 启动
sleep 5

# 加入网络并启用 SSH 支持
sudo tailscale up --auth-key="$AUTHKEY" --hostname="ephemeral-server" --accept-routes --ssh

# 获取并显示 IPv4 地址（仅 IP 值）
IP4=$(tailscale ip --4)
echo "✅ Tailscale IPv4 地址：$IP4"

# 可选：显示完整网络状态
echo "完整状态信息："
tailscale status
