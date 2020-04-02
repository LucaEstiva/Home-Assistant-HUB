# Home-Assistant-HUB</br>
</br>
Vedere: https://lucaestiva.github.io/

<h1>L'HUB è estremamente importante. Senza di esso non saremo in grado di utilizzare nessun dispositivo nella nostra casa !
</h1></br>
</br>
I dispositivi con firmware Tasmota supportano il FAULT TOLERANCE ( è possibile specificare più di una rete WiFi alla quale connettersi )</br>

# La ridondanza nelle infrastruttue di questo tipo dovrebbe essere fondamentale !</br>
</br>
Un HUB completamente indipendente per Home Assistant personalizzabile al 100%.</br>
</br>
Il progetto consente di creare un Router, ed un Access Point con server DHCP ( che chiameremo HUB ) in grado di fornire</br>
indirizzi IP a tutti i dispostivi domotici ad esso connessi e gestirne la comunicazione con il server Home Assistant,</br>
anch'esso installato nello stesso PC.</br>
</br>
Il router non sarà più necessario ( tranne per le comunicazioni via Internet )<br />
In caso di guasto la rete domotica sarà ugualmente in grado di funzionare<br />
Si velocizza la comunicazione tra il server Home Assistant e i dispositivi, soprattuto se il router è già impegnato...<br />

# L'HARDWARE</br>
Nel mio caso l'HUB è realizzato con questo PC industriale ( barebone no RAM no Disco ):</br>

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
