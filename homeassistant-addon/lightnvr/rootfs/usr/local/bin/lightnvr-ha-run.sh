#!/bin/sh
set -e

PERSIST_ROOT="/data"
PERSIST_CONFIG_DIR="${PERSIST_ROOT}/lightnvr-config"
PERSIST_DATA_DIR="${PERSIST_ROOT}/lightnvr-data"

mkdir -p "${PERSIST_CONFIG_DIR}" "${PERSIST_DATA_DIR}" "${PERSIST_DATA_DIR}/recordings" "${PERSIST_DATA_DIR}/database" "${PERSIST_DATA_DIR}/models"
mkdir -p /etc /var/lib/lightnvr

# Seed persistent config/data from image defaults only once.
if [ ! -f "${PERSIST_CONFIG_DIR}/lightnvr.ini" ] && [ -d "/etc/lightnvr" ]; then
    cp -a /etc/lightnvr/. "${PERSIST_CONFIG_DIR}/" 2>/dev/null || true
fi

if [ -z "$(ls -A "${PERSIST_DATA_DIR}" 2>/dev/null)" ] && [ -d "/var/lib/lightnvr/data" ]; then
    cp -a /var/lib/lightnvr/data/. "${PERSIST_DATA_DIR}/" 2>/dev/null || true
fi

rm -rf /etc/lightnvr
ln -s "${PERSIST_CONFIG_DIR}" /etc/lightnvr

rm -rf /var/lib/lightnvr/data
ln -s "${PERSIST_DATA_DIR}" /var/lib/lightnvr/data

# Create minimal defaults if upstream image/config seeding did not provide them.
if [ ! -f /etc/lightnvr/lightnvr.ini ]; then
    cat > /etc/lightnvr/lightnvr.ini << 'EOF'
[general]
pid_file = /var/run/lightnvr.pid
log_file = /var/log/lightnvr/lightnvr.log
log_level = 2

[storage]
path = /var/lib/lightnvr/data/recordings
record_mp4_directly = false
mp4_path = /var/lib/lightnvr/data/recordings/mp4

[database]
path = /var/lib/lightnvr/data/database/lightnvr.db

[web]
port = 18080
root = /var/lib/lightnvr/www
auth_enabled = true
username = admin
password = admin
web_thread_pool_size = 8

[models]
path = /var/lib/lightnvr/data/models

[go2rtc]
binary_path = /bin/go2rtc
config_dir = /etc/lightnvr/go2rtc
api_port = 11984

[mqtt]
enabled = false
broker_host = localhost
broker_port = 1883
client_id = lightnvr
topic_prefix = lightnvr
tls_enabled = false
keepalive = 60
qos = 1
retain = false
EOF
fi

mkdir -p /etc/lightnvr/go2rtc
if [ ! -f /etc/lightnvr/go2rtc/go2rtc.yaml ]; then
    cat > /etc/lightnvr/go2rtc/go2rtc.yaml << 'EOF'
api:
  listen: :11984
  origin: "*"
  base_path: /go2rtc

rtsp:
  listen: :18554

webrtc:
  listen: :18555
  ice_servers:
    - urls: [stun:stun.l.google.com:19302]
  candidates:
    - "*:18555"
    - stun:stun.l.google.com:19302

log:
  level: info

streams:
EOF
fi

# Prefer upstream init flow when available; otherwise run command directly.
if [ -x /usr/local/bin/docker-entrypoint.sh ]; then
    exec /usr/local/bin/docker-entrypoint.sh "$@"
fi

exec "$@"
