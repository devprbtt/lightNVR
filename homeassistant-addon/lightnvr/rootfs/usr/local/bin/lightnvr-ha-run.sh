#!/bin/sh
set -e

PERSIST_ROOT="/data"
PERSIST_CONFIG_DIR="${PERSIST_ROOT}/lightnvr-config"
PERSIST_DATA_DIR="${PERSIST_ROOT}/lightnvr-data"

mkdir -p "${PERSIST_CONFIG_DIR}" "${PERSIST_DATA_DIR}" "${PERSIST_DATA_DIR}/recordings" "${PERSIST_DATA_DIR}/database" "${PERSIST_DATA_DIR}/models"

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

# Use the upstream init and startup flow.
exec /usr/local/bin/docker-entrypoint.sh "$@"
