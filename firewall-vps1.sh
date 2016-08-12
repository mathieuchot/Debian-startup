#!/usr/bin/env bash

### BEGIN INIT INFO
# Provides: 			iptables-rules
# Required-Start:		$remote_fs $syslog
# Required-Stop:		$remote_fs $syslog
# Default-Start: 		2 3 4 5
# Default-Stop:
# Short-Description:		SCALEWAY VPS BASIC FIREWALL RULES
### END INIT INFO

# exit if error code !=0 
set -e

# Init
INTERNET=$(ip route | grep default | cut -d " " -f 5)
# /usr/local/bin/oc-metadata | grep VOLUMES_0_EXPORT_URI | awk -F "/|:" '{print $4}'
REMOTEHD=$(/usr/local/bin/oc-metadata | grep VOLUMES_0_EXPORT_URI | cut -d ":" -f "2" | cut -d "/" -f "3")

echo $REMOTEHD
echo $INTERNET
enable_iptable() {
	iptables -P OUTPUT ACCEPT 
	iptables -P FORWARD DROP
	
	#---------------INPUT---------------#
	iptables -A INPUT -p tcp ! --dport ssh -j LOG  --log-prefix "INPUT" 
	iptables -A INPUT -i lo -j ACCEPT
	#allow connection to the SSD on the network 
	iptables -A INPUT -i $INTERNET -s $REMOTEHD -j ACCEPT
	
	iptables -A INPUT -i $INTERNET -p udp --dport 53 -j ACCEPT
	iptables -A INPUT -i $INTERNET -p tcp -m multiport --dports 80,22,443,43900,8000 -j ACCEPT
	iptables -A INPUT -m conntrack --ctstate NEW,RELATED,ESTABLISHED -j ACCEPT
	iptables -A INPUT -i $INTERNET -p icmp --icmp-type echo-reply -j ACCEPT
	#DROP after because there's no auto reco to the disk if we drop before allowing REMOTEHD
	iptables -P INPUT DROP
	#---------------OUTPUT--------------#
	iptables -A OUTPUT -p tcp ! --sport ssh -j LOG --log-prefix "OUTPUT" 
	
}


disable_iptable() {
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT
	
	iptables -F INPUT
	iptables -F OUTPUT
	iptables -F FORWARD 
	iptables -t nat -F POSTROUTING
	iptables -t nat -F PREROUTING
}

case "$1" in
	start)
		enable_iptable ;;
	stop)
		disable_iptable ;;
	reload)
		disable_iptable
		enable_iptable
		;;
	status)
		watch 'iptables -vnL --line-numbers'
		;;
	*)
		echo "Usage: /etc/init.d/firewall.sh {start|stop|regle|reload|status}"
		exit 1
esac

exit 0
