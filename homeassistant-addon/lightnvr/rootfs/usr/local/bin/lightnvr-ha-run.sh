#!/bin/sh
set -e

PERSIST_ROOT="/data"
PERSIST_CONFIG_DIR="${PERSIST_ROOT}/lightnvr-config"
PERSIST_DATA_DIR="${PERSIST_ROOT}/lightnvr-data"

mkdir -p "${PERSIST_CONFIG_DIR}" "${PERSIST_DATA_DIR}" "${PERSIST_DATA_DIR}/recordings" "${PERSIST_DATA_DIR}/database" "${PERSIST_DATA_DIR}/models"
mkdir -p /etc /var/lib/lightnvr
mkdir -p /etc/lightnvr /etc/lightnvr/go2rtc

# Seed persistent config from image defaults only once.
if [ ! -f "${PERSIST_CONFIG_DIR}/lightnvr.ini" ] && [ -f "/etc/lightnvr/lightnvr.ini" ]; then
    cp -a /etc/lightnvr/. "${PERSIST_CONFIG_DIR}/" 2>/dev/null || true
fi

# Keep runtime config in /etc, sourced from persisted /data.
cp -a "${PERSIST_CONFIG_DIR}/." /etc/lightnvr/ 2>/dev/null || true

# Create minimal defaults if upstream image/config seeding did not provide them.
if [ ! -f /etc/lightnvr/lightnvr.ini ]; then
    cat > /etc/lightnvr/lightnvr.ini << 'EOF'
[general]
pid_file = /var/run/lightnvr.pid
log_file = /var/log/lightnvr/lightnvr.log
log_level = 2

[storage]
path = /data/lightnvr-data/recordings
record_mp4_directly = false
mp4_path = /data/lightnvr-data/recordings/mp4

[database]
path = /data/lightnvr-data/database/lightnvr.db

[web]
port = 18080
root = /var/lib/lightnvr/www
auth_enabled = true
username = admin
password = admin
web_thread_pool_size = 8

[models]
path = /data/lightnvr-data/models

[go2rtc]
binary_path = /bin/go2rtc
config_dir = /data/lightnvr-config/go2rtc
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

mkdir -p "${PERSIST_CONFIG_DIR}/go2rtc" /etc/lightnvr/go2rtc
if [ ! -f "${PERSIST_CONFIG_DIR}/go2rtc/go2rtc.yaml" ]; then
    cat > "${PERSIST_CONFIG_DIR}/go2rtc/go2rtc.yaml" << 'EOF'
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

cp -a "${PERSIST_CONFIG_DIR}/go2rtc/." /etc/lightnvr/go2rtc/ 2>/dev/null || true

# Persist generated defaults back to /data.
cp -a /etc/lightnvr/. "${PERSIST_CONFIG_DIR}/" 2>/dev/null || true

# Prefer upstream init flow when available; otherwise run command directly.
if [ -x /usr/local/bin/docker-entrypoint.sh ]; then
    exec /usr/local/bin/docker-entrypoint.sh "$@"
fi

exec "$@"
