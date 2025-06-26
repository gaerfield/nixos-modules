{ inputs, ... }: let
  hm = inputs.self.homeModules;
in {
  imports = [
    hm.home
    hm.gnome
    hm.shell
    hm.terminal
    hm.vscode
    hm.firefoxBrowser
    hm.chromiumBrowser
  ];
  hm.gnm.home-manager.home.username = "gaerfield";
}
