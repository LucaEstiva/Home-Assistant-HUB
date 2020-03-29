# Home-Assistant-HUB</br>
# PROCEDURA NON COMPLETA !</br>
</br>

<h1>L'HUB è estremamente importante. Senza di esso non saremo in grado di utilizzare nessun dispositivo nella nostra casa !
</h1></br>
</br>
I dispositivi con firmware Tasmota supportano il FAULT TOLERANCE ( è possibile specificare più di una rete WiFi alla quale connettersi )</br>

# La ridondanza nelle infrastruttue di questo tipo dovrebbe essere fondamentale !</br>
</br>
Un HUB completamente indipendente per Home Assistant personalizzabile al 100%.</br>
</br>
Consente di creare una rete lan DOMOTICA in grado di fornire indirizzi IP a tutti i dispostivi domotici ad esso connessi</br>
e di evitare il routing dei pacchetti ( passaggio dei pacchetti ) attraverso il router che può non essere disponibile.</br>
Inoltre libera il nostro router da flussi di dati ( anche pesanti come gli streaming ) lasciandolo disponibile per i nostri usi.</br>
</br>
Dotato di accesso WiFi ( Access Point AP ).</br>
Può dialogare con una rete MESH.</br>
Necessita di una connessione WAN ( Wide Area Network - Internet ) solo se i dispositivi sono di tipo CLOUD.</br>

# L'HARDWARE</br>
Nel mio caso l'HUB è realizzato con questo PC industriale:</br>

https://www.amazon.it/gp/product/B083SLWMHV/ref=ppx_yo_dt_b_asin_title_o05_s00?ie=UTF8&psc=1</br>

E' stao dotato di:</br>
Crucial CT16G4SFD824A Memoria da 16 GB Dual Rank x 8, DDR4, 2400 MT/s, PC4-19200, SODIMM, 260-Pin</br>
Western Digital WD GREEN SATA SSD Unità allo Stato Solido Interna 2.5" M.2 2280, 120 GB</br>
</br>
La scheda di rete WiFi presente nel PC supporta la modalità MASTER.</br>
</br>
# Prima di continuare è necessario verificare che la scheda di rete del PC scelto supporti la modalità MASTER ( AP ):</br>
# Vedere il file [Master_Mode.txt](Master_Mode.txt)
</br>
</br>
Installare Ubuntu Server scaricando l'immagine ISO da qui:</br>
https://ubuntu.com/download/server</br>

VERSIONE PER PROCESSORI CON ARCHITETTURA AMD64 ( non ARM ) 64Bit</br>
https://ubuntu.com/download/server/thank-you?version=18.04.4&architecture=amd64</br>

Creare un supporto di avvio ( chiavetta USB ) utilizzando BALENAETCHER:</br>
https://www.balena.io/etcher/</br>

Durante l'installazione di Ubuntu abilitare il SERVER SSH.</br>

Usare SUDO ( Super User Do )

Aggiornare la lista dei pacchetti:</br>
sudo apt update</br>

Aggiornare il software:</br>
sudo apt upgrade</br>

Installare i pacchetti necessari:</br>
</br>
sudo apt install bridge-utils</br>
sudo apt install wireless-tools</br>
sudo apt install isc-dhcp-server</br>
sudo apt install hostapd</br>
</br>

-------------------------------------------------------------------------------------------------------</br>
DISABILITARE IL SERVIZIO MODEM MANAGER - Potrebbe influire negativamente con il server Home Assistant...:</br>
-------------------------------------------------------------------------------------------------------</br>
sudo systemctl stop ModemManager</br>
sudo systemctl disable ModemManager</br>

-------------------------------------------------------------------------------------------------------</br>
Rimuovere NETPLAN ( purtroppo crea problemi se vengono utilizzati Hostapd e isc-dhcp-server contemporaneamente )</br>
-------------------------------------------------------------------------------------------------------</br>
sudo apt remove --auto-remove netplan.io</br>
sudo apt purge netplan.io</br>

