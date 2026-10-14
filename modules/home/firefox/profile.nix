{ config, lib, ... }:
let
  cfg = config.gnm.hm.firefoxProfiles;

  mkProfile = profileName: profileCfg: {
    id = profileCfg.id;
    name = profileCfg.name;
    isDefault = profileCfg.isDefault;
    extensions.packages = lib.unique profileCfg.extensions;
  } // profileCfg.extraSettings;
in {
  options.gnm.hm.firefoxProfiles = {
    enable = lib.mkEnableOption "custom Firefox profiles with declarative addon sets";

    profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
        options = {
          id = lib.mkOption {
            type = lib.types.int;
            description = "Numeric Firefox profile id.";
          };

          name = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = "Profile display name in Firefox profile manager.";
          };

          isDefault = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether this profile should be marked as the default profile.";
          };

          extensions = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
            description = "Firefox extension packages for this profile only.";
          };

          extraSettings = lib.mkOption {
            type = lib.types.attrs;
            default = { };
            description = "Additional Home Manager programs.firefox.profiles.<name> attributes.";
          };
        };
      }));
      default = { };
      description = "Declarative Firefox profiles keyed by profile name.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox.profiles = lib.mapAttrs mkProfile cfg.profiles;
  };
}
