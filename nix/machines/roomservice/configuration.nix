{ config, pkgs, inputs, lib, ... }:
{
  imports =
    [
      ./disko.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];

  # Enables DHCP on each ethernet and wireless interface.
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;


  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "24.11";

  networking.hostName = "roomservice";

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot UEFI boot loader
  # Disko needs this for UEFI
  boot.loader.systemd-boot.enable = true;

  boot.zfs.extraPools = [ "tiger" ];
  # Ignore any datasets that are encrypted
  boot.zfs.requestEncryptionCredentials = [];

  # Need to be set for ZFS or else leads to:
  # Failed assertions:
  # - ZFS requires networking.hostId to be set
  # to generate: head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "7f5e8509";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root = {
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEiESod7DOT2cmT2QEYjBIrzYqTDnJLld1em3doDROq" ];
  };

  # remove the annoying experimental warnings
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  environment = {
    # Installs all necessary packages for the minimal
    systemPackages = with pkgs; [
      abcde
    ];

  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

  services.tlp.enable = true;
}
