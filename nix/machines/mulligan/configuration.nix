{ config, pkgs, lib, ... }:

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

  #boot.kernelPatches = [{
  #  name = "packet-radio-protocols";
  #  patch = null;
  #  extraConfig = ''
  #    HAMRADIO y
  #    AX25 y
  #    AX25_DAMA_SLAVE y
  #  '';
  #}];
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
    ];

    # libax25, etc. are set to assume the common config path
    # TODO: Definitely need to come up with a beter way to deal with this
    etc."ax25/axports" = {
      text = ''
        # me callsign speed paclen window description
        #
        wl2k km6lbu-6 57600 255 7 Winlink
      '';

      # The UNIX file mode bits
      mode = "0644";
    };

  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

  # Bug in kernels ~5.4<5.19
  # Resulting in pat to error with: address already in use error after first connection
  #boot.kernelPackages = pkgs.linuxPackages_6_0;

  services.tlp.enable = true;
}
