SRC_NAME=dropbear-2022.83
SRC_URL=https://matt.ucc.asn.au/dropbear/releases/$(SRC_NAME).tar.bz2

ifeq ($(CONFIG_FIRMWARE_INCLUDE_SFTP),y)
COPT=-DSFTPSERVER_PATH=\"/usr/libexec/sftp-server\"
else
COPT=-DSFTPSERVER_PATH=\"/opt/libexec/sftp-server\"
endif
ifneq ($(CONFIG_FIRMWARE_INCLUDE_DROPBEAR_FAST_CODE),y)
COPT+=-DDROPBEAR_SMALL_CODE
endif
CFLAGS+=$(COPT) -O2 -Wall -DARGTYPE=3 -ffunction-sections -fdata-sections
LDFLAGS += -ffunction-sections -fdata-sections -Wl,--gc-section

all: download_test extract_test config_test
	$(MAKE) -j$(HOST_NCPU) -C $(SRC_NAME) PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" MULTI=1

download_test:
	( if [ ! -f $(SRC_NAME).tar.bz2 ]; then \
		wget -t5 --timeout=20 --no-check-certificate -O $(SRC_NAME).tar.bz2 $(SRC_URL); \
	fi )

extract_test:
	( if [ ! -d $(SRC_NAME) ]; then \
		tar xf $(SRC_NAME).tar.bz2; \
		patch -d $(SRC_NAME) -p1 -i ../patches/100-Fix-so-DROPBEAR_DSS-is-only-forced-for-fuzzing.patch; \
		patch -d $(SRC_NAME) -p1 -i ../patches/101-Add-missing-break-in-switch.patch; \
		patch -d $(SRC_NAME) -p1 -i ../patches/102-Fix-building-only-client-or-server.patch; \
		patch -d $(SRC_NAME) -p1 -i ../patches/001-firmware-specific.patch; \
		patch -d $(SRC_NAME) -p1 -i ../patches/120-Explicitly-force-IPv4-or-IPv6-usage.patch; \
	fi )

config_test:
	( if [ -f ./config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure && touch config_done; \
	fi )

configure:
	( cd $(SRC_NAME) ; \
	autoreconf -v; \
	./configure \
		--prefix=/usr \
		--disable-lastlog \
		--disable-utmp \
		--disable-utmpx \
		--disable-wtmp \
		--disable-wtmpx \
		--disable-loginfunc \
		--disable-pututline \
		--disable-pututxline \
		--enable-zlib \
		--enable-bundled-libtom \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	if [ -f $(SRC_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_NAME) distclean ; \
	fi ; \
	rm -f dropbearmulti
	rm -f config_done

romfs:
	cp $(SRC_NAME)/dropbearmulti .
	$(STRIP) dropbearmulti
	$(ROMFSINST) /usr/bin/dropbearmulti
	$(ROMFSINST) -p +x /usr/bin/sshd.sh
	$(ROMFSINST) -s dropbearmulti /usr/bin/ssh
	$(ROMFSINST) -s dropbearmulti /usr/bin/scp
	$(ROMFSINST) -s dropbearmulti /usr/bin/dropbearkey
	$(ROMFSINST) -s dropbearmulti /usr/bin/dropbearconvert
	$(ROMFSINST) -s /usr/bin/dropbearmulti /usr/sbin/dropbear
