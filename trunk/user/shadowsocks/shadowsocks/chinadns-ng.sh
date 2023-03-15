#!/bin/sh
# Compile:by-lanse	2023-03-06

modprobe xt_set
modprobe ip_set_hash_ip
modprobe ip_set_hash_net

STORAGE="/etc/storage"
SSR_HOME="$STORAGE/shadowsocks"
DNSMASQ_RURE="$STORAGE/dnsmasq/dnsmasq.conf"
STORAGE_V2SH="$STORAGE/storage_v2ray.sh"
ss_tunnel_local_port=$(nvram get ss-tunnel_local_port)

func_del_rule(){
    if [ -n "$(pidof chinadns-ng)" ] ; then
        killall chinadns-ng >/dev/null 2>&1
        kill -9 "$(pidof chinadns-ng)" >/dev/null 2>&1
    fi
    if grep -q "no-resolv" "$DNSMASQ_RURE"
    then
        sed -i '/no-resolv/d; /server=127.0.0.1/d' $DNSMASQ_RURE
    fi
}

func_del_ipt(){
    if [ $(nvram get ss_enable) = "0" ]
    then
        flush_iptables(){
            ipt="iptables -t $1"
            DAT=$(iptables-save -t $1)
            eval $(echo "$DAT" | grep "SS_SPEC_" | sed -e 's/^-A/$ipt -D/' -e 's/$/;/')
            for chain in $(echo "$DAT" | awk '/^:chain/{print $1}'); do
                $ipt -F ${chain:1} 2>/dev/null && $ipt -X ${chain:1}
            done
        }
        sleep 2 && flush_iptables
    fi
    ipt="iptables -t nat"
    $ipt -D SS_SPEC_WAN_AC -d $v2_address -j RETURN
    $ipt -D SS_SPEC_WAN_AC -m set --match-set gmlan dst -j RETURN
    $ipt -D SS_SPEC_WAN_AC -m set --match-set china dst -j RETURN
    $ipt -D SS_SPEC_WAN_FW -m set --match-set china dst -j RETURN
    $ipt -D SS_SPEC_WAN_FW -p udp -d 127.0.0.1 --dport 53 -j REDIRECT --to-ports 65353
    $ipt -D SS_SPEC_WAN_FW -p tcp -j SS_SPEC_WAN_AC
    $ipt -D SS_SPEC_WAN_AC -p tcp -j REDIRECT --to-ports 12345
    iptables-save -c | grep -v gmlan | iptables-restore -c
    for setname in $(ipset -n list | grep "gmlan"); do
        ipset destroy "$setname" 2>/dev/null
    done
    $ipt -D PREROUTING -j SS_SPEC_WAN_FW
    $ipt -D OUTPUT -j SS_SPEC_WAN_AC
}

func_conf(){
    /usr/bin/chinadns-ng -b 0.0.0.0 -l 65353 -c 119.29.29.29#53 -t 127.0.0.1#$ss_tunnel_local_port -4 china >/dev/null 2>&1 &
    #/usr/bin/chinadns-ng -c 119.29.29.29#53 -t 127.0.0.1#$ss_tunnel_local_port -4 chnroute >/dev/null 2>&1 &
    sleep 2
    if grep -q "no-resolv" "$DNSMASQ_RURE"
    then
        sed -i '/no-resolv/d; /server=127.0.0.1/d' $DNSMASQ_RURE
    fi
    cat >> $DNSMASQ_RURE << EOF
no-resolv
server=127.0.0.1#65353
EOF
    sleep 2
}

func_gmlan(){
ipset -! restore <<-EOF
create gmlan hash:net hashsize 64
$(gen_lan_ip | sed -e "s/^/add gmlan /")
EOF
}

gen_lan_ip(){
cat <<-EOF | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}"
0.0.0.0/8
10.0.0.0/8
127.0.0.0/8
169.254.0.0/16
172.16.0.0/12
192.0.2.0/24
192.168.0.0/16
224.0.0.0/4
240.0.0.0/4
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

$ipt -N SS_SPEC_WAN_FW
$ipt -N SS_SPEC_WAN_AC

$ipt -A PREROUTING -j SS_SPEC_WAN_FW
$ipt -A OUTPUT -j SS_SPEC_WAN_AC
$ipt -A SS_SPEC_WAN_AC -d $v2_address -j RETURN
$ipt -A SS_SPEC_WAN_AC -m set --match-set gmlan dst -j RETURN
$ipt -A SS_SPEC_WAN_AC -m set --match-set china dst -j RETURN
$ipt -A SS_SPEC_WAN_FW -m set --match-set china dst -j RETURN
$ipt -A SS_SPEC_WAN_FW -p udp -d 127.0.0.1 --dport 53 -j REDIRECT --to-ports 65353

$ipt -A SS_SPEC_WAN_FW -p tcp -j SS_SPEC_WAN_AC
$ipt -A SS_SPEC_WAN_AC -p tcp -j REDIRECT --to-ports 12345

cat <<-CAT >>$FWI
iptables-save -c | grep -v SS_SPEC_ | iptables-restore -c
iptables-restore -n <<-EOF
$(iptables-save | grep -E "SS_SPEC|^\*|^COMMIT" |\
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

