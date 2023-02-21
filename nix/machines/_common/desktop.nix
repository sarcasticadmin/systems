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
        url = "https://addons.mozilla.org/firefox/downloads/file/4047353/ublock_origin-1.46.0.xpi"; # Get this from about:addons
        sha256 = "sha256-a/ivUmY1P6teq9x0dt4CbgHt+3kBsEMMXlOfZ5Hx7cg=";
      })
      (pkgs.fetchFirefoxAddon {
        name = "bitwarden";
        url = "https://addons.mozilla.org/firefox/downloads/file/4046308/bitwarden_password_manager-2022.12.1.xpi";
        sha256 = "sha256-fSixe/USIr9gUUK5GJoYHgUYTJWTfHKQbqH48I8jq7A=";
      })
      (pkgs.fetchFirefoxAddon {
        name = "zoomScheduler";
        url = "https://addons.mozilla.org/firefox/downloads/file/4048126/zoom_new_scheduler-2.1.37.xpi";
        sha256 = "sha256-Tj8DU5fxLIp3UgHZfD4hMhO/yKiQNlzCa1U6dOVjVAY=";
      })
    ];
  };
in
{
  # install Desktop packages
  environment.systemPackages = with pkgs; [
    myFirefox # robs custom firefox
    autorandr # cli xrandr tool for saving/load profiles
    arandr # ui xrandr tool for interacting the multimonitors
    chromium
    scrot # screenshots
    feh # set wallpaper
    gomuks # matrix
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
