#!/bin/bash
# github:http://github.com/SuzukiHonoka
# Compile:by-lanse	2020-06-25

modprobe xt_set
modprobe ip_set_hash_ip
modprobe ip_set_hash_net

BINARY_NAME="redsocks"
BIN_DIR="/usr/bin"
STORAGE="/etc/storage"
TMP_HOME="/tmp/$BINARY_NAME"
REDSOCKS_FILE="$TMP_HOME/redsocks"
BINARY_PATH="$BIN_DIR/$BINARY_NAME"
REDSOCKS_CONF="$TMP_HOME/$BINARY_NAME.conf"
CHAIN_NAME="REDSOCKS"
dir_chnroute_file="$STORAGE/chinadns/chnroute.txt"
LOCK="/tmp/set_lock"
SET_NAME="china"

SOCKS5_IP=$(nvram get lan_ipaddr)
SOCKS5_PORT=$(nvram get ss_local_port)
REMOTE_IP="127.0.0.1"

ARG1=$1
ARG2=$2
ARG3=$3

func_redsocks(){
    ln -sf $BINARY_PATH $REDSOCKS_FILE
    $REDSOCKS_FILE -c $REDSOCKS_CONF
}

func_save(){
    /sbin/mtd_storage.sh save
}

func_start(){
if [ -n "$(pidof redsocks)" ]
then
func_stop
logger -t $BINARY_NAME "ALREADY RUNNING: KILLED"
fi
if [ ! -f $REDSOCKS_CONF ]
then
if  [ -n "$ARG2" ]
then
if [ -n "$ARG3" ]
then
SOCKS5_IP=$ARG2
SOCKS5_PORT=$ARG3
[ ! -d "$TMP_HOME" ] && mkdir -p "$TMP_HOME"
cat > "$REDSOCKS_CONF" <<EOF
base {
log_debug = off;
log_info = off;
redirector = iptables;
daemon = on;
redsocks_conn_max = 1000;
}

redsocks {
local_ip = 0.0.0.0;
local_port = 12345;
ip = $(nvram get lan_ipaddr);
port = $(nvram get ss_local_port);
type = socks5;
}

//Keep this line
EOF
chmod 644 $REDSOCKS_CONF
logger -t $BINARY_NAME "CONFIG FILE SAVED."
func_redsocks
fi
else
logger -t $BINARY_NAME "CONFIG FILE NOT FOUND"
return 0
fi
else
func_redsocks
logger -t $BINARY_NAME "STARTED."
fi
}

func_china_file(){
if [ ! -f "$dir_chnroute_file" ] || [ ! -s "$dir_chnroute_file" ]
then
    [ ! -d $STORAGE/chinadns ] && mkdir -p "$STORAGE/chinadns"
    tar jxf "/etc_ro/chnroute.bz2" -C "$STORAGE/chinadns"
    chmod 644 "$dir_chnroute_file" && sleep 2
fi
if [ -f "$dir_chnroute_file" ] || [ -s "$dir_chnroute_file" ]
then
    ipset -N china hash:net
    awk '!/^$/&&!/^#/{printf("add china %s'" "'\n",$0)}' $dir_chnroute_file | ipset restore && \
    wait
    echo "load ip rules !"
fi
[ ! -f $LOCK ] && touch $LOCK && logger -t $BINARY_NAME "SET LOCKED"
}

flush_ipt_file(){
    FWI="/tmp/shadowsocks_iptables.save"
    [ -n "$FWI" ] && echo '# firewall include file' >$FWI && \
    chmod +x $FWI
    return 0
}

