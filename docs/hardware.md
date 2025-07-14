# 🚀 Home Lab Hardware Details
![Proxmox](https://img.shields.io/badge/Proxmox-E52F5A?style=for-the-badge&logo=proxmox&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![UniFi](https://img.shields.io/badge/UniFi-0056B3?style=for-the-badge&logo=ubiquiti&logoColor=white)

This document provides a detailed overview of the physical hardware that powers the home lab. Each component was selected to fulfill a specific role within the overall architecture, from high-performance virtualization to energy-efficient, always-on services.

## 🎯 Design Philosophy

The hardware selection is guided by three core principles:

* **Professional Grade:** Using reliable hardware that supports enterprise-level virtualization and networking solutions to build a stable foundation.
* **Energy Efficiency:** Balancing computational performance with power consumption to ensure sustainable and cost-effective 24/7 operation.
* **Purpose-Built:** Assigning components to roles where their strengths are best utilized, avoiding waste and maximizing performance for critical tasks.

---

## 🖥️ Primary Server (Proxmox Host)

This is the workhorse of the lab, providing the computational power for virtualized services, including the entire AI stack.

* **Hostname:** `proxmox`
* **Role in the Lab:** Hypervisor host running **Proxmox VE**. It hosts the main Docker VMs for AI experimentation and other core services.
* **Specifications:**
    * **CPU:** 12 Cores
    * **RAM:** 12 GB
    * **Storage:** NVMe & SSD storage pool
    * **Network:** Wired Gigabit Ethernet

### Rationale

This server was chosen for its multi-core performance, making it ideal for running multiple virtual machines simultaneously without bottlenecks. It hosts `vm-docker-main` (AI & services) and `vm-docker-network` (network services), effectively isolating resource-intensive workloads from the rest of the infrastructure.

---

## 🔌 Secondary Server (Low-Power Host)

This node is the lab's stability-focused backbone, running critical 24/7 services that require constant uptime with minimal power draw.

* **Hostname:** `debian-host`
* **Role in the Lab:** A physical Debian server hosting essential services that manage the network and home automation.
* **Specifications:**
    * **CPU:** Dual-Core (Low Power)
    * **RAM:** 4 GB
    * **Storage:** SSD
    * **Network:** Wired Gigabit Ethernet

### Rationale

This low-power machine is perfect for services that must always be online, like the **UniFi Network Controller** and **Home Assistant**. Its minimal energy consumption makes it cost-effective for 24/7 operation, while its wired connection ensures maximum reliability for managing the network infrastructure and home automation tasks.

---

## 🌐 Network Equipment (UniFi Stack)

The network is built entirely on the Ubiquiti UniFi platform, providing enterprise-level features, security, and centralized management. The ISP modem is configured in "Bridge Mode," passing the public IP directly to the UniFi Gateway.

### Gateway/Firewall: UniFi Gateway Lite (UXG-Lite)
* **Function:** Acts as the primary router, advanced firewall, and VPN server (WireGuard). It manages all network traffic, VLANs, and security policies.

### Switch: UniFi Switch
* **Function:** Serves as the wired backbone of the network, connecting the servers, access point, and other wired devices. It handles VLAN tagging to enforce network segmentation.

### Access Point: UniFi AP7 Lite
* **Function:** Provides high-performance Wi-Fi 7 connectivity. It broadcasts multiple SSIDs, each mapped to a specific VLAN (e.g., `cacau`, `mochi`, `iot`) to ensure wireless devices are properly segmented.