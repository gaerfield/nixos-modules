{config, inputs, lib, pkgs, ...}: with lib; let
  cfg = config.gnm.hm.nix;
in {
  imports = [
    inputs.nix-index-database.hmModules.nix-index
  ];

  options.gnm.hm.nix = {
    flakePath = mkOption {
      type = types.str;
      default = "";
      example = "/home/user/my-nixos-config";
      description = "Path to the nixos flake configuration (used by 'nh').";
    };
  };

  config = {
    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";

    home.packages = with pkgs; [alejandra nixd];
    nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    # nixos-helper: https://github.com/nix-community/nh
    programs = {
      nix-index.enable = true;
      nix-index-database.comma.enable = true;
      nix-your-shell.enable = true;
      nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 4d --keep 3";
        flake = cfg.flakePath;
      };
    };
  };
}