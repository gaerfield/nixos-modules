{
  flake = {
    homeModules = import ./home-manager;
    nixosModules = import ./nixos;
  };
}
