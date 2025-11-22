{ config, pkgs, ... }:
{
  boot.kernelParams = [ "console=ttyS0,115200n8" ];
  boot.loader.grub.extraConfig = "
    serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
    terminal_input serial
    terminal_output serial
  ";
  # Some secure defaults
  boot.tmp.cleanOnBoot = true;

  environment.systemPackages = with pkgs; [
    wget
    git
    vim
  ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
  # Enables the smart card mode of the Yubikey
  services.pcscd.enable = true;

  services.fwupd.enable = true;

  # Sets the root user to have an empty password
  services.getty.helpLine = "The 'root' account has an empty password.";
  users.extraUsers.root = {
    initialHashedPassword = "";
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEiESod7DOT2cmT2QEYjBIrzYqTDnJLld1em3doDROq" ];
  };

  networking.firewall.enable = false;
  networking.useDHCP = true;
}
