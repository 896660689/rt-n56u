SRC_NAME=busybox-1.3X.X

extract_test:
	( if [ ! -d $(SRC_NAME) ]; then \
		unzip -qq $(SRC_NAME).zip; \
	fi )

all:
	$(MAKE) -j$(HOST_NCPU) -C $(SRC_NAME)

clean:
	$(MAKE) -C $(SRC_NAME) distclean

romfs:
	$(MAKE) -C $(SRC_NAME) CONFIG_PREFIX=$(ROMFSDIR) install
