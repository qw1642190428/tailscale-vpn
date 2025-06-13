#!/usr/bin/env bash
set -e

# 检查是否提供 Tailscale AUTHKEY
if [[ -z "$1" ]]; then
  echo "❌ 用法: bash install.sh <Tailscale AUTHKEY>"
  exit 1
fi

AUTHKEY="$1"

echo "📦 安装 Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "🚀 启动 tailscaled..."
sudo nohup tailscaled --state=mem: >/var/log/tailscaled.log 2>&1 &
sleep 5

echo "🔑 加入 Tailscale 网络..."
sudo tailscale up \
  --auth-key="$AUTHKEY" \
  --hostname="ephemeral-server" \
  --accept-routes \
  --ssh

echo ""
echo "✅ 已接入 Tailscale，IP："
sudo tailscale ip --4

echo ""
echo "📋 状态："
sudo tailscale status

# ===============================
# 安装 Hysteria 2（hy2）
# ===============================
echo ""
echo "📦 安装 Hysteria 2（hy2）..."
curl -fsSL https://get.hy2.sh | bash

echo "🛠️ 配置 Hysteria 2..."
sudo mkdir -p /etc/hysteria

# UUID 持久化
if [[ ! -f /etc/hysteria/uuid.txt ]]; then
  sudo uuidgen | tee /etc/hysteria/uuid.txt
fi

UUID=$(cat /etc/hysteria/uuid.txt)
PORT=4000

# 配置 hy2（无加密）
sudo tee /etc/hysteria/config.yaml >/dev/null <<EOF
listen: :$PORT
protocol: udp
auth:
  type: password
  password: "$UUID"
masquerade:
  type: proxy
  proxy:
    url: http://127.0.0.1
disable_udp_checksum: true
EOF

# Systemd 服务
sudo tee /etc/systemd/system/hysteria-server.service >/dev/null <<EOF
[Unit]
Description=Hysteria 2 Server
After=network.target

[Service]
ExecStart=/usr/local/bin/hysteria server -c /etc/hysteria/config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "🚀 启动 hy2 服务..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now hysteria-server

# 获取 Tailscale 内网 IPv4 地址
TS_IP=$(sudo tailscale ip --4 | head -n 1)

echo ""
echo "============================="
echo "✅ 部署完成！以下是连接信息"
echo "============================="

echo "📡 Tailscale 局域网 IPv4: $TS_IP"
echo "🧩 Hysteria2 客户端配置参考："
echo ""
echo "-----------------------------"
echo "server: $TS_IP:$PORT"
echo "auth: \"$UUID\""
echo "obfs: null"
echo "-----------------------------"
