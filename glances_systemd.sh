#!/bin/bash

cat <<EOF > $SYSTEMD_DIRECTORY/$SYSTEMD_FILE_NAME
[Unit]
Description=Glances

[Service]
ExecStart=TEST=1 $GLANCES_LOCATION --quiet --export-http
Restart=on-failure
RestartSec=30s
TimeoutSec=30s

[Install]
WantedBy=multi-user.target
EOF

#install and start the daemon!
do_with_root systemctl enable glances.service
do_with_root systemctl start glances.service &
