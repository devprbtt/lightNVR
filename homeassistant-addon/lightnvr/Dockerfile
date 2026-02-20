ARG BUILD_FROM=ghcr.io/opensensor/lightnvr:latest
FROM ${BUILD_FROM}

COPY rootfs/ /
RUN chmod +x /usr/local/bin/lightnvr-ha-run.sh

ENTRYPOINT ["/usr/local/bin/lightnvr-ha-run.sh"]
CMD ["/bin/start.sh"]
