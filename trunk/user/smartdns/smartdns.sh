#!/bin/sh
# Copyright (C) 2018 Nick Peng (pymumu@gmail.com)
# Copyright (C) 2019 chongshengB
SMARTDNS_CONF_DIR="/etc/storage"
SMARTDNS_CONF="$SMARTDNS_CONF_DIR/smartdns.conf"
ADDRESS_CONF="$SMARTDNS_CONF_DIR/smartdns_address.conf"
BLACKLIST_IP_CONF="$SMARTDNS_CONF_DIR/smartdns_blacklist-ip.conf"
WHITELIST_IP_CONF="$SMARTDNS_CONF_DIR/smartdns_whitelist-ip.conf"
CUSTOM_CONF="$SMARTDNS_CONF_DIR/smartdns_custom.conf"
smartdns_file="/usr/bin/smartdns"
sdns_enable=`nvram get sdns_enable`
snds_name=`nvram get snds_name`
sdns_port=`nvram get sdns_port`
sdns_tcp_server=`nvram get sdns_tcp_server`
sdns_ipv6_server=`nvram get sdns_ipv6_server`
snds_ip_change=`nvram get snds_ip_change`
sdns_www=`nvram get sdns_www`
snds_redirect=`nvram get snds_redirect`
snds_cache=`nvram get snds_cache`
sdns_ttl=`nvram get sdns_ttl`
sdns_ttl_min=`nvram get sdns_ttl_min`
sdns_ttl_max=`nvram get sdns_ttl_max`
sdnse_enable=`nvram get sdnse_enable`
sdnse_port=`nvram get sdnse_port`
sdnse_tcp=`nvram get sdnse_tcp`
sdnse_speed=`nvram get sdnse_speed`
sdnse_name=`nvram get sdnse_name`
sdnse_address=`nvram get sdnse_address`
sdnse_ns=`nvram get sdnse_ns`
sdnse_ipset=`nvram get sdnse_ipset`
sdnse_as=`nvram get sdnse_as`
sdnse_ipc=`nvram get sdnse_ipc`
sdnse_cache=`nvram get sdnse_cache`
ss_white=`nvram get ss_white`
ss_black=`nvram get ss_black`
get_tz()
{
	SET_TZ=""
	for tzfile in /etc/TZ
	do
		if [ ! -e "$tzfile" ]; then
			continue
		fi		
		tz="`cat $tzfile 2>/dev/null`"
	done	
	if [ -z "$tz" ]; then
		return	
	fi	
	SET_TZ=$tz
}
gensmartconf(){
rm -f $SMARTDNS_CONF
touch $SMARTDNS_CONF
echo "server-name $snds_name" >> $SMARTDNS_CONF
	if [ "$sdns_ipv6_server" = "1" ]; then
		echo "bind" "[::]:$sdns_port" >> $SMARTDNS_CONF
	else
		echo "bind" ":$sdns_port" >> $SMARTDNS_CONF
	fi
	if [ "$sdns_tcp_server" = "1" ]; then
		if [ "$sdns_ipv6_server" = "1" ]; then
			echo "bind-tcp" "[::]:$sdns_port" >> $SMARTDNS_CONF
		else
			echo "bind-tcp" ":$sdns_port" >> $SMARTDNS_CONF
		fi
	fi
gensdnssecond
echo "cache-size $snds_cache" >> $SMARTDNS_CONF
if [ $snds_ip_change -eq 1 ];then
echo "dualstack-ip-selection yes" >> $SMARTDNS_CONF
fi
if [ $sdns_www -eq 1 ];then
echo "prefetch-domain yes" >> $SMARTDNS_CONF
else
echo "prefetch-domain no" >> $SMARTDNS_CONF
fi
echo "log-level info" >> $SMARTDNS_CONF
listnum=`nvram get sdnss_staticnum_x`
for i in $(seq 1 $listnum)
do
j=`expr $i - 1`
sdnss_enable=`nvram get sdnss_enable_x$j`
if  [ $sdnss_enable -eq 1 ]; then
sdnss_name=`nvram get sdnss_name_x$j`
sdnss_ip=`nvram get sdnss_ip_x$j`
sdnss_port=`nvram get sdnss_port_x$j`
sdnss_type=`nvram get sdnss_type_x$j`
sdnss_ipc=`nvram get sdnss_ipc_x$j`
ipc=""
if [ $sdnss_ipc = "whitelist" ]; then
ipc="-whitelist-ip"
elif [ $sdnss_ipc = "blacklist" ]; then
ipc="-blacklist-ip"
fi
if [ $sdnss_type = "tcp" ]; then
if [ $sdnss_port = "default" ]; then
echo "server-tcp $sdnss_ip $ipc" >> $SMARTDNS_CONF
else
echo "server-tcp $sdnss_ip:$sdnss_port $ipc" >> $SMARTDNS_CONF
fi
elif [ $sdnss_type = "udp" ]; then
if [ $sdnss_port = "default" ]; then
echo "server $sdnss_ip" >> $SMARTDNS_CONF
else
echo "server $sdnss_ip:$sdnss_port $ipc" >> $SMARTDNS_CONF
fi
elif [ $sdnss_type = "tls" ]; then
if [ $sdnss_port = "default" ]; then
echo "server-tls $sdnss_ip $ipc" >> $SMARTDNS_CONF
else
echo "server-tls $sdnss_ip:$sdnss_port $ipc" >> $SMARTDNS_CONF
fi
elif [ $sdnss_type = "https" ]; then
if [ $sdnss_port = "default" ]; then
echo "server-https $sdnss_ip $ipc" >> $SMARTDNS_CONF
fi	
fi	
fi
done
}

