# The base toolchain that I expect on a system
{ inputs, pkgs, lib, ... }:

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
    nix-tree
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
    units # gnu-units for unit everyday unit conversions
  ];

  # set nixpkgs to inputs.nixpkgs for `nix shell || run`
  nix.registry = {
    nixpkgs.to = {
      type = "path";
      path = inputs.nixpkgs;
    };
    nixpkgs-unstable.to = {
      type = "path";
      path = inputs.nixpkgs-unstable;
    };
    nixpkgs-master.to = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
    };
  };

  nix.settings.trusted-users = [ "rherna" ];

  # remove the annoying experimental warnings
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Purge nano from being the default
  environment.variables = { EDITOR = "vim"; };
}
