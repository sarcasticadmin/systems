# The base toolchain that I expect on a system
{ config, pkgs, ... }:

let
  # Need the pythons in my vims
  myVim = pkgs.vim_configurable.override { pythonSupport = true; };
in
{
  # install Nebulaworks packages
  environment.systemPackages = with pkgs; [
    btop
    dig
    file
    wget
    git
    git-lfs
    ldns
    tmux
    silver-searcher
    stow
    gnumake
    jq
    lsof
    myVim # Custom vim
    nixpkgs-fmt
    openssl
    shellcheck
    tree
    manix # useful search for nix docs
    unzip
  ];
}
