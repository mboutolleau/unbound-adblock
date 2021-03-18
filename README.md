# Block Ads with Unbound

Ads can be efficiently blocked on your network by using a DNS block list. Such block lists contain domain names used to deliver ads and prevent your devices from reaching them.

In addition to blocking ads, this can have several advantages. It may  speed up connections, reduce online tracking and/or exposure to malware.

Several projects and tools aims to the same goals. One of the most popular is [Pi-hole](https://pi-hole.net/). But for this project we are going to use the venerable [Unbound](https://nlnetlabs.nl/projects/unbound/about/). We can find online numerous DNS block list, but [StevenBlack's Unified hosts](https://github.com/StevenBlack/hosts) were chosen for its completeness and flexibility.

## How does it work ?

For example the default [Unified hosts](https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts) contains currently 67,403 entries.

Unbound will answer that all these entries, which are linked to adware or malware, corresponds to the `0.0.0.0` IPv4 address. This IPv4 address is non-routable and designate an invalid target.

The legitimate DNS queries will be answered normally by Unbound following your configuration.

## Dependencies

* Unbound
* Wget

## Usage

*Please note that the script is written to run on OpenBSD.*

1. Use the script to download and prepare the DNS block list for Unbound:
```
# ./download_block list.sh
```
2. Configure Unbound to use your new DNS block list by editing `/var/unbound/etc/unbound.conf`:
```
server:
    ...
    include: /var/unbound/etc/block list.conf
    ...
```

Optionally, one can let the system periodically update the block list using `cron(8)`. For example, to run the script every day, create or modify `/etc/daily.local` :

```
# Update Unbound DNS block list.
# The script needs to be executable by root and located somewhere in the $PATH
download_block list.sh
```

## Acknowledgements

deadc0de, whose blog was the inspiration for this project : https://deadc0de.re/articles/unbound-blocking-ads.html.

## See also

[Block Samsung Smart TV Telemetry](https://github.com/mboutolleau/block-samsung-tv-telemetry) with Unbound.