# Home-Assistant-HUB

Un HUB completamente indipendente per Home Assistant personalizzabile al 100%.

Consente di creare una rete lan DOMOTICA in grado di fornire indirizzi IP a tutti i dispostivi domotici e di evitare
il routing dei pacchetti ( passaggio dei pacchetti ) attraverso il router che può non essere disponibile.

Dotato di accesso WiFi ( Access Point AP ).
Può dialogare con una rete MESH.
Necessita di una connessione WAN ( Wide Area Network - Internet ) solo se i dispositivi sono di tipo CLOUD.

Installare Ubuntu Server scaricando l'immagine ISO da qui:
https://ubuntu.com/download/server
VERSIONE PER PROCESSORI CON ARCHITETTURA AMD64 ( non ARM ) 64Bit
https://ubuntu.com/download/server/thank-you?version=18.04.4&architecture=amd64

Creare un supporto di avvio ( chiavetta USB ) utilizzando BALENAETCHER:
https://www.balena.io/etcher/

Durante l'installazione di Ubuntu abilitare il SERVER SSH.

Aggiornare la lista dei pacchetti:
sudo apt update

Aggioranre il software:
sudo apt upgrade



