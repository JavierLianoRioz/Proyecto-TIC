# NixOS Minecraft Server Installation Instructions

These instructions guide you through installing NixOS on a virtual machine using the NixOS ISO and applying the provided configuration to run a Minecraft server.

## Prerequisites

- A virtualization platform (e.g., VirtualBox, VMware, QEMU)
- NixOS ISO image (e.g., `ISOs/nixos.iso` in this project)

## Installation Steps

1. **Create a new virtual machine**

   - Allocate sufficient RAM (at least 2GB recommended)
   - Create a virtual hard disk (at least 10GB recommended)
   - Mount the NixOS ISO as the VM's bootable CD/DVD

2. **Boot the VM from the NixOS ISO**

3. **Partition and format the disk**

   Use `fdisk` or `parted` to create partitions, then format them (e.g., ext4 for root).

4. **Mount the partitions**

   Mount the root partition to `/mnt`.

5. **Copy the configuration files**

   Copy the `configuration.nix` and `hardware-configuration.nix` files from this directory (`nixos-minecraft-server/`) to `/mnt/etc/nixos/` inside the VM.

   You can use a USB drive, shared folder, or network transfer to move these files.

6. **Generate hardware-configuration.nix**

   If you don't have `hardware-configuration.nix`, generate it by running:

   ```
   nixos-generate-config --root /mnt
   ```

   Then merge or replace the existing `hardware-configuration.nix` in `/mnt/etc/nixos/`.

7. **Install NixOS**

   Run the installation command:

   ```
   nixos-install
   ```

   Set a root password if prompted.

8. **Reboot**

   After installation completes, reboot the VM and remove the ISO from the virtual drive.

9. **Start the Minecraft server**

   The Minecraft server service is enabled by default in the configuration. It will start automatically on boot.

10. **Access the Minecraft server**

    Connect to the VM's IP address on port 25565 using a Minecraft client.

## Notes

- You may want to change the root password and hostname in `configuration.nix` before installation.
- Ensure the VM's network is configured to allow incoming connections on port 25565.
- For more advanced configuration, refer to the [NixOS manual](https://nixos.org/manual/nixos/stable/).