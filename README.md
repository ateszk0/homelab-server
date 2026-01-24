
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
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#007ACC', 'edgeLabelBackground':'#ffffff', 'tertiaryColor': '#F0F0F0'}}}%%
graph TD
    %% --- STYLING DEFINITIONS ---
    classDef user fill:#FFD700,stroke:#333,stroke-width:2px,color:black;
    classDef netService fill:#FF9900,stroke:#333,stroke-width:2px,color:white,stroke-dasharray: 5 5;
    classDef physical fill:#E6E6E6,stroke:#333,stroke-width:3px;
    classDef hypervisor fill:#CCE5FF,stroke:#007ACC,stroke-width:2px;
    classDef container fill:#D4EDDA,stroke:#28a745,stroke-width:2px;
    classDef app fill:#FFFFFF,stroke:#007ACC,stroke-width:1px;
    classDef storage fill:#FFE5CC,stroke:#D9534F,stroke-width:3px,shape:cylinder;
    classDef hardware fill:#E1D5E7,stroke:#9673A6,stroke-width:2px;

    %% --- EXTERNAL ACTORS & NETWORKING ---
    User((Admin / User)):::user
    
    subgraph Public_Access [Internet / Zero Trust]
        CF{{Cloudflare Tunnel}}:::netService
    end
    
    subgraph Secure_Access [VPN / SD-WAN]
        Meshnet{{NordVPN Meshnet}}:::netService
    end

    User == "Public URL (HTTPS/443)" ==> CF
    User -- "Encrypted Tunnel (NordLynx)" --> Meshnet

    %% --- PHYSICAL HOST LAYER ---
    subgraph Dynabook_Host [💻 Physical Layer: Laptop Host]
        class Dynabook_Host physical

        subgraph Hardware_Resources [Hardware Resources]
            iGPU[Intel UHD 620 iGPU]:::hardware
        end

        %% --- STORAGE LAYER ---
        subgraph Storage_Layer [Storage Drives]
            NVMe[(System NVMe SSD)]:::storage
            ExtSSD[(1TB External Data SSD)]:::storage
        end

        %% --- HYPERVISOR LAYER ---
        subgraph PVE_Host [☁️ Hypervisor: Proxmox VE 8]
            class PVE_Host hypervisor
            PVE_Shell[Proxmox Shell]:::app

            %% --- LXC: MONITORING ---
            subgraph LXC102 [LXC 102: Monitor Stack]
                class LXC102 container
                Glances["Glances (Host PID)"]:::app
                Scrutiny["Scrutiny (SMART)"]:::app
                Kuma[Uptime Kuma]:::app
            end

            %% --- LXC: DOCKER HOST ---
            subgraph LXC101 [LXC 101: Docker Host]
                class LXC101 container
                
                subgraph Docker_Apps [🐳 Docker Apps]
                    Portainer["Portainer"]:::app
                    Nextcloud["Nextcloud"]:::app
                    n8n["n8n (Automation)"]:::app
                    Immich_Srv[Immich Server]:::app
                    Immich_ML["Immich ML"]:::app
                    Ollama[Ollama LLM]:::app
                    WebUI[Open WebUI]:::app
                end
            end
        end
    end

    %% --- CONNECTIONS ---

    %% Networking Ingress
    CF -- "Tunnel" --> Nextcloud
    CF -- "Tunnel" --> Immich_Srv
    CF -- "Tunnel" --> n8n
    CF -- "Tunnel" --> WebUI
    Meshnet -- "SSH Access" --> PVE_Shell

    %% Storage Connections
    ExtSSD == "Bind Mount" ===> Immich_Srv
    ExtSSD == "Bind Mount" ===> Nextcloud
    NVMe -.-> PVE_Shell

    %% Hardware Acceleration
    iGPU == "QuickSync /dev/dri" ===> Immich_ML
    iGPU == "OpenCL /dev/dri" ===> Ollama

    %% Internal Comms
    WebUI -- "API" --> Ollama
    Immich_Srv -- "API" --> Immich_ML

    %% Monitoring
    Glances -. "Monitor" .-> PVE_Shell
    Scrutiny -. "Read SMART" .-> ExtSSD
    Scrutiny -. "Read SMART" .-> NVMe
    Kuma -. "APIvailability Check" .-> Docker_Apps
```

## ⚙️ Hardware Specifications

The server runs on a repurposed business ultrabook acting as a host with a built-in UPS (battery).
|‎ **Component**‎‎‎ - **Specification**
|‎ **Device** - Dynabook Portégé X30-F
|‎ **CPU** - Intel Core i5-8265U (4C/8T)
|‎ **RAM** - 16 GB DDR4
|‎ **Internal Storage**‎ - 256 GB NVMe
|‎ **External Storage** - 1 TB Samsung 860 EVO (USB)



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