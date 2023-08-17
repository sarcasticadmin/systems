# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  myReaverwps-t6x = pkgs.reaverwps-t6x.overrideAttrs (finalAttrs: previousAttrs: {
    version = "2023-07-19_unstable";
    src = pkgs.fetchFromGitHub {
      owner = "t6x";
      repo = "reaver-wps-fork-t6x";
      rev = "bd0f38262224c1b88ba9f1f95cb5476a488d2295";
      sha256 = "sha256-DE0Jai9EXioueo6HBTDTJUan7mA8b3f+o2LbvvMfgKg=";
    };
  });

  # For now use my fork until merged upstream
  myKismet = pkgs.kismet.overrideAttrs (finalAttrs: previousAttrs: {
    pname = "kismet";
    version = "2023-08-07_unstable";
    src = pkgs.fetchFromGitHub {
      #owner = "kismetwireless";
      owner = "sarcasticadmin";
      repo = "kismet";
      rev = "c0b1ab78f0eda395549ed59090ae2cbe44f7d2ed";
      sha256 = "sha256-8izDUtLbsR09u2rDoWJbB3QMWX6XNqZhs2qpYPugB7U=";
    };
    #nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ pkgs.breakpointHook ];
  });
in
{
  imports =
    [
      ./hardware-configuration.nix
      ../_common/desktop.nix
      ../_common/base.nix
    ];

  # Necessary in most configurations
  nixpkgs.config.allowUnfree = true;

  nix.settings.trusted-users = [ "rherna" ];

  # remove the annoying experimental warnings
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # enabled apropos and "man -K" searching
  # https://nixos.org/manual/nixos/stable/options.html#opt-documentation.man.generateCaches
  documentation.man.generateCaches = true;

  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8812au # Realtek usb adapter 0bda:8812
  ];

  # Disable scatter-gather so kernel doesnt crash for mediatek cards
  #   confirm via: cat /sys/modules/mt76_usb/parameters/disable_usb (should result in Y
  boot.extraModprobeConfig = ''
  options mt76-usb disable_usb_sg=1
  '';

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "rufio"; # Define your hostname.
  # Need to be set for ZFS or else leads to:
  # Failed assertions:
  # - ZFS requires networking.hostId to be set
  networking.hostId = "7f702d2b";

  # Enables wireless support via wpa_supplicant
  networking.wireless = {
    enable = true;
    # Limit wpa_supplicant to specific interface
    interfaces = [ "wlp3s0" ];
    # Option is misleading but we dont want it
    userControlled.enable = false;
    # Allow configuring networks "imperatively"
    allowAuxiliaryImperativeNetworks = true;
  };

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # dhcpcd will conflict with interfaces being put into monitoring mode
  networking.useDHCP = false;

  # Explicitly set interfaces we need dhcp on
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Tether to android
  networking.interfaces.enp0s20u2.useDHCP = true;

  # Make sure that dhcpcd doesnt timeout when interfaces are down
  # ref: https://nixos.org/manual/nixos/stable/options.html#opt-networking.dhcpcd.wait
  networking.dhcpcd.wait = "if-carrier-up";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rherna = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "audio" "sound" "docker" "plugdev" "libvirtd" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEiESod7DOT2cmT2QEYjBIrzYqTDnJLld1em3doDROq" ];
  };

  users.groups.plugdev = { };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      cntr
      gh
      glab
      ticker # stocks
      icdiff
      imagemagick
      magic-wormhole
      nixpkgs-review
      # hardware key
      gnupg
      pcsclite
      pinentry
      strace
      tailscale
      vagrant
      proxmark3-rrg
      aircrack-ng
      myKismet
      wifite2
      myReaverwps-t6x
      wireshark
      tshark
      tcpdump
      yt-dlp
      hashcat
      hashcat-utils
      hcxtools
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
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.cron = {
    enable = true;
    # Clean up nixOS generations
    # NOTE: Still requires a nix-rebuild switch to update grub
    # List generations: nix-env --list-generations -p /nix/var/nix/profiles/system
    systemCronJobs = [
      "0 1 * * * root nix-env --delete-generations +10 -p /nix/var/nix/profiles/system 2>&1 | logger -t generations-cleanup"
    ];
  };
  services.fwupd.enable = true;

  networking.firewall.checkReversePath = "loose";

  services.logind.extraConfig = "HandleLidSwitch=ignore";

  # part of gnupg reqs
  services.pcscd.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "tty";
    # Make pinentry across multiple terminal windows, seamlessly
    enableSSHSupport = true;
  };

  programs.ssh = {
    extraConfig = ''
      Host *
        # Fix timeout from client side
        # Ref: https://www.cyberciti.biz/tips/open-ssh-server-connection-drops-out-after-few-or-n-minutes-of-inactivity.html
        ServerAliveInterval 15
        ServerAliveCountMax 3
        # Keep ~C control seq enabled post ssh-9.2
        EnableEscapeCommandline yes
    '';
  };
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

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  systemd.services.zfs-scrub.unitConfig.ConditionACPower = true;

  # dont hiberate/sleep by default
  powerManagement.enable = false;
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  # Enable tlp for stricter governance of power management
  # Validate status: `sudo tlp-stat -b`
  services.tlp.enable = true;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
