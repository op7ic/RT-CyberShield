#!/bin/bash
# This script should be deployed on your red team infrastructure to protect you from these pesky blue teams
# Tested on Debian/Centos
# author: op7ic

# do installation based on which package manager is available.
if VERB="$( which apt-get )" 2> /dev/null; then
   apt-get -y update
   apt-get install -y ipset iptables curl fontconfig libfontconfig
elif VERB="$( which yum )" 2> /dev/null; then
   yum -y update
   yum -y install ipset iptables curl fontconfig libfontconfig bzip2
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



declare -A array
array[digitalocean]="https://bgp.he.net/search?search[search]=digitalocean&commit=Search"
array[symantec]="https://bgp.he.net/search?search[search]=symantec&commit=Search"
array[ibm]="https://bgp.he.net/search?search[search]=IBM&commit=Search"
array[rackspace]="https://bgp.he.net/search?search%5Bsearch%5D=rackspace+&commit=Search"
array[verizon]="https://bgp.he.net/search?search%5Bsearch%5D=verizon&commit=Search"
array[cisco]="https://bgp.he.net/search?search%5Bsearch%5D=cisco&commit=Search"
array[forcepoint]="https://bgp.he.net/search?search%5Bsearch%5D=ForcePoint&commit=Search"
array[paloalto]="https://bgp.he.net/search?search%5Bsearch%5D=%09Palo+Alto+Networks&commit=Search"
array[barracuda]="https://bgp.he.net/search?search%5Bsearch%5D=Barracuda&commit=Search"
array[l3]="https://bgp.he.net/search?search%5Bsearch%5D=Level+3+Parent&commit=Search"
array[avast]="https://bgp.he.net/search?search%5Bsearch%5D=Avast&commit=Search"
array[bitdefender]="https://bgp.he.net/search?search%5Bsearch%5D=Bitdefender&commit=Search"
array[ESET]="https://bgp.he.net/search?search%5Bsearch%5D=ESET&commit=Search"
array[fireeye]="https://bgp.he.net/search?search%5Bsearch%5D=FireEye&commit=Search"
array[fortinet]="https://bgp.he.net/search?search%5Bsearch%5D=Fortinet&commit=Search" 
array[kaspersky]="https://bgp.he.net/search?search%5Bsearch%5D=Kaspersky&commit=Search"
array[McAfee]="https://bgp.he.net/search?search%5Bsearch%5D=McAfee&commit=Search"
array[Sophos]="https://bgp.he.net/search?search%5Bsearch%5D=Sophos&commit=Search"
array[OVH]="https://bgp.he.net/search?search%5Bsearch%5D=OVH&commit=Search"
array[WatchGuard]="https://bgp.he.net/search?search%5Bsearch%5D=WatchGuard&commit=Search"
array[Webroot]="https://bgp.he.net/search?search%5Bsearch%5D=Webroot&commit=Search"
array[Microsoft]="https://bgp.he.net/search?search%5Bsearch%5D=Microsoft&commit=Search"
array[splunk]="https://bgp.he.net/search?search%5Bsearch%5D=splunk&commit=Search"
array[rapid7]="https://bgp.he.net/search?search%5Bsearch%5D=rapid7&commit=Search"
array[raytheon]="https://bgp.he.net/search?search%5Bsearch%5D=Raytheon&commit=Search"
array[mimecast]="https://bgp.he.net/search?search%5Bsearch%5D=Mimecast+&commit=Search"
array[lockheed]="https://bgp.he.net/search?search%5Bsearch%5D=Lockheed&commit=Search"
array[accenture]="https://bgp.he.net/search?search%5Bsearch%5D=accenture&commit=Search"
array[kpmg]="https://bgp.he.net/search?search%5Bsearch%5D=kpmg&commit=Search"
array[bae]="https://bgp.he.net/search?search[search]=bae&commit=Search"
array[fsecure]="https://bgp.he.net/search?search%5Bsearch%5D=%22F-Secure%22&commit=Search"
array[trendmicro]="https://bgp.he.net/search?search%5Bsearch%5D=%22Trend+Micro%22&commit=Search"
array[ncc]="https://bgp.he.net/search?search%5Bsearch%5D=%22NCC+Services%22&commit=Search"

MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  echo [+] unpacking phantomjs x64
  tar xvjf phantomjs/phantomjs-2.1.1-linux-x86_64.tar.bz2
  
  for i in "${!array[@]}"
  do
    echo [+] downloading blocks for $i addresses from "${array[$i]}"
    phantomjs-2.1.1-linux-x86_64/bin/phantomjs 7.js ${array[$i]} | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > $i.txt
  done

  echo [+] removing phantomjs folder
  rm -rf phantomjs-2.1.1-linux-x86_64
  
else
  echo [+] unpacking phantomjs x86
  tar xvjf phantomjs/phantomjs-2.1.1-linux-i686.tar.bz2
  
  for i in "${!array[@]}"
  do
    echo [+] downloading blocks for $i addresses from "${array[$i]}"
    phantomjs-2.1.1-linux-i686/bin/phantomjs 7.js ${array[$i]} | grep "a href" | grep -v "AS" | grep net | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | grep "/" > $i.txt
  done
  
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

