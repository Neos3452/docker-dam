#!/bin/bash
set -e

function close() {
    iptables -N DOCKER-DAM
    iptables -A DOCKER-DAM -s 172.17.0.0/16 -j RETURN
    iptables -A DOCKER-DAM -j REJECT
    iptables -I DOCKER-USER 1 -j DOCKER-DAM
    echo "All ports closed"
}

function open() {
    iptables -F DOCKER-DAM
    iptables -D DOCKER-USER -j DOCKER-DAM
    iptables -X DOCKER-DAM
    echo "All ports open"
}

function version() {
    echo "Version 0.0.1 - Docker Dam"
}

function help() {
    echo "Usage:"
    echo "docker-dam.sh command options"
    echo ""
    echo "Available commands:"
    echo "--close: disable port blocking"
    echo "--open: enable port blocking"
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

for cmd in close open help version; do
    if [ "-${cmd:0:1}" == "$1" -o "--${cmd}" == "$1" ]; then
        shift 1
        ${cmd} "$@"
        exit
    fi
done
echo "Unknown command \"$1\""; help "$@"
exit 1

