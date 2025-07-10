{  config, inputs, lib, pkgs, ...}: with lib; let 
  user = config.gnm.home-manager.user;
in {
  options.gnm.home-manager.user = mkOption {
    type = types.str;
    default = "nixos";
    description = "user that gets enabled the home-manager module";
  };
  
  imports = [
    inputs.home-manager.nixosModules.home-manager
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" "${user}" ])
  ];

  config = {
    home-manager = {
      # backupFileExtension = "bak";
      extraSpecialArgs = { inherit inputs self; };
      useGlobalPkgs = true;
      useUserPackages = true;
    };
    environment.systemPackages = with pkgs; [
      home-manager
    ];
  };
}
