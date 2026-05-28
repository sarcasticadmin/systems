{ lib, config, pkgs, ... }:
let
  cfg = config.sarcasticadmin.wifi;

  inherit (lib.modules)
    mkIf
    ;

  inherit (lib.options)
    mkEnableOption
    ;
in
{
  options.sarcasticadmin.wifi.enable = mkEnableOption "enable wifi";

  config = mkIf cfg.enable {
    networking.wireless.iwd = {
      enable = true;
      settings = {
        Settings = {
          AutoConnect = false;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      impala
    ];

    fonts = {
      packages = with pkgs; [
        # impala needs symbols
        # https://github.com/pythops/impala/issues/8
        nerd-fonts.symbols-only
      ];
    };
  };
}
