{
  pkgs,
  inputs,
  ...
}:
inputs.treefmt-nix.lib.mkWrapper pkgs {
  projectRootFile = "flake.nix";

  programs = {
    alejandra.enable = true; # formatter for nix files
    deadnix.enable = true; # scans for dead nix code
    statix.enable = true; # linter for nix files
  };
  settings = {
    global.excludes = [
      # "LICENSE"
      # let's not mess with the test folder
      # "test/*"
      # unsupported extensions
      # "*.{gif,png,svg,tape,mts,lock,mod,sum,toml,env,envrc,gitignore,pages}"
    ];

    formatter = {
      deadnix = {priority = 1;};
      statix = {priority = 2;};
      alejandra = {priority = 3;};
    };
  };
}
