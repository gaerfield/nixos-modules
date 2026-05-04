{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.impermanence;
  nixPersistence = config.persistence;
  # Normalize an HM persistence entry for a given user.
  # Paths starting with '/' are treated as absolute; all others are resolved
  # relative to the user's home directory.
  normalizeUserDir = userName: homeDir: entry:
    let
      base       = if builtins.isString entry then { directory = entry; } else entry;
      resolvedDir = if lib.hasPrefix "/" base.directory
                    then base.directory
                    else homeDir + "/" + base.directory;
      userGroup  = config.users.users.${userName}.group;
    in
      (base // { directory = resolvedDir; })
      // lib.optionalAttrs (!base ? user)  { user  = userName; }
      // lib.optionalAttrs (!base ? group) { group = userGroup; }
      // lib.optionalAttrs (!base ? mode)  { mode  = "0700"; };
  normalizeUserFile = userName: homeDir: entry:
    let
      base         = if builtins.isString entry then { file = entry; } else entry;
      resolvedFile = if lib.hasPrefix "/" base.file 
                     then base.file
                     else homeDir + "/" + base.file;
      userGroup    = config.users.users.${userName}.group;
      existingPD   = base.parentDirectory or {};
      parentDir    = existingPD
        // lib.optionalAttrs (!existingPD ? user)  { user  = userName; }
        // lib.optionalAttrs (!existingPD ? group) { group = userGroup; }
        // lib.optionalAttrs (!existingPD ? mode)  { mode  = "0700"; };
    in
      base // { file = resolvedFile; parentDirectory = parentDir; };
  hmDirs = lib.concatMap
    (userName:
      let hmCfg = config.home-manager.users.${userName};
      in map (normalizeUserDir userName hmCfg.home.homeDirectory) hmCfg.persistence.directories
    )
    (lib.attrNames config.home-manager.users);
  hmFiles = lib.concatMap
    (userName:
      let hmCfg = config.home-manager.users.${userName};
      in map (normalizeUserFile userName hmCfg.home.homeDirectory) hmCfg.persistence.files
    )
    (lib.attrNames config.home-manager.users);
  cleanup =
    ''
      # This script cleans the disk at boot to have clean setup
      # also keeps backup of the previous boot
      mkdir -p /btrfs_tmp
      mount ${cfg.mount} /btrfs_tmp
      if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%b-%d-%Y_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi
      
      delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
      }

      # Deleting backup older than 30 days
      while IFS= read -r -d "" directory
      do
        delete_subvolume_recursively "$directory"
      done <   <(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30 -print0)
      
      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    '';
in {
  options.gnm.impermanence = {
    enable = mkEnableOption ''
      Enable impermanence for system and home manager.
      gnm.persistence.directories and gnm.persistence.files will be used to configure which directories and files are persistent in the system.
      gnm.hm.persistence.directories and gnm.hm.persistence.files will be used to configure which directories 
      and files are persistent in the home manager.
    '';

    mount = mkOption {
      type = types.str;
      description = "The device to mount for persistent storage.";
      example = "/dev/mapper/cryptroot";
    };
    persistencePath = mkOption {
      type = types.str;
      description = "The path to your persistent storage location.";
      example = "/persist";
    };
  };

  config = mkIf cfg.enable {
    security.sudo.extraConfig = ''
      # rollback results in sudo lectures after each reboot
      Defaults lecture = never
    '';
    
    # Make sure all your persistent and ephemeral storage volumes are marked with neededForBoot,
    # otherwise you will run into problems.
    fileSystems."${cfg.persistencePath}".neededForBoot = true;
    
    # as the rollback.service is running in initrd, the status and logs can be checked
    # only by taking a look into the boot log with `journalctl -b`
    boot.initrd.systemd.services.rollback = {
      description = "Rollback BTRFS root subvolume to a pristine state";
      wantedBy = [
        "initrd.target"
      ];
      after = [
        # LUKS/TPM process
        "dev-mapper-cryptroot.device"
      ];
      before = [
        "local-fs-pre.target"
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = cleanup;
    };
    
    environment.persistence."${cfg.persistencePath}" = {
      # allows you to specify whether to hide the bind mounts from showing up as mounted drives in the file manager.
      # If enabled, it sets the mount option x-gvfs-hide on all the bind mounts.
      hideMounts = true;
      # allows you to specify whether to allow apps that use certain GTK-based technologies such as GIO to put items
      # in the trash. If enabled, it sets the mount option x-gvfs-trash on all the bind mounts.
      allowTrash = true;
      directories = nixPersistence.directories ++ hmDirs;
      files = nixPersistence.files ++ hmFiles;

      # Handles files and directories in bird’s home directory.
      # The users option defines a set of submodules which correspond to the users’ names.
      # The directories and files options of each submodule work like their root counterparts, 
      # but the paths are automatically prefixed with with the user’s home directory.
    };
  };
}
