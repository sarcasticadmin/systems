# First log in

1. Clone down dotfiles and stow for appropriate config:

```
git git@github.com:sarcasticadmin/dotfiles.git
cd dotfiles
make CONFIG=./_make/workstation-pkgs.mk world
```

2. Log out (alt+shift+e) and log back into i3

## Known Issues

- wpa_supplicant.conf gets copied to /run/wpa_supplicant/wpa_supplicant.conf during service start. Resulting in the inability to actually update /etc/wpa_supplicant.conf
