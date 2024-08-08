# systems

My system configs

## rebuild

Locally:

```
nixos-rebuild switch --flake /home/rherna/systems#driver --refresh
```

Remotely:

```
nixos-rebuild --flake .#rufio  --target-host user@hostname switch
```

## Provision

As long as we have ssh to the host and disks defined with `disko`:

```
nixos-rebuild --flake .#mulligan.config.system.build.disko --target-host user@hostname switch
```
