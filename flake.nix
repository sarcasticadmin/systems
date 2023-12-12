{
  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = [
      "https://sarcasticadmin-systems.cachix.org"
    ];
    extra-trusted-public-keys = [
      "sarcasticadmin-systems.cachix.org-1:K6fNUgpf4HtKZLt+HoJBBNzLnt8xHm/aoKbTH2U2SfA="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    ham-overlay = {
      url = "github:sarcasticadmin/ham-overlay";
      # Make sure to set to the specific input of the remote flake
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , ham-overlay
    , disko
    }@inputs: {
      nixosConfigurations = {
        cola = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nix/machines/_common/base.nix
            ./nix/machines/cola/configuration.nix
          ];
        };
        driver = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./nix/machines/driver/configuration.nix ];
        };
        mulligan = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ ham-overlay.overlays.default ]; })
            ham-overlay.nixosModules.default.ax25d
            ham-overlay.nixosModules.default.mheardd
            ham-overlay.nixosModules.default.axlistend
            ham-overlay.nixosModules.default.beacond
            ./nix/machines/_common/base.nix
            ./nix/machines/_common/wifi.nix
            ./nix/machines/mulligan/configuration.nix
          ];
        };
        rufio = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./nix/machines/rufio/configuration.nix ];
        };
        tinfoil = nixpkgs.lib.nixosSystem {
          # nix build -L .#nixosConfigurations.tinfoil.config.system.build.isoImage
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ./nix/isos/tinfoil/configuration.nix
          ];
        };
        sidekick = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./nix/machines/sidekick/configuration.nix ];
        };
        sign = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./nix/machines/sign/configuration.nix ];
          # Example how to pass an arg to configuration.nix:
          #specialArgs = { hostname = "staging"; };
        };
      };
    };
}
