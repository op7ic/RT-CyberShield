#!/bin/bash
# This script should be deployed on your red team infrastructure
# Tested on Debian


if [ -f /etc/redhat-release ]; then
  yum -y update
  yum -y install ipset iptables curl
fi

if [ -f /etc/lsb-release ]; then
  apt-get -y update
  apt-get install -y ipset iptables curl
fi

echo [+] downloading IPs for current tor exit node addresses from https://check.torproject.org/exit-addresses
curl https://check.torproject.org/exit-addresses | grep ExitAddress | awk '{print $2}' | sort | uniq > tor_current_nodes.txt

echo [+] downloading IPs for tor exit node addresses from https://www.dan.me.uk/torlist/
curl https://www.dan.me.uk/torlist/ | sort | uniq > tor_current_nodes_torlist.txt

echo [+] downloading blocks for digital ocean addresses from https://bgp.he.net/search?search[search]=digitalocean&commit=Search
 > digitalocean.txt

echo [+] downloading blocks for IBM ocean addresses from https://bgp.he.net/search?search[search]=digitalocean&commit=Search
curl -i -s -k  -X $'GET' -H $'Host: bgp.he.net' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:61.0) Gecko/20100101 Firefox/61.0' -H $'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H $'Accept-Language: en-GB,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'Cookie: c=BAgiEzUxLjE0OC4xMTUuMTc3--fe45cb679a09cd36f00701e9aa751724feaa2212; _bgp_session=BAh7BjoPc2Vzc2lvbl9pZEkiJTA1MzViMWYzZTYzOGM4NGJhNDI0NzI5OTc0OTVmNDcxBjoGRUY%3D--718cf0fc286695ca7ec0dda181f67c3eb14e2328' -H $'DNT: 1' -H $'Connection: close' -H $'Upgrade-Insecure-Requests: 1' -b $'c=BAgiEzUxLjE0OC4xMTUuMTc3--fe45cb679a09cd36f00701e9aa751724feaa2212; _bgp_session=BAh7BjoPc2Vzc2lvbl9pZEkiJTA1MzViMWYzZTYzOGM4NGJhNDI0NzI5OTc0OTVmNDcxBjoGRUY%3D--718cf0fc286695ca7ec0dda181f67c3eb14e2328' $'https://bgp.he.net/search?search[search]=IBM&commit=Search' | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > ibm.txt

echo [+] downloading blocks for AWS from https://ip-ranges.amazonaws.com/ip-ranges.json
curl https://ip-ranges.amazonaws.com/ip-ranges.json | grep ip_prefix | awk -F ":" '{print $2}' | sed 's/"//' | sed 's/",//' | sed "s/^[ \t]*//" > aws_ranges.txt

echo [+] downloading blocks for azure from https://download.microsoft.com/download/0/1/8/018E208D-54F8-44CD-AA26-CD7BC9524A8C/PublicIPs_20180806.xml
curl https://download.microsoft.com/download/0/1/8/018E208D-54F8-44CD-AA26-CD7BC9524A8C/PublicIPs_20180806.xml | awk -F "Subnet=" '{print $2}' | sed 's/"//' | sed 's/",//' | sed "s/^[ \t]*//" | sed 's/"//' | sed 's/\/>//' > azure.txt

echo [+] downloading blocks for cloudflare (ipv4) from https://www.cloudflare.com/ips-v4
curl https://www.cloudflare.com/ips-v4 > cloudflare-ip4.txt

echo [+] downloading blocks for cloudflare (ipv6) from https://www.cloudflare.com/ips-v6
curl https://www.cloudflare.com/ips-v6 > cloudflare-ip6.txt


echo [+] setting up to list blocks

ipset create tor-individual-ip1 hash:ip
while read line; do ipset add tor-individual-ip1 $line; done < tor_current_nodes.txt
iptables -I INPUT -m set --match-set tor-individual-ip1 src -j DROP

ipset create tor-individual-ip2 hash:ip
while read line; do ipset add tor-individual-ip2 $line; done < tor_current_nodes_torlist.txt
iptables -I INPUT -m set --match-set tor-individual-ip2 src -j DROP

ipset create aws hash:net
while read line; do ipset add aws $line; done < aws_ranges.txt
iptables -I INPUT -m set --match-set aws src -j DROP

ipset create ibm hash:net
while read line; do ipset add ibm $line; done < ibm.txt
iptables -I INPUT -m set --match-set ibm src -j DROP

ipset create digitalocean hash:net
while read line; do ipset add digitalocean $line; done < digitalocean.txt
iptables -I INPUT -m set --match-set digitalocean src -j DROP

ipset create azure hash:net
while read line; do ipset add azure $line; done < azure.txt
iptables -I INPUT -m set --match-set azure src -j DROP

ipset create cloudflare4 hash:net
while read line; do ipset add cloudflare4 $line; done < cloudflare-ip4.txt
iptables -I INPUT -m set --match-set cloudflare4 src -j DROP

ipset create cloudflare6 hash:net
while read line; do ipset add cloudflare6 $line; done < cloudflare-ip6.txt
iptables -I INPUT -m set --match-set cloudflare6 src -j DROP

rm -f tor_current_nodes.txt
rm -f tor_current_nodes_torlist.txt
rm -f aws_ranges.txt
rm -f ibm.txt
rm -f digitalocean.txt
rm -f azure.txt
rm -f cloudflare-ip6.txt
rm -f cloudflare-ip4.txt

echo [+] saving full output
ipset save > /etc/ipset.conf

echo [+] Here is your full block list:
ipset list

#toadd:
#https://bgp.he.net/search?search%5Bsearch%5D=cisco&commit=Search
#https://bgp.he.net/search?search%5Bsearch%5D=ovh&commit=Search
#https://bgp.he.net/search?search%5Bsearch%5D=verizon&commit=Search
#https://bgp.he.net/search?search%5Bsearch%5D=rackspace+&commit=Search