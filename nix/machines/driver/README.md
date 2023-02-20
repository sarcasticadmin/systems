# First log in

1. Clone down dotfiles and stow for appropriate config:

```
git git@github.com:sarcasticadmin/dotfiles.git
cd dotfiles
make CONFIG=./_make/workstation-pkgs.mk world
```

2. Log out (alt+shift+e) and log back into i3

## Add display profile

> Have to pause this effort since it looks like `x-prop-*` options arent supported yet via nix:

```
$ autorandr --debug
laptop
office (detected)
| Differences between the two profiles:
| [Output DisplayPort-2] Option --x-prop-tearfree (= `auto') is not present in the new configuration
| [Output DisplayPort-2] Option --x-prop-underscan_vborder (= `0') is not present in the new configuration
| [Output DisplayPort-2] Option --x-prop-underscan_hborder (= `0') is not present in the new configuration
| [Output DisplayPort-2] Option --x-prop-max_bpc (= `8') is not present in the new configuration
| [Output DisplayPort-2] Option --x-prop-scaling_mode (= `None') is not present in the new configuration
| [Output DisplayPort-2] Option --crtc (= `0') is `1' in the new configuration
| [Output DisplayPort-2] Option --x-prop-non_desktop (= `0') is not present in the new configuration
| [Output DisplayPort-2] Option --x-prop-underscan (= `off') is not present in the new configuration
\-
```

Configure the display layout as desired:

```
$ arandr
```

Save an autorandr config `~/.config/autorandr/tmp`:

```
$ autorandr --save tmp
```

Port over config and display ids to `autorandr.nix`

## Known Issues

- wpa_supplicant.conf gets copied to /run/wpa_supplicant/wpa_supplicant.conf during service start. Resulting in the inability to actually update /etc/wpa_supplicant.conf

- wpa_supplicant defaults to the wrong interface (p2p). Have had to specify which interface for `wpa_cli` via `-i <interface>`

- Check to make sure the interface is actually enabled, sometimes the hardware button (F8) is disabling the wifi card. You can notice this in
  the `wpa_cli status` since it will say `DISABLE_INTERFACE`
