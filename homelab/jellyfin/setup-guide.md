# 🔁 Step-by-Step Jellyfin Rebuild Guide (Proxmox 9.x / 8.x)

This guide lets you **rebuild everything from scratch** using modern Proxmox 9.x and 8.x features.

---

## Phase 1: Proxmox Host Preparation

1.  **Install Proxmox VE** on the host.
2.  **Update the system and install headers:**
    *   Proxmox 9.x uses a newer kernel (e.g., 6.14+). You **must** install the matching headers for the NVIDIA installer to build modules.

    ```bash
    apt update && apt upgrade -y
    apt install pve-headers-$(uname -r) -y
    ```

3.  **Blacklist Nouveau (Open Source Driver):**
    *   The proprietary NVIDIA driver conflicts with Nouveau. Create a blacklist file:

    ```bash
    echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nouveau.conf
    echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nouveau.conf
    update-initramfs -u
    reboot
    ```

4.  **Verify GPU is visible:**

    ```bash
    lspci | grep -i nvidia
    ```

---

## Phase 2: Host Driver Setup

1.  **Install NVIDIA drivers on the Proxmox host:**
    *   **Proxmox 9.x Warning:** Ensure you download a driver version compatible with **Linux Kernel 6.14+** (e.g., driver version 570.xx or newer). Older drivers may fail to compile.
    *   Run the installer. **Important:** Select "Yes" to register the kernel module sources with DKMS. This ensures drivers survive kernel updates.

    ```bash
    ./NVIDIA-Linux-x86_64-xxx.xx.run --dkms
    ```

2.  **Verify Host Drivers:**

    ```bash
    nvidia-smi
    ```

> ✅ At this point, the host must see the GPU and display driver details.

---

## Phase 3: Jellyfin LXC Deployment

1.  **Run the Proxmox Helper Script** for Jellyfin (recommended for ease).
2.  **Script automatically:**
    *   Creates LXC
    *   Installs Jellyfin
    *   Starts the service
3.  **Verify access:** `http://<container-ip>:8096`

---

## Phase 4: GPU Passthrough (Proxmox 8.x Web UI)

1.  **Stop the Jellyfin container.**
2.  **Open Proxmox Web UI:**
    *   Select your Jellyfin Container.
    *   Go to **Resources** → **Add** → **Device Passthrough**.
3.  **Configure Passthrough:**
    *   **Device:** Select your NVIDIA GPU (e.g., `/dev/nvidia0` or `/dev/dri/renderD128`).
    *   **Mode:** `0666` (Read/Write access for all users - simplest for troubleshooting).
    *   **GID:** If using an **unprivileged** container (default), you may need to map the `render` group.
        *   Run `getent group render` inside the container to find the GID (often `105` or `108`).
        *   Enter this GID in the "Group ID" field in Proxmox.
4.  **Start the Container.**

---

## Phase 5: Install Drivers INSIDE the Container

> ⚠️ **CRITICAL STEP**: The container needs the *user-space* drivers to talk to the kernel module on the host.

1.  **Download the SAME NVIDIA `.run` file** you used on the host.
2.  **Copy it to the container** (or download it inside via `wget`).
3.  **Run the installer inside the LXC:**
    *   **Crucial flag:** `--no-kernel-module`. The container cannot install kernel modules; it uses the host's.

    ```bash
    ./NVIDIA-Linux-x86_64-xxx.xx.run --no-kernel-module
    ```
    *   Say "No" to updating X configuration if asked.

4.  **Verify INSIDE Container:**

    ```bash
    nvidia-smi
    ```
    *   If this works, the container has full access to the GPU!

---

## Phase 6: Enable Hardware Transcoding in Jellyfin

1.  **Open Jellyfin dashboard.**
2.  **Go to Playback → Transcoding.**
3.  **Enable:**
    *   **Hardware acceleration:** NVIDIA NVENC
    *   **Enable decoding for:** H.264, HEVC, MPEG2, VC1, VP8, VP9, AV1 (if supported).
    *   **Enable hardware encoding:** Checked.
4.  **Save settings.**
5.  **Test playback:** Play a movie and verify CPU usage is low and GPU usage is active (check `nvidia-smi` on host).

---

## Phase 7: Media Storage Mounts

1.  **Create media directories on host.**
2.  **Mount them into container** (Edit config or use UI):
    *   **UI Method:** Resources → Add → Mount Point.
    *   **Config Method (`/etc/pve/lxc/<CTID>.conf`):**

    ```ini
    mp0: /mnt/media/movies,mp=/media/movies
    mp1: /mnt/media/tv,mp=/media/tv
    ```

3.  **Restart container.**
