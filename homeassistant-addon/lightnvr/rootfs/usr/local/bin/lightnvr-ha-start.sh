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

if [ -x /bin/start.sh ]; then
    exec /bin/start.sh
fi

GO2RTC_BIN=""
if [ -x /bin/go2rtc ]; then
    GO2RTC_BIN="/bin/go2rtc"
elif command -v go2rtc >/dev/null 2>&1; then
    GO2RTC_BIN="$(command -v go2rtc)"
fi

LIGHTNVR_BIN=""
if [ -x /bin/lightnvr ]; then
    LIGHTNVR_BIN="/bin/lightnvr"
elif command -v lightnvr >/dev/null 2>&1; then
    LIGHTNVR_BIN="$(command -v lightnvr)"
fi

if [ -n "${GO2RTC_BIN}" ]; then
    "${GO2RTC_BIN}" --config /etc/lightnvr/go2rtc/go2rtc.yaml &
    GO2RTC_PID=$!
else
    GO2RTC_PID=""
fi

cleanup() {
    if [ -n "${GO2RTC_PID}" ]; then
        kill "${GO2RTC_PID}" 2>/dev/null || true
        wait "${GO2RTC_PID}" 2>/dev/null || true
    fi
}
trap cleanup EXIT INT TERM

sleep 2

if [ -z "${LIGHTNVR_BIN}" ]; then
    echo "lightnvr binary not found in image (expected /bin/lightnvr or PATH)"
    exit 127
fi

exec "${LIGHTNVR_BIN}" -c /etc/lightnvr/lightnvr.ini
