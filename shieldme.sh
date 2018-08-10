#!/bin/bash
# This script should be deployed on your red team infrastructure to protect you from these pesky blue teams
# Tested on Debian


if [ -f /etc/redhat-release ]; then
  yum -y update
  yum -y install ipset iptables curl fontconfig libfontconfig
fi

if [ -f /etc/lsb-release ]; then
  apt-get -y update
  apt-get install -y ipset iptables curl fontconfig libfontconfig
fi

echo [+] Dropping script for phantomjs

cat >> 7.js << EOF
var page = require('webpage').create();
var system = require('system'); 
url = system.args[1] 
page.settings.loadImages = false;
page.settings.userAgent = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7';
page.open(url, function(status) {
    if (status === "success") {
        setTimeout(function() {
            console.log(page.content);
            phantom.exit();
        },10000);
    }
});
EOF

echo [+] Unpacking phantomjs distribution

MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  echo [+] unpacking phantomjs x64
  tar xvjf phantomjs/phantomjs-2.1.1-linux-x86_64.tar.bz2
  
  echo [+] downloading blocks for digital ocean addresses from https://bgp.he.net/search?search[search]=digitalocean&commit=Search
  phantomjs-2.1.1-linux-x86_64/bin/phantomjs 7.js "https://bgp.he.net/search?search[search]=digitalocean&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > digitalocean.txt
  
  echo [+] downloading blocks for IBM addresses from https://bgp.he.net/search?search[search]=IBM&commit=Search
  phantomjs-2.1.1-linux-x86_64/bin/phantomjs 7.js "https://bgp.he.net/search?search[search]=IBM&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > ibm.txt
  
  echo [+] downloading blocks for rackspace addresses https://bgp.he.net/search?search%5Bsearch%5D=rackspace+&commit=Search
  phantomjs-2.1.1-linux-x86_64/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=rackspace+&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > rackspace.txt
  
  echo [+] downloading blocks for verizon addresses https://bgp.he.net/search?search%5Bsearch%5D=verizon&commit=Search
  phantomjs-2.1.1-linux-x86_64/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=verizon&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > verizon.txt
  
  echo [+] downloading blocks for cisco addresses https://bgp.he.net/search?search%5Bsearch%5D=cisco&commit=Search
  phantomjs-2.1.1-linux-x86_64/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=cisco&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > cisco.txt
  
  echo [+] downloading blocks for symantec addresses https://bgp.he.net/search?search%5Bsearch%5D=symantec&commit=Search
  phantomjs-2.1.1-linux-x86_64/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=symantec&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > symantec.txt
  
  echo [+] downloading blocks for forcepoint addresses https://bgp.he.net/search?search%5Bsearch%5D=ForcePoint&commit=Search
  phantomjs-2.1.1-linux-x86_64/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=ForcePoint&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > forcepoint.txt
  
  echo [+] downloading blocks for paloalto addresses https://bgp.he.net/search?search%5Bsearch%5D=%09Palo+Alto+Networks&commit=Search
  phantomjs-2.1.1-linux-x86_64/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=%09Palo+Alto+Networks&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > paloalto.txt
  
  echo [+] downloading blocks for paloalto addresses https://bgp.he.net/search?search%5Bsearch%5D=Barracuda&commit=Search
  phantomjs-2.1.1-linux-x86_64/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=Barracuda&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > barracuda.txt
  
  echo [+] downloading blocks for L3 addresses https://bgp.he.net/search?search%5Bsearch%5D=Level+3+Parent&commit=Search
  phantomjs-2.1.1-linux-x86_64/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=Level+3+Parent&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > l3.txt
  
  echo [+] removing phantomjs folder
  rm -rf phantomjs-2.1.1-linux-x86_64
