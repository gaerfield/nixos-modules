{
  # basic configuration of git
  programs.git = {
    enable = true;
    userName = "gaerfield";
    userEmail = "gaerfield@users.noreply.github.com";
  
    extraConfig = {
      core = {
        sshCommand = "ssh -i ~/.ssh/gaerfield";
      };
      init.defaultBranch = "main";
    };
  };
}