RT-CyberShield
===============

Protecting Red Team infrastructure with cyber shield. This simple bash script will block known ranges for cloud providers and some security vendors.

## Prerequisites for Debian/Ubuntu based installations
The script will aim to setup everything for you including installation of appropriate libraries. It can also be done manually:
 
```
apt-get install -y ipset iptables curl fontconfig libfontconfig
```

## Installation
```
git clone https://github.com/op7ic/RT-CyberShield.git
chmod +x shieldme.sh
./shieldme.sh
```

## [shieldme.sh](shieldme.sh) filter rules

The following providers/IP ranges are currently blocked:

- Digital Ocean
- IBM
- Rackspace
- Verizon
- Cisco
- Symantec
- ForcePoint
- Palo Alto
- L3
- AWS
- TOR exit nodes
- Azure
- Cloudflare
- Avast
- Bitdefender
- Fireeye
- Fortinet
- Kaspersky
- ESET
- McAfee
- Sophos

## Cron job

In order to auto-update the blocks, copy the following code into /etc/cron.d/update-cybershield. Don't update the list too often or some providers will ban your IP address. Once a week should be sufficient. 
```
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
0 0 * * 0      root /tmp/RT-CyberShield/shieldme.sh
```

## Check for dropped packets
Using iptables, you can check how many packets got dropped using the filters:
```
iptables -L INPUT -v --line-numbers
```

## Modify the blacklists you want to use

Edit [shieldme.sh](shieldme.sh) and add/remove specific lists. You can see URLs which this script feeds from. Simply modify them or comment them out.
If you for some reason want to ban all IP addresses from a certain country, have a look at [IPverse.net's](http://ipverse.net/ipblocks/data/countries/) aggregated IP lists which you can simply add to the list already implemented. 