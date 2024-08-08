# The base toolchain that I expect on a system
{ config, pkgs, lib, ... }:

let
  # Need the pythons in my vims
  myVim = pkgs.vim-full.override { pythonSupport = true; };
in
{
  environment.systemPackages = with pkgs; [
    bc
    binutils
    bc
    btop
    coreutils
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
    pciutils
    shellcheck
    tree
    manix # useful search for nix docs
    unzip
  ] ++ lib.optionals (!stdenv.isDarwin) [
    dmidecode
    parted
    usbutils
    openssl # conflicts with nix-darwin
  ];

  # Purge nano from being the default
  environment.variables = { EDITOR = "vim"; };
}
