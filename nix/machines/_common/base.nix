# The base toolchain that I expect on a system
{ config, pkgs, ... }:

let
  # Need the pythons in my vims
  myVim = pkgs.vim_configurable.override { python = pkgs.python3; };
in
{
  # install Nebulaworks packages
  environment.systemPackages = with pkgs; [
    wget
    git
    git-lfs
    tmux
    ag
    stow
    gnumake
    myVim # Custom vim
    nixpkgs-fmt
    shellcheck
    manix # useful search for nix docs
    unzip
  ];
}
