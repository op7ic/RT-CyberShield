RT-CyberShield
===============

Protecting Red Team infrastructure with red cyber shield. This simple bash script will block known ranges for cloud providers and some security vendors.

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
- OVH
- WatchGuard
- Webroot
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
```

The table should look similar to this: 

```
Chain INPUT (policy ACCEPT 69 packets, 4328 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1        0     0 DROP       all  --  any    any     anywhere             anywhere             match-set Microsoft src
2        0     0 DROP       all  --  any    any     anywhere             anywhere             match-set Webroot src
3        0     0 DROP       all  --  any    any     anywhere             anywhere             match-set WatchGuard src
4        8   480 DROP       all  --  any    any     anywhere             anywhere             match-set OVH src
5        0     0 DROP       all  --  any    any     anywhere             anywhere             match-set McAfee src
6        0     0 DROP       all  --  any    any     anywhere             anywhere             match-set Sophos src
7        0     0 DROP       all  --  any    any     anywhere             anywhere             match-set ESET src
8        0     0 DROP       all  --  any    any     anywhere             anywhere             match-set kaspersky src
9        0     0 DROP       all  --  any    any     anywhere             anywhere             match-set fortinet src
10       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set fireeye src
11       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set bitdefender src
12       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set avast src
13       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set l3 src
14       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set barracuda src
15       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set paloalto src
16       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set forcepoint src
17       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set symantec src
18       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set rackspace src
19       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set verizon src
20       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set cisco src
21       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set cloudflare6 src
22       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set cloudflare4 src
23       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set azure src
24       1    76 DROP       all  --  any    any     anywhere             anywhere             match-set digitalocean src
25       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set ibm src
26       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set aws src
27       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set tor-individual-ip2 src
28       0     0 DROP       all  --  any    any     anywhere             anywhere             match-set tor-individual-ip1 src

```

## Modify the blacklists you want to use

Edit [shieldme.sh](shieldme.sh) and add/remove specific lists. You can see URLs which this script feeds from. Simply modify them or comment them out.
If you for some reason want to ban all IP addresses from a certain country, have a look at [IPverse.net's](http://ipverse.net/ipblocks/data/countries/) aggregated IP lists which you can simply add to the list already implemented. 

## I don't want to run this script

IP blocks do not change that often so just copy [ipset.conf](ipset-config/ipset.conf) to your local copy: 
```
cp ipset-config/ipset.conf /etc/ipset.conf
```
You will then need to run following commands to ensure that ranges are dropped via iptables: 
```
iptables -I INPUT -m set --match-set tor-individual-ip1 src -j DROP
iptables -I INPUT -m set --match-set tor-individual-ip2 src -j DROP
iptables -I INPUT -m set --match-set aws src -j DROP
iptables -I INPUT -m set --match-set ibm src -j DROP
iptables -I INPUT -m set --match-set digitalocean src -j DROP
iptables -I INPUT -m set --match-set azure src -j DROP
iptables -I INPUT -m set --match-set cloudflare4 src -j DROP
iptables -I INPUT -m set --match-set cloudflare6 src -j DROP
iptables -I INPUT -m set --match-set cisco src -j DROP
iptables -I INPUT -m set --match-set verizon src -j DROP
iptables -I INPUT -m set --match-set rackspace src -j DROP
iptables -I INPUT -m set --match-set symantec src -j DROP
iptables -I INPUT -m set --match-set forcepoint src -j DROP
iptables -I INPUT -m set --match-set paloalto src -j DROP
iptables -I INPUT -m set --match-set barracuda src -j DROP
iptables -I INPUT -m set --match-set l3 src -j DROP
iptables -I INPUT -m set --match-set avast src -j DROP
iptables -I INPUT -m set --match-set bitdefender src -j DROP
iptables -I INPUT -m set --match-set fireeye src -j DROP
iptables -I INPUT -m set --match-set fortinet src -j DROP
iptables -I INPUT -m set --match-set kaspersky src -j DROP
iptables -I INPUT -m set --match-set ESET src -j DROP
iptables -I INPUT -m set --match-set Sophos src -j DROP
iptables -I INPUT -m set --match-set McAfee src -j DROP
iptables -I INPUT -m set --match-set OVH src -j DROP
iptables -I INPUT -m set --match-set WatchGuard src -j DROP
iptables -I INPUT -m set --match-set Webroot src -j DROP
iptables -I INPUT -m set --match-set Microsoft src -j DROP
```

## Limitations

- Ipset doesn't like ipv6 ranges (WIP)
- This script relies heavily on https://bgp.he.net portal.
- If you have VPS-To-VPS communication (i.e. Cobalt Strike to Fronting Server on OVH) the range might get blocked. Be careful where/how you set this script up or comment out specific ranges from config file
- The script relies on precomipled version of phantomjs
- Need some "for" loops in there. Its very crude script for now.