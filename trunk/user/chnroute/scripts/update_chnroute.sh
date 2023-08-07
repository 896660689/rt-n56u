#!/bin/sh
# Compile:by-lanse	2023-08-07

tmp_chnroute="/tmp/chnroute.txt"
tmp_chnroute6="/tmp/chnroute6.txt"
set -e -o pipefail

logger -st "chnroute" "Starting update..."
[ -f $tmp_chnroute ] && rm -rf $tmp_chnroute && [ -f $tmp_chnroute6 ] && rm -rf $tmp_chnroute6

if [ "$1" != "force" ] && [ "$(nvram get ss_update_chnroute)" != "1" ]; then
	exit 0
else
	[ ! -d "/etc/storage/chinadns" ] && mkdir -p /etc/storage/chinadns
	wget -t 15 -T 50 -c --no-check-certificate -O /tmp/tmp_chips 'https://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' && sleep 5
	awk -F\| '/CN\|ipv6/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' < /tmp/tmp_chips > $tmp_chnroute6 && sleep 3
	awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' < /tmp/tmp_chips > $tmp_chnroute && sleep 3
	rm -rf /tmp/tmp_chips
 	if [ -s "$tmp_chnroute6" ] ; then
		touch /tmp/chnroute6-md5.json && md5sum /etc/storage/chinadns/chnroute6.txt > /tmp/chnroute6-md5.json
		touch /tmp/chinadns6-md5.json && md5sum $tmp_chnroute6 > /tmp/chinadns6-md5.json
		chnroute6_local=$(grep 'chnroute6' /tmp/chnroute6-md5.json | awk -F' ' '{print $1}')
		chinadns6_md5=$(grep 'ch' /tmp/chinadns6-md5.json | awk -F' ' '{print $1}')
		if [ "$chnroute6_local"x == "$chinadns6_md5"x ] ; then
			logger -t "chnroute6" "No update"
			rm -f $tmp_chnroute6
		else
			chmod 644 $tmp_chnroute6 && mv -f $tmp_chnroute6 /etc/storage/chinadns/chnroute6.txt
			logger -t "chnroute6" "update rule"
		fi
		rm -f /tmp/chnroute6-md5.json /tmp/chinadns6-md5.json
	fi
	if [ -s "$tmp_chnroute" ] ; then
		touch /tmp/chnroute-md5.json && md5sum /etc/storage/chinadns/chnroute.txt > /tmp/chnroute-md5.json
		touch /tmp/chinadns-md5.json && md5sum $tmp_chnroute > /tmp/chinadns-md5.json
		chnroute_local=$(grep 'chnroute' /tmp/chnroute-md5.json | awk -F' ' '{print $1}')
		chinadns_md5=$(grep 'ch' /tmp/chinadns-md5.json | awk -F' ' '{print $1}')
		if [ "$chnroute_local"x == "$chinadns_md5"x ] ; then
			logger -t "chnroute" "No update"
			rm -f $tmp_chnroute
		else
			chmod 644 $tmp_chnroute && mv -f $tmp_chnroute /etc/storage/chinadns/chnroute.txt; sleep 2
			[ -f /usr/bin/shadowsocks.sh ] && [ "$(nvram get ss_enable)" = "1" ] && /usr/bin/shadowsocks.sh restart >/dev/null 2>&1
			logger -t "chnroute" "update rule"
		fi
		rm -f /tmp/chnroute-md5.json /tmp/chinadns-md5.json
	fi
fi

