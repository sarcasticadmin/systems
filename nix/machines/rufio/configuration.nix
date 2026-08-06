{ config, pkgs, inputs, ... }:
let
  # myReaverwps-t6x = pkgs.reaverwps-t6x.overrideAttrs (finalAttrs: previousAttrs: {
  #   version = "2023-07-19_unstable";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "t6x";
  #     repo = "reaver-wps-fork-t6x";
  #     rev = "bd0f38262224c1b88ba9f1f95cb5476a488d2295";
  #     sha256 = "sha256-DE0Jai9EXioueo6HBTDTJUan7mA8b3f+o2LbvvMfgKg=";
  #   };
  # });

  # Use unstable since there hasn't been a release in year+
  # myKismet = pkgs.kismet.overrideAttrs (finalAttrs: previousAttrs: {
  #   pname = "kismet";
  #   version = "2025-08-06_unstable";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "kismetwireless";
  #     repo = "kismet";
  #     rev = "62599e6ee19b149fb98ca75e7d9a91dbd90a45b9";
  #     sha256 = "sha256-oYj7ysGxJbSCg8SboCtD8iIRBlrDrRpcZf0UCc3pATc=";
  #   };
  #   buildInputs = previousAttrs.buildInputs ++ [ pkgs.mosquitto pkgs.rtl-sdr-librtlsdr ];
  #   #nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ pkgs.breakpointHook ];
  # });
in
{
  imports =
    [
      ./hardware-configuration.nix
      ../_common/desktop.nix
      ./disko.nix
    ];

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
  networking = {
      hostName = "rufio"; # Define your hostname.
      # Need to be set for ZFS or else leads to:
      # Failed assertions:
      # - ZFS requires networking.hostId to be set
      hostId = "38590d79";

      # use systemd.networkd full stop
      useNetworkd = true;

      # The global useDHCP flag is deprecated, therefore explicitly set to false here.
      # Per-interface useDHCP will be mandatory in the future, so this generated config
      # replicates the default behaviour.
      useDHCP = false;

      interfaces.enp6s0.useDHCP = true;
      interfaces.wlan0.useDHCP = true;
    };

  # The notion of "online" is a broken concept
  # also cant guarantee that laptop will always have a connection
  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  # https://github.com/NixOS/nixpkgs/issues/247608
  systemd.network.wait-online.enable = false;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Enable sound.
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
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
      pinentry-tty
      strace
      tailscale
      vagrant
      proxmark3
      aircrack-ng
      #myKismet
      kismet
      wifite2
      #myReaverwps-t6x
      wireshark
      tshark
      tcpdump
      yt-dlp
      hashcat
      hashcat-utils
      hcxtools
      sdrpp
      john # john the ripper
    ];
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

  services.logind.settings.Login = { HandleLidSwitch = "ignore"; };

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

  # dont hiberate/sleep by default
  powerManagement.enable = false;
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  # Enable tlp for stricter governance of power management
  # Validate status: `sudo tlp-stat -b`
  services.tlp.enable = true;

  sarcasticadmin = {
    mynvim.enable = true;
    base.enable = true;
    users.rherna.enable = true;
    hardwareToken.enable = true;
    nix = {
      inherit (inputs) nixpkgs nixpkgs-unstable;
      enable = true;
    };
    wifi.enable = true;
  };}
