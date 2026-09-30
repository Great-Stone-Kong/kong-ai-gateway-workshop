#!/bin/bash
set -euo pipefail

WORKDIR=/tmp/kong-workshop
LICENSE_SRC="$WORKDIR/license.json"
YML_SRC="$WORKDIR/kong.yml"
KONG_IMAGE="${KONG_IMAGE:-kong/kong-gateway:3.15}"
PUBLIC_IP="${PUBLIC_IP:?PUBLIC_IP is required}"
ADMIN_GUI_URL="http://${PUBLIC_IP}:8002"
ADMIN_GUI_API_URL="http://${PUBLIC_IP}:8001"

echo "Waiting for user-data / Docker..."
for _ in $(seq 1 60); do
  if [[ -f /var/tmp/user-data-done ]] && command -v docker >/dev/null 2>&1 && sudo docker info >/dev/null 2>&1; then
    break
  fi
  sleep 5
done

if ! sudo docker info >/dev/null 2>&1; then
  echo "Docker is not ready" >&2
  exit 1
fi

sudo mkdir -p /etc/kong/declarative
sudo cp "$LICENSE_SRC" /etc/kong/license.json
sudo chmod 600 /etc/kong/license.json
sudo cp "$YML_SRC" /etc/kong/declarative/kong.yml
sudo chmod 644 /etc/kong/declarative/kong.yml

KONG_LICENSE_DATA="$(sudo cat /etc/kong/license.json | tr -d '\n')"

sudo docker pull "$KONG_IMAGE"
sudo docker rm -f kong >/dev/null 2>&1 || true
sudo docker run -d --name kong --restart unless-stopped \
  -p 8000:8000 -p 8001:8001 -p 8002:8002 \
  -e KONG_DATABASE=off \
  -e KONG_DECLARATIVE_CONFIG=/kong/declarative/kong.yml \
  -e KONG_PROXY_LISTEN=0.0.0.0:8000 \
  -e KONG_ADMIN_LISTEN=0.0.0.0:8001 \
  -e KONG_ADMIN_GUI_LISTEN=0.0.0.0:8002 \
  -e "KONG_ADMIN_GUI_URL=$ADMIN_GUI_URL" \
  -e "KONG_ADMIN_GUI_API_URL=$ADMIN_GUI_API_URL" \
  -e KONG_LOG_LEVEL=notice \
  -e "KONG_LICENSE_DATA=$KONG_LICENSE_DATA" \
  -v /etc/kong/declarative:/kong/declarative:ro \
  "$KONG_IMAGE"

echo "Waiting for Kong Admin API..."
for _ in $(seq 1 60); do
  if curl -sf http://127.0.0.1:8001/status >/dev/null; then
    curl -sf http://127.0.0.1:8001/status
    echo
    exit 0
  fi
  sleep 5
done

echo "Kong Admin API did not become ready" >&2
sudo docker logs kong --tail=100 || true
exit 1