ipset create avast hash:net
while read line; do ipset add avast $line; done < avast.txt
iptables -I INPUT -m set --match-set avast src -j DROP

ipset create bitdefender hash:net
while read line; do ipset add bitdefender $line; done < bitdefender.txt
iptables -I INPUT -m set --match-set bitdefender src -j DROP

ipset create fireeye hash:net
while read line; do ipset add fireeye $line; done < fireeye.txt
iptables -I INPUT -m set --match-set fireeye src -j DROP

ipset create fortinet hash:net
while read line; do ipset add fortinet $line; done < fortinet.txt
iptables -I INPUT -m set --match-set fortinet src -j DROP

ipset create kaspersky hash:net
while read line; do ipset add kaspersky $line; done < kaspersky.txt
iptables -I INPUT -m set --match-set kaspersky src -j DROP

ipset create ESET hash:net
while read line; do ipset add ESET $line; done < ESET.txt
iptables -I INPUT -m set --match-set ESET src -j DROP

ipset create Sophos hash:net
while read line; do ipset add Sophos $line; done < Sophos.txt
iptables -I INPUT -m set --match-set Sophos src -j DROP

ipset create McAfee hash:net
while read line; do ipset add McAfee $line; done < McAfee.txt
iptables -I INPUT -m set --match-set McAfee src -j DROP

ipset create OVH hash:net
while read line; do ipset add OVH $line; done < OVH.txt
iptables -I INPUT -m set --match-set OVH src -j DROP

ipset create WatchGuard hash:net
while read line; do ipset add WatchGuard $line; done < WatchGuard.txt
iptables -I INPUT -m set --match-set WatchGuard src -j DROP

ipset create Webroot hash:net
while read line; do ipset add Webroot $line; done < Webroot.txt
iptables -I INPUT -m set --match-set Webroot src -j DROP

ipset create Microsoft hash:net
while read line; do ipset add Microsoft $line; done < Microsoft.txt
iptables -I INPUT -m set --match-set Microsoft src -j DROP

ipset create Splunk hash:net
while read line; do ipset add Splunk $line; done < splunk.txt
iptables -I INPUT -m set --match-set Splunk src -j DROP

ipset create Rapid7 hash:net
while read line; do ipset add Rapid7 $line; done < rapid7.txt
iptables -I INPUT -m set --match-set Rapid7 src -j DROP

ipset create raytheon hash:net
while read line; do ipset add raytheon $line; done < raytheon.txt
iptables -I INPUT -m set --match-set raytheon src -j DROP

ipset create mimecast hash:net
while read line; do ipset add mimecast $line; done < mimecast.txt
iptables -I INPUT -m set --match-set mimecast src -j DROP

ipset create lockheed hash:net
while read line; do ipset add lockheed $line; done < lockheed.txt
iptables -I INPUT -m set --match-set lockheed src -j DROP

ipset create accenture hash:net
while read line; do ipset add accenture $line; done < accenture.txt
iptables -I INPUT -m set --match-set accenture src -j DROP

ipset create kpmg hash:net
while read line; do ipset add kpmg $line; done < kpmg.txt
iptables -I INPUT -m set --match-set kpmg src -j DROP

ipset create bae hash:net
while read line; do ipset add bae $line; done < bae.txt
iptables -I INPUT -m set --match-set bae src -j DROP

ipset create fsecure hash:net
while read line; do ipset add fsecure $line; done < fsecure.txt
iptables -I INPUT -m set --match-set fsecure src -j DROP

ipset create trendmicro hash:net
while read line; do ipset add trendmicro $line; done < trendmicro.txt
iptables -I INPUT -m set --match-set trendmicro src -j DROP

ipset create ncc hash:net
while read line; do ipset add ncc $line; done < ncc.txt
iptables -I INPUT -m set --match-set ncc src -j DROP

echo [+] removing block lists
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
rm -f avast.txt
rm -f bitdefender.txt
rm -f fireeye.txt
rm -f fortinet.txt
rm -f kaspersky.txt
rm -f ESET.txt
rm -f McAfee.txt
rm -f Sophos.txt
rm -f OVH.txt
rm -f WatchGuard.txt
rm -f Webroot.txt
rm -f Microsoft.txt
rm -f splunk.txt
rm -f rapid7.txt
rm -f raytheon.txt
rm -f mimecast.txt
rm -f lockheed.txt
rm -f accenture.txt
rm -f kpmg.txt
rm -f bae.txt
rm -f fsecure.txt
rm -f trendmicro.txt
rm -f ncc.txt

echo [+] removing phantomjs script
rm -f 7.js

echo [+] saving full output
ipset save > /etc/ipset.conf

echo [+] Full list of blocked ranges is in blockedranges.txt
ipset list > blockedranges.txt

#No this script is not smart ... you could do loops but hey ho