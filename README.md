# Home-Assistant-HUB</br>

- ![#f03c15](https://placehold.it/15/f03c15/000000?text=+)
<h1>L'HUB è estremamente importante. Senza di esso non saremo in grado di utilizzare nessun dispositivo nella nostra casa !
</h1></br>
</br>
I dispositivi con firmware Tasmota supportano il FAULT TOLERANCE ( è possibile specificare più di una rete WiFi alla quale connettersi )</br>
</br>
#La ridondanza nelle infrastruttue di questo tipo dovrebbe essere fondamentale !</br>
</br>
Un HUB completamente indipendente per Home Assistant personalizzabile al 100%.<br/>
</br>
Consente di creare una rete lan DOMOTICA in grado di fornire indirizzi IP a tutti i dispostivi domotici e di evitare
il routing dei pacchetti ( passaggio dei pacchetti ) attraverso il router che può non essere disponibile.<br/>
</br>
Dotato di accesso WiFi ( Access Point AP ).<br/>
Può dialogare con una rete MESH.<br/>
Necessita di una connessione WAN ( Wide Area Network - Internet ) solo se i dispositivi sono di tipo CLOUD.<br/>
<br/>

# Prima di continuare è necessario verificare che la scheda di rete supporti la modalità MASTER ( AP ):<br/>
# Vedere il file [Master_Mode.txt](Master_Mode.txt)
<br/>
<br/>
Installare Ubuntu Server scaricando l'immagine ISO da qui:<br/>
https://ubuntu.com/download/server<br/>

VERSIONE PER PROCESSORI CON ARCHITETTURA AMD64 ( non ARM ) 64Bit<br/>
https://ubuntu.com/download/server/thank-you?version=18.04.4&architecture=amd64<br/>

Creare un supporto di avvio ( chiavetta USB ) utilizzando BALENAETCHER:<br/>
https://www.balena.io/etcher/<br/>

Durante l'installazione di Ubuntu abilitare il SERVER SSH.<br/>

Usare SUDO ( Super User Do )

Aggiornare la lista dei pacchetti:<br/>
sudo apt update<br/>

Aggiornare il software:<br/>
sudo apt upgrade<br/>

Installare i pacchetti necessari:</br>
</br>
sudo apt install bridge-utils</br>
sudo apt install wireless-tools</br>
sudo apt install isc-dhcp-server</br>
sudo apt install hostapd</br>
</br>

-------------------------------------------------------------------------------------------------------</br>
DISABILITARE IL SERVIZIO MODEM MANAGER - Potrebbe influire negativamente con il sever Home Assistant...:</br>
-------------------------------------------------------------------------------------------------------</br>
sudo systemctl stop ModemManager</br>
sudo systemctl disable ModemManager</br>

-------------------------------------------------------------------------------------------------------</br>
Rimuovere NETPLAN ( purtroppo crea problemi se vengono utilizzati Hostapd e isc-dhcp-server contemporaneamente )</br>
-------------------------------------------------------------------------------------------------------</br>
</br>
sudo apt remove --auto-remove netplan.io</br>
sudo apt purge netplan.io</br>

-------------------------------------------------------------------------------------------------------</br>
Configurare le interfacce di rete - NETWORK MANAGER:</br>
-------------------------------------------------------------------------------------------------------</br>
</br>
sudo nano /etc/network/interfaces</br>
</br>
</br>
# ifupdown has been replaced by netplan(5) on this system.  See</br>
# /etc/netplan for current configuration.</br>
# To re-enable ifupdown on this system, you can run:</br>
#    sudo apt install ifupdown</br>

# The loopback network interface</br>
auto lo</br>
iface lo inet loopback</br>

# L'interfaccia enp1s0 viene utilizzata per connettere l'HUB a internet attraveso il modem-router</br>
allow-hotplug enp1s0</br>
iface enp1s0 inet static</br>
  address 192.168.1.106 # Assegnare un IP statico all'interfaccia che dipende dalla vostra rete</br>
  netmask 255.255.255.0 # La subnet mask dovrebbe funzionare se specificata in questo modo</br>
  broadcast 192.168.1.255 # Modificare utilizzando come riferimento l'IP del vostro modem-router ovvero 192.168.1.255 potrebbe essere 192.168.0.255. Deve essere 255 finale !</br>
  gateway 192.168.1.1</br>
  # Only relevant if you make use of RESOLVCONF(8) or similar...</br>
  dns-nameservers 8.8.8.8 8.8.4.4</br>
</br>
allow-hotplug enp2s0</br>
iface enp2s0 inet dhcp</br>
</br>
auto wlp3s0</br>
iface wlp3s0 inet manual</br>
wireless-mode master</br>
wireless-essid Home_Assistant</br> # Assegnare un nome alla vostra rete WiFi

# Definizione del BRIDGE - br0 setup with static wan IPv4 with ISP router as gateway</br>
auto br0</br>
iface br0 inet static</br>
 address 192.168.3.1</br>
 network 192.168.3.0</br>
 netmask 255.255.255.0</br>
 broadcast 192.168.3.255</br>
 bridge_ports enp2s0 wlp3s0
 bridge_stp off
 bridge_fd 0
 bridge_maxwait 0</br>
 </br>
# Riavviare il servizio Network Manager:</br>
sudo service network-manager restart</br>
# Verificare che non siano presenti errori nella configurazione:</br>
</br>
sudo service network-manager status</br>
</br>

##Configurazione di Hostapd</br>

sudo nano /etc/hostapd/hostapd.conf

Copiare la configurazione nel file hostapd.conf

\# Wireless interface the interface used by the AP\
interface=wlp3s0
\# The wireless interface driver\
driver=nl80211
\# Specify the bridge...\
bridge=br0
\# The country code ( BO = Bolivia, IT = Italy ) this is because we can manage the WiFi Transmit Power :)\
country_code=BO
\# Wireless environment\
ssid=Home_Assistant # Il nome del vostro AP WiFi
\# "g" simply means 2.4GHz band\
hw_mode=g
\# the channel to use\
channel=10
'#
logger_syslog=-1
\# QoS support
wmm_enabled=1
\# limit the frequencies used to those allowed in the country
\# ieee80211d=1
\# 802.11n
ieee80211n=1
\# 802.11ac
ieee80211ac=0

\# ht_capab=[HT40+][RX-STBC1][SMPS-STATIC][SHORT-GI-20][SHORT-GI-40][DSSS_CCK-40]
\# Authentication and encryption
macaddr_acl=0
\# 1=wpa, 2=wep, 3=both
auth_algs=1
\#
\# ignore_broadcast_ssid=1

\# WPA2 only
wpa=2
wpa_passphrase=pawssword # La vorta password
\# WPA-PSK WPA-EAP WPA-PSK-SHA256 WPA-EAP-SHA256
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
