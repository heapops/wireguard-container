#!/bin/sh -ex

# wireguard interface name
WG_INF=${WG_INF:-"wg0"}

WG_CONF_FILE=/etc/wireguard/$WG_INF.conf

finish() {
    echo "stopping"
    exit 0
}

wg-quick up $WG_INF

trap finish SIGINT SIGTERM SIGQUIT

set +x
while sleep 1; do :; done
