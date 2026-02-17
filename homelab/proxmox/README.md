# Proxmox Hypervisor Documentation

## Overview

This directory documents the configuration and management of the primary Proxmox VE host **(Dell Precision T5810)**.

The host serves as the foundation for the homelab, running LXC containers and VMs for services like Jellyfin.

## Hardware Specifications

*   **Model:** Dell Precision T5810
*   **CPU:** Intel Xeon E5-2660 v4 @ 2.00GHz (14 Cores / 28 Threads)
*   **RAM:** 128GB DDR4 ECC
*   **GPU:** NVIDIA Quadro P2000 (Used for transcoding passthrough)
*   **Boot Drive:** 500GB NVMe (CT500P3PSSD8)
*   **Storage Pools:** ZFS (See below for detailed architecture)
*   **Network:** Direct Ethernet connection to Router (1GbE).

## Storage Architecture (ZFS)

| Pool Name | Type | Capacity (Raw) | Disks | Purpose | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`flash`** | Mirror (RAID1) | ~1TB Usable | 2x 1TB SSDs | High-speed VM/LXC storage | ✅ Online |
| **`vault`** | RAIDZ1 (RAID5) | ~3TB Usable | 4x 1TB SSDs | Mass storage (Media/Data) | ✅ Online |
| **`ssdpool`** | Single Disk | 256GB | 1x Toshiba SSD | Scratch / Cache / ISOs | ✅ Online |
| **`hddpool`** | Single Disk | 500GB | 1x Seagate HDD | Backup / Low-priority data | ✅ Online |

## Configuration Highlights

### 1. IOMMU / Passthrough
*   IOMMU is enabled in BIOS and Kernel command line (`intel_iommu=on`).
*   Verify IOMMU groups: `find /sys/kernel/iommu_groups/ -type l`
*   **GPU Isolation:** The host does not grab the NVIDIA card, allowing full passthrough to LXC containers.

### 2. Networking
*   **Dual Bridge Setup:**
    *   `vmbr0` (1GbE): Bridged to built-in Intel NIC.
    *   **`vmbr1` (2.5GbE):** Bridged to TP-Link PCIe card (Primary Host Connection).
*   **Mode:** Multi-interface / Simple Bridge (Both on same 10.0.0.x subnet).
*   **Addressing:** Static IP recommended for server stability.
*   **Repository:** Using the `pve-no-subscription` repository for updates.
*   **Update Command:** `apt update && apt dist-upgrade`

## Hosted Services (LXC/VM)

| ID | Name | Type | IP | Description |
| :--- | :--- | :--- | :--- | :--- |
| 1xx | **Jellyfin** | LXC | `10.0.0.x` | [Documentation](../jellyfin/README.md) |
| ... | ... | ... | ... | ... |

## Resources & Scripts

*   **[Proxmox VE Helper Scripts](https://tteck.github.io/Proxmox/)**: Used for rapid deployment of LXC containers and post-install configuration.
*   **[Official Proxmox Documentation](https://pve.proxmox.com/wiki/Main_Page)**: definitive reference.

## Maintenance Tasks

- [ ] Regularly check for PVE updates.
- [ ] Backup critical LXC configurations to external storage (e.g., PBS or NAS).
- [ ] Monitor disk health (SMART data) on the T5810.
