{ pkgs, lib, config, ... }:

{
  # allow me to remote nixos-rebuild switch
  nix.settings.trusted-users = [ "rherna" ];

  users.users.rherna = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "dialout" ]
      ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd"
      ++ lib.optional config.virtualisation.docker.enable "docker"
      ++ lib.optional config.programs.light.enable "video"
      ++ lib.optional config.services.actkbd.enable "input"
      ++ lib.optionals config.services.pipewire.enable [ "audio" "sound" ]
      ++ lib.optional (lib.hasAttrByPath [ "plugdev" ] config.users.groups) "plugdev";
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEiESod7DOT2cmT2QEYjBIrzYqTDnJLld1em3doDROq" ];
  };
}
