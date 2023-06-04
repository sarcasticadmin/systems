# First log in

1. Clone down dotfiles and stow for appropriate config:

```
git git@github.com:sarcasticadmin/dotfiles.git
cd dotfiles
make CONFIG=./_make/workstation-pkgs.mk world
```

2. Log out (alt+shift+e) and log back into i3

# Notes

## NixOS Upgrades

Common options for `flake` references:

```
local filesystem: /home/rherna/systems#driver
remote git repo: github:sarcasticadmin/systems/0c46f1c6009e2515e51baee6cba621fd7093c41b#driver
```

### Major

1. Check the release notes for the new version: https://nixos.org/blog/announcements.html

2. Bump the `input` version in the flake then:

```
nix flake update
```

3. `dry-run` and then build for next boot:

```
nixos-rebuild dry-run --flake /home/rherna/systems#driver
nixos-rebuild boot --flake /home/rherna/systems#driver
```
> `dry-run` should help catch any issues in the existing configuration

### Minor

1. Bump the `input` version in the flake then:

```
nix flake update
```

2. `switch` the system to the configuration:

```
nixos-rebuild switch --flake /home/rherna/systems#driver
```

## Firefox addons

Update the firefox addons found in `nix/machines/_common/desktop.nix`. Unforunately, I dont have a better way of do this
outside of just copying the url found on the addons page and adding it to the wrapped firefox config.

## autorandr

Show all exiting profiles:

```
autorandr
```

Saving a new profile:

```
autorandr --save mobile
```

# Known Issues

- wpa_supplicant.conf gets copied to /run/wpa_supplicant/wpa_supplicant.conf during service start. Resulting in the inability to actually update /etc/wpa_supplicant.conf

- wpa_supplicant defaults to the wrong interface (p2p). Have had to specify which interface for `wpa_cli` via `-i <interface>`

- Check to make sure the interface is actually enabled, sometimes the hardware button (F8) is disabling the wifi card. You can notice this in
  the `wpa_cli status` since it will say `DISABLE_INTERFACE`
