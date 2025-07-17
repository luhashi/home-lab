# 🚀 My Home Lab: From Videomaker to AI/DevOps Engineer

![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Home%20Assistant](https://img.shields.io/badge/Home%20Assistant-41BDF5?style=for-the-badge&logo=home-assistant&logoColor=white)
![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=cloudflare&logoColor=white)

Welcome to my home lab repository! This project serves as my personal proving ground and portfolio, documenting my career transition journey into the world of tech, with a focus on **DevOps**, **AI Engineering**, and **Zero Trust Security**.

## 🎯 Guiding Principles

Coming from a 10-year background in audiovisual production, I believe in building robust solutions by blending creativity with technical efficiency. This lab is:

* **Practical:** Everything here runs on real hardware, solving everyday problems and serving real purposes.
* **Evolving:** It started simple and is constantly improving, with a clear roadmap for automation and scalability.
* **Documented:** I believe clear documentation is the foundation of any sustainable and collaborative project.
* **Secure:** Built on Zero Trust principles, implementing enterprise-grade security practices.

---

## 🏛️ Current Architecture

The infrastructure follows a professional-grade home lab setup with Zero Trust security principles, proper network segmentation, and virtualization.

```mermaid
graph TD
    subgraph "External Access (Internet)"
        User_External["External User"]
    end

    subgraph "Cloudflare"
        CF_Proxy["Proxy (CDN/WAF)"]
        CF_Access["Access (SSO Login)"]
        CF_Tunnel["Tunnel"]
    end

    subgraph "Local Network (Homelab)"
        subgraph "VM: vm-docker-network"
            Cloudflared["cloudflared (Tunnel Agent)"]
            NPM["Nginx Proxy Manager"]
            AdGuard["AdGuard Home (Internal DNS)"]
        end

        subgraph "Internal Services"
            HA["Home Assistant"]
            OpenWebUI["OpenWebUI / LittleLLM"]
            UnifiCtrl["UniFi Controller"]
            OtherServices["...other services"]
        end

        User_Internal["Internal User / VPN Client"]
    end

    User_External -- "1. https://service.example.com" --> CF_Proxy
    CF_Proxy -- "2. Filters Threats (WAF)" --> CF_Access
    CF_Access -- "3. Forces SSO Login" --> CF_Tunnel
    CF_Tunnel -- "4. Secure Bridge (No Open Ports)" --> Cloudflared
    Cloudflared -- "5. Forwards ALL traffic to NPM" --> NPM

    User_Internal -- "https://service.lab.example.com" --> AdGuard
    AdGuard -- "Replies with NPM's internal IP" --> User_Internal
    User_Internal -- "Accesses NPM directly" --> NPM

    NPM -- "Routes to correct service" --> HA
    NPM -- "Routes to correct service" --> OpenWebUI
    NPM -- "Routes to correct service" --> UnifiCtrl
    NPM -- "Routes to correct service" --> OtherServices
```

### 🛡️ Security Stack

This homelab is built with a security-first, Zero Trust architecture. Access is governed by multiple layers of defense:

* **✅ Zero Trust Perimeter:** External access is exclusively handled by Cloudflare Tunnels, eliminating any open inbound firewall ports and hiding the home IP address.
* **🔐 Primary Authentication:** Cloudflare Access provides a robust primary authentication layer, requiring SSO (Google/GitHub) before any request reaches the local network.
* **🛡️ Web Application Firewall (WAF):** Cloudflare's WAF is configured with geo-fencing rules to allow traffic only from authorized countries and to block common web-based threats.
* **🚦 Centralized Reverse Proxy:** Nginx Proxy Manager serves as the single ingress point for all traffic, managing SSL termination and routing based on hostname.
* **🔑 Secondary Authentication:** NPM Access Lists provide an additional layer of basic user/password authentication for critical management services.
* **🧱 Internal Network Firewall:** UniFi firewall rules prevent direct IP-based access to services, enforcing all traffic through the reverse proxy.
* **🌐 Split-Horizon & Secure DNS:** AdGuard Home manages internal DNS resolution (`*.lab.example.com`) and provides network-wide ad and malware blocking.

### Network Segmentation

The network is divided into four distinct subnets, each with specific security policies:

| Subnet | CIDR | Purpose | Access Rights |
|--------|------|---------|---------------|
| **prod** | /27 | Production infrastructure | Full access to all services |
| **cacau** | /27 | Family network (medium security) | Access to OpenWebUI and Home Assistant |
| **mochi** | /28 | Guest network | Internet only, no internal services |
| **iot** | /25 | IoT devices | Restricted; only port 8223 accessible from prod network |

### Hardware

| Component | Specification | Function |
|-----------|--------------|-----------|
| **Main Server** | 12 Cores, 12 GB RAM | Proxmox VE host for main service VMs |
| **Secondary Server** | Dual Core (Low Power) | Debian host for 24/7 low-demand services |
| **Gateway/Firewall** | UniFi Gateway Lite | Router, Firewall, WireGuard VPN |
| **Access Point** | UniFi AP7 Lite | Wi-Fi 7, guest network, security management |
| **Switch** | Network backbone | Local network connectivity |
*For a more detailed overview, see the [Hardware & Network Documentation](./docs/hardware.md).*

### Software & Virtualization Stack

| Technology | Description |
|------------|-------------|
| **Hypervisor** | Proxmox VE - Installed on main server for VM management |
| **Operating System** | Debian - Base OS for secondary server and all VMs |
| **Containerization** | Docker - Used across all hosts to isolate and run services |
| **Management** | Portainer - Centralized management of 3 Docker environments (2 VMs + 1 physical host) |
| **Network** | UniFi Network - UniFi Controller manages Gateway and AP for complete network control |
| **Security** | Cloudflare Zero Trust - Edge security, authentication, and secure tunneling |

---

## 🛠️ Services

This lab consists of three main service stacks distributed across virtual machines and physical hosts, all managed through Portainer for centralized control.

### AI and Management Stack (`vm-docker-main`)

This VM hosts the AI services and central management tools. Configuration is defined in `services/ai-stack/docker-compose.yml`.

| Service | Purpose | Network Access |
|---------|---------|----------------|
| **Portainer Server** | Central container management hub | prod only |
| **Ollama** | Local LLM execution engine | prod, cacau |
| **Open WebUI** | Web interface for Ollama models | prod, cacau |
| **LittleLLM** | API key and model access management | prod only |

### Network Services (`vm-docker-network`)

This VM handles network-level services. Configuration is in `services/network-services/docker-compose.yml`.

| Service | Purpose | Network Access |
|---------|---------|----------------|
| **AdGuard Home** | DNS-level ad/tracker blocking | prod only |
| **Nginx Proxy Manager** | Central reverse proxy and SSL management | prod only |
| **Cloudflared** | Cloudflare Tunnel agent | prod only |
| **Portainer Agent** | Remote management endpoint | prod only |

### Home Automation Stack (Physical Server)

Running on the low-power physical server, these services manage home automation and network control. Configuration in `services/home-automation/docker-compose.yml`.

| Service | Purpose | Network Access |
|---------|---------|----------------|
| **Home Assistant** | Home automation orchestrator | prod, cacau, iot (8223) |
| **UniFi Controller** | Network device management | prod only |
| **Portainer Agent** | Remote management endpoint | prod only |

## 🗺️ Future Roadmap

This project is just the beginning. The next planned steps are:

-   [ ] **Monitoring:** Implement a Prometheus & Grafana stack for visibility into the lab's health and performance metrics.
-   [ ] **IaC with Ansible:** Automate the base configuration (package installation, Docker setup, security hardening) of all nodes.
-   [ ] **GitOps Pipeline:** Implement automated deployments using GitLab CI/CD and ArgoCD.
-   [ ] **Secret Management:** Integrate HashiCorp Vault for centralized secrets management.

---

Thanks for stopping by! Feel free to explore the repository and its documentation.