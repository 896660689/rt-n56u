url=http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest
THISDIR = $(shell pwd)

all :
	( if [ ! -f chnroute.txt ]; then \
		wget -t3 -4 --timeout=5 -O tmp_chips '$(url)' && \
		awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $$4, 32-log($$5)/log(2)) }' < tmp_chips > chnroute.txt && \
		awk -F\| '/CN\|ipv6/ { printf("%s/%d\n", $$4, 32-log($$5)/log(2)) }' < tmp_chips > chnroute6.txt && \
		rm -rf tmp_chips && tar jcf chnroute.bz2 chnroute.txt chnroute6.txt && \
		tar jcf chnlist.bz2 chnlist.txt gfw.txt ; \
	fi )

romfs:
	chmod -R +x ./scripts
	$(ROMFSINST) $(THISDIR)/scripts/ /usr/bin/
	$(ROMFSINST) -d $(THISDIR)/chnroute.bz2 /etc_ro/chnroute.bz2
	$(ROMFSINST) -d $(THISDIR)/chnlist.bz2 /etc_ro/chnlist.bz2

clean :
	rm -f chnroute.*

