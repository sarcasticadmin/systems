{ config, pkgs, inputs, ... }:
let
  linker = import ../../lib/generic-linker.nix;
  dotfiles = inputs.self.packages.${pkgs.system}.dotfiles;
in
linker [
  {
    origin = "${dotfiles}/bash/.bash_profile";
    target = ".bash_profile";
  }
  {
    origin = "${dotfiles}/bash/.bashrc";
    target = ".bashrc";
  }
  {
    origin = "${dotfiles}/bash/.bashrc.d";
    target = ".bashrc.d";
  }
  {
    origin = "${dotfiles}/tmux/.tmux.conf";
    target = ".tmux.conf";
  }
] "/root"
