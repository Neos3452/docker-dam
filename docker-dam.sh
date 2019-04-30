#!/bin/bash
set -e

SYSTEMD_SCRIPT=$(cat << EOF
[Unit]
Description=Docker Dam - firewall manager for docker
Requisite=docker.service
After=docker.service

[Install]
RequiredBy=docker.service

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/usr/bin/damdocker --close
ExecStop=/usr/bin/damdocker --open

EOF
)
SYSTEMD_PATH="/lib/systemd/system/damdocker.service"

function install() {
    echo "${SYSTEMD_SCRIPT}" > "${SYSTEMD_PATH}"
    systemctl enable damdocker
    systemctl start damdocker
}

function uninstall() {
    systemctl disable damdocker
    systemctl stop damdocker
    rm "${SYSTEMD_PATH}"
}

function close() {
    iptables -N DOCKER-DAM
    iptables -A DOCKER-DAM -s 172.17.0.0/16 -j RETURN
    iptables -A DOCKER-DAM -j REJECT
    iptables -I DOCKER-USER 1 -j DOCKER-DAM
    echo "All ports closed"
}

function open() {
    if ! iptables -L DOCKER-USER > /dev/null; then
        echo "There is no docker chain in iptables. Is docker daemon running?"
        exit 2
    fi
    iptables -F DOCKER-DAM
    iptables -D DOCKER-USER -j DOCKER-DAM
    iptables -X DOCKER-DAM
    echo "All ports open"
}

function version() {
    echo "Version 0.0.2 - Docker Dam"
}

function help() {
    echo "Usage:"
    echo "damdocker command options"
    echo ""
    echo "Available commands:"
    echo "--close: enable port blocking"
    echo "--open: disable port blocking"
    echo "--install: install as systemd service"
    echo "--uninstall: remove systemd service"
    echo "--version: show current version"
    echo "--help: show this message"
}

# Check for iptables permissions
IPTABLES_OUTPUT=$(iptables -L)
IPTABLES_RETURN=$?
if [ ${IPTABLES_RETURN} -ne 0 ]; then
    echo "${IPTABLES_OUTPUT}"
    exit ${IPTABLES_RETURN}
fi

for cmd in close open install uninstall help version; do
    if [ "-${cmd:0:1}" == "$1" -o "--${cmd}" == "$1" ]; then
        shift 1
        ${cmd} "$@"
        exit
    fi
done
echo "Unknown command \"$1\""; help "$@"
exit 1

