🏛️ Home Lab Hardware Details
The hardware selection for this lab follows a professional-grade approach, balancing performance with efficiency for a reliable and scalable infrastructure.

Professional Grade: Using enterprise-level virtualization and networking solutions.

Energy Efficiency: Balancing performance with power consumption for sustainable 24/7 operation.

Purpose-Built: Each component is chosen for a specific role, from high-power virtualization to low-power, always-on services.

🖥️ Primary Server (Proxmox Host)
This is the workhorse of the lab, providing the computational power for virtualized services, including the entire AI stack.

Hostname: proxmox

Role in the Lab: Hypervisor host running Proxmox VE. It hosts the main Docker VMs for AI experimentation and other core services.

Specifications:

CPU: 12 Cores

RAM: 12 GB

Storage: NVMe & SSD storage pool

Network: Wired Gigabit Ethernet

Rationale

This server was chosen for its multi-core performance, making it ideal for running multiple virtual machines simultaneously without bottlenecks. It hosts vm-docker-main (AI & services) and vm-docker-network (network services), effectively isolating resource-intensive workloads.

🔌 Secondary Server (Low-Power Host)
This node is the lab's stability-focused backbone, running critical 24/7 services that require constant uptime with minimal power draw.

Hostname: debian-host

Role in the Lab: A physical Debian server hosting essential services that manage the network and home automation.

Specifications:

CPU: Dual-Core (Low Power)

RAM: 4 GB

Storage: SSD

Network: Wired Gigabit Ethernet

Rationale

This low-power machine is perfect for services that must always be online, like the UniFi Network Controller and Home Assistant. Its minimal energy consumption makes it cost-effective for 24/7 operation, while its wired connection ensures maximum reliability for managing the network infrastructure and home automation tasks.

🌐 Network Equipment (UniFi Stack)
The network is built entirely on the Ubiquiti UniFi platform, providing enterprise-level features, security, and centralized management. The ISP modem is configured in "Bridge Mode," passing the public IP directly to the UniFi Gateway.

Gateway/Firewall: UniFi Gateway Lite (UXG-Lite)

Function: Acts as the primary router, advanced firewall, and VPN server (WireGuard). It manages all network traffic, VLANs, and security policies.

Switch: UniFi Switch

Function: Serves as the wired backbone of the network, connecting the servers, access point, and other wired devices. It handles VLAN tagging to enforce network segmentation.

Access Point: UniFi AP7 Lite

Function: Provides high-performance Wi-Fi 7 connectivity. It broadcasts multiple SSIDs, each mapped to a specific VLAN (e.g., cacau, mochi, iot) to ensure wireless devices are properly segmented.