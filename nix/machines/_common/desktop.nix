# This config is only to contain x11 and gui pkgs
{ config, pkgs, ... }:

let
  # Nix firefox addons only work with the firefox-esr package.
  # https://github.com/NixOS/nixpkgs/blob/master/doc/builders/packages/firefox.section.md
  myFirefox = pkgs.wrapFirefox pkgs.firefox-esr-unwrapped {
    cfg = { smartcardSupport = true; };
    nixExtensions = [
      (pkgs.fetchFirefoxAddon {
        name = "ublock"; # Has to be unique!
        url = "https://addons.mozilla.org/firefox/downloads/file/3998742/ublock_origin-1.44.2.xpi"; # Get this from about:addons
        sha256 = "sha256:0zvsjsjlp0r1glqf0qpv425zshrwmimk1in1v339acwy1ysxkx00";
      })
      (pkgs.fetchFirefoxAddon {
        name = "bitwarden";
        url = "https://addons.mozilla.org/firefox/downloads/file/3986147/bitwarden_password_manager-2022.8.0.xpi";
        sha256 = "sha256:002lap6vn1n1k7w1pmrm996dg4x9802yvq33csyyizc6iwsbm3r0";
      })
      (pkgs.fetchFirefoxAddon {
        name = "zoomScheduler";
        url = "https://addons.mozilla.org/firefox/downloads/file/3979414/zoom_new_scheduler-2.1.29.xpi";
        sha256 = "sha256:18zsrcg82pbj08645k5pq970hyblmjs01fnwbv6hw31zwgb0bjyl";
      })

    ];
  };
in
{
  # install Desktop packages
  environment.systemPackages = with pkgs; [
    myFirefox # robs custom firefox
    chromium
    scrot # screenshots
    feh # set wallpaper
    zoom-us
    zathura # simple pdf viewer
    obsidian
    xsel
    viewnior
    mpv
    xournal # pdf annotations
    #imagemagick # dup might be a problem?
  ];

  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      defaultSession = "none+i3";
    };

    # This is the way
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu # simple launcher
        i3status # default i3 status bar
        i3lock # default + simple lock that matches my config
      ];
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # libinput.enable = true;
  };
}
