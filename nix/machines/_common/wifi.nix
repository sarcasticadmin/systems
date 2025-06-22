{ pkgs, ... }:
{
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

}
