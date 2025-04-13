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

  boot.kernelPackages = pkgs.linuxPackages_ham;

  environment = {
    # Installs all necessary packages for the minimal
    systemPackages = with pkgs; [
      alsa-utils # Soundcard utils
      ardopc
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
      wwl
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

  services.udev.packages = [ UdevRulesNinoTNC ];

  #boot.initrd.extraUdevRulesCommands =
  #  ''
  #    cat <<'EOF' > $out/99-other.rules
  #    ${config.boot.initrd.services.udev.rules}
  #    EOF
  #  '';

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

  # Bug in kernels ~5.4<5.19
  # Resulting in pat to error with: address already in use error after first connection
  #boot.kernelPackages = pkgs.linuxPackages_6_0;

  # Enable tlp for stricter governance of power management
  # Validate status: `sudo tlp-stat -b`
  services.tlp = {
    enable = true;
  };

  system.stateVersion = config.system.nixos.version;
}
