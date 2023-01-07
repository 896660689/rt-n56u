SRC_NAME=dnsmasq-2.88
SRC_URL=https://thekelleys.org.uk/dnsmasq/$(SRC_NAME).tar.xz
THISDIR = $(shell pwd)

COPTS := -DHAVE_BROKEN_RTC -DNO_INOTIFY -DNO_AUTH -DNO_LOOP -DNO_ID
ifndef CONFIG_IPV6
COPTS += -DNO_IPV6
endif
ifndef CONFIG_USB_SUPPORT
COPTS += -DNO_TFTP
endif
ifneq ($(CONFIG_FIRMWARE_INCLUDE_IPSET),y)
COPTS += -DNO_IPSET
endif
all: download_test extract_test
	$(MAKE) -j$(HOST_NCPU) -C $(SRC_NAME) COPTS="$(COPTS)"

download_test:
	( if [ ! -f $(SRC_NAME).tar.xz ]; then \
		wget -t5 --timeout=20 --no-check-certificate -O $(SRC_NAME).tar.xz $(SRC_URL); \
	fi )

extract_test:
	( if [ ! -d $(SRC_NAME) ]; then \
		tar xf $(SRC_NAME).tar.xz; \
		patch -d $(SRC_NAME) -p1 -i ../patchs/001-adjust-variables.patch; \
		patch -d $(SRC_NAME) -p1 -i ../patchs/100-remove-old-runtime-kernel-support.patch; \
		patch -d $(SRC_NAME) -p1 -i ../patchs/112-add-back-ability-to-compile-without-IPv6-support.patch; \
	fi )

clean:
	$(MAKE) -C $(SRC_NAME) clean
	rm -f dnsmasq

romfs:
	cp $(SRC_NAME)/src/dnsmasq .
	$(STRIP) dnsmasq
	$(ROMFSINST) /usr/sbin/dnsmasq
