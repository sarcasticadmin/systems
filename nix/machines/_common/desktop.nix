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
        url = "https://addons.mozilla.org/firefox/downloads/file/4171020/ublock_origin-1.52.2.xpi"; # Get this from about:addons
        sha256 = "sha256-6O4/nVl6bULbnXP+h8HVId40B1X9i/3WnkFiPt/gltY=";
      })
      (pkgs.fetchFirefoxAddon {
        name = "bitwarden";
        url = "https://addons.mozilla.org/firefox/downloads/file/4170561/bitwarden_password_manager-2023.9.1.xpi";
        sha256 = "sha256-RtT+EOo6F1empMDXKPP3Zdk4g/dCo+u3PzauuA7sVak=";
      })
      (pkgs.fetchFirefoxAddon {
        name = "zoomExtension";
        url = "https://addons.mozilla.org/firefox/downloads/file/4158802/zoom_new_scheduler-2.1.47.xpi";
        sha256 = "sha256-v8fDftZS8Pjq9oz2fiJNeZTQGyQepF4OJUQpNuI7n/0=";
      })
    ];

    # https://github.com/mozilla/policy-templates
    extraPolicies = {
      PasswordManagerEnabled = false;
      OfferToSaveLogins = false;
      DisablePocket = true;
      DisableTelemetry = true;
      DNSOverHTTPS = {
        Enabled = false;
        Locked = true;
      };
      DontCheckDefaultBrowser = true;
    };
  };
in
{
  # install Desktop packages
  environment.systemPackages = with pkgs; [
    myFirefox # robs custom firefox
    autorandr # cli xrandr tool for saving/load profiles
    arandr # ui xrandr tool for interacting the multimonitors
    chromium
    exfat
    scrot # screenshots
    feh # set wallpaper
    gomuks # matrix
    zoom-us
    zathura # simple pdf viewer
    alacritty
    obsidian
    shiori
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
