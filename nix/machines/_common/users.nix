{ pkgs, lib, config, ... }:

{
  users.users.rherna = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ]
      ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd"
      ++ lib.optional config.virtualisation.docker.enable "docker"
      ++ lib.optionals config.sound.enable [ "audio" "sound" ]
      ++ lib.optional (lib.hasAttrByPath [ "plugdev" ] config.users.groups) "plugdev";
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEiESod7DOT2cmT2QEYjBIrzYqTDnJLld1em3doDROq" ];
  };
}
