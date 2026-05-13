{ config, pkgs, lib, ... }:
let
  cfg = config.sarcasticadmin.base;

  # Need the pythons in my vims
  myVim = pkgs.vim-full.override { pythonSupport = true; };

  inherit (lib.modules)
    mkIf
    ;

  inherit (lib.options)
    mkEnableOption
    ;
in
{
  options.sarcasticadmin.base.enable = mkEnableOption "enable the base of every system";

  # The base toolchain that I expect on a system
  config = mkIf cfg.enable {

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
      zip
      unzip
    ] ++ lib.optionals (!stdenv.isDarwin) [
      dmidecode
      parted
      usbutils
      openssl # conflicts with nix-darwin
      units # gnu-units for unit everyday unit conversions
    ];

    # Purge nano from being the default
    # this will also work for nvim since if its enabled it points vim -> nvim
    environment.variables = { EDITOR = "vim"; };
  };
}
