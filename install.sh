#!/usr/bin/env bash
set -e

# 判断是否传入 AUTHKEY
if [[ -z "$1" ]]; then
  echo "❌ 用法: bash install.sh <Tailscale AUTHKEY>"
  exit 1
fi

AUTHKEY="$1"

# 安装 tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# 启动 tailscaled (内存模式)
nohup tailscaled --state=mem: >/var/log/tailscaled.log 2>&1 &
sleep 5

# 加入网络并启用 SSH，使用传入的 AUTHKEY
tailscale up --auth-key="$AUTHKEY" \
  --hostname="ephemeral-server" \
  --accept-routes --ssh

# 显示 IP
echo "✅ 设备已上线，分配的 Tailscale IP："
tailscale ip --4

# 可选：显示详细状态
echo "📋 当前连接状态："
tailscale status
