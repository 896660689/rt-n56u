#!/bin/sh
# Compile:by-lanse	2023-07-26

forwarding_port=12345
wan_dns=$(nvram get wan_dns1_x)
dns2_ip=$(nvram get ss-tunnel_remote | awk -F '[:/]' '{print $1}')

start_iptables() {
    ##################### CNNG_OUT #####################
    iptables -t mangle -N CNNG_OUT

    # connection-mark -> packet-mark
    iptables -t mangle -A CNNG_OUT -j CONNMARK --restore-mark

    # please modify MyIP, MyPort, etc.
    # ignore traffic sent to ss-server
    iptables -t mangle -A CNNG_OUT -p tcp -d MyIP --dport MyPort -j RETURN
    iptables -t mangle -A CNNG_OUT -p udp -d MyIP --dport MyPort -j RETURN

    # ignore traffic sent to reserved addresses
    iptables -t mangle -A CNNG_OUT -d 0.0.0.0/8          -j RETURN
    iptables -t mangle -A CNNG_OUT -d 10.0.0.0/8         -j RETURN
    iptables -t mangle -A CNNG_OUT -d 100.64.0.0/10      -j RETURN
    iptables -t mangle -A CNNG_OUT -d 127.0.0.0/8        -j RETURN
    iptables -t mangle -A CNNG_OUT -d 169.254.0.0/16     -j RETURN
    iptables -t mangle -A CNNG_OUT -d 172.16.0.0/12      -j RETURN
    iptables -t mangle -A CNNG_OUT -d 192.0.0.0/24       -j RETURN
    iptables -t mangle -A CNNG_OUT -d 192.0.2.0/24       -j RETURN
    iptables -t mangle -A CNNG_OUT -d 192.88.99.0/24     -j RETURN
    iptables -t mangle -A CNNG_OUT -d 192.168.0.0/16     -j RETURN
    iptables -t mangle -A CNNG_OUT -d 198.18.0.0/15      -j RETURN
    iptables -t mangle -A CNNG_OUT -d 198.51.100.0/24    -j RETURN
    iptables -t mangle -A CNNG_OUT -d 203.0.113.0/24     -j RETURN
    iptables -t mangle -A CNNG_OUT -d 224.0.0.0/4        -j RETURN
    iptables -t mangle -A CNNG_OUT -d 240.0.0.0/4        -j RETURN
    iptables -t mangle -A CNNG_OUT -d 255.255.255.255/32 -j RETURN

    # mark the first packet of the connection
    iptables -t mangle -A CNNG_OUT -p tcp --syn                      -j MARK --set-mark 0x2333
    iptables -t mangle -A CNNG_OUT -p udp -m conntrack --ctstate NEW -j MARK --set-mark 0x2333
	iptables -t mangle -A OUTPUT -j RETURN -m mark --mark 0xff &>/dev/null

    # packet-mark -> connection-mark
    iptables -t mangle -A CNNG_OUT -j CONNMARK --save-mark

    ##################### OUTPUT #####################
    # proxy the outgoing traffic from this machine
    iptables -t mangle -A OUTPUT -p tcp -m addrtype --src-type LOCAL ! --dst-type LOCAL -j CNNG_OUT
    iptables -t mangle -A OUTPUT -p udp -m addrtype --src-type LOCAL ! --dst-type LOCAL -j CNNG_OUT

    ##################### PREROUTING #####################
    # proxy traffic passing through this machine (other->other)
    iptables -t mangle -A PREROUTING -p tcp -m addrtype ! --src-type LOCAL ! --dst-type LOCAL -j CNNG_OUT
    iptables -t mangle -A PREROUTING -p udp -m addrtype ! --src-type LOCAL ! --dst-type LOCAL -j CNNG_OUT

    # hand over the marked package to TPROXY for processing
    iptables -t mangle -A PREROUTING -p tcp -m mark --mark 0x2333 -j TPROXY --on-ip 127.0.0.1 --on-port "$forwarding_port"
    iptables -t mangle -A PREROUTING -p udp -m mark --mark 0x2333 -j TPROXY --on-ip 127.0.0.1 --on-port "$forwarding_port"
}

stop_iptables() {
    ##################### PREROUTING #####################
    iptables -t mangle -D PREROUTING -p tcp -m mark --mark 0x2333 -j TPROXY --on-ip 127.0.0.1 --on-port "$forwarding_port" &>/dev/null
    iptables -t mangle -D PREROUTING -p udp -m mark --mark 0x2333 -j TPROXY --on-ip 127.0.0.1 --on-port "$forwarding_port" &>/dev/null

    iptables -t mangle -D PREROUTING -p tcp -m addrtype ! --src-type LOCAL ! --dst-type LOCAL -j CNNG_OUT &>/dev/null
    iptables -t mangle -D PREROUTING -p udp -m addrtype ! --src-type LOCAL ! --dst-type LOCAL -j CNNG_OUT &>/dev/null

    ##################### OUTPUT #####################
    iptables -t mangle -D OUTPUT -p tcp -m addrtype --src-type LOCAL ! --dst-type LOCAL -j CNNG_OUT &>/dev/null
    iptables -t mangle -D OUTPUT -p udp -m addrtype --src-type LOCAL ! --dst-type LOCAL -j CNNG_OUT &>/dev/null

    ##################### CNNG_OUT #####################
    iptables -t mangle -F CNNG_OUT &>/dev/null
    iptables -t mangle -X CNNG_OUT &>/dev/null
}

start_iproute2() {
    ip route add local default dev lo table 100
    ip rule  add fwmark 0x2333        table 100
}

stop_iproute2() {
    ip rule  del   table 100 &>/dev/null
    ip route flush table 100 &>/dev/null
}

start_resolvconf() {
    # or nameserver 8.8.8.8, etc.
    echo "nameserver $dns2_ip" >/etc/resolv.conf
}

stop_resolvconf() {
    echo "nameserver $wan_dns" >/etc/resolv.conf
}

start() {
    echo "start ..."
    #start_CNNG_OUT
    start_iptables
    start_iproute2
    #start_resolvconf
    echo "start end"
}

stop() {
    echo "stop ..."
    #stop_resolvconf
    stop_iproute2
    stop_iptables
    #stop_CNNG_OUT
    echo "stop end"
}

 case "$1" in
start)
    start
    ;;
stop)
    stop
    ;;
*)
    echo "Usage: $0 { start | stop }"
    exit 1
    ;;
esac

