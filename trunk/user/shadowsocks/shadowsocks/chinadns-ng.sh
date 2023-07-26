#!/bin/sh
# Compile:by-lanse	2023-07-24

modprobe xt_set
modprobe ip_set_hash_ip
modprobe ip_set_hash_net

STORAGE="/etc/storage"
SSR_HOME="$STORAGE/shadowsocks"
DNSMASQ_RURE="$STORAGE/dnsmasq/dnsmasq.conf"
STORAGE_V2SH="$STORAGE/storage_v2ray.sh"
ss_tunnel_local_port=$(nvram get ss-tunnel_local_port)
ss_local_port=$(nvram get ss_local_port)
wan_dns=$(nvram get wan_dns1_x)
local_chnlist_file=/tmp/chnlist.txt
cdn_url=https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/direct-list.txt
local_gfwlist_file=/tmp/gfw.txt
gfw_url=https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/gfw.txt


func_del_rule(){
    if [ -n "$(pidof chinadns-ng)" ] ; then
        killall chinadns-ng >/dev/null 2>&1
        kill -9 "$(pidof chinadns-ng)" >/dev/null 2>&1
    fi
    if grep -q "65353" "$DNSMASQ_RURE"
    then
        sed -i '/no-resolv/d; /server=127.0.0.1/d; /min-cache-ttl/d' $DNSMASQ_RURE
        restart_dhcpd
    fi
}

func_del_ipt(){
    if [ $(nvram get ss_enable) = "0" ]
    then
        flush_iptables(){
            ipt="iptables -t $1"
            DAT=$(iptables-save -t $1)
            eval $(echo "$DAT" | grep "CNNG" | sed -e 's/^-A/$ipt -D/' -e 's/$/;/')
            for chain in $(echo "$DAT" | awk '/^:CNNG/{print $1}'); do
                $ipt -F ${chain:1} 2>/dev/null && $ipt -X ${chain:1}
            done
        }
        sleep 2 && flush_iptables net
    fi
    ipt="iptables -t nat"
    $ipt -D CNNG_PRE -d $v2_address -p tcp -m tcp ! --dport 53 -j RETURN
    $ipt -D CNNG_PRE -m set --match-set gateway dst -j RETURN
    $ipt -D CNNG_PRE -m set --match-set chnroute dst -j RETURN
    $ipt -D CNNG_OUT -m set --match-set chnroute dst -j RETURN
    $ipt -D CNNG_OUT -p udp -d 127.0.0.1 --dport 53 -j REDIRECT --to-ports 65353
    $ipt -D CNNG_OUT -p tcp -j CNNG_PRE
    $ipt -D CNNG_PRE -p tcp -j REDIRECT --to-ports 12345
    $ipt -D CNNG_OUT -d 0.0.0.0/8 -j RETURN
    $ipt -D CNNG_OUT -d 10.0.0.0/8 -j RETURN
    $ipt -D CNNG_OUT -d 100.64.0.0/10 -j RETURN
    $ipt -D CNNG_OUT -d 127.0.0.0/8 -j RETURN
    $ipt -D CNNG_OUT -d 169.254.0.0/16 -j RETURN
    $ipt -D CNNG_OUT -d 172.16.0.0/12 -j RETURN
    $ipt -D CNNG_OUT -d 192.0.0.0/24 -j RETURN
    $ipt -D CNNG_OUT -d 192.0.2.0/24 -j RETURN
    $ipt -D CNNG_OUT -d 192.88.99.0/24 -j RETURN
    $ipt -D CNNG_OUT -d 192.168.0.0/16 -j RETURN
    $ipt -D CNNG_OUT -d 198.18.0.0/15 -j RETURN
    $ipt -D CNNG_OUT -d 198.51.100.0/24 -j RETURN
    $ipt -D CNNG_OUT -d 169.254.0.0/16 -j RETURN
    $ipt -D CNNG_OUT -d 203.0.113.0/24 -j RETURN
    $ipt -D CNNG_OUT -d 224.0.0.0/4 -j RETURN
    $ipt -D CNNG_OUT -d 240.0.0.0/4 -j RETURN
    $ipt -D CNNG_OUT -d 255.255.255.255/32 -j RETURN
    #$ipt -D CNNG_PRE -m set --match-set gfwlist dst -j CNNG_OUT
    #$ipt -D CNNG_PRE -j CNNG_OUT
    $ipt -D CNNG_OUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports $ss_local_port

    iptables-save -c | grep -v gateway | iptables-restore -c
    for setname in $(ipset -n list | grep "gateway"); do
        ipset destroy "$setname" 2>/dev/null
    done
    $ipt -D PREROUTING -j CNNG_OUT
    $ipt -D OUTPUT -j CNNG_PRE
}

