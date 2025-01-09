{ config, pkgs, inputs, lib, ... }:
let
  aercUnstable = pkgs.callPackage ./aerc { };

  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./home.nix
      ./wg.nix
      ./nvim.nix
    ];

  # Necessary in most configurations
  nixpkgs.config.allowUnfree = true;

  # set nixpkgs to inputs.nixpkgs for `nix shell || run`
  nix.registry = {
    nixpkgs.to = {
      type = "path";
      path = inputs.nixpkgs;
    };
    nixpkgs-unstable.to = {
      type = "path";
      path = inputs.nixpkgs-unstable;
    };
  };

  nix.settings.trusted-users = [ "rherna" ];

  # remove the annoying experimental warnings
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # enabled apropos and "man -K" searching
  # https://nixos.org/manual/nixos/stable/options.html#opt-documentation.man.generateCaches
  documentation.man.generateCaches = true;

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
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint ];

  hardware.pulseaudio.enable = false;
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.pulse.enable = true;

  users.groups.plugdev = { };

  # allowed whitelist of insecure pkgs
  nixpkgs.config.permittedInsecurePackages = [ "olm-3.2.16" ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      awscli2
      cntr
      direnv
      element-desktop
      freetube
      gh
      glab
      ticker # stocks
      newsboat
      icdiff
      mosh
      imagemagick
      magic-wormhole
      pkgs-unstable.nixpkgs-review
      # hardware key
      gnupg
      pcsclite
      pinentry
      nmap
      mob
      strace
      tailscale
      android-udev-rules
      #vagrant  # broken as of 24.11
      pkgs-unstable.beeper
      pkgs-unstable.prusa-slicer
      pavucontrol
      openscad
      pulsemixer
      isync #mbsync
      protonmail-bridge
      #aerc
      aercUnstable
      notmuch
      afew
      msmtp
      tio
      xosd
      wireguard-tools
      ntfs3g
      chirp
    ];

    etc."wpa_supplicant.conf" = {
      source = "/persist/etc/wpa_supplicant.conf";
      mode = "symlink";
    };
  };

  users.users.rherna = {
      # adding extra keys from _common/users.nix
      openssh.authorizedKeys.keys = [ "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEJ4EITcSl4uGLHg7MGsQg/CaT4+jWfOBfp56xeyRcUnXYPslpATZlkMxfLTetdxi44VdjSl/i96ptofryCf4jQ=" ];
  };

  services.udev.packages = [ pkgs.android-udev-rules ];
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

  # Dont start tailscale by default
  services.tailscale.enable = false;
  # didnt work for me
  #systemd.services.tailscaled.after = [ "network-online.target" "systemd-resolved.service" ];
  # Remove warning from tailscale: Strict reverse path filtering breaks Tailscale exit node use and some subnet routing setups
  networking.firewall.checkReversePath = "loose";

  services.logind.extraConfig = "HandleLidSwitch=ignore";

  # part of gnupg reqs
  services.pcscd.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    # Make pinentry across multiple terminal windows, seamlessly
    enableSSHSupport = true;
  };

  # Mosh server setup with proper setguid
  programs.mosh.enable = true;

  programs.less.lessopen = lib.mkDefault null;

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

  programs.light.enable = true;
  systemd.services."actkbd@" =
    {
      # Not great but allows actkbd to be able to access the display and display vars easily
      serviceConfig.User = lib.mkForce "rherna";
    };

  services.actkbd =
  let
    osd_bar = "(export DISPLAY=:0.0; /run/current-system/sw/bin/osd_cat -A center -p bottom -o 120 -f -*-*-bold-*-*-*-36-120-*-*-*-*-*-* -c green -s 1 -d 2 -w -b percentage -P $(/run/current-system/sw/bin/light) -T brightness &)";
    #osd_bar = "(export DISPLAY=:0.0; /run/current-system/sw/bin/osd_cat -A center -p bottom -o 120 -f -*-*-bold-*-*-*-36-120-*-*-*-*-*-* -c green -d 1 -s 1 -a 0 -b percentage -P $(/run/current-system/sw/bin/light) -T brightness > /tmp/brightdown.log 2>&1)";
  in
  {
    enable = true;
    # Check key mappings:
    # Get event<num>: cat /proc/bus/input/devices | grep "Name\|Handlers"
    # Watch events: actkbd -n -s -d /dev/input/event<num>
    # F1-F4 = /dev/input/event0
    # F5-F8 = /dev/input/event2
    # F9-F12 = /dev/input/event6
    # T14 Gen 2
    # F5-F6 = /dev/input/event5
    # F7-F12 = /dev/input/event10
    bindings = [
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10; ${osd_bar}"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10; ${osd_bar}"; }
    ];
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

  services.lldpd.enable = true;

  systemd.services.zfs-scrub.unitConfig.ConditionACPower = true;

  # dont hiberate/sleep by default
  powerManagement.enable = false;
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  # Enable tlp for stricter governance of power management
  # Validate status: `sudo tlp-stat -b`
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 80;

      # Optional helps save long term battery health
      START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
      STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
    };
  };

  system.stateVersion = config.system.nixos.version;
}
