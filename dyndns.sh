#!/bin/sh
#
# dyndns.org updater script
#

# dyndns options
# Do not edit this file!
# Use the default /etc/dyndns.conf file instead.
USER=
PASS=
DOMAIN=
WGET_ARGS="--no-check-certificate -q"
CONF="/etc/dyndns.conf"
TMPDIR="/tmp"

if [ -x /usr/bin/wget -a -x /bin/wget ]; then
  echo "$0: no wget found, abort .."
fi

# check for compiled in SSL support
/usr/bin/wget --version | grep -E '\+https(.*)\+openssl' >&2 >/dev/null
if [ $? -ne 0 ]; then
  echo "$0: need wget with SSL support"
  echo "$0: check wget --version"
  exit 127
fi

[ -z "$1" ] || CONF="$1"
if [ -r $CONF ]; then
  . $CONF
else
  echo "$0: no $CONF, abort .."
  exit 1
fi

[ -z "$2" ] || TMPDIR="$2"
wget $WGET_ARGS "http://checkip.dyndns.com/index.html" --output-document="$TMPDIR/new.ip"
[ -f "$TMPDIR/old.ip" ] || touch "$TMPDIR/old.ip"

if [ "`cat $TMPDIR/new.ip`" = "`cat $TMPDIR/old.ip`" ]; then
        echo "No new IP"
else
        wget $WGET_ARGS "https://$USER:$PASS@members.dyndns.org/nic/update?hostname=$DOMAIN" --output-document="$TMPDIR/upd.ip"
        echo "New IP"
        cat "$TMPDIR/upd.ip"
        rm -f "$TMPDIR/upd.ip"
        echo
fi

rm -f "$TMPDIR/old.ip"
mv -f "$TMPDIR/new.ip" "$TMPDIR/old.ip"

exit 0
