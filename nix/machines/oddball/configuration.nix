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
      ./disko.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot UEFI boot loader
  # Disko needs this for UEFI
  boot.loader.systemd-boot.enable = true;

  # Need to be set for ZFS or else leads to:
  # Failed assertions:
  # - ZFS requires networking.hostId to be set
  # to generate: head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "8cf24204";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root = {
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEiESod7DOT2cmT2QEYjBIrzYqTDnJLld1em3doDROq" ];
  };

  # remove the annoying experimental warnings
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  boot.kernelPatches = lib.singleton {
    name = "ax25-ham";
    patch = null;
    extraStructuredConfig = with lib.kernel; {
      HAMRADIO = yes;
      AX25 = yes;
      AX25_DAMA_SLAVE = yes;
    };
  };

  environment = {
    # Installs all necessary packages for the minimal
    systemPackages = with pkgs; [
      alsa-utils # Soundcard utils
      ardopc
      aprx
      ax25-tools
      ax25-apps
      tncattach
      libax25
      hamlib_4
      pat
      flashtnc
      tmux
      screen
      tio
      kermit
      wwl
      wsjtx
      js8call
      fldigi
      tncattach
    ];

    # libax25, etc. are set to assume the common config path
    # TODO: Definitely need to come up with a beter way to deal with this
    etc."ax25/axports" = {
      text = ''
        # me callsign speed paclen window description
        #
        wl2k km6lbu-5 57600 255 7 Winlink
      '';

      # The UNIX file mode bits
      mode = "0644";
    };

  };

  services.udev.packages = [ UdevRulesNinoTNC ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

  services.ax25d = {
    enable = true;
  };

  services.mheardd = {
    enable = true;
  };

  #services.beacond = {
  #  enable = true;
  #  interval = 5;
  #  message = "hello this is rob";
  #};

  services.axlistend = {
    enable = true;
  };

  services.tlp.enable = true;
}
