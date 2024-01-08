# The base toolchain that I expect on a system
{ config, pkgs, ... }:

let
  # Need the pythons in my vims
  myVim = pkgs.vim-full.override { pythonSupport = true; };
in
{
  # install Nebulaworks packages
  environment.systemPackages = with pkgs; [
    bc
    binutils
    bc
    btop
    cachix
    dig
    dmidecode
    file
    wget
    git
    git-lfs
    gptfdisk #sgdisk, sfdisk, etc.
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
    pciutils
    parted
    shellcheck
    tree
    manix # useful search for nix docs
    usbutils
    unzip
  ];

  # Purge nano from being the default
  environment.variables = { EDITOR = "vim"; };
}
