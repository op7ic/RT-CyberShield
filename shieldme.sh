#!/bin/bash
# This script should be deployed on your red team infrastructure to protect from blue team investigation
# Tested on Debian/CentOS
# Author: Jerzy 'Yuri' Kramarz (op7ic) 
# Version: 1.1
# Homepage: https://github.com/op7ic/RT-CyberShield
echo ===== Updating box, downloading prerequisites and setting up base folder  =====
if VERB="$( which apt-get )" 1> /dev/null 2> /dev/null; then
   apt-get -y update 1> /dev/null 2> /dev/null
   apt-get install -y ipset iptables curl bzip2 1> /dev/null 2> /dev/null
elif VERB="$( which yum )" 1> /dev/null 2> /dev/null; then
   yum -y update 1> /dev/null 2> /dev/null
   yum -y install ipset iptables curl bzip2 1> /dev/null 2> /dev/null
fi

TEMP_FOLDER_DATE=`date +%d"-"%m"-"%Y`
OUTPUT_DIR="rt-shield-${TEMP_FOLDER_DATE}"
echo [+] Creating Temp Directory $OUTPUT_DIR
mkdir $OUTPUT_DIR

# Basic array to store names of security vendors
providers=("digitalocean" "symantec" "ibm" "rackspace" "verizon" "cisco" "forcepoint" "paloalto" "barracuda" "avast" "bitdefender" "ESET" "FireEye" "fortinet" "kaspersky" "McAfee" "Sophos" "OVH" "WatchGuard" "Webroot" "Microsoft" "splunk" "rapid7" "raytheon" "mimecast" "lockheed" "accenture" "kpmg" "bae" "fsecure" "trendmicro" "eSentire" "alibaba" "hornetsecurity" "InteliSecure" "Masergy" "NTTSecurity" "checkpoint" "atos" "CGI" "DELL" "TCS" "Unisys" "CrowdStrike" "VMware" "Broadcom" "BlackBerry" "Cynet" "RSA" "cylance" "gdata" "virus")

# Basic array to store details related to cloud and tor
declare -A cloudtor
cloudtor[tor1]="https://check.torproject.org/exit-addresses"
cloudtor[tor2]="https://www.dan.me.uk/torlist/"
cloudtor[tor3]="https://raw.githubusercontent.com/SecOps-Institute/Tor-IP-Addresses/master/tor-exit-nodes.lst"
cloudtor[tor4]="https://raw.githubusercontent.com/SecOps-Institute/Tor-IP-Addresses/master/tor-nodes.lst"
cloudtor[aws]="https://ip-ranges.amazonaws.com/ip-ranges.json"
cloudtor[azure]="https://download.microsoft.com/download/7/1/D/71D86715-5596-4529-9B13-DA13A5DE5B63/ServiceTags_Public_20220530.json"
cloudtor[cloudflare]="https://www.cloudflare.com/ips-v4"
cloudtor[cloudflateip6]="https://www.cloudflare.com/ips-v6"
cloudtor[GCP]="https://www.gstatic.com/ipranges/cloud.json"
cloudtor[google]="https://www.gstatic.com/ipranges/goog.json"
cloudtor[akamai]="https://raw.githubusercontent.com/SecOps-Institute/Akamai-ASN-and-IPs-List/master/akamai_ip_cidr_blocks.lst"
cloudtor[twitter]="https://raw.githubusercontent.com/SecOps-Institute/TwitterIPLists/master/twitter_ipv4_cidr_blocks.lst"
cloudtor[oracle]="https://docs.oracle.com/en-us/iaas/tools/public_ip_ranges.json"
cloudtor[o365]="https://docs.microsoft.com/en-us/microsoft-365/enterprise/urls-and-ip-address-ranges?view=o365-worldwide"

