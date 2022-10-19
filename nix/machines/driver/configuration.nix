# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  # Locals
in
{
  imports =
    [
      ../_common/desktop.nix
      ../_common/base.nix
      # Import nix-garage
      ./nix-garage-overlay.nix
      ./home.nix
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

  networking.hostName = "driver"; # Define your hostname.
  # Need to be set for ZFS or else leads to:
  # Failed assertions:
  # - ZFS requires networking.hostId to be set
  networking.hostId = "6f602d2b";

  # Enables wireless support via wpa_supplicant
  networking.wireless.enable = true;
  # Option is misleading but we dont want it
  networking.wireless.userControlled.enable = false;
  # Allow configuring networks "imperatively"
  networking.wireless.allowAuxiliaryImperativeNetworks = true;

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Make sure that dhcpcd doesnt timeout when interfaces are down
  # ref: https://nixos.org/manual/nixos/stable/options.html#opt-networking.dhcpcd.wait
  networking.dhcpcd.wait = "if-carrier-up";
  networking.interfaces.enp2s0f0.useDHCP = true;
  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Leave commented until tether is needed
  #networking.interfaces.enp7s0f4u2.useDHCP = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rherna = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "audio" "sound" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEiESod7DOT2cmT2QEYjBIrzYqTDnJLld1em3doDROq" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      awscli2
      gh
      ticker # stocks
      newsboat
      imagemagick
      nixpkgs-review
      # hardware key
      gnupg
      pcsclite
      pinentry
    ];

    etc."wpa_supplicant.conf" = {
      source = "/persist/etc/wpa_supplicant.conf";
      mode = "symlink";
    };
  };
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  services.logind.extraConfig = "HandleLidSwitch=ignore";

  # part of gnupg reqs
  services.pcscd.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # ZFS
  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
    autoSnapshot = {
      enable = true;
      monthly = 3;
    };
  };

  systemd.services.zfs-scrub.unitConfig.ConditionACPower = true;

  # dont hiberate/sleep by default
  powerManagement.enable = false;
  # Enable tlp for stricter governance of power management
  # Validate status: `sudo tlp-stat -b`
  services.tlp.enable = true;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
