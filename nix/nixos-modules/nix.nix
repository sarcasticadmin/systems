{ config, lib, ... }:
let
  cfg = config.sarcasticadmin.nix;

  inherit (lib.modules)
    mkIf
    ;

  inherit (lib)
    types
    ;

  inherit (lib.options)
    mkEnableOption
    mkOption
    ;
in
{
  options.sarcasticadmin.nix = {
    enable = mkEnableOption "enable the nix command options";
    nixpkgs = mkOption {
       type = types.path;
       description = ''
         nixpkgs input for registry
       '';
    };
    nixpkgs-unstable = mkOption {
       type = types.path;
       description = ''
         nixpkgs-unstable input for registry
       '';
    };
  };

  config = mkIf cfg.enable {

    # set nixpkgs to inputs.nixpkgs for `nix shell || run`
    nix = {
      registry = {
        nixpkgs.to = {
          type = "path";
          path = cfg.nixpkgs;
        };
        nixpkgs-unstable.to = {
          type = "path";
          path = cfg.nixpkgs-unstable;
        };
        nixpkgs-master.to = {
          type = "github";
          owner = "NixOS";
          repo = "nixpkgs";
        };
      };
      settings = {
        # remove the annoying experimental warnings
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        # allow everyone in wheel group able to nixos-rebuild
        trusted-users = [ "@wheel" ];
      };
    };
    nixpkgs.config.allowUnfree = true;

    # set stateVersion to nixos.release
    system.stateVersion = config.system.nixos.release;
  };
}
