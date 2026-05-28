{ lib, config, pkgs, ... }:
let
  cfg = config.sarcasticadmin.hardwareToken;

  inherit (lib.modules)
    mkIf
    ;

  inherit (lib.options)
    mkEnableOption
    ;
in
{
  options.sarcasticadmin.hardwareToken.enable = mkEnableOption "enable my hardware token";

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        gnupg
        pcsclite
        pinentry-tty
      ];
    };
    # part of gnupg reqs
    services.pcscd.enable = true;
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    #
    # Troubleshooting: sudo journalctl -n 500 | grep agent
    programs.gnupg.agent = {
      enable = true;
      # Make pinentry across multiple terminal windows, seamlessly
      enableSSHSupport = true;
    };

    # since gpg-agent looks for fullpath (/usr/bin/pinentry-tty)
    # keep this symlink to ensure compat across all systems
    systemd.tmpfiles.rules = [
      "L+ /usr/bin/pinentry-tty - - - - ${pkgs.pinentry-tty}/bin/pinentry-tty"
    ];
  };
}