flush_ipt_rules(){
    ipt="iptables -t nat"
    $ipt -N $CHAIN_NAME

    $ipt -A $CHAIN_NAME -d $REMOTE_IP -j RETURN
    $ipt -A $CHAIN_NAME -d 0.0.0.0/8 -j RETURN
    $ipt -A $CHAIN_NAME -d 10.0.0.0/8 -j RETURN
    $ipt -A $CHAIN_NAME -d 127.0.0.0/8 -j RETURN
    $ipt -A $CHAIN_NAME -d 169.254.0.0/16 -j RETURN
    $ipt -A $CHAIN_NAME -d 172.16.0.0/12 -j RETURN
    $ipt -A $CHAIN_NAME -d 192.168.0.0/16 -j RETURN
    $ipt -A $CHAIN_NAME -d 224.0.0.0/4 -j RETURN
    $ipt -A $CHAIN_NAME -d 240.0.0.0/4 -j RETURN
    $ipt -A $CHAIN_NAME -m set --match-set china dst -j RETURN
    $ipt -A $CHAIN_NAME -p tcp -j REDIRECT --to-ports 12345
    #$ipt -I PREROUTING -p tcp -j $CHAIN_NAME
    #$ipt -I OUTPUT -p tcp -j $CHAIN_NAME

    ipt_m="iptables -t mangle"

    $ipt -N CNNG_OUT
    $ipt -N CNNG_PRE
    $ipt_m -N CNNG_OUT
    $ipt_m -N CNNG_PRE
    $ipt_m -N UDPCHAIN

    $ipt_m -A UDPCHAIN -d 0.0.0.0/8 -j RETURN
    $ipt_m -A UDPCHAIN -d 10.0.0.0/8 -j RETURN
    $ipt_m -A UDPCHAIN -d 127.0.0.0/8 -j RETURN
    $ipt_m -A UDPCHAIN -d 169.254.0.0/16 -j RETURN
    $ipt_m -A UDPCHAIN -d 172.16.0.0/12 -j RETURN
    $ipt_m -A UDPCHAIN -d 192.168.0.0/16 -j RETURN
    $ipt_m -A UDPCHAIN -d 224.0.0.0/4 -j RETURN
    $ipt_m -A UDPCHAIN -d 240.0.0.0/4 -j RETURN

    $ipt_m -A UDPCHAIN -m set --match-set china dst -j RETURN
    $ipt -A CNNG_OUT -p udp -d 127.0.0.1 --dport 53 -j REDIRECT --to-ports 65353
    $ipt -A CNNG_OUT -p tcp -j $CHAIN_NAME
    $ipt_m -A CNNG_OUT -p udp -j UDPCHAIN
    $ipt -I OUTPUT -j CNNG_OUT
    $ipt_m -A OUTPUT -j CNNG_OUT
    $ipt -I PREROUTING -j CNNG_PRE
    $ipt_m -A PREROUTING -j CNNG_PRE

    cat <<-CAT >>$FWI
    iptables-save -c | grep -v $CHAIN_NAME | iptables-restore -c
    iptables-restore -n <<-EOF
    $(iptables-save | grep -E "$CHAIN_NAME|^\*|^COMMIT" |\
        sed -e "s/^-A \(OUTPUT\|PREROUTING\)/-I \1 1/")
    EOF
CAT
    return 0
}

func_del_ipt(){
	iptables-save -c | grep -v CNNG_OUT | iptables-restore -c
	iptables-save -c | grep -v CNNG_PRE | iptables-restore -c
	iptables-save -c | grep -v UDPCHAIN | iptables-restore -c
}

func_cnng_ipt(){
if [ "$ss_router_proxy" = "5" ] ; then
    ipt="iptables -t nat"
    ipt_m="iptables -t mangle"
    func_del_ipt
    $ipt -D PREROUTING -p tcp -j $CHAIN_NAME
    $ipt -D OUTPUT -p tcp -j $CHAIN_NAME

    $ipt -N CNNG_OUT
    $ipt -N CNNG_PRE
    $ipt_m -N CNNG_OUT
    $ipt_m -N CNNG_PRE
    $ipt_m -N UDPCHAIN

    $ipt_m -A UDPCHAIN -d 0.0.0.0/8 -j RETURN
    $ipt_m -A UDPCHAIN -d 10.0.0.0/8 -j RETURN
    $ipt_m -A UDPCHAIN -d 127.0.0.0/8 -j RETURN
    $ipt_m -A UDPCHAIN -d 169.254.0.0/16 -j RETURN
    $ipt_m -A UDPCHAIN -d 172.16.0.0/12 -j RETURN
    $ipt_m -A UDPCHAIN -d 192.168.0.0/16 -j RETURN
    $ipt_m -A UDPCHAIN -d 224.0.0.0/4 -j RETURN
    $ipt_m -A UDPCHAIN -d 240.0.0.0/4 -j RETURN

    $ipt_m -A UDPCHAIN -m set --match-set china dst -j RETURN
    $ipt -A CNNG_OUT -p udp -d 127.0.0.1 --dport 53 -j REDIRECT --to-ports 65353
    $ipt -A CNNG_OUT -p tcp -j $CHAIN_NAME
    $ipt_m -A CNNG_OUT -p udp -j UDPCHAIN
    $ipt -A OUTPUT -j CNNG_OUT
    $ipt_m -A OUTPUT -j CNNG_OUT
    $ipt -A PREROUTING -j CNNG_PRE
    $ipt_m -A PREROUTING -j CNNG_PRE
fi
}

func_iptables(){
if [ -n "$ARG2" ]
then
    REMOTE_IP=$ARG2
else
    logger -t $BINARY_NAME "$REMOTE_IP NOT FOUND!"
return 0
fi
func_clean
func_china_file
wait
echo "CH list rule !"
flush_ipt_file && flush_ipt_rules
}

func_clean(){
iptables-save -c | grep -v $CHAIN_NAME | iptables-restore -c && sleep 2
ipset -X $SET_NAME >/dev/null 2>&1 &
}

func_stop(){
    if [ -n "$(pidof $BINARY_NAME)" ] ; then
    killall $BINARY_NAME >/dev/null 2>&1 &
    sleep 2
    fi
    func_clean
    func_del_ipt
    [ -d "$TMP_HOME" ] && rm -rf "$TMP_HOME"
    logger -t $BINARY_NAME "KILLED"
}

case "$ARG1" in
start)
    func_start
    ;;
stop)
    func_stop
    ;;
iptables)
    func_iptables
    ;;
clean)
    func_clean
    ;;
restart)
    func_stop
    func_start
    ;;
*)
    echo "Usage: $0 { start [ $1 IP $2 PORT $3 IP ] | stop | iptables [ $1 IP ] | restart }"
    exit 1
    ;;
esac

