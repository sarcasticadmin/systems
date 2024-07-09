# The base toolchain that I expect on a system
{ config, pkgs, lib, ... }:

let
  # Need the pythons in my vims
  myVim = pkgs.vim-full.override { pythonSupport = true; };
in
{
  # install Nebulaworks packages
  environment.systemPackages = with pkgs; ([
    bc
    binutils
    bc
    btop
    cachix
    dig
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
    inetutils # telnet,ftp,etc
    myVim # Custom vim
    neovim
    ripgrep # needed for nvim telescope
    nixpkgs-fmt
    openssl
    pciutils
    shellcheck
    tree
    manix # useful search for nix docs
    unzip
  ] ++ lib.optionals (!stdenv.isDarwin) [
    pkgs.dmidecode
    pkgs.parted
    pkgs.usbutils
  ]);

  # Purge nano from being the default
  environment.variables = { EDITOR = "vim"; };
}
