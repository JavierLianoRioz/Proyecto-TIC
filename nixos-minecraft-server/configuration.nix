{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Basic system settings
  networking.hostName = "nixos-minecraft-server"; # Define your hostname
  time.timeZone = "UTC";

  # Enable the Minecraft server service
  services.minecraft = {
    enable = true;
    eula = true;
  };

  # Enable SSH for remote access (optional but useful)
  services.openssh.enable = true;

  # Users configuration
  users.users.root.initialPassword = "nixos"; # Change this password after install

  # Enable the NixOS firewall
  networking.firewall.enable = true;

  # Allow Minecraft default port 25565 through the firewall
  networking.firewall.allowedTCPPorts = [ 25565 ];

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  # Enable the OpenSSH daemon
  services.openssh.enable = true;

  # Enable the NixOS graphical environment (optional, can be removed)
  # services.xserver.enable = true;

  # System state version
  system.stateVersion = "23.05"; # Adjust to your NixOS version
}