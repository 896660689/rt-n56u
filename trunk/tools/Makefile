/bin/sh /usr/bin/smartdns.sh start

/bin/sh /tmp/smartdns.sh start



/tmp/smartdns.sh start



/tmp/smartdns.sh

mount --bind /tmp/smartdns.sh /usr/bin/smartdns.sh

STORAGE_DIR="/etc/storage"
SMARTDNS_CONF="$STORAGE_DIR/smartdns.conf"
if [ ! -d $STORAGE_DIR/smartdns ]; then
    mkdir -p "$STORAGE_DIR/smartdns"
	touch $SMARTDNS_CONF &
else
    [ -f $SMARTDNS_CONF ] && rm -f $SMARTDNS_CONF
    touch $SMARTDNS_CONF &

smartdns_folder