#!/usr/bin/env bash
set -e

if [[ -z "$1" ]]; then
  echo "❌ 用法: bash install.sh <Tailscale AUTHKEY>"
  exit 1
fi

AUTHKEY="$1"

echo "📦 正在安装 Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "🚀 启动 tailscaled (内存模式)..."
sudo nohup tailscaled --state=mem: >/var/log/tailscaled.log 2>&1 &

sleep 5

echo "🔑 使用 AUTHKEY 加入 Tailscale 网络..."
sudo tailscale up \
  --auth-key="$AUTHKEY" \
  --hostname="ephemeral-server" \
  --accept-routes \
  --ssh

echo ""
echo "✅ 已成功接入 Tailscale 网络"
echo -n "📡 分配的 IPv4 地址："
sudo tailscale ip --4

echo ""
echo "📋 当前连接状态："
sudo tailscale status
