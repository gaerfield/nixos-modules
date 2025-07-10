{ inputs, self, ... }: {
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs self; };
      modules = [
        ./vm/configuration.nix
      ];
    };
}