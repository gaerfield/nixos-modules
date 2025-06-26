{flake, ...}: let
  hmm = flake.homeModules;
in {
  imports = [
    #hmm.home
    hmm.gnome
    hmm.shell
    hmm.terminal
    hmm.vscode
    hmm.firefox
    hmm.chromium
  ];
  #hm.gnm.home-manager.home.username = "gaerfield";
  #home-manager.users.gaerfield.gnm.home-manager.home.username = "gaerfield";
  #home-manager.users.gaerfield.hm
  home.stateVersion = "24.11"; 
}