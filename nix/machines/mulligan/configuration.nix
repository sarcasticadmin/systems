{ config, pkgs, lib, ... }:

let
  UdevRulesNinoTNC = pkgs.writeTextFile {
    name = "extra-udev-rules";
    text = ''
      KERNEL=="ttyACM*", SUBSYSTEMS=="usb", ATTRS{idProduct}=="00dd", SYMLINK+="ninotnc" TAG+="systemd" ENV{SYSTEMD_WANTS}+="ax25.target"
    '';
    destination = "/etc/udev/rules.d/99-ham.rules";
  };

in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Need to be set for ZFS or else leads to:
  # Failed assertions:
  # - ZFS requires networking.hostId to be set
  networking.hostId = "e2dbfa21";

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
      alsa-utils # Soundcard utils
      #ardopc
      aprx
      ax25-tools
      ax25-apps
      fend
      tncattach
      libax25
      hamlib_4
      pat
      flashtnc
      tmux
      screen
      tio
      kermit
      #wwl
    ];
  };

  services.udev.packages = [ UdevRulesNinoTNC ];

  services.ax25.axports.wl2k = {
    enable = true;
    baud = 57600;
    tty = "/dev/ninotnc";
    callsign = "KM6LBU-6";
    description = "ninotnc";
  };

  services.ax25.axlisten = {
    enable = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

  #services.beacond = {
  #  enable = true;
  #  interval = 5;
  #  message = "hello this is rob";
  #};

  # Enable tlp for stricter governance of power management
  # Validate status: `sudo tlp-stat -b`
  services.tlp = {
    enable = true;
  };

  #system.stateVersion = config.system.nixos.version;
  system.stateVersion = "25.05";
}
