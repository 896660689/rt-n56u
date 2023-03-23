SRC_NAME=ipset-7.1
SRC_URL=http://ipset.netfilter.org/$(SRC_NAME).tar.bz2

THISDIR = $(shell pwd)

all: download_test extract_test config_test
	$(MAKE) -C $(SRC_NAME)
	$(MAKE) modules -C $(SRC_NAME)

download_test:
	( if [ ! -f $(SRC_NAME).tar.bz2 ]; then \
		wget -t5 --timeout=20 --no-check-certificate -O $(SRC_NAME).tar.bz2 $(SRC_URL); \
	fi )

extract_test:
	( if [ ! -d $(SRC_NAME) ]; then \
		tar xf $(SRC_NAME).tar.bz2; \
		find $(THISDIR)/patches -type f -name '*.patch' -print0 \
		  | sort -z \
		  | xargs -t -0 -n 1 patch -d $(SRC_NAME)  -p1 -i; \
	fi )

config_test:
	( if [ -f ./config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure && touch config_done; \
	fi )

configure:
	( cd $(SRC_NAME) ; \
	./autogen.sh ; \
	PKG_CONFIG_PATH=$(STAGEDIR)/lib/pkgconfig \
	./configure \
		--prefix= \
		--enable-static \
		--disable-shared \
		libmnl_CFLAGS="-I$(STAGEDIR)/include" \
		libmnl_LIBS="-L$(STAGEDIR)/lib -lmnl" \
		--with-kmod=yes \
		--with-kbuild=$(ROOTDIR)/$(LINUXDIR) \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	if [ -f $(SRC_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_NAME) modules_clean ; \
		$(MAKE) -C $(SRC_NAME) distclean ; \
	fi ; \
	rm -f config_done

romfs:
	cp $(THISDIR)/$(SRC_NAME)/src/ipset .
	$(STRIP) ipset
	$(ROMFSINST) /sbin/ipset

