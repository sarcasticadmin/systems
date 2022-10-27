{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      myOverlay = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
        ];
        config = { allowUnfree = true; };
      };
    in
    {
      overlays.default = (final: prev: rec {
        myPinentry = prev.pinentry.override { enabledFlavors = [ "curses" "tty" ]; };
      });
      packages.x86_64-linux = pkgs;
      nixosConfigurations = {
        driver = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ 
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ myOverlay ]; })
            ./nix/machines/driver/configuration.nix ];
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