echo ===== Downloading IP blocks from rest.db.ripe.net =====
for i in "${!providers[@]}"
  do
  echo [+] Downloading IPs for current address range for "${providers[$i]}". Extracting both IPv4 and IPv6
  outputvar=$(curl -s -L -A "Mozilla/5.0 (Windows NT x.y; rv:10.0) Gecko/20100101 Firefox/10.0" "https://rest.db.ripe.net/search?source=ripe&query-string=${providers[$i]}&flags=no-filtering&flags=no-referenced&showDetails=true&showARIN=false&ext=netref2")
  echo $outputvar | grep "inetnum" | grep "locator" | grep -e "\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\} \- \([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}"  -o | awk -F " - " '{print $1"-"$2}'| sort | uniq > $OUTPUT_DIR/${providers[$i]}.ipv4.txt 2> /dev/null
  echo $outputvar | grep -E "((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:)))(%.+)?s*(\/(12[0-8]|1[0-1][0-9]|[1-9][0-9]|[0-9]))" -o | sort | uniq > $OUTPUT_DIR/${providers[$i]}.ipv6.txt 2> /dev/null 
done

echo ===== Downloading IP blocks from whois.arin.net =====
for i in "${!providers[@]}"
  do
  echo [+] Downloading IPs for current address range for "${providers[$i]}". Extracting IPv4
  outputvar=$(curl -s -L -A "Mozilla/5.0 (Windows NT x.y; rv:10.0) Gecko/20100101 Firefox/10.0" "https://whois.arin.net/rest/org/${providers[$i]}/nets")
  echo $outputvar | grep -e "endAddress=\"\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}\"[[:space:]]startAddress=\"\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}" -o | awk -F "\"" '{print $4"-"$2}' >>  $OUTPUT_DIR/${providers[$i]}.ipv4.txt 2> /dev/null
done

echo ===== Downloading IP blocks for cloud and TOR  networks =====
for i in "${!cloudtor[@]}"
  do
  echo [+] Downloading IPs for current $i blocklist from "${cloudtor[$i]}". Extracting both IPv4 and IPv6
  cloudtorout=$(curl -s -L -A "Mozilla/5.0 (Windows NT x.y; rv:10.0) Gecko/20100101 Firefox/10.0" ${cloudtor[$i]})
  echo $cloudtorout | grep -o -E '([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?' | grep -v "127\.0\.0\.1" | sort | uniq > $OUTPUT_DIR/$i.ipv4.txt 2> /dev/null
  echo $cloudtorout | grep -E "((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:)))(%.+)?s*(\/(12[0-8]|1[0-1][0-9]|[1-9][0-9]|[0-9]))" -o | sort | uniq > $OUTPUT_DIR/$i.ipv6.txt 2> /dev/null
done


echo ===== Removing empty files =====
for REMOVELIST in `find $OUTPUT_DIR/ -size 0`
do
    rm -rf $REMOVELIST 2> /dev/null
done

echo ===== Setting up IPv4 blocks =====
for z in "${!providers[@]}"
  do
   if [[ -f $OUTPUT_DIR/${providers[$z]}.ipv4.txt ]]; then
     echo [+] Setting up blocks for ${providers[$z]}
     ipset create ${providers[$z]} hash:net hashsize 32768 maxelem 999999999 family inet 2> /dev/null || ipset flush ${providers[$z]} 2> /dev/null
     while read line; do ipset -exist add ${providers[$z]} $line; done < $OUTPUT_DIR/${providers[$z]}.ipv4.txt 2>/dev/null
     iptables -C INPUT -m set --match-set ${providers[$z]} src -j DROP 2>/dev/null || iptables -I INPUT -m set --match-set ${providers[$z]} src -j DROP 2>/dev/null
   fi
done

for z in "${!cloudtor[@]}"
  do
   if [[ -f $OUTPUT_DIR/$z.ipv4.txt ]]; then
     echo [+] Setting up blocks for $z
     ipset create $z hash:net hashsize 32768 maxelem 999999999 family inet 2> /dev/null || ipset flush $z 2> /dev/null
     while read line; do ipset -exist add $z $line; done < $OUTPUT_DIR/$z.ipv4.txt 2>/dev/null
     iptables -C INPUT -m set --match-set $z src -j DROP 2>/dev/null || iptables -I INPUT -m set --match-set $z src -j DROP 2>/dev/null
   fi
