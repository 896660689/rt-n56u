SRC_NAME = ZeroTierOne-1.10.2
THISDIR = $(shell pwd)
FLAGS := DEFS=""
CFLAGS := -Os -ffunction-sections -fdata-sections
LDFLAGS := -Wl,--gc-sections,--as-needed


all: extract_test extract_src
	$(MAKE) -j$(HOST_NCPU) -C $(SRC_NAME)

extract_test:
	( if [ ! -d $(SRC_NAME) ]; then \
		tar zxf ZeroTierOne-1.10.2-01.tar.gz ; \
		sleep 20 ; \
	fi )
extract_src:
	( if [ -d $(SRC_DIR) ]; then \
		tar zxf ZeroTierOne-1.10.2-02.tar.gz ; \
		sleep 35 ; \
		patch -d $(SRC_NAME) -p1 -i ../0002-remove-pie.patch; \
		patch -d $(SRC_NAME) -p1 -i ../0007-add-cerrno-header-for-str-errno.patch ; \
		patch -d $(SRC_NAME) -p1 -i ../0009-fix-set-mac-and-change-confpath.patch ; \
	fi )

config_test:
clean:
	if [ -f $(SRC_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_NAME) distclean ; \
	fi ; \

romfs:
	$(ROMFSINST) $(THISDIR)/$(SRC_NAME)/zerotier-one /usr/bin/zerotier-one
	$(ROMFSINST) $(THISDIR)/zerotier.sh /usr/bin/zerotier.sh
	$(ROMFSINST) $(THISDIR)/Advanced_zerotier.asp /www/Advanced_zerotier.asp
	ln -sf zerotier-one $(ROMFSDIR)/usr/bin/zerotier-cli
	ln -sf zerotier-one $(ROMFSDIR)/usr/bin/zerotier-idtool
	cp -fP $(CONFIG_CROSS_COMPILER_ROOT)/mipsel-linux-uclibc/sysroot/lib/libstdc++.so* $(ROMFSDIR)/lib

