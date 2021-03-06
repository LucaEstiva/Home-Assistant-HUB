#!/bin/bash


BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'

NC='\033[0m' # No Color

echo -e "${BLUE}Start making the HUB...${NC}"


#
if [ -z "$1" ]; then
        echo "Specificare l'interfaccia LAN 1 Es: eth0"
        exit 1
else
        LanIF1=$1
        printf 'Interface LAN 1 set to: %s\n' $LanIF1
fi

#
if [ -z "$2" ]; then
        echo "Specificare l'interfaccia WiFi"
        exit 1
else
        WiFiIF=$2
        printf 'Interface WiFi set to: %s\n' $WiFiIF
fi

#
if [ -z "$3" ]; then
        echo "Specificare un nome per l'access point !"
        exit 1
else
        APName=$3
        printf 'Nome nuovo access point: %s\n' $APName
fi

#
if [ -z "$4" ]; then
        echo "Specificare una password per l'access point !"
        exit 1
else
        APPassword=$4
        printf 'Password access point: %s\n' $APPassword
fi

# Check password lenght - Min 8, Max 64
if [ ${#APPassword} -lt 8 ]; then
        echo "La password deve contenere almeno 8 caratteri"
        exit 1
fi

#
sudo apt update
sudo dpkg --configure -a
sudo apt upgrade -y


#
echo -e "${GREEN}Installo pacchetti necessari...${NC}"
#
echo -e "${GREEN}Installo ifupdown...${NC}"
sudo apt install ifupdown
# Installa server dhcp
echo -e "${GREEN}Installo bridge-utils...${NC}"
sudo apt install bridge-utils -y
# 
echo -e "${GREEN}Installo wireless-tools...${NC}"
sudo apt install wireless-tools -y
#
echo -e "${GREEN}Installo hostapd...${NC}"
sudo apt install hostapd -y
# Installa server dhcp
echo -e "${GREEN}Installo isc-dhcp-server...${NC}"
sudo apt install isc-dhcp-server -y



#
echo -e "${GREEN}Rimuovo modemmanger...${NC}"

#
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' modemmanager|grep "install ok installed")
#
if ["" == "$PKG_OK"]; then
  echo "Rimuovo package modemmanager..."
  sudo apt purge modemmanager
fi

#
echo -e "${GREEN}Rimuovo network-manager...${NC}"

#
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' network-manager|grep "install ok installed")
#
if ["" == "$PKG_OK"]; then
  echo "Removing network-manager..."
  sudo apt purge network-manager
fi

#
echo -e "${GREEN}Configuro networking...${NC}"

# Elimina e ricrea il file - vuoto.
if test -f /etc/network/interfaces; then
	# Delete interfaces configuration file
	rm -f /etc/network/interfaces
	# Create a new interfaces configuration file
	touch /etc/network/interfaces
fi

# Copy interfaces configuration to hostapd configuration file
cat <<EOF >/etc/network/interfaces
auto lo
iface lo inet loopback

auto $LanIF1
allow-hotplug $LanIF1
iface $LanIF1 inet manual

auto $WiFiIF
iface $WiFiIF inet static
address 192.168.2.1
netmask 255.255.255.0

auto br0
allow-hotplug br0
iface br0 inet dhcp
bridge_ports $LanIF1
bridge_stp off
bridge_fd 0
bridge_maxwait 0
EOF

#
echo -e "${GREEN}Rimuovo netplan...${NC}"

#
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' netplan|grep "install ok installed")
#
if ["" == "$PKG_OK"]; then
        echo "Rimuovo package netplan..."
        # RIMOZIONE NETPLAN
        sudo systemctl stop systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
        sudo systemctl disable systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
        sudo systemctl mask systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
        #
        sudo apt-get --assume-yes purge nplan netplan.io
fi

# RIMOZIONE UFW

#
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ufw|grep "install ok installed")
#
if ["" == "$PKG_OK"]; then
  echo "Removing network-manager..."
  sudo apt -y purge ufw
fi

#
echo -e "${GREEN}Avvio networking...${NC}"

### DNS

#
echo -e "${GREEN}Configuro DNS...${NC}"

# AGGIUNGERE INDIRIZZI SERVER DNS:
sed -i 's/#DNS=/DNS=8.8.8.8 8.8.4.4/g' /etc/systemd/resolved.conf

### IP-FORWARDING

#
echo -e "${GREEN}Abilito IP FORWARDING...${NC}"

# ABILITARE IP FORWARDING:
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

sudo systemctl restart systemd-resolved

### HOSTAPD

echo -e "${GREEN}Configuro hostapd...${NC}"

# Copy configuration to hostapd configuration file - 5Ghz WiFi Access Point
cat <<EOF >/etc/hostapd/hostapd.conf
interface=$WiFiIF
driver=nl80211
country_code=US
ssid=$APName
hw_mode=a
channel=40
ieee80211n=1
require_ht=1
ht_capab=[HT40-][SHORT-GI-20][SHORT-GI-40][DSSS_CCK-40][MAX-AMSDU-3839]
logger_syslog=-1
wmm_enabled=0
macaddr_acl=0
auth_algs=1
wpa=2
wpa_passphrase=$APPassword
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

#
sed -i 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd


### DHCP SERVER

#
echo -e "${GREEN}Configuro server DHCP...${NC}"

# Modifica configurazione server dhcp in /etc/default/isc-dhcp-server
sed -i 's/INTERFACESv4=""/INTERFACESv4="'"${WiFiIF}"'"/g' /etc/default/isc-dhcp-server

# Verifica se il servizio isc-dhcp-server è in esecuzione:
if test -f /etc/dhcp/dhcpd.conf; then
        # Delete isc dhcp server configuration file
        rm -f /etc/dhcp/dhcpd.conf
        # Create a new isc dhcp server configuration file
        touch /etc/dhcp/dhcpd.conf
fi

# Copia configurazione server dhcp nel file /etc/dhcp/dhcpd.conf
cat << EOF >/etc/dhcp/dhcpd.conf
option domain-name "homeassistant.org";
option domain-name-servers 8.8.8.8, 8.8.4.4;
ddns-update-style none;
authoritative;

subnet 192.168.2.0 netmask 255.255.255.0 {
range 192.168.2.5 192.168.2.250;
option domain-name-servers 8.8.8.8;
option domain-name "homeassistant.org";
option subnet-mask 255.255.255.0;
option routers 192.168.2.1;
option broadcast-address 192.168.2.255;
option ntp-servers 192.186.2.1;
option netbios-name-servers 192.168.2.1;
option netbios-node-type 2;
default-lease-time -1;
max-lease-time -1;
}
EOF

#
echo -e "${YELLOW}Procedura terminata con successo !"
echo -e "Tutti i servizi verranno avviati..."
echo -e "Successivamente l'hub verrà riavviato per rendere attive tutte le mofiche..."
echo -e "Dopo il riavvio sarà possibile consultare il file di log MakeTheHub.log${NC}"
#
read -p "Premere invio per continuare..."

#
echo "Log attivazione servizi..." > MakeTheHub.log

#
echo "Avvio networking..." >> MakeTheHub.log

# Avvio del servizio networking:
sudo systemctl unmask networking
sudo systemctl enable networking
sudo systemctl restart networking.service

# Rinnovo indirizzo IP eth0 dhcp
sudo dhclient -r && sudo dhclient br0


#
if systemctl is-active --quiet networking; then
	echo "Networking service is runnig... OK!"
else
	echo "Networking service is not started. Check for problems and run the script again."
	echo "Script execution terminated !"
	exit 1
fi

#
echo "Avvio hostapd..." >> MakeTheHub.log

# Start hostapd service
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd


# Verifica se il servizio hostapd è in esecuzione:
if systemctl is-active --quiet hostapd; then
	echo "Hostapd service is runnig... OK!" >> MakeTheHub.log
else
	echo "Hostapd service is not started. Check for problems and run the script again." >> MakeTheHub.log
	echo "Script execution terminated !" >> MakeTheHub.log
	exit 1
fi

#
echo "Avvio isc-dhcp-server..." >> MakeTheHub.log

# RIAVVIA SERVER DHCP
sudo systemctl restart isc-dhcp-server

# Verifica se il servizio isc-dhcp-server è in esecuzione:
if systemctl is-active --quiet isc-dhcp-server; then
		echo "isc-dhcp-server service is runnig... OK!" >> MakeTheHub.log
else
	echo "isc-dhcp-server service is not started. Check for problems and run the script again." >> MakeTheHub.log
	echo "Script execution terminated !" >> MakeTheHub.log
        exit 1
fi

#
echo "Aggiungo iptable..." >> MakeTheHub.log
#
sudo iptables -t nat -A POSTROUTING -o br0 -j MASQUERADE

#
echo "Installo iptables-presistent e salvo iptable..." >> MakeTheHub.log

# Installa iptables-presistent e salva route ( iptable - Netfilter )
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections

#
sudo apt -y install iptables-persistent

#
sudo reboot
