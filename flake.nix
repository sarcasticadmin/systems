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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
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

      packages.x86_64-linux =
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
          };
        in
        {
          dotfiles = pkgs.callPackage ./nix/pkgs/dotfiles.nix { };
          accrip = pkgs.callPackage ./nix/pkgs/accrip/package.nix { };
        };

      nixosConfigurations = {
        cola = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nix/machines/_common/base.nix
            ./nix/machines/cola/configuration.nix
          ];
        };
        dark = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ ham-overlay.overlays.default ]; })
            disko.nixosModules.disko
            ./nix/machines/_common/users.nix
            ./nix/machines/_common/base.nix
            ./nix/machines/dark/config.nix
          ];
        };

        driver = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./nix/machines/_common/desktop.nix
            ./nix/machines/_common/base.nix
            ./nix/machines/_common/users.nix
            ./nix/machines/driver/configuration.nix ];
        };
        mulligan = nixpkgs-unstable.lib.nixosSystem {
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
        oddball = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            disko.nixosModules.disko
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ ham-overlay.overlays.default ]; })
            ham-overlay.nixosModules.default.ax25d
            ham-overlay.nixosModules.default.mheardd
            ham-overlay.nixosModules.default.axlistend
            ham-overlay.nixosModules.default.beacond
            ./nix/machines/_common/users.nix
            ./nix/machines/_common/base.nix
            ./nix/machines/_common/wifi.nix
            ./nix/machines/_common/desktop.nix
            ./nix/machines/oddball/configuration.nix
          ];
        };
        roomservice = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            disko.nixosModules.disko
            ./nix/machines/_common/users.nix
            ./nix/machines/_common/base.nix
            ./nix/machines/roomservice/configuration.nix
          ];
        };
        rufio = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [ 
            disko.nixosModules.disko
            ./nix/machines/rufio/configuration.nix
          ];
        };
        tinfoil = nixpkgs.lib.nixosSystem {
          # nix build -L .#nixosConfigurations.tinfoil.config.system.build.isoImage
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ./nix/isos/tinfoil/configuration.nix
          ];
        };
        simpleIso = nixpkgs.lib.nixosSystem {
          # nix build -L .#nixosConfigurations.simpleIso.config.system.build.isoImage
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ./nix/isos/simple/configuration.nix
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
        router1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            #{ disko.devices.disk.disk1.device = "/dev/vda"; }
            ./nix/machines/router1/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}
