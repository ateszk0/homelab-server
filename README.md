
Markdown


# Homelab: Sustainable IT Engineering Playground

![Proxmox](https://img.shields.io/badge/Proxmox-VE-orange?style=flat&logo=proxmox)
![Docker](https://img.shields.io/badge/Docker-Container-blue?style=flat&logo=docker)
![Linux](https://img.shields.io/badge/OS-Linux-yellow?style=flat&logo=linux)
![Cloudflare](https://img.shields.io/badge/Network-Zero_Trust-orange?style=flat&logo=cloudflare)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

## 📖 Project Overview
This project is an implementation of an **ultra-efficient, laptop-based home server**. The goal was to build a fully self-hosted private cloud capable of running enterprise-grade services (Immich, Nextcloud, n8n) with minimal power consumption.

Key features include creative software solutions to overcome hardware limitations (e.g., using the battery as a UPS, AI workload scheduling).

## 🏗️ Architecture
The system is built on **Proxmox VE**, utilizing a containerized (LXC + Docker) environment.

```mermaid
graph TD
    subgraph Host [Laptop: Dynabook Portégé X30-F]
        PVE[Proxmox VE 8 Host]
        
        subgraph LXC_Monitor [LXC 102: Monitor]
            Glances[Glances]
            Kuma[Uptime Kuma]
            Scrutiny[Scrutiny SMART]
        end
        
        subgraph LXC_Docker [LXC 101: Docker Host]
            Portainer[Portainer]
            Immich[Immich Photo + AI]
            Nextcloud[Nextcloud]
            n8n[n8n Automation]
            Ollama[Ollama LLM]
        end
        
        STORAGE[(External SSD 1TB)]
    end

    User((User / Admin))
    Cloudflare[Cloudflare Tunnel]
    NordVPN[NordVPN Meshnet]

    User -->|Public URL| Cloudflare
    User -->|Private Access| NordVPN
    Cloudflare --> LXC_Docker
    NordVPN --> PVE
    LXC_Docker -->|Bind Mount| STORAGE
    LXC_Monitor -->|Host PID| PVE
```

## ⚙️ Hardware Specifications

The server runs on a repurposed business ultrabook acting as a host with a built-in UPS (battery).
|‎ **Component**‎‎‎ | **Specification**
|‎ **Device** ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎‎  ‎ ‎| Dynabook Portégé X30-F
|‎ **CPU**‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ | Intel Core i5-8265U (4C/8T)
|‎ **RAM** ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ | 16 GB DDR4
|‎ **Storage 1**‎ ‎ ‎ ‎ ‎ ‎ | 256 GB NVMe
|‎ **Storage 2** ‎ ‎ ‎ ‎ ‎ | 1 TB Samsung 860 EVO (USB)



## 🛠️ Tech Stack & Solutions

### 1. Containerization & DevOps

-   **Hypervisor:** Proxmox VE (Bare Metal).
    
-   **Orchestration:** Docker Compose + Portainer (Running inside LXC with Nesting).
    
-   **Services:**
    
    -   **Data:** Immich (Photos/Video), Nextcloud (Files).
        
    -   **Automation:** n8n, Custom Bash Scripts.
        
    -   **AI:** Ollama (Local LLM), Immich Machine Learning.
        

### 2. Networking & Security

-   **Zero Trust:** Cloudflare Tunnel used instead of open ports for public services.
    
-   **VPN:** NordVPN Meshnet (Gateway mode) for secure admin access and SSH.
    
-   **Monitoring:** Glances (Resources), Uptime Kuma (Service Health), Scrutiny (HDD Health).
    

##  Key Engineering Challenges

### - Battery Management (Laptop as UPS)

Running a laptop 24/7 on AC power can damage the battery.

-   **Solution:** BIOS "Eco Charge" limit (80%) + Custom **Bash Script** monitoring `/sys/class/power_supply`.
    
-   **Logic:** If power is lost AND battery drops < 15% -> `shutdown -h now` (Graceful Shutdown).
    

### - Storage Mounting in LXC

Proxmox LXC containers do not see USB drives on the Host by default.

-   **Issue:** Docker services threw `EACCES` and `ENOENT` errors.
    
-   **Solution:**
    
    1.  Host level `fstab` mount by UUID.
        
    2.  LXC Bind Mount configuration (`mp0: /mnt/ssd,mp=/mnt/external_drive`).
        
    3.  User mapping fix (`chown 1000:1000`) for Docker compatibility.
        

### - Resource Optimization (AI Scheduling)

16GB RAM is limited for running heavy AI models alongside other services.

-   **Solution:** Scheduled Resource Management.
    
-   **Implementation:** Cron jobs stop the `immich_machine_learning` container during the day and start it only at night (22:00-08:00).