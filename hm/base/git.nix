let
  user = {
    name = "gaerfield";
    email = "gaerfield@users.noreply.github.com";
  };
in {
  # basic configuration of git
  programs.git = {
      enable = true;
      userName = user.name;
      userEmail = user.email;
    
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
        name = user.name;
        email = user.email;
      };
      ui = {
        default-command = "log";
      };
    };
  };
}