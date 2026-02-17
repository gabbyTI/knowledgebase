# 📺 Jellyfin Homelab Setup

## Overview

This project documents how I deployed **Jellyfin** in my homelab using **Proxmox LXC**, **GPU passthrough**, and a **secure HTTPS setup** via a reverse proxy and Cloudflare DNS challenge.

The goal was to build a **lightweight, performant, and production-style media server** with proper authentication, hardware transcoding, and clean external access.

## 🔗 Quick Links

*   **[📝 Step-by-Step Setup Guide](./setup-guide.md)**: The complete command-by-command guide to building this setup.
*   **[Proxmox Helper Scripts](https://tteck.github.io/Proxmox/)**: The source of the LXC installation script.

---

## Architecture Summary

* **Hypervisor:** Proxmox VE
* **Workload type:** LXC container
* **GPU passthrough:** NVIDIA Quadro P2000 (hardware transcoding)
* **Reverse proxy:** Nginx Proxy Manager
* **DNS & SSL:** Cloudflare
* **Auth:** Authentik (LDAP)

---

## Key Features

* Hardware-accelerated transcoding using NVIDIA GPU
* Low-overhead LXC deployment
* Host-mounted persistent media storage
* HTTPS with custom domain
* Centralized authentication via LDAP
* Clean separation between infrastructure and application data

---

## Hardware

* **Host:** Dell Precision T5810
* **CPU:** Xeon
* **GPU:** NVIDIA Quadro P2000
* **Storage:** Local disks mounted into container
* **Network:** WiFi-to-Ethernet extender (no router access)

---

## Jellyfin Deployment

* Installed using the **Proxmox Helper Script** (see [Setup Guide Phase 3](./setup-guide.md#phase-3-jellyfin-lxc-deployment)).
* Runs as a system service inside the LXC container
* Exposed via reverse proxy over HTTPS

---

## GPU Transcoding

* **GPU:** NVIDIA Quadro P2000 passed directly to the LXC container.
* **Configuration:** Jellyfin configured to use **NVIDIA NVENC/NVDEC**.
* **Setup:** See [Setup Guide Phase 4](./setup-guide.md#phase-4-gpu-passthrough-proxmox-8x-web-ui) for the critical passthrough and driver installation steps.
* **Results:**
  * Reduced CPU usage
  * Smooth playback
  * Multiple concurrent streams supported

---

## Storage Strategy

* Media stored on Proxmox host
* Mounted into container
* Container can be destroyed/recreated without data loss