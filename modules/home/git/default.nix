{ config, lib, ... }:
with lib; let
  cfg = config.gnm.hm.git;
in {
  options.gnm.hm.git = {
    enable = mkEnableOption "Enable git and jujutsu support";
    name = mkOption {
      type = types.str;
      description = "The name to use for git commits.";
    };
    email = mkOption {
      type = types.str;
      description = "The email to use for git commits.";
    };
  };

  config = {
    programs.git = {
      enable = true;
      userName = cfg.name;
      userEmail = cfg.email;

      extraConfig = {
        core = {
          sshCommand = "ssh -i ~/.ssh/gaerfield";
        };
        init.defaultBranch = "main";
      };

      ignores = [
        "**/.jj/**"
      ];
    };

    programs.jujutsu = {
      enable = true;

      # https://github.com/jj-vcs/jj/blob/main/docs/config.md
      settings = {
        user = {
          name = cfg.name;
          email = cfg.email;
        };
        ui = {
          default-command = "log";
        };
      };
    };
  };
}
