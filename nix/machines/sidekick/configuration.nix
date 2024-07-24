# Edit this configuration file to define what should be installed on
{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./disko.nix
      #../_common/base.nix
    ];

  # Necessary in most configurations
  nixpkgs.config.allowUnfree = true;

  # remove the annoying experimental warnings
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sidekick"; # Define your hostname.

  security.sudo.wheelNeedsPassword = false;
  # Enables wireless support via wpa_supplicant
  networking.wireless.enable = false;

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = true;

  # Make sure that dhcpcd doesnt timeout when interfaces are down
  # ref: https://nixos.org/manual/nixos/stable/options.html#opt-networking.dhcpcd.wait
  networking.dhcpcd.wait = "if-carrier-up";

  sound.enable = false;

  users.users.rherna = {
      # adding extra keys from _common/users.nix
      openssh.authorizedKeys.keys = [ "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEJ4EITcSl4uGLHg7MGsQg/CaT4+jWfOBfp56xeyRcUnXYPslpATZlkMxfLTetdxi44VdjSl/i96ptofryCf4jQ=" ];
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  system.stateVersion = "23.05";
}
