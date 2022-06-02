RT-CyberShield
===============

Protecting Red Team infrastructure with cyber shield. This simple bash script will block known ranges for cloud providers and some security vendors.

## Prerequisites for Debian/Ubuntu based installations
The script will execute the following to get necessary packages installed:
```
apt-get -y update
apt-get install -y ipset iptables curl fontconfig libfontconfig
```

## Prerequisites for Red Hat/Centos based installations
The script will execute the following to get necessary packages installed:
```
yum -y update
yum -y install ipset iptables curl fontconfig libfontconfig bzip2
```

## Installation
```
git clone https://github.com/op7ic/RT-CyberShield.git
cd RT-CyberShield
chmod +x shieldme.sh
./shieldme.sh
```

## [shieldme.sh](shieldme.sh) filter rules

The following providers, and their IP ranges are used to build a block list:

- Digital Ocean
- IBM
- Rackspace
- Verizon
- Cisco
- Symantec
- ForcePoint
- Palo Alto
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
- OVH
- WatchGuard
- Microsoft
- Rapid7
- Splunk
- Raytheon
- Mimecast
- Lockheed Martin
- Accenture
- KPMG
- BAE Systems
- F-Secure
- Trend Micro
- NCC
- eSentire
- Alibaba
- Hornetsecurity
- InteliSecure
- Masergy
- NTT Security
- Check Point
- Atos 
- CGI
- SecureWorks
- TCS
- Unisys
- BlackBerry
- RSA
- gdata
- Cylance
- Dell
- CrowdStrike
- VMware
- Broadcom
- BlackBerry
- Cynet
- Google
- Microsoft

## CRON job

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
ip6tables -L INPUT -v --line-numbers
```

## Deleting full chain

If you would like to destory the set and all the associated rules, iptables needs to be cleared first, followed by deletion of ipset rules. 
```
# Clean iptables list for IPv4 or delete individual rulesets using -D option for specific rule (i.e. ssh)
iptables --flush

# Clean iptables list for Ipv6 or delete individual rulesets using -D option for specific rule (i.e. ssh)
ip6tables --flush

# Remove all sets from ipset
ipset list | grep Name | awk -F ": " '{print $2}' | xargs -i ipset destroy {}
```

## Protecting NGNIX or Apache

This script will also generate config for NGNIX and Apache that can be used to block web-server level access.

## Modify the blacklists you want to use

Edit [shieldme.sh](shieldme.sh) and add/remove specific lists. You can see URLs which this script feeds from. Simply modify them or comment them out.
If you for some reason want to ban all IP addresses from a certain country, have a look at [IPverse.net's](http://ipverse.net/ipblocks/data/countries/) aggregated IP lists which you can simply add to the list already implemented. 

## Limitations

If you have VPS-To-VPS communication (i.e. Cobalt Strike to Fronting Server on OVH) the range might get blocked. Be careful where/how you set this script up or comment out specific ranges from config file
