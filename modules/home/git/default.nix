{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.hm.git;
in {
  options.gnm.hm.git = {
    enable = mkEnableOption "Enable git and jujutsu support";
    name = mkOption {
      type = types.str;
      default = "";
      description = "The name to use for git commits.";
    };
    email = mkOption {
      type = types.str;
      default = "";
      description = "The email to use for git commits.";
    };
  };

  config = {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = cfg.name;
          email = cfg.email;
        };
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
          inherit (cfg) name;
          inherit (cfg) email;
        };
        ui = {
          default-command = "log";
        };
      };
    };
  };
}