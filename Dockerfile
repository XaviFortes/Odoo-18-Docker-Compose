FROM odoo:18

USER root

# copy our custom entrypoint into the image so Portainer won't need to mount a single file
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# keep default CMD of the base image (odoo)
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
