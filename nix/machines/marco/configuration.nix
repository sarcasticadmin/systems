# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  # Without it: import plugins seems to fail with: "No GSettings schemas are installed on the system"
  # https://github.com/NixOS/nixpkgs/issues/16285
  # https://github.com/NixOS/nixpkgs/pull/220336
  myOpencpn = pkgs.opencpn.overrideAttrs (old: { buildInputs = old.buildInputs ++ [ pkgs.wrapGAppsHook ]; });
  imgkap = pkgs.stdenv.mkDerivation rec {
    # https://github.com/bdbcat/o-charts_pi.git
    pname = "imgkap";
    version = "1.16.2";

    src = pkgs.fetchFromGitHub {
      owner = "nohal";
      repo = "imgkap";
      rev = "v${version}";
      hash = "sha256-Dthx6yS1ApirQ6AHFDG0kuHDnPGPVUTInwMzyyh5WTQ=";
    };
    buildInputs = with pkgs; [
      freeimage
    ];
    installPhase = ''
      mkdir -p $out/bin
      cp imgkap $out/bin
    '';
  };

  oChartsPlugin = pkgs.stdenv.mkDerivation rec {
    # https://github.com/bdbcat/o-charts_pi.git
    pname = "o-charts_pi";
    version = "1.0.34.0";

    src = pkgs.fetchFromGitHub {
      owner = "bdbcat";
      repo = "o-charts_pi";
      rev = "${version}";
      hash = "sha256-UP6alDMglvp4tGs1eGMx9uFx5IMDm43NBlTL7em0a4I=";
    };
    nativeBuildInputs = with pkgs; [
      cmake
      pkg-config
      gettext
      xorg.libX11.dev
    ] ++ lib.optionals stdenv.isLinux [
      lsb-release
    ];
    buildInputs = with pkgs; [
      wxGTK31 # Instead of wxGTK32 due to deprecation errors - maybe try compat in 32 later?
      tinyxml
      zlib
      curl
      libGLU
      libGL
    ];
    #cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];
    #SEARCH_LIB = "${pkgs.libGLU.out}/lib ${pkgs.libGL.out}/lib";
  };
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

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "marco"; # Define your hostname.
  # Need to be set for ZFS or else leads to:
  # Failed assertions:
  # - ZFS requires networking.hostId to be set
  networking.hostId = "6f602d2a";

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
  networking.interfaces.enp0s25.useDHCP = true;
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
    extraGroups = [ "wheel" "audio" "sound" "dialout" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEiESod7DOT2cmT2QEYjBIrzYqTDnJLld1em3doDROq" ];
  };

  environment = {
    systemPackages = with pkgs; [
      newsboat
      gpsd # explicitly include in pkgs to get gpsd clients: gpsctl, etc
      myOpencpn
      oChartsPlugin
      imgkap
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

  services.gpsd = {
    enable = true;
    # -n and required for opencpn to use the gps
    nowait = true;
    # TODO: figure out a better way than hardcoding the serial device
    device = "/dev/ttyACM0";
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
  system.stateVersion = "22.11"; # Did you read the comment?

}