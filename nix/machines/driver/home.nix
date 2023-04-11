{ config, pkgs, ... }:
let
  # Locals
  dotfiles = pkgs.callPackage ./dotfiles.nix { };
  linker = import ../../lib/generic-linker.nix;
in
  # Small example use case
  linker [{
  origin = "${dotfiles}/xpdf/.xpdfrc";
  target = ".xpdfrc";
}] "/home/rramirez"
