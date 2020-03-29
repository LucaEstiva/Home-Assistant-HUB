# Home-Assistant-HUB

Un HUB completamente indipendente per Home Assistant personalizzabile al 100%.<br/>

Consente di creare una rete lan DOMOTICA in grado di fornire indirizzi IP a tutti i dispostivi domotici e di evitare
il routing dei pacchetti ( passaggio dei pacchetti ) attraverso il router che può non essere disponibile.<br/>

Dotato di accesso WiFi ( Access Point AP ).<br/>
Può dialogare con una rete MESH.<br/>
Necessita di una connessione WAN ( Wide Area Network - Internet ) solo se i dispositivi sono di tipo CLOUD.<br/>

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

Aggioranre il software:<br/>
sudo apt upgrade<br/>

-------------------------------------------------------------------------------------------------------</br>
DISABILITARE IL SERVIZIO MODEM MANAGER - Potrebbe influire negativamente con il sever Home Assistant...:</br>
-------------------------------------------------------------------------------------------------------</br>
sudo systemctl stop ModemManager</br>
sudo systemctl disable ModemManager</br>

-------------------------------------------------------------------------------------------------------</br>
Rimuovere NETPLAN ( purtroppo crea problemi se vengono utilizzati Hostapd e isc-dhcp-server contemporaneamente )</br>
-------------------------------------------------------------------------------------------------------</br>
</br>
sudo apt-get remove --auto-remove netplan.io</br>
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
sudo service network-manager status</br>
