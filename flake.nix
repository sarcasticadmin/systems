{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    ham-overlay = {
      url = "github:sarcasticadmin/ham-overlay";
      # Make sure to set to the specific input of the remote flake
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , ham-overlay
    }: {
      nixosConfigurations = {
        driver = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./nix/machines/driver/configuration.nix ];
        };
        mulligan = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ ham-overlay.overlays.default ]; })
            ./nix/machines/mulligan/configuration.nix
          ];
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
