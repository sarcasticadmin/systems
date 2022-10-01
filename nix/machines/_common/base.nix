# The base toolchain that I expect on a system
{ config, pkgs, ... }:

let
  # Need the pythons in my vims
  myVim = pkgs.vim_configurable.override { pythonSupport = true; };
in
{
  # install Nebulaworks packages
  environment.systemPackages = with pkgs; [
    wget
    git
    git-lfs
    tmux
    silver-searcher
    stow
    gnumake
    lsof
    myVim # Custom vim
    nixpkgs-fmt
    shellcheck
    tree
    manix # useful search for nix docs
    unzip
  ];
}
