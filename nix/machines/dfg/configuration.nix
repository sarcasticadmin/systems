{ config, pkgs, inputs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./disko.nix
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

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dfg"; # Define your hostname.
  
  # dhcpcd will conflict with interfaces being put into monitoring mode
  networking.useDHCP = true;

  services.ax25 = {
    axports = { 
      w2lk = {
        enable = true;
        buad = 57600;
        callsign = "KM6LBU-11";
        tty = "/dev/ttyACM0";
        kissParams = "-t 300 -l 10 -s 12 -r 80 -f n";
      };
    };
    axlisten = {
      enable = true;
    };
  }
  # Make sure that dhcpcd doesnt timeout when interfaces are down
  # ref: https://nixos.org/manual/nixos/stable/options.html#opt-networking.dhcpcd.wait
  networking.dhcpcd.wait = "if-carrier-up";

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
    ];
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

  # Enable tlp for stricter governance of power management
  # Validate status: `sudo tlp-stat -b`
  services.tlp.enable = true;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
