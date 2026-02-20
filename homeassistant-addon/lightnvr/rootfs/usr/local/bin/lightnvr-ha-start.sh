#!/bin/sh
set -e

PATCH_MARKER="/data/.lightnvr-ha-ports-patched-v1"
INI_FILE="/etc/lightnvr/lightnvr.ini"
GO2RTC_FILE="/etc/lightnvr/go2rtc/go2rtc.yaml"

# Apply one-time default port migration to avoid UniFi collisions on host network.
if [ ! -f "${PATCH_MARKER}" ]; then
    if [ -f "${INI_FILE}" ]; then
        sed -i '/^\[web\]/,/^\[/ s/^port = 8080$/port = 18080/' "${INI_FILE}" || true
        sed -i '/^\[go2rtc\]/,/^\[/ s/^api_port = 1984$/api_port = 11984/' "${INI_FILE}" || true
    fi

    if [ -f "${GO2RTC_FILE}" ]; then
        sed -i 's/:1984/:11984/g' "${GO2RTC_FILE}" || true
        sed -i 's/:8554/:18554/g' "${GO2RTC_FILE}" || true
        sed -i 's/:8555/:18555/g' "${GO2RTC_FILE}" || true
    fi

    touch "${PATCH_MARKER}" || true
fi

exec /bin/start.sh
