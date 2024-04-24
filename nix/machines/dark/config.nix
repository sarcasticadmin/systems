{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [
      ./hardware-config.nix
      ./disko.nix
      ./home.nix
    ];

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "23.11";

  networking.hostName = "darktangent";

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot UEFI boot loader
  # Disko needs this for UEFI
  boot.loader.systemd-boot.enable = true;

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
      tmux
      tio
      firefox
      neofetch
    ];
    gnome.excludePackages = (with pkgs; [
      gnome-photos
      gnome-tour
    ]) ++ (with pkgs.gnome; [
      gnome-music
      epiphany # web browser
      geary # email reader
      totem # video player
      iagno # go game
      atomix # puzzle game
    ]);
  };

  # need for any user thats using the camera
  users.users.rherna.extraGroups = [ "video" ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

  # conflicts with gnome power-profiles-daemon
  #services.tlp.enable = true;

  services.gnome = {
    games.enable = true;
    sushi.enable = true;
  };

  services.xserver = {
    enable = true;
    desktopManager = {
      gnome.enable = true;
    };
    displayManager.gdm.enable = true;
  };
}
