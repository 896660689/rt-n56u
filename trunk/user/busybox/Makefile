SRC_NAME=busybox-1.34.1

extract_test:
	( if [ ! -d $(SRC_NAME) ]; then \
		tar xjf $(SRC_NAME).tar.gz; \
	fi )

all:
	$(MAKE) -j$(HOST_NCPU) -C $(SRC_NAME)

clean:
	$(MAKE) -C $(SRC_NAME) distclean

romfs:
	$(MAKE) -C $(SRC_NAME) CONFIG_PREFIX=$(ROMFSDIR) install

