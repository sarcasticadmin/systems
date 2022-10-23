{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
  
  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      sign = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nix/machines/sign/configuration.nix ];
        # Example how to pass an arg to configuration.nix:
        #specialArgs = { hostname = "staging"; };
      }; 
    };
  };
}
