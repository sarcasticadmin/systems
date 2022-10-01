{ config, pkgs, ... }:

let
  # Using pkgs.fetchFromGitHub causes infinite recursion
  nix-garage = builtins.fetchGit {
    url = "https://github.com/nebulaworks/nix-garage";
    rev = "e5baed156d59f36776ef8e4e8cd63d8850ed63fa";
  };
  garage-overlay = import (nix-garage.outPath + "/overlay.nix");
in
{
  nixpkgs.overlays = [ garage-overlay ];

  # install Nebulaworks packages
  environment.systemPackages = with pkgs; [
    aws-key-rotator
    git-divergence
    sshcb
    terraform-config-inspect
  ];
}
