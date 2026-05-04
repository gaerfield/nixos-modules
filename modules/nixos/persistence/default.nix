# This is a lightweight option module that just defines persistence.directories
# and persistence.files as mergeable list options. No bind mounts, 
# no activation logic — it's purely a data collector used by NixOS-level persistence.
# It simply collects the directories and files that should be persisted if impermanence is enabled,
# and then the actual impermanence module will take care of the rest.
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
