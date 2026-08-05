{ lib, config, pkgs, ... }:
let
  cfg = config.sarcasticadmin.backlight;

  inherit (lib.modules)
    mkIf
    ;

  inherit (lib.options)
    mkEnableOption
    ;
in
{
  options.sarcasticadmin.backlight.enable = mkEnableOption "enable backlight";

  config = mkIf cfg.enable {
    hardware.acpilight.enable = true;

    environment.systemPackages = with pkgs; [
      acpilight # provides xbacklight
    ];
  };
}
