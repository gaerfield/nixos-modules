{inputs, pkgs, ...}: {
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [alejandra nixd];
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
}