# 🏛️ Home Lab Hardware Details

The hardware selection for this lab was guided by a philosophy of pragmatism and resourcefulness.

1.  **Resourcefulness:** This lab is built entirely on hardware I already had on hand. The goal is to maximize the value of existing equipment, proving that a capable lab doesn't require a large initial investment.
2.  **Energy Efficiency:** Using low-power components is a priority to allow for 24/7 operation without a significant impact on electricity costs.
3.  **Right-Sizing:** Each piece of hardware is assigned a role that matches its capabilities, avoiding the waste of powerful components on simple tasks.

---

## 🖥️ AI Node: `mercury`

This node is dedicated to my experiments with Artificial Intelligence.

* **Hostname:** `mercury`
* **Model:** Microsoft Surface Pro 4
* **Role in the Lab:** An experimentation server for hosting and testing local language models (LLMs) and other AI applications.
* **Operating System:** Debian 12 (using the [custom linux-surface kernel](https://github.com/linux-surface/linux-surface) for full hardware support).

### Specifications

* **CPU:** Intel Core i5-6300U (Dual-Core, 4 Threads @ 2.40GHz)
* **RAM:** 8 GB DDR3
* **Storage:** 256 GB NVMe SSD
* **Network:** Marvell AVASTAR Wireless-AC (Wi-Fi Connection)

### Rationale

The Surface Pro 4 was chosen as the AI node primarily because it was an available, unused device. Its characteristics, however, make it surprisingly suitable for this role. The i5 processor can run medium-sized LLMs via Ollama effectively for testing, and its low power draw and fanless operation at idle are ideal for a 24/7 server. Installing Debian with a custom kernel was also a valuable system administration exercise.

---

## 🔌 Core Services Node: `jupiter`

This node is the backbone of the network, running critical services that demand stability.

* **Hostname:** `jupiter`
* **Model:** Generic Dual-Core Notebook
* **Role in the Lab:** Hosts essential infrastructure services for the network, including DNS, home automation, and monitoring.
* **Operating System:** Debian 12 Server

### Specifications

* **CPU:** Intel Celeron N2830 (Dual-Core @ 2.16GHz)
* **RAM:** 4 GB DDR3
* **Storage:** 500 GB HDD
* **Network:** Realtek Gigabit Ethernet (Wired Connection)

### Rationale

Similarly, this notebook was repurposed to serve as the core services node. While its processing power is modest, its key feature is the reliable, wired Gigabit Ethernet port. This provides the stability and low latency needed for critical services like AdGuard Home (as a DNS server) and Home Assistant, which must remain online. It perfectly embodies the "right-sizing" principle, handling its essential tasks reliably while freeing up the more powerful `mercury` node for its demanding AI workloads.

---

## 🌐 Network Equipment

* **Primary Router:** ISP-provided All-in-One modem/router.
    * **Function:** Currently acts as the modem, router, switch, and Wi-Fi access point for the entire network.
    * **Limitations:** It offers limited configuration options, lacks VLAN support, and runs closed-source firmware. This is a known bottleneck and a primary target for a future upgrade.

---

## 🚀 Future Hardware Roadmap

The current setup is a starting point. The planned hardware evolution includes:

1.  **Dedicated Mini PC:** Acquiring a dedicated mini PC (like an Intel NUC, Beelink, etc.) to act as the primary server running Proxmox VE. This will enable more professional virtualization and containerization (VMs & LXCs).
2.  **Managed Switch:** Implementing a managed switch (e.g., from TP-Link Omada or Ubiquiti UniFi) to enable VLAN creation for network segmentation and enhanced security.
3.  **Network Attached Storage (NAS):** Building or buying a dedicated NAS to centralize file storage, server backups, and datasets for AI applications.