else
  echo [+] unpacking phantomjs x86
  tar xvjf phantomjs/phantomjs-2.1.1-linux-i686.tar.bz2
  
  echo [+] downloading blocks for digital ocean addresses from https://bgp.he.net/search?search[search]=digitalocean&commit=Search
  phantomjs-2.1.1-linux-i686/bin/phantomjs 7.js "https://bgp.he.net/search?search[search]=digitalocean&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > digitalocean.txt
  
  echo [+] downloading blocks for IBM addresses from https://bgp.he.net/search?search[search]=IBM&commit=Search
  phantomjs-2.1.1-linux-i686/bin/phantomjs 7.js "https://bgp.he.net/search?search[search]=IBM&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > ibm.txt
  
  echo [+] downloading blocks for rackspace addresses https://bgp.he.net/search?search%5Bsearch%5D=rackspace+&commit=Search
  phantomjs-2.1.1-linux-i686/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=rackspace+&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > rackspace.txt
  
  echo [+] downloading blocks for verizon addresses https://bgp.he.net/search?search%5Bsearch%5D=verizon&commit=Search
  phantomjs-2.1.1-linux-i686/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=verizon&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > verizon.txt
  
  echo [+] downloading blocks for cisco addresses https://bgp.he.net/search?search%5Bsearch%5D=cisco&commit=Search
  phantomjs-2.1.1-linux-i686/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=cisco&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > cisco.txt
  
  echo [+] downloading blocks for symantec addresses https://bgp.he.net/search?search%5Bsearch%5D=symantec&commit=Search
  phantomjs-2.1.1-linux-i686/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=symantec&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > symantec.txt
  
  echo [+] downloading blocks for forcepoint addresses https://bgp.he.net/search?search%5Bsearch%5D=ForcePoint&commit=Search
  phantomjs-2.1.1-linux-i686/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=ForcePoint&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > forcepoint.txt
  
  echo [+] downloading blocks for paloalto addresses https://bgp.he.net/search?search%5Bsearch%5D=%09Palo+Alto+Networks&commit=Search
  phantomjs-2.1.1-linux-i686/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=%09Palo+Alto+Networks&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > paloalto.txt
  
  echo [+] downloading blocks for paloalto addresses https://bgp.he.net/search?search%5Bsearch%5D=Barracuda&commit=Search
  phantomjs-2.1.1-linux-i686/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=Barracuda&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > barracuda.txt
  
  echo [+] downloading blocks for L3 addresses https://bgp.he.net/search?search%5Bsearch%5D=Level+3+Parent&commit=Search
  phantomjs-2.1.1-linux-i686/bin/phantomjs 7.js "https://bgp.he.net/search?search%5Bsearch%5D=Level+3+Parent&commit=Search" | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > l3.txt
  
  echo [+] removing phantomjs folder
  rm -rf phantomjs-2.1.1-linux-i686
fi


echo [+] downloading IPs for current tor exit node addresses from https://check.torproject.org/exit-addresses
curl https://check.torproject.org/exit-addresses | grep ExitAddress | awk '{print $2}' | sort | uniq > tor_current_nodes.txt

echo [+] downloading IPs for tor exit node addresses from https://www.dan.me.uk/torlist/
curl https://www.dan.me.uk/torlist/ | sort | uniq > tor_current_nodes_torlist.txt

echo [+] downloading blocks for AWS from https://ip-ranges.amazonaws.com/ip-ranges.json
curl https://ip-ranges.amazonaws.com/ip-ranges.json | grep ip_prefix | awk -F ":" '{print $2}' | sed 's/"//' | sed 's/",//' | sed "s/^[ \t]*//" > aws_ranges.txt

echo [+] downloading blocks for azure from https://download.microsoft.com/download/0/1/8/018E208D-54F8-44CD-AA26-CD7BC9524A8C/PublicIPs_20180806.xml
curl https://download.microsoft.com/download/0/1/8/018E208D-54F8-44CD-AA26-CD7BC9524A8C/PublicIPs_20180806.xml | awk -F "Subnet=" '{print $2}' | sed 's/"//' | sed 's/",//' | sed "s/^[ \t]*//" | sed 's/"//' | sed 's/\/>//' > azure.txt

echo [+] downloading blocks for cloudflare ipv4 from https://www.cloudflare.com/ips-v4
curl https://www.cloudflare.com/ips-v4 > cloudflare-ip4.txt

echo [+] downloading blocks for cloudflare ipv6 from https://www.cloudflare.com/ips-v6
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

ipset create cisco hash:net
while read line; do ipset add cisco $line; done < cisco.txt
iptables -I INPUT -m set --match-set cisco src -j DROP

ipset create verizon hash:net
while read line; do ipset add verizon $line; done < verizon.txt
iptables -I INPUT -m set --match-set verizon src -j DROP

ipset create rackspace hash:net
while read line; do ipset add rackspace $line; done < rackspace.txt
iptables -I INPUT -m set --match-set rackspace src -j DROP

ipset create symantec hash:net
while read line; do ipset add symantec $line; done < symantec.txt
iptables -I INPUT -m set --match-set symantec src -j DROP

ipset create forcepoint hash:net
while read line; do ipset add forcepoint $line; done < forcepoint.txt
iptables -I INPUT -m set --match-set forcepoint src -j DROP

ipset create paloalto hash:net
while read line; do ipset add paloalto $line; done < paloalto.txt
iptables -I INPUT -m set --match-set paloalto src -j DROP

ipset create barracuda hash:net
while read line; do ipset add barracuda $line; done < barracuda.txt
iptables -I INPUT -m set --match-set barracuda src -j DROP

ipset create l3 hash:net
while read line; do ipset add l3 $line; done < l3.txt
iptables -I INPUT -m set --match-set l3 src -j DROP

rm -f tor_current_nodes.txt
rm -f tor_current_nodes_torlist.txt
rm -f aws_ranges.txt
rm -f ibm.txt
rm -f digitalocean.txt
rm -f azure.txt
rm -f cloudflare-ip6.txt
rm -f cloudflare-ip4.txt
rm -f rackspace.txt
rm -f verizon.txt
rm -f cisco.txt
rm -f symantec.txt
rm -f forcepoint.txt
rm -f paloalto.txt
rm -f barracuda.txt
rm -f l3.txt
rm -f 7.js

echo [+] saving full output
ipset save > /etc/ipset.conf

echo [+] Here is your full block list:
ipset list

#toadd:
#https://bgp.he.net/search?search%5Bsearch%5D=ovh&commit=Search
