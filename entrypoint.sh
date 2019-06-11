#!/bin/sh -ex

# client or server
CS=${CS:-"S"}
# wireguard interface name
WG_INF=${WG_INF:-"wg0"}

WG_CONF_FILE=/etc/wireguard/$WG_INF.conf

if [[ $CS != "C" && $CS != "S" ]]; then
    echo "$(date): invalid parameter C/S"
    exit 1
fi

get_ip() {
    local name=$1
    local c=0
    local cnt=5
    local ip=""
    while [[ $c -lt $cnt ]]; do
        ip=$(getent hosts $name | awk '{print $1}')
        if [[ "$ip" ]]; then
            break
        fi
        sleep 1
        c=$((c+1))
    done
    echo "$ip"
}

add_rules() {
    echo "Adding rules"
    if [[ $CS == "S" ]]; then
        iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    else
        endpoint=$(grep Endpoint $WG_CONF_FILE | cut -d'=' -f2 | cut -d: -f1)
        ip=$(get_ip $endpoint)
        if [[ -z $ip ]]; then
            continue
        fi
        default_gw=$(ip ro get 8.8.8.8|awk '{print $3}')
        ip route add $ip via $default_gw
        ip route change default dev $WG_INF
        iptables -t nat -A POSTROUTING -o $WG_INF -j MASQUERADE
    fi
}

finish() {
    echo "stopping"
    exit 0
}

wg-quick up $WG_INF
add_rules

trap finish SIGINT SIGTERM SIGQUIT

set +x
while sleep 1; do :; done
