FROM odoo:18

USER root

# Copy configuration and requirements into the image, then create a virtualenv
# and install Python dependencies at build time to avoid runtime pip calls
COPY etc /etc/odoo
RUN python3 -m venv /opt/venv \
	&& /opt/venv/bin/pip install --upgrade pip setuptools wheel \
	&& if [ -f /etc/odoo/requirements.txt ]; then /opt/venv/bin/pip install -r /etc/odoo/requirements.txt; fi

# Make the venv binaries first on PATH so Odoo runs with that environment
ENV PATH="/opt/venv/bin:$PATH"

# copy our custom entrypoint into the image so Portainer won't need to mount a single file
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# keep default CMD of the base image (odoo)
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