-------------------------------------------------------------------------------------------------------</br>
Disabilitare la gestione dell'interfaccia di rete WiFi</br>
-------------------------------------------------------------------------------------------------------</br>
Per ottenere il MAC address dell'interfaccia di rete WiFi utilizzare il comando:</br>
ifconfig -a</br>
</br>
sudo nano /etc/NetworkManager/NetworkManager.conf</br>
</br>
[main]</br>
plugins=ifupdown,keyfile</br>
</br>
[ifupdown]</br>
managed=false</br>
</br>
[device]</br>
wifi.scan-rand-mac-address=no</br>
</br>
[keyfile]</br>
\# Sostituire le coppie di 0 con i valori riportati da IFCONFING per l'interfaccia wlp_s0 o wlan</br>
unmanaged-devices=mac:00:00:00:00:00:00</br>
</br>

-------------------------------------------------------------------------------------------------------</br>
Abilitare la scheda di rete WiFi - Hostapd potrebbe non essere in grado di creare correttamente il novo</br>
access point a causa dell'utilizzo della scheda WiFi da parte di un'altro software oppure a causa di</br>
restrizioni applicate al driver della scheda...</br>
-------------------------------------------------------------------------------------------------------</br>
sudo nano /var/lib/NetworkManager/NetworkManager.state</br>
</br>
[main]</br>
NetworkingEnabled=true</br>
WirelessEnabled=true</br>
WWANEnabled=true</br>


-------------------------------------------------------------------------------------------------------</br>
Configurare le interfacce di rete - NETWORK MANAGER:</br>
-------------------------------------------------------------------------------------------------------</br>
sudo nano /etc/network/interfaces</br>
</br>
\# ifupdown has been replaced by netplan(5) on this system.</br>
\# See /etc/netplan for current configuration.</br>
\# To re-enable ifupdown on this system, you can run:</br>
\# sudo apt install ifupdown</br>

\# The loopback network interface</br>
auto lo</br>
iface lo inet loopback</br>

\# L'interfaccia enp1s0 viene utilizzata per connettere l'HUB a internet attraverso il modem-router</br>
allow-hotplug enp1s0</br>
iface enp1s0 inet static</br>
  address 192.168.1.106 # Assegnare un IP statico all'interfaccia che dipende dalla vostra rete</br>
  netmask 255.255.255.0 # Lasciare invariata la maschera di sottorete ( Subnet Mask )</br>
  broadcast 192.168.1.255 # Modificare utilizzando come riferimento l'IP del vostro modem-router ( gateway )
                         /# ovvero 192.168.1.1 potrebbe essere 192.168.0.1. Deve essere 255 finale !</br>
  gateway 192.168.1.1 /# Usare l'indirizzo IP del vostro modem-router ( gateway )</br>
  \# Only relevant if you make use of RESOLVCONF(8) or similar...</br>
  dns-nameservers 8.8.8.8 8.8.4.4 /# Specificare i server DNS ( google o altri )</br>
</br>
allow-hotplug enp2s0</br>
iface enp2s0 inet dhcp</br>
</br>
auto wlp3s0</br>
iface wlp3s0 inet manual</br>
wireless-mode master</br>
wireless-essid Home_Assistant</br> # Assegnare un nome alla vostra rete WiFi

\# Definizione del BRIDGE - br0 setup with static wan IPv4 with ISP router as gateway</br>
auto br0</br>
iface br0 inet static</br>
 address 192.168.2.1 \# Assegnare un indirizzo IP ( gateway ) alla vostra nuova rete: Es 192.168.3.1, 192.168.4.1</br>
 network 192.168.2.0 \# Assegnare un indirizzo IP uguale all'indirizzo gateway ma con 0 finale</br>
 netmask 255.255.255.0 \# Lasciare invariata la maschera di sottorete ( Subnet Mask )</br>
 broadcast 192.168.2.255 \# Assegnare un indirizzo IP uguale all'indirizzo gateway ma con 255 finale</br>
 bridge_ports enp2s0 wlp3s0 \# Specificare le interfaccie assegnate al bridge</br>
 bridge_stp off</br>
 bridge_fd 0</br>
 bridge_maxwait 0</br>
