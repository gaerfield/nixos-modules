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
    # config.home-manager.users.${user} -> config.hm
    (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" mainuser])
  ];

  config = {
    hm.imports = [
      self.homeModules.home
    ];
    hm.nixos-modules.home-manager.home.username = mainuser;
    # Make sure to use hm = { imports = [ ./<homemanagerFiles> ];}; in nixosconfig
    home-manager = {
      extraSpecialArgs = {inherit inputs self;};
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
