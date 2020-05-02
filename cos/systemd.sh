#!/bin/bash
echo "LogLevel=debug" >> /etc/systemd/system.conf

echo """[Unit]
Description=Logging
After=metadata.service
Requires=metadata.service
[Service]
ExecStart=/usr/bin/docker run fail-log
ExecStop=/usr/bin/docker stop fail-log
Restart=on-failure
RestartSec=5
""" > /etc/systemd/system/logging.service

echo """[Unit]
Description=Metadata
After=network.service
Requires=network.service
StopWhenUnneeded=true
[Service]
ExecStart=/usr/bin/docker run fail-meta
ExecStop=/usr/bin/docker stop fail-meta
Restart=on-failure
RestartSec=5
""" > /etc/systemd/system/metadata.service

echo """[Unit]
Description=Docker Network
StopWhenUnneeded=true
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/echo success-start
ExecStop=/bin/echo success-stop
""" > /etc/systemd/system/network.service