</br>
</br>
## Riavviare il servizio Network Manager:</br>
sudo service network-manager restart</br>
## Verificare che non siano presenti errori nella configurazione:</br>
sudo service network-manager status</br>
</br>

-------------------------------------------------------------------------------------------------------</br>
IP FORWARDING:</br>
-------------------------------------------------------------------------------------------------------</br>
Editare il file /etc/sysctl.conf</br>
sudo nano /etc/sysctl.conf</br>
</br>
\# Uncomment the next line to enable packet forwarding for IPv4</br>
\# net.ipv4.ip_forward=1 Togliere il commento ( cancellare il carattere # ) a questa riga</br>
Diventerà:</br>
\# Uncomment the next line to enable packet forwarding for IPv4</br>
net.ipv4.ip_forward=1</br>
</br>
Riavviare il computer:
sudo reboot</br>
</br>
Verificare il valore del flag net.ipv4.ip_forward che deve essere 1</br>
sysctl net.ipv4.ip_forward</br>
</br>
-------------------------------------------------------------------------------------------------------</br>
Configurazione di Hostapd</br>
-------------------------------------------------------------------------------------------------------</br>
</br>
sudo nano /etc/hostapd/hostapd.conf
</br>
Copiare la configurazione nel file hostapd.conf
</br>
\# Wireless interface the interface used by the AP</br>
interface=wlp3s0</br>
\# The wireless interface driver</br>
driver=nl80211</br>
\# Specify the bridge...</br>
bridge=br0</br>
\# The country code ( BO = Bolivia, IT = Italy ) this is because we can manage the WiFi Transmit Power :)</br>
country_code=BO</br>
\# Wireless environment</br>
ssid=Home_Assistant # Il nome del vostro AP WiFi</br>
\# "g" simply means 2.4GHz band</br>
hw_mode=g</br>
\# the channel to use</br>
channel=10</br>
\#
logger_syslog=-1</br>
\# QoS support</br>
wmm_enabled=1</br>
\# limit the frequencies used to those allowed in the country</br>
\# ieee80211d=1</br>
\# 802.11n</br>
ieee80211n=1</br>
\# 802.11ac</br>
ieee80211ac=0</br>

\# ht_capab=[HT40+][RX-STBC1][SMPS-STATIC][SHORT-GI-20][SHORT-GI-40][DSSS_CCK-40]</br>
\# Authentication and encryption</br>
macaddr_acl=0</br>
\# 1=wpa, 2=wep, 3=both</br>
auth_algs=1</br>

\# ignore_broadcast_ssid=1</br>

\# WPA2 only</br>
wpa=2</br>
wpa_passphrase=pawssword # La vostra password</br>
\# WPA-PSK WPA-EAP WPA-PSK-SHA256 WPA-EAP-SHA256</br>
wpa_key_mgmt=WPA-PSK</br>
wpa_pairwise=TKIP</br>
rsn_pairwise=CCMP</br>
</br>
##Editare il file /etc/default/hostapd</br>
sudo nano /etc/default/hostapd</br>
</br>
Togliere il commento alla riga seguente e verificare che il percorso specificato "punti" al file hostapd.conf</br>
DAEMON_CONF="/etc/hostapd/hostapd.conf"</br>

Eseguire un test di hostapd:</br>
sudo hostapd /etc/hostapd/hostapd.conf</br>
Se non sono presenti errori o "blocchi" il nuovo AccessPoint verrà avviato. Terminare hostapd premendo CTRL+C</br>

Installare hostapd come servizio, in questo modo l'AccesPoint sarà disponibile ad agni avvio del PC</br>
sudo systemctl unmask hostapd</br>
sudo systemctl enable hostapd</br>
</br>
Verificare lo stato del servizio:</br>
sudo systemctl status hostapd.service o sudo service hostapd status</br>
In caso di errori eseguire che aiutera a stabilire cosa non funziona</br>
journalctl -xe</br>
</br>