cdn_file_d(){
    if [ ! -f "$local_chnlist_file" ]
    then
        curl -k -s -o $local_chnlist_file --connect-timeout 10 --retry 3 $cdn_url && \
        #wget -t 5 -T 10 -c --no-check-certificate -O- $cdn_url > $local_chnlist_file && \
        chmod 644 "$local_chnlist_file"
    fi
}

gfw_file_d(){
    if [ ! -f "$local_gfwlist_file" ]
    then
        curl -k -s -o $local_gfwlist_file --connect-timeout 10 --retry 3 $gfw_url && \
        chmod 644 "$local_gfwlist_file"
    fi
}

ipset_init() {
    ipset -! restore <<-EOF || return 1
        create gfwlist hash:net hashsize 64
        $(gen_wa_fw_ip | sed -e "s/^/add gfwlist /")
EOF
    return 0
}

gen_wa_fw_ip() {
    cat <<-EOF | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}"
	216.58.200.238
	217.160.0.201
	172.217.160.78
	172.217.24.3
	172.217.160.110
	104.244.42.129
	104.18.9.230
	104.18.27.103
	67.228.126.62
	176.9.146.200
	46.4.7.165
	195.201.59.244
	136.243.22.80
	78.46.27.186
	85.10.210.166
	91.108.12.0/22
	91.108.4.0/22
	91.108.8.0/22
	91.108.16.0/22
	91.108.20.0/22
	91.108.36.0/23
	91.108.38.0/23
	91.108.56.0/22
	149.154.160.0/20
	149.154.164.0/22
	204.246.176.0/20
	149.154.172.0/22
EOF
}

gfw_dns(){
    dns2_ip=$(nvram get ss-tunnel_remote | awk -F '[:/]' '{print $1}')
    ipset add gfwlist $dns2_ip 2>/dev/null
}

func_conf(){
    cdn_file_d && sleep 3
    if grep -q "min-cache-ttl" "$DNSMASQ_RURE"
    then
        echo ''
    else
        cat >> $DNSMASQ_RURE << EOF
min-cache-ttl=1800
EOF
    fi
    #ipset_init && \
    #gfw_dns && \
    gfw_file_d && sleep 3
    if [ -f "$local_chnlist_file" ]
    then
        if [ -f "$local_gfwlist_file" ]
        then
            /usr/bin/chinadns-ng -b 0.0.0.0 -l 65353 -c $wan_dns#53 -t 127.0.0.1#$ss_tunnel_local_port -4 chnroute -M -m $local_chnlist_file -g $local_gfwlist_file >/dev/null 2>&1 &
	else
            /usr/bin/chinadns-ng -b 0.0.0.0 -l 65353 -c $wan_dns#53 -t 127.0.0.1#$ss_tunnel_local_port -4 chnroute -M -m $local_chnlist_file >/dev/null 2>&1 &
	fi
    else
        /usr/bin/chinadns-ng -b 0.0.0.0 -l 65353 -c $wan_dns#53 -t 127.0.0.1#$ss_tunnel_local_port -4 chnroute >/dev/null 2>&1 &
    fi
    if [ $(nvram get sdns_enable) = "1" ]; then
        if grep -q "no-resolv" "$DNSMASQ_RURE"
        then
            echo ''
        else
            cat >> $DNSMASQ_RURE << EOF
no-resolv
server=127.0.0.1#65353
EOF
        restart_dhcpd
        fi
    else
        if grep -q "65353" "$DNSMASQ_RURE"
        then
            sed -i '/no-resolv/d; /server=127.0.0.1/d' $DNSMASQ_RURE
        fi
        cat >> $DNSMASQ_RURE << EOF
no-resolv
server=127.0.0.1#65353
EOF
    restart_dhcpd
    fi
}

func_gmlan(){
    ipset -! restore <<-EOF
        create gateway hash:net hashsize 64
        $(gen_lan_ip | sed -e "s/^/add gateway /")
EOF
}

gen_lan_ip(){
    cat <<-EOF | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}"
        0.0.0.0/8
        10.0.0.0/8
        100.64.0.0/10
        127.0.0.0/8
        169.254.0.0/16
        172.16.0.0/12
        192.0.0.0/24
        192.0.2.0/24
        192.88.99.0/24
        192.168.0.0/16
        198.18.0.0/15
        198.51.100.0/24
        203.0.113.0/24
        224.0.0.0/4
        240.0.0.0/4
        255.255.255.255/32