gensdnssecond(){
if  [ $sdnse_enable -eq 1 ]; then
ARGS=""
ADDR=""
if [ "$sdnse_speed" = "1" ]; then
	ARGS="$ARGS -no-speed-check"
fi
if [ ! -z "$sdnse_name" ]; then
		ARGS="$ARGS -group $sdnse_name"
	fi
if [ "$sdnse_address" = "1" ]; then
		ARGS="$ARGS -no-rule-addr"
	fi
	if [ "$sdnse_ns" = "1" ]; then
		ARGS="$ARGS -no-rule-nameserver"
	fi
	if [ "$sdnse_ipset" = "1" ]; then
		ARGS="$ARGS -no-rule-ipset"
	fi
	if [ "$sdnse_as" = "1" ]; then
		ARGS="$ARGS -no-rule-soa"
	fi
	if [ "$sdnse_ipc" = "1" ]; then
		ARGS="$ARGS -no-dualstack-selection"
	fi
	if [ "$sdnse_cache" = "1" ]; then
		ARGS="$ARGS -no-cache"
	fi
	if [ "$sdns_ipv6_server" = "1" ]; then
		ADDR="[::]"
	else
		ADDR=""
	fi
echo "bind" "$ADDR:$sdnse_port $ARGS" >> $SMARTDNS_CONF
	if [ "$sdnse_tcp" = "0" ]; then
		echo "bind-tcp" "$ADDR:$sdnse_port$ARGS" >> $SMARTDNS_CONF
	fi
fi
}

change_dns() {
sed -i '/no-resolv/d' /etc/storage/dnsmasq/dnsmasq.conf
sed -i '/server=127.0.0.1/d' /etc/storage/dnsmasq/dnsmasq.conf
cat >> /etc/storage/dnsmasq/dnsmasq.conf << EOF
no-resolv
server=127.0.0.1#$sdns_port
EOF
/sbin/restart_dhcpd
logger -t "SmartDNS" "添加DNS转发到$sdns_port端口"
}
del_dns() {
sed -i '/no-resolv/d' /etc/storage/dnsmasq/dnsmasq.conf
sed -i '/server=127.0.0.1/d' /etc/storage/dnsmasq/dnsmasq.conf
/sbin/restart_dhcpd
}

set_iptable()
{
	ipv6_server=$1
	tcp_server=$2

	IPS="`ifconfig | grep "inet addr" | grep -v ":127" | grep "Bcast" | awk '{print $2}' | awk -F : '{print $2}'`"
	for IP in $IPS
	do
		if [ "$tcp_server" == "1" ]; then
			iptables -t nat -A PREROUTING -p tcp -d $IP --dport 53 -j REDIRECT --to-ports $sdns_port >/dev/null 2>&1
		fi
		iptables -t nat -A PREROUTING -p udp -d $IP --dport 53 -j REDIRECT --to-ports $sdns_port >/dev/null 2>&1
	done

	if [ "$ipv6_server" == 0 ]; then
		return
	fi

	IPS="`ifconfig | grep "inet6 addr" | grep -v " fe80::" | grep -v " ::1" | grep "Global" | awk '{print $3}'`"
	for IP in $IPS
	do
		if [ "$tcp_server" == "1" ]; then
			ip6tables -t nat -A PREROUTING -p tcp -d $IP --dport 53 -j REDIRECT --to-ports $sdns_port >/dev/null 2>&1
		fi
		ip6tables -t nat -A PREROUTING -p udp -d $IP --dport 53 -j REDIRECT --to-ports $sdns_port >/dev/null 2>&1
	done
logger -t "SmartDNS" "重定向53端口"
}

