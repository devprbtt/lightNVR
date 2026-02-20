# LightNVR Home Assistant Add-on

This add-on runs LightNVR inside Home Assistant OS as a custom add-on.

## What this add-on does

- Runs `ghcr.io/opensensor/lightnvr:latest`
- Keeps LightNVR config/data persistent under add-on storage (`/data`)
- Uses host networking for camera discovery and streaming ports

## Install

1. Copy this folder to Home Assistant OS local add-ons path as:
   - `/addons/local/lightnvr/`
2. In Home Assistant, go to **Settings -> Add-ons -> Add-on Store**.
3. Click the menu and choose **Check for updates**.
4. Open **Local add-ons**, install **LightNVR**, then start it.

## Access

This add-on defaults to UniFi-safe host ports:

- Web UI: `http://<home-assistant-ip>:18080`
- go2rtc API: `http://<home-assistant-ip>:11984`
- RTSP: `rtsp://<home-assistant-ip>:18554/...`
- WebRTC: `http://<home-assistant-ip>:18555/...`

## Notes

- Main config is persisted at `/data/lightnvr-config/lightnvr.ini` inside the add-on container.
- Recordings/database/models are persisted under `/data/lightnvr-data`.
- Configure MQTT in `lightnvr.ini` to integrate with Home Assistant automations.
- On first boot, default ports are migrated once and then left under your control.
