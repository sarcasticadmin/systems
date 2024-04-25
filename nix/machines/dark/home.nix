{ config, pkgs, inputs, ... }:
let
  linker = import ../../lib/generic-linker.nix;
in
# Small example use case
linker [
  {
    origin = "${inputs.self.packages.${pkgs.system}.dotfiles}/bash/.bashrc";
    target = ".bashrc";
  }
  {
    origin = "${inputs.self.packages.${pkgs.system}.dotfiles}/bash/.bashrc.d";
    target = ".bashrc.d";
  }
  {
    origin = "${inputs.self.packages.${pkgs.system}.dotfiles}/tmux/.tmux.conf";
    target = ".tmux.conf";
  }
  {
    origin = "${inputs.self.packages.${pkgs.system}.dotfiles}/alacritty/.config/alacritty/alacritty.yml";
    target = ".alacritty.yml";
  }

] "/home/rherna"
