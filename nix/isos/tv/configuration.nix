{ config, pkgs, ... }:
{

  imports = [
    ../../machines/_common/users.nix
  ];

  nixpkgs.config.allowUnfree = true;

  users.users.rherna.initialHashedPassword = "$6$yOjsY1t3c1l5OHyP$flrfkFAwmZG6ZJKVE.t3.IlkW0cQzzTH3E6lWc2.ccHezDwnpSgrERllJx4UGQuBrWp2u1LiZZgziWW3F/CYs/";

  environment.systemPackages = with pkgs; [
    wget
    vim
    google-chrome
  ];

  services.openssh = {
    enable = true;
  };

  # good baseline of fonts
  fonts = {
    enableDefaultPackages = true;
  };

  services.xserver.desktopManager.mate.enable = true;
  services.xserver.enable = true;

  networking.networkmanager.enable = true;
  networking.wireless.enable = false;
}
