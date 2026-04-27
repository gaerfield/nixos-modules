# The home-manager impermanence module creates bind mounts during HM activation
# (which can race with services), while the NixOS module does it at boot time.
# This is a lightweight HM option module that just defines persistence.directories
# and persistence.files as mergeable list options. No bind mounts, 
# no activation logic — it's purely a data collector used by NixOS-level persistence.
#
# see: https://discourse.nixos.org/t/impermanence-can-the-nixos-module-do-everything-the-home-manager-module-does/60638/2

{ lib, ... }: {
  options.persistence = {
    directories = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [];
      description = "Directories to persist via the NixOS impermanence module.";
    };
    files = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [];
      description = "Files to persist via the NixOS impermanence module.";
    };
  };
}
