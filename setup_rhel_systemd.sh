#!/bin/bash

SYSTEMD_FILE_NAME="glances.service"
SYSTEMD_DIRECTORY="/etc/systemd/system"
GLANCES_LOCATION=/bin/glances

cat <<EOF > $SYSTEMD_DIRECTORY/$SYSTEMD_FILE_NAME
[Unit]
Description=Glances

[Service]
ExecStart=$GLANCES_LOCATION --quiet --export-http
Restart=on-failure
RestartSec=30s
TimeoutSec=30s

[Install]
WantedBy=multi-user.target
EOF

#install and start the daemon!
systemctl enable glances.service
systemctl start glances.service &