done

echo ===== Setting up IPv6 blocks =====
for z in "${!providers[@]}"
  do
   if [[ -f $OUTPUT_DIR/${providers[$z]}.ipv6.txt ]]; then
     echo [+] Setting up IPv6 blocks for ${providers[$z]}
     ipset create "${providers[$z]}_ip6" hash:net hashsize 32768 maxelem 999999999 family inet6 2> /dev/null || ipset flush "${providers[$z]}_ip6" 2> /dev/null
     while read line; do ipset -exist add "${providers[$z]}_ip6" $line; done < $OUTPUT_DIR/${providers[$z]}.ipv6.txt 2>/dev/null
     ip6tables -C INPUT -m set --match-set "${providers[$z]}_ip6" src -j DROP 2>/dev/null || ip6tables -I INPUT -m set --match-set "${providers[$z]}_ip6" src -j DROP 2>/dev/null
   fi
done

for z in "${!cloudtor[@]}" 
  do
   if [[ -f $OUTPUT_DIR/$z.ipv6.txt ]]; then
     echo [+] Setting up IPv6 blocks for $z
     ipset create "$z_ip6" hash:net hashsize 32768 maxelem 999999999 family inet6 2> /dev/null || ipset flush "$z_ip6" 2> /dev/null
     while read line; do ipset -exist add "$z_ip6" $line; done < $OUTPUT_DIR/$z.ipv6.txt 2>/dev/null
     ip6tables -C INPUT -m set --match-set "$z_ip6" src -j DROP 2>/dev/null || ip6tables -I INPUT -m set --match-set "$z_ip6" src -j DROP 2>/dev/null
   fi
done

echo [+] Full list of blocked ranges is in `pwd`/RT-CyberShield-blocked-ranges.txt
ipset list > RT-CyberShield-blocked-ranges.txt
echo [+] Saving full firewall block list to /etc/ipset.conf
ipset save > /etc/ipset.conf

echo ===== Generating NGINX block file - based on GEO module =====
echo "[!] Note that separate installation of libnginx-mod-http-geoip is required"
ipset list | grep "/" > `pwd`/ipset_ip_extract.txt
echo "geo \$redblock {" > `pwd`/ngix_block.conf
while read line; do
echo "$line  0;" >> `pwd`/ngix_block.conf;
done < `pwd`/ipset_ip_extract.txt
echo "}" >> `pwd`/ngix_block.conf;
echo "server {" >> `pwd`/ngix_block.conf;
echo "if (\$redblock) {" >> `pwd`/ngix_block.conf;
echo " rewrite ^ http://www.google.com/;" >> `pwd`/ngix_block.conf;
echo " }" >> `pwd`/ngix_block.conf;
echo "}" >> `pwd`/ngix_block.conf;
echo [+] NGINX block list can be found in `pwd`/ngix_block.conf
echo [+] Move `pwd`/ngix_block.conf to /etc/nginx/conf.d/ folder and restart nginx

echo ===== Generating Apache mod_rewrite .htaccess =====
echo "[!] Note that you need to enable rewrite with a2enmod rewrite and restart apache server"
touch `pwd`/mod_rewrite.htaccess
echo "RewriteEngine On" >> `pwd`/mod_rewrite.htaccess;
while read line; do
echo "RewriteCond expr \"-R '$line'\"" >> `pwd`/mod_rewrite.htaccess;
done < `pwd`/ipset_ip_extract.txt
echo "RewriteRule ^/(.*)?$ http://www.google.com/$1 [R=301,NC,NE,L]" >> `pwd`/mod_rewrite.htaccess;
echo [+] Apache mod_rewrite block list can be found in `pwd`/mod_rewrite.htaccess;
echo [+] Please remember to enable rewrite in global apache config by adding AllowOverride All to directory you are protecting.

echo ===== Cleanup =====
rm -rf $OUTPUT_DIR
rm -rf `pwd`/ipset_ip_extract.txt

