{ config, pkgs, ... }:

let
  # Using pkgs.fetchFromGitHub causes infinite recursion
  nix-garage = builtins.fetchGit {
    url = "https://github.com/nebulaworks/nix-garage";
    rev = "22a0c8fb0b39bf3a440fdf3e2ff514a24022a13d";
  };
  garage-overlay = import (nix-garage.outPath + "/overlay.nix");
in
{
  nixpkgs.overlays = [ garage-overlay ];

  # install Nebulaworks packages
  environment.systemPackages = with pkgs; [
    aws-key-rotator
    git-divergence
    # Currently broken
    #sshcb
    terraform-config-inspect
  ];
}
