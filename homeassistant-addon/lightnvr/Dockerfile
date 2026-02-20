FROM ghcr.io/opensensor/lightnvr:latest

COPY rootfs/ /
RUN chmod +x /usr/local/bin/lightnvr-ha-run.sh
RUN chmod +x /usr/local/bin/lightnvr-ha-start.sh

ENTRYPOINT ["/usr/local/bin/lightnvr-ha-run.sh"]
CMD ["/usr/local/bin/lightnvr-ha-start.sh"]
