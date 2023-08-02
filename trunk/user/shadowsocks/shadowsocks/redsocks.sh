#!/bin/sh
# Compile:by-lanse	2023-03-06

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
SET_NAME="chnroute"
SOCKS_LOG="/tmp/ss-watchcat.log"
ss_router_proxy=$(nvram get ss_router_proxy)
v2_port=$(cat /tmp/V2mi.txt | grep "port:" | awk -F '[:/]' '{print $2}') 
SOCKS5_IP=$(nvram get lan_ipaddr)
SOCKS5_PORT=$(nvram get ss_local_port)
REMOTE_IP="127.0.0.1"

ARG1=$1
ARG2=$2
ARG3=$3

func_redsocks(){
if [ "$ss_router_proxy" = "5" ] ; then
    IPT2SOCKS_CMD="ipt2socks -s 127.0.0.1 -p $SOCKS5_PORT -l 12345 -r -4 -R"
    $IPT2SOCKS_CMD >/dev/null 2>&1 &
else
    ln -sf $BINARY_PATH $REDSOCKS_FILE
    cd $TMP_HOME
    ./redsocks -c ./redsocks.conf
fi
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
log = "file:/$SOCKS_LOG";
redirector = iptables;
daemon = on;
redsocks_conn_max = 10000;
rlimit_nofile = 10240;
}

redsocks {
local_ip = 0.0.0.0;
local_port = 12345;
ip = $SOCKS5_IP;
port = $SOCKS5_PORT;
type = socks5;
}
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
$ipt -A $CHAIN_NAME -d 127.0.0.0/8 -j RETURN
$ipt -A $CHAIN_NAME -d 172.16.0.0/12 -j RETURN
$ipt -A $CHAIN_NAME -d 192.168.0.0/16 -j RETURN
$ipt -A $CHAIN_NAME -d 224.0.0.0/4 -j RETURN
$ipt -A $CHAIN_NAME -d 240.0.0.0/4 -j RETURN
$ipt -A $CHAIN_NAME -m set --match-set chnroute dst -j RETURN
$ipt -A $CHAIN_NAME -p tcp -j REDIRECT --to-ports 12345
$ipt -A PREROUTING -i br0 -p tcp -j $CHAIN_NAME

cat <<-CAT >>$FWI
iptables-save -c | grep -v $CHAIN_NAME | iptables-restore -c
iptables-restore -n <<-EOF
$(iptables-save | grep -E "$CHAIN_NAME|^\*|^COMMIT" |\
sed -e "s/^-A \(OUTPUT\|PREROUTING\)/-I \1 1/")
EOF
CAT
return 0
}

func_iptables(){
if [ -n "$ARG2" ]
then
REMOTE_IP=$ARG2
else
logger -t $BINARY_NAME "REMOTE_IP NOT FOUND!"
return 0
fi
func_clean
wait
echo "CH list rule !"
if [ "$ss_router_proxy" = "5" ] ; then
echo "ipt2_socks"
else
flush_ipt_file && flush_ipt_rules
fi
}

func_clean(){
if [ $(nvram get ss_enable) = "0" ]; then
flush_iptables() {
ipt="iptables -t $1"
DAT=$(iptables-save -t $1)
eval $(echo "$DAT" | grep "REDSOCKS" | sed -e 's/^-A/$ipt -D/' -e 's/$/;/')
for chain in $(echo "$DAT" | awk '/^:REDSOCKS/{print $1}'); do
$ipt -F ${chain:1} 2>/dev/null && $ipt -X ${chain:1}
done
}
sleep 3 && flush_iptables nat &
fi
ipt="iptables -t nat"
$ipt -D $CHAIN_NAME -d $REMOTE_IP -j RETURN
$ipt -D $CHAIN_NAME -d 0.0.0.0/8 -j RETURN
$ipt -D $CHAIN_NAME -d 127.0.0.0/8 -j RETURN
$ipt -D $CHAIN_NAME -d 172.16.0.0/12 -j RETURN
$ipt -D $CHAIN_NAME -d 192.168.0.0/16 -j RETURN
$ipt -D $CHAIN_NAME -d 224.0.0.0/4 -j RETURN
$ipt -D $CHAIN_NAME -d 240.0.0.0/4 -j RETURN
$ipt -D $CHAIN_NAME -m set --match-set chnroute dst -j RETURN
$ipt -D $CHAIN_NAME -p tcp -j REDIRECT --to-ports 12345
$ipt -D PREROUTING -i br0 -p tcp -j $CHAIN_NAME
[ -d "$SOCKS_LOG" ] && cat /dev/null > $SOCKS_LOG
}

func_stop(){
if [ -n "$(pidof $BINARY_NAME)" ] ; then
killall $BINARY_NAME &
sleep 2
fi
if [ -n "$(pidof ipt2socks)" ] ; then
killall ipt2socks >/dev/null 2>&1
kill -9 "$(pidof ipt2socks)" >/dev/null 2>&1
fi
func_clean
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
    echo "Usage: $0 { start [ ARG2:Server IP ARG3:Server PORT ] | stop | iptables [ ARG1:Server IP ] | restart }"
    exit 1
    ;;
esac

