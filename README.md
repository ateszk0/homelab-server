\# Homelab: Sustainable IT Engineering Playground



!\[Proxmox](https://img.shields.io/badge/Proxmox-VE\_8-orange?style=flat\&logo=proxmox)

!\[Docker](https://img.shields.io/badge/Docker-Container-blue?style=flat\&logo=docker)

!\[Linux](https://img.shields.io/badge/OS-Linux-yellow?style=flat\&logo=linux)

!\[Cloudflare](https://img.shields.io/badge/Network-Zero\_Trust-orange?style=flat\&logo=cloudflare)

!\[Status](https://img.shields.io/badge/Status-Active-brightgreen)



\## 📖 Projekt Áttekintés

Ez a projekt egy \*\*ultragazdaságos, laptop-alapú otthoni szerver\*\* implementációja. A cél egy teljesen önellátó, privát felhő (Self-Hosted Cloud) létrehozása volt, amely minimális energiafogyasztás mellett képes nagyvállalati szintű szolgáltatások (Immich, Nextcloud, n8n) futtatására.



A rendszer különlegessége a hardveres korlátok kreatív szoftveres áthidalása (pl. akkumulátor használata UPS-ként, AI workloadok ütemezése).



\## 🏗️ Architektúra

A rendszer \*\*Proxmox VE\*\* alapokon nyugszik, konténerizált (LXC + Docker) környezetben.



```mermaid

graph TD

&nbsp;   subgraph Host \[Laptop: Dynabook Portégé X30-F]

&nbsp;       PVE\[Proxmox VE Host]

&nbsp;       

&nbsp;       subgraph LXC\_Monitor \[LXC 102: Monitor]

&nbsp;           Glances\[Glances]

&nbsp;           Kuma\[Uptime Kuma]

&nbsp;           Scrutiny\[Scrutiny SMART]

&nbsp;       end

&nbsp;       

&nbsp;       subgraph LXC\_Docker \[LXC 101: Docker Host]

&nbsp;           Portainer\[Portainer]

&nbsp;           Immich\[Immich Photo + AI]

&nbsp;           Nextcloud\[Nextcloud]

&nbsp;           n8n\[n8n Automation]

&nbsp;           Ollama\[Ollama LLM]

&nbsp;       end

&nbsp;       

&nbsp;       subgraph VM\_HA \[VM: Home Assistant]

&nbsp;           HAOS\[Home Assistant OS]

&nbsp;       end

&nbsp;       

&nbsp;       STORAGE\[(External SSD 1TB)]

&nbsp;   end



&nbsp;   User((User / Admin))

&nbsp;   Cloudflare\[Cloudflare Tunnel]

&nbsp;   NordVPN\[NordVPN Meshnet]



&nbsp;   User -->|Public URL| Cloudflare

&nbsp;   User -->|Private Access| NordVPN

&nbsp;   Cloudflare --> LXC\_Docker

&nbsp;   NordVPN --> PVE

&nbsp;   LXC\_Docker -->|Bind Mount| STORAGE

&nbsp;   LXC\_Monitor -->|Host PID| PVE