-------------------------------------------------------------------------------------------------------</br>
Abilitare il server DHCP isc-dhcp-server per l'interfaccia Bridge br0</br>
-------------------------------------------------------------------------------------------------------</br>
sudo nano /etc/default/isc-dhcp-server
Specificare su quale interfaccia deve rispondere il server DHCP in questo modo:
INTERFACESv4="br0"

-------------------------------------------------------------------------------------------------------</br>
Configurare il sever DHCP isc-dhcp-server</br>
-------------------------------------------------------------------------------------------------------</br>
sudo nano /etc/dhcp/dhcpd.conf</br>
</br>
Cercare le rige riportate di seguito e eliminare il carattere commento alle righe se presente:
</br>
# option definitions common to all supported networks...</br>
option domain-name "domotica.org";</br>
option domain-name-servers 8.8.8.8, 8.8.4.4;</br>
</br>
\# The ddns-updates-style parameter controls whether or not the server will</br>
\# attempt to do a DNS update when a lease is confirmed. We default to the</br>
\# behavior of the version 2 packages ('none', since DHCP v2 didn't</br>
\# have support for DDNS.)</br>
ddns-update-style none;</br>
</br>
\# If this DHCP server is the official DHCP server for the local</br>
\# network, the authoritative directive should be uncommented.</br>
authoritative;</br>
</br>
\# A slightly different configuration for an internal subnet.</br>
subnet 192.168.2.0 netmask 255.255.255.0 {</br>
 range 192.168.2.2 192.168.2.250;</br>
 option domain-name-servers 8.8.8.8;</br>
 option domain-name "domotica.org";</br>
 option subnet-mask 255.255.255.0;</br>
 option routers 192.168.2.1;</br>
 option broadcast-address 192.168.2.255;</br>
\# option domain-name-servers 192.168.1.1;</br>
\# option ntp-servers 10.152.187.1;</br>
 option netbios-name-servers 192.168.2.1;</br>
 option netbios-node-type 2;</br>
 default-lease-time -1;</br>
 max-lease-time -1;</br>
</br>
</br>
  \# Assegnare un indirizzo IP statico ai disposiviti utilizzando il MAC Address. Nella nostra rete abbiamo a disposizione gli
  \# indirizzi IP da 192.168.2.2 a 192.168.2.254</br>
  </br>
  \# Assegnare un IP statico alla lampada Yeelight cucina</br>
  host Yeelight_ceiling_cucina {</br>
    hardware ethernet 00:00:00:00:00:00;</br>
    fixed-address 192.168.2.130;</br>
  }</br>
  </br>
  \# Assegnare un IP statico alla lampada Yeelight camera</br>
  host Yeelight_ceiling_camera {</br>
    hardware ethernet 00:00:00:00:00:00;</br>
    fixed-address 192.168.2.131;</br>
  }</br>
</br>
}
</br>
</br>
Abilitare il servizio server DHCP</br>
sudo systemctl enable isc-dhcp-server</br>
</br>
Verificare che il server funzioni correttamente</br>
sudo systemctl status isc-dhcp-server</br>
</br>
-------------------------------------------------------------------------------------------------------</br>
Aggiunta di una ROUTE statica per l'instradamento dei pacchetti verso internet - IP TABLES:</br>
-------------------------------------------------------------------------------------------------------
Una volta aggiunta la questa regola alla tabella di routing sarà possibile accedere ad internet utilizzando il nuovo AP</br>
</br>
sudo iptables -t nat -A POSTROUTING -o enp1s0 -j MASQUERADE</br>
</br>
La regola però non è persistente, ovvero al riavvio del PC la regola non esisterà più.</br>
E' necessario salvare la nuova regola utilizzando il comando:</br>
</br>
iptables-save</br>
</br>
E' possibile visualizzare le regoule attualmente impostate con:</br>
</br>
sudo iptables -S</br>
e</br>
sudo iptables -L</br>