clear_iptable()
{
	local OLD_PORT="$1"
	local ipv6_server=$2
	IPS="`ifconfig | grep "inet addr" | grep -v ":127" | grep "Bcast" | awk '{print $2}' | awk -F : '{print $2}'`"
	for IP in $IPS
	do
		iptables -t nat -D PREROUTING -p udp -d $IP --dport 53 -j REDIRECT --to-ports $OLD_PORT >/dev/null 2>&1
		iptables -t nat -D PREROUTING -p tcp -d $IP --dport 53 -j REDIRECT --to-ports $OLD_PORT >/dev/null 2>&1
	done

	if [ "$ipv6_server" == 0 ]; then
		return
	fi

	IPS="`ifconfig | grep "inet6 addr" | grep -v " fe80::" | grep -v " ::1" | grep "Global" | awk '{print $3}'`"
	for IP in $IPS
	do
		ip6tables -t nat -D PREROUTING -p udp -d $IP --dport 53 -j REDIRECT --to-ports $OLD_PORT >/dev/null 2>&1
		ip6tables -t nat -D PREROUTING -p tcp -d $IP --dport 53 -j REDIRECT --to-ports $OLD_PORT >/dev/null 2>&1
	done
	
}

dl_smartdns(){
smartdns_file="/tmp/smartdns"
curl -k -s -o $smartdns_file --connect-timeout 10 --retry 3 https://dev.tencent.com/u/dtid_39de1afb676d0d78/p/kp/git/raw/master/smartdns
if [ ! -f "$smartdns_file" ]; then
logger -t "SmartDNS" "SmartDNS二进制文件下载失败，可能是地址失效或者网络异常！"
nvram set sdns_enable=0
stop_smartdns
exit 0
else
logger -t "SmartDNS" "SmartDNS二进制文件下载成功"
chmod -R 777 $smartdns_file
fi
}
start_smartdns(){
if [ ! -f "$smartdns_file" ];then
dl_smartdns
fi
args=""
logger -t "SmartDNS" "创建配置文件."
gensmartconf
if [ $ss_white = "1" ]; then
rm -f /tmp/whitelist.txt
awk '{printf("whitelist-ip %s\n", $1, $1 )}' /etc/storage/chinadns/chnroute.txt >> /tmp/whitelist.txt
fi
if [ $ss_black = "1" ]; then
rm -f /tmp/blacklist.txt
awk '{printf("blacklist-ip %s\n", $1, $1 )}' /etc/storage/chinadns/chnroute.txt >> /tmp/blacklist.txt
fi
grep -v ^! $ADDRESS_CONF >> $SMARTDNS_CONF
grep -v ^! $BLACKLIST_IP_CONF >> $SMARTDNS_CONF
grep -v ^! $WHITELIST_IP_CONF >> $SMARTDNS_CONF
grep -v ^! $CUSTOM_CONF >> $SMARTDNS_CONF
grep -v ^! /tmp/whitelist.txt >> $SMARTDNS_CONF
rm -f /tmp/whitelist.txt
grep -v ^! /tmp/blacklist.txt >> $SMARTDNS_CONF
rm -f /tmp/blacklist.txt
if [ "$sdns_coredump" = "1" ]; then
		args="$args -S"
	fi
	#get_tz
	#if [ ! -z "$SET_TZ" ]; then
#		procd_set_param env TZ="$SET_TZ"
	#fi
$smartdns_file -f -c $SMARTDNS_CONF $args &>/dev/null &
logger -t "SmartDNS" "SmartDNS启动成功"
if [ $snds_redirect = "2" ]; then
		set_iptable $sdns_ipv6_server $sdns_tcp_server
	elif [ $snds_redirect = "1" ]; then
		change_dns
	fi

}

stop_smartdns(){

killall -9 smartdns
del_dns
clear_iptable $sdns_port $sdns_ipv6_server
if [ "$snds_redirect" = "2" ]; then
		clear_iptable $sdns_port $sdns_ipv6_server
	elif [ "$snds_redirect" = "1" ]; then
		del_dns
	fi
logger -t "SmartDNS" "SmartDNS已关闭"
}

case $1 in
start)
	start_smartdns
	;;
stop)
	stop_smartdns
	;;
*)
	echo "check"
	;;
esac