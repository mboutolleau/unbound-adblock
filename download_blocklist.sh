#!/usr/bin/env bash

set -euo pipefail

BLOCKLIST="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
BLOCKLIST_LOCATION="/var/unbound/etc/"

cleanup(){
    rm -f "$TMPDIR/blocklist.conf"
    rm -f "$TMPDIR/hosts"
    rmdir "$TMPDIR"
}

# Create a temp dir, exit if impossible
TMPDIR=$(mktemp -d) || exit 1

trap cleanup EXIT

cd "$TMPDIR"

if ! wget --no-verbose "$BLOCKLIST"; then
    echo "Could not download '$BLOCKLIST'"
    exit 1
fi

# Transform the hosts file into one that can be read by Unbound.
# For example, entries like '0.0.0.0 <domain>' becomes :
# local-zone: "<domain>" redirect
# local-data: "<domain> A 0.0.0.0"
#
# Courtesy of deadc0de : https://deadc0de.re/articles/unbound-blocking-ads.html
if ! grep "^0\.0\.0\.0" "$TMPDIR/hosts" | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' > "$TMPDIR/blocklist.conf"; then
    echo "Could not prepare blocklist for Unbound"
    exit 1
fi

if ! mv "$TMPDIR/blocklist.conf" "$BLOCKLIST_LOCATION"; then
    echo "Could not move block list to desired location"
    exit 1
fi

if ! unbound-checkconf; then
    echo "Unbound configuration file is not valid"
    exit 1
fi

if ! /etc/rc.d/unbound reload; then
    echo "Could not reload Unbound"
    exit 1
fi
