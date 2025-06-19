{config, ...}: let
  mainuser = config.mainuser;
in {
  imports = [
    ./gc.nix
    ./packages.nix
    ./nix-ld.nix
  ];

  users.users."${mainuser.name}" = {
    isNormalUser = true;
    description = "${mainuser.name}";
    extraGroups = ["wheel"];
    linger = true;
    openssh.authorizedKeys.keys = mainuser.authorizedKeys;
  };

  boot.kernel.sysctl = {
    "kernel.sysrq" = 1; # enable reisub sequence
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable flakes
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
    use-xdg-base-directories = true;
    trusted-users = [mainuser.name "root"];
  };
}
