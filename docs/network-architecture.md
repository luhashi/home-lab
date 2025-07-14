🌐 Network Architecture
Overview
This document outlines the architecture of a professional-grade home lab network. The design philosophy has evolved from a simple flat network to a robust, secure, and highly-managed infrastructure. It leverages enterprise-level concepts like virtualization, network segmentation (VLANs), and centralized management to create a powerful and flexible environment for self-hosting and experimentation.

The core of the network is built on the Ubiquiti UniFi platform, providing granular control over traffic, while services are logically separated and managed across two physical servers using Proxmox VE and Docker.

✨ Key Architectural Advantages
This new design provides significant improvements in security, performance, and manageability:

Virtualization with Proxmox: Workloads are isolated into dedicated Virtual Machines (e.g., vm-docker-main for AI, vm-docker-network for network services). This prevents a single application failure from impacting the entire system and allows for efficient resource allocation and snapshot-based backups.

Centralized Container Management: Portainer provides a single web interface to manage all three Docker environments across two physical machines. This simplifies deployment, monitoring, and maintenance of containerized services.

Dedicated UniFi Network Stack: Replacing the ISP router with a UniFi Gateway, Switch, and AP provides full control over the network. This enables advanced firewalling, secure VPN access via WireGuard, and the implementation of VLANs.

Purpose-Built Servers: The architecture uses a powerful Primary Server for resource-intensive tasks like running AI models and a Low-Power Secondary Server for essential 24/7 services like Home Assistant and the UniFi Controller, optimizing performance and energy consumption.

Diagram
This diagram illustrates the multi-server architecture and the flow of management and network traffic.


graph TD
    subgraph "Internet"
        ISP_Modem("ISP Modem (Bridge Mode)")
    end

    subgraph "Networking - UniFi Stack"
        UGW["UniFi Gateway Lite (Router/Firewall/VPN)"]
        SW["Network Switch"]
        AP["UniFi AP7 Lite (Wi-Fi 7)"]
    end

    subgraph "Primary Server (Proxmox VE)"
        PVE("Proxmox Host")
        subgraph "VM: vm-docker-main"
            DockerMain["Docker"]
            PortainerServer("Portainer Server")
            Ollama("Ollama")
            OpenWebUI("Open WebUI")
        end
        subgraph "VM: vm-docker-network"
            DockerNet["Docker"]
            AdGuard("AdGuard Home")
            AgentNet("Portainer Agent")
        end
    end

    subgraph "Secondary Server (Low Power)"
        DebianServer("Physical Debian Host")
        DockerLP["Docker"]
        HA("Home Assistant")
        UniFiCtrl("UniFi Controller")
        AgentLP("Portainer Agent")
    end

    ISP_Modem -- "WAN" --> UGW
    UGW -- "LAN" --> SW
    SW --> PVE
    SW --> DebianServer
    SW --> AP

    PVE --> vm-docker-main
    PVE --> vm-docker-network

    PortainerServer -- "Manages" --> DockerMain
    PortainerServer -- "Manages" --> DockerNet
    PortainerServer -- "Manages" --> AgentLP
    
🔒 Network Segmentation & Security
The network is divided into four distinct VLANs, each with a specific purpose and strict firewall rules to control access and enhance security.

Network Name

VLAN ID

Subnet

Purpose & Key Firewall Rules

Prod (Servers)

10

.../27

For core infrastructure (Proxmox, VMs). Highly restricted access from other VLANs.

Cacau (Trusted)

20

.../27

For trusted family devices. Can access: Home Assistant (Port 8123) and Open WebUI.

Mochi (Guest)

30

.../28

For guests. Provides internet access only. Blocked from all local network resources.

IoT (Untrusted)

40

.../25

For IoT devices. Isolated, cannot initiate contact with other VLANs. Can be accessed by Home Assistant.

🚦 Example Traffic Flow
Here’s how a request from a trusted device to a self-hosted service works in this architecture:

A user on their laptop (connected to the "Cacau" Wi-Fi network, VLAN 20) opens a browser to the Open WebUI address.

The request travels from the laptop to the UniFi AP.

The AP tags the traffic for VLAN 20 and sends it to the UniFi Switch.

The Switch forwards the request to the UniFi Gateway.

The Gateway's firewall rules check if VLAN 20 is allowed to access the IP of the OpenWebUI service on the "Prod" network (VLAN 10). The rule allows this specific traffic.

The Gateway routes the request to the Proxmox Host, which passes it to the vm-docker-main VM.

The Docker container for Open WebUI receives the request and serves the webpage back along the same path.

🚀 Future Improvements
With the foundational architecture in place, future enhancements will focus on automation and deeper observability:

High Availability (HA): Deploy a second instance of AdGuard Home on the secondary server and configure them for HA to eliminate DNS as a single point of failure.

Infrastructure as Code (IaC): Use Ansible to automate the setup and configuration of new VMs and Docker hosts, ensuring consistency and repeatability.

Monitoring & Logging: Implement a Prometheus and Grafana stack to collect metrics from all servers, VMs, and services for in-depth monitoring and alerting.