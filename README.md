# Home-Assistant-HUB

### Nel caso in cui troviate inesattezze, errori, o vogliate suggerire miglioramenti segnalateli utilizzando Issues.

[Guida alla realizzazione](https://lucaestiva.github.io/)

[Video guida](https://youtu.be/8yDdO18deoA) 

# L'HUB è estremamente importante. Senza di esso non saremo in grado di utilizzare nessun dispositivo nella nostra casa !

## I dispositivi con firmware Tasmota supportano il FAULT TOLERANCE ( è possibile specificare più di una rete WiFi alla quale connettersi )

## La ridondanza nelle infrastruttue di questo tipo dovrebbe essere fondamentale !

Un HUB completamente indipendente per Home Assistant personalizzabile al 100%.

Il progetto consente di creare un Router, ed un Access Point con server DHCP ( che chiameremo HUB ) in grado di fornire
indirizzi IP a tutti i dispostivi domotici ad esso connessi e gestirne la comunicazione con il server Home Assistant,
anch'esso installato nello stesso PC.

Il router non sarà più necessario ( tranne per le comunicazioni via Internet )
In caso di guasto la rete domotica sarà ugualmente in grado di funzionare
Si velocizza la comunicazione tra il server Home Assistant e i dispositivi, soprattuto se il router è già impegnato...

# L'HARDWARE

Nel mio caso l'HUB è realizzato con questo PC industriale ( barebone no RAM no Disco ):<br />
<br />
https://www.amazon.it/gp/product/B083SLWMHV/ref=ppx_yo_dt_b_asin_title_o05_s00?ie=UTF8&psc=1<br />
<br />
E' stao dotato di:<br />
Crucial CT16G4SFD824A Memoria da 16 GB Dual Rank x 8, DDR4, 2400 MT/s, PC4-19200, SODIMM, 260-Pin<br />
Western Digital WD GREEN SATA SSD Unità allo Stato Solido Interna 2.5" M.2 2280, 120 GB<br />
<br />
La scheda di rete WiFi presente nel PC supporta la modalità MASTER.<br />
<br />
# Per un PC diverso, verificare che la scheda di rete del PC scelto supporti la modalità MASTER ( AP ):</br>
# Vedere il file [Master_Mode.txt](Master_Mode.txt)<br />
Se la modalità MASTER o AP non è supportata dalla vostra scheda di rete dovrete sostituirala o utlizzare una periferica USB.<br />
<br />
Per i dettagli veder la guida alla realizzazione: [GitHub Pages](https://lucaestiva.github.io/)
