{ config, pkgs, inputs, lib, ... }:
let
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
    ];

  # need to be 6.18 to avoid https://copy.fail/
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # enabled apropos and "man -K" searching
  # https://nixos.org/manual/nixos/stable/options.html#opt-documentation.man.generateCaches
  documentation.man.cache.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Give me all network logs
  systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";

  networking = {
    hostName = "driver"; # Define your hostname.
    # Need to be set for ZFS or else leads to:
    # Failed assertions:
    # - ZFS requires networking.hostId to be set
    hostId = "6f602d2b";

    # use systemd.networkd full stop
    useNetworkd = true;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;

    interfaces.enp2s0f0.useDHCP = true;
    interfaces.enp5s0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;

    # Leave commented until tether is needed
    #interfaces.enp7s0f4u2.useDHCP = true;
  };

  # The notion of "online" is a broken concept
  # also cant guarantee that laptop will always have a connection
  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  # https://github.com/NixOS/nixpkgs/issues/247608
  systemd.network.wait-online.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint ];

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
      awscli2
      cntr
      direnv
      element-desktop
      pkgs-unstable.freetube
      gh
      glab
      pkgs-unstable.ticker # stocks
      newsboat
      icdiff
      mosh
      imagemagick
      magic-wormhole
      pkgs-unstable.nixpkgs-review
      nmap
      mob
      strace
      tailscale
      twingate
      #vagrant  # broken as of 24.11
      pkgs-unstable.beeper
      pkgs-unstable.signal-desktop
      pkgs-unstable.prusa-slicer
      pavucontrol
      openscad
      pulsemixer
      isync #mbsync
      protonmail-bridge
      notmuch
      afew
      msmtp
      tio
      xosd
      wireguard-tools
      ntfs3g
      chirp
      pkgs-unstable.cc-tool # TI CC Debugger
      inputs.self.packages.${pkgs.system}.cm108
      inputs.self.packages.${pkgs.system}.accrip
      inputs.self.packages.${pkgs.system}.myabcde
    ];
  };

  users.users.rherna = {
      # adding extra keys from _common/users.nix
      openssh.authorizedKeys.keys = [ "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEJ4EITcSl4uGLHg7MGsQg/CaT4+jWfOBfp56xeyRcUnXYPslpATZlkMxfLTetdxi44VdjSl/i96ptofryCf4jQ=" ];
  };

  services.udev.packages = with pkgs; [
    pkgs-unstable.cc-tool # TI CC Debugger
    direwolf
  ];
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

  services.logind.settings.Login = { HandleLidSwitch = "ignore"; };

  # Mosh server setup with proper setguid
  programs.mosh.enable = true;

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

  systemd.services."actkbd@" =
    {
      # Not great but allows actkbd to be able to access the display and display vars easily
      serviceConfig.User = lib.mkForce "rherna";
    };

  services.actkbd =
  let
    backlight = pkgs.writeShellScript "backlight.sh" ''
       export DISPLAY=:0.0
       # this doesnt work
       #pkill -f osd_cat 2>/dev/null || true

       ${pkgs.xosd}/bin/osd_cat -A center -p bottom -o 120 \
         -f "-*-*-bold-*-*-*-36-120-*-*-*-*-*-*" \
         -c green -s 1 -d 2 -w -b percentage \
         -P $(${lib.getExe pkgs.acpilight}) -get &
    '';
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
      { keys = [ 224 ]; events = [ "key" ]; command = "${lib.getExe pkgs.acpilight} -inc 10; ${backlight}"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "${lib.getExe pkgs.acpilight} -dec 10; ${backlight}"; }
      { keys = [ 227 ]; events = [ "key" ]; command = "export DISPLAY=:0.0; /run/current-system/sw/bin/autorandr --force common; echo 'autorandr: common' | /run/current-system/sw/bin/osd_cat -A center -p bottom -o 120 -f -*-*-bold-*-*-*-36-120-*-*-*-*-*-* -c green"; }
    ];
  };

  # List services that you want to enable:

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

  sarcasticadmin = {
    mynvim.enable = true;
    base.enable = true;
    users.rherna.enable = true;
    hardwareToken.enable = true;
    nix = {
      inherit (inputs) nixpkgs nixpkgs-unstable;
      enable = true;
    };
    i3.enable = true;
    wifi.enable = true;
    backlight.enable = true;
  };

  # dont autostart the VPN
  services.twingate.enable = false;
}
