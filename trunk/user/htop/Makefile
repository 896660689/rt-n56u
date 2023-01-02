SRC_NAME = htop
SRC_VERSION = 3.2.1
SRC_SOURCE = $(SRC_NAME)-$(SRC_VERSION)
SRC_URL = https://codeload.github.com/htop-dev/htop/tar.gz/$(SRC_VERSION)?
THISDIR = $(shell pwd)

all: download_test extract_test config_test
	$(MAKE) -j$(HOST_NCPU) -C $(SRC_SOURCE)

download_test:
	( if [ ! -f $(SRC_SOURCE).tar.gz ]; then \
		wget -t5 --timeout=20 --no-check-certificate -O $(SRC_SOURCE).tar.gz $(SRC_URL); \
	fi )

extract_test:
	( if [ ! -d $(SRC_SOURCE) ]; then \
		tar zxf $(SRC_SOURCE).tar.gz; \
	fi )

config_test:
	( if [ -f ./config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure && touch config_done; \
	fi )

configure:
	( cd $(SRC_SOURCE) ; \
	./autogen.sh ; \
	./configure \
		--prefix=/usr \
		--enable-unicode \
		HTOP_NCURSESW_CONFIG_SCRIPT="$(STAGEDIR)/bin/ncursesw6-config" \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	if [ -f $(SRC_SOURCE)/Makefile ] ; then \
		$(MAKE) -C $(SRC_SOURCE) distclean ; \
	fi ; \
	rm -f config_done

romfs:
	$(ROMFSINST) -p +x $(THISDIR)/$(SRC_SOURCE)/htop /usr/bin/htop
