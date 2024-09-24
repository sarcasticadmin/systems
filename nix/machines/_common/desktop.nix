# This config is only to contain x11 and gui pkgs
{ config, pkgs, inputs, ... }:

let
  myFirefox = pkgs.wrapFirefox pkgs.firefox-esr-unwrapped {
    cfg = { smartcardSupport = true; };

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
    fend # calculate all the things
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
    xorg.xmodmap # util for modding keymaps and pointer button mappings in Xorg
    #imagemagick # dup might be a problem?
  ];

  # due to obsidian we need to permit electron
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];


  programs.firefox = {
    enable = true;
    package = myFirefox;
    policies = {
      # src: https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/17
      ExtensionSettings = with builtins;
        let
          extension = shortId: uuid: {
            name = uuid;
            value = {
              install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
              installation_mode = "normal_installed";
            };
          };
        in
        listToAttrs [
          # To add additional extensions, find it on addons.mozilla.org, find
          # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
          # Then, download the XPI by filling it in to the install_url template, unzip it,
          # run `jq .browser_specific_settings.gecko.id manifest.json` or
          # `jq .applications.gecko.id manifest.json` to get the UUID
          (extension "ublock-origin" "uBlock0@raymondhill.net")
          (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
          (extension "darkreader" "addon@darkreader.org")
          (extension "user-agent-string-switcher" "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}")
        ];
    };
    preferences = {
      "browser.shell.checkDefaultBrowser" = false;
      "browser.tabs.firefox-view.ui-state.tab-pickup.open" = false;
      "browser.toolbars.bookmarks.visibility" = "newtab"; # never,always are also options
      "app.update.auto" = false;
      "extensions.pocket.enabled" = false;
      "signon.rememberSignons" = false; # dont prompt to save credentials to browser
    };
  };

  programs.chromium = {
    enable = true;
    extraOpts = {
      "DefaultInsecureContentSetting" = true;
      "BrowserSignin" = 0;
      "SyncDisabled" = true;
      "PasswordManagerEnabled" = false;
      "SpellcheckEnabled" = true;
      "DnsOverHttpsMode" = "off";
    };
  };

  services = {
    xserver = {
      enable = true;

      desktopManager = {
        xterm.enable = false;
      };

      # This is the way
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu # simple launcher
          i3status # default i3 status bar
          i3lock # default + simple lock that matches my config
        ];
        configFile = "${inputs.self.packages.${pkgs.system}.dotfiles}/i3/.i3/config";
      };

      # Enable touchpad support (enabled default in most desktopManager).
      # libinput.enable = true;
    };

    displayManager = {
      defaultSession = "none+i3";
    };
  };

  environment.etc."i3status.conf" = {
    source = "${inputs.self.packages.${pkgs.system}.dotfiles}/workstation/.i3status.conf";
  };
}