EOF
}

flush_ipt_file(){
    FWI="/tmp/shadowsocks_iptables.save"
    [ -n "$FWI" ] && echo '# firewall include file' >$FWI && \
    chmod +x $FWI
    return 0
}

func_ipt_n(){
    if grep -q "vmess" "$STORAGE_V2SH"
    then
        V2RUL=/tmp/V2mi.txt
        v2_address=$(sed -n "2p" $V2RUL | cut -f 2 -d ":")
    else
        v2_address=$(cat $STORAGE_V2SH | grep "address" | awk -F '[:/]' '{print $2}')
    fi
    sleep 2
    ipt="iptables -t nat"

    $ipt -N CNNG_OUT
    $ipt -N CNNG_PRE

    $ipt -A PREROUTING -j CNNG_OUT
    $ipt -A OUTPUT -j CNNG_PRE
    $ipt -A CNNG_PRE -d $v2_address -p tcp -m tcp ! --dport 53 -j RETURN
    $ipt -A CNNG_PRE -m set --match-set gateway dst -j RETURN
    #$ipt -A CNNG_PRE -m set --match-set chnroute dst -j RETURN
    $ipt -A CNNG_OUT -m set --match-set chnroute dst -j RETURN
    $ipt -A CNNG_OUT -p udp -d 127.0.0.1 --dport 53 -j REDIRECT --to-ports 65353

    $ipt -A CNNG_OUT -p tcp -j CNNG_PRE
    $ipt -A CNNG_PRE -p tcp -j REDIRECT --to-ports 12345

    $ipt -A CNNG_OUT -d 0.0.0.0/8 -j RETURN
    $ipt -A CNNG_OUT -d 10.0.0.0/8 -j RETURN
    $ipt -A CNNG_OUT -d 100.64.0.0/10 -j RETURN
    $ipt -A CNNG_OUT -d 127.0.0.0/8 -j RETURN
    $ipt -A CNNG_OUT -d 169.254.0.0/16 -j RETURN
    $ipt -A CNNG_OUT -d 172.16.0.0/12 -j RETURN
    $ipt -A CNNG_OUT -d 192.0.0.0/24 -j RETURN
    $ipt -A CNNG_OUT -d 192.0.2.0/24 -j RETURN
    $ipt -A CNNG_OUT -d 192.88.99.0/24 -j RETURN
    $ipt -A CNNG_OUT -d 192.168.0.0/16 -j RETURN
    $ipt -A CNNG_OUT -d 198.18.0.0/15 -j RETURN
    $ipt -A CNNG_OUT -d 198.51.100.0/24 -j RETURN
    $ipt -A CNNG_OUT -d 169.254.0.0/16 -j RETURN
    $ipt -A CNNG_OUT -d 203.0.113.0/24 -j RETURN
    $ipt -A CNNG_OUT -d 224.0.0.0/4 -j RETURN
    $ipt -A CNNG_OUT -d 240.0.0.0/4 -j RETURN
    $ipt -A CNNG_OUT -d 255.255.255.255/32 -j RETURN
    #$ipt -A CNNG_PRE -j CNNG_OUT
    #$ipt -A CNNG_PRE -m set --match-set gfwlist dst -j CNNG_OUT
    $ipt -A CNNG_OUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports $ss_local_port

    cat <<-CAT >>$FWI
    iptables-save -c | grep -v CNNG_ | iptables-restore -c
    iptables-restore -n <<-EOF
        $(iptables-save | grep -E "CNNG_|^\*|^COMMIT" |\
        sed -e "s/^-A \(OUTPUT\|PREROUTING\)/-I \1 1/")
EOF
    CAT
    return 0
}

func_start(){
    func_del_rule && \
    echo -e "\033[41;37m 部署 [CHINADNS-NG] 文件,请稍后...\e[0m\n"
    func_del_ipt
    func_gmlan && flush_ipt_file && func_ipt_n
    wait
    echo "dns"
    func_conf
    logger -t "[CHINADNS-NG]" "开始运行…"
}

func_stop(){
    func_del_rule && \
    func_del_ipt && \
    logger -t "[CHINADNS-NG]" "已停止运行 !"
    [ -f $local_chnlist_file ] && rm -rf $local_chnlist_file
    if [ $(nvram get ss_mode) = "3" ]
    then
        echo "V2RAY Not closed "
    fi
}

case "$1" in
start)
    func_start
    ;;
stop)
    func_stop
    ;;
*)
    echo "Usage: $0 { start | stop }"
    exit 1
    ;;
esac

