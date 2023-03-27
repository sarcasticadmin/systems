{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";

  outputs = { self, nixpkgs }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlays.default ]; });
    in
    {
      overlays.default = (final: prev:
        with final.pkgs;
        rec {
          oChartsPlugin = callPackage ./nix/pkgs/oChartsPlugin.nix { };
        });

      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}) oChartsPlugin;
      });

      nixosConfigurations = {
        driver = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./nix/machines/driver/configuration.nix ];
        };
        marco = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./nix/machines/marco/configuration.nix ];
          # Example how to pass an arg to configuration.nix:
          #specialArgs = { hostname = "staging"; };
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
