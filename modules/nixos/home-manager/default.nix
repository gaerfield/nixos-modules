{
  self,
  inputs,
  lib,
  opts,
  ...
}: {
  imports = [
    # inputs.home-manager.flakeModules.home-manager
    inputs.home-manager.nixosModules.home-manager

    # Make sure to use hm = { imports = [ ./<homemanagerFiles> ];}; in nixosconfig

    {
      home-manager = {
        extraSpecialArgs = {inherit opts inputs self;};
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    }

    # config.home-manager.users.${user} -> config.hm
    (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" opts.username])
  ];

  hm.imports = [
    self.homeModules.home
  ];
}
