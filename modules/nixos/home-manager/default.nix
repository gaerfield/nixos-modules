{
  self,
  inputs,
  lib,
  config,
  ...
}: let
  mainuser = config.nixos-modules.system.mainuser.name;
in {
  imports = [
    # inputs.home-manager.flakeModules.home-manager
    inputs.home-manager.nixosModules.home-manager

    # Make sure to use hm = { imports = [ ./<homemanagerFiles> ];}; in nixosconfig

    {
      nixos-modules.home-manager.home.username = mainuser;
      home-manager = {
        extraSpecialArgs = {inherit inputs self;};
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    }

    # config.home-manager.users.${user} -> config.hm
    (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" mainuser])
  ];

  hm.imports = [
    self.homeModules.home
  ];
}
