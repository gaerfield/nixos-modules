{ pkgs, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = [ (pkgs.nerd-fonts.jetbrains-mono) pkgs.nil ];

  programs.fish.shellAbbrs.code = "codium";

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    mutableExtensionsDir = false;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        shd101wyy.markdown-preview-enhanced
        jnoortheen.nix-ide
        github.copilot
      ];

      userSettings = {
        "editor.fontFamily" = "JetBrainsMono Nerd Font";
        "terminal.external.linuxExec" = "${pkgs.alacritty}/bin/alacritty";
        "terminal.integrated.defaultProfile.linux" = "fish";
        "terminal.integrated.profiles.linux" = {
          bash.path = "${pkgs.bash}/bin/bash";
          fish.path = "${pkgs.fish}/bin/fish";
          sh.path = "${pkgs.bashInteractive}/bin/sh";
          zsh.path = "${pkgs.zsh}/bin/zsh";
        };
        "terminal.integrated.smoothScrolling" = true;
        "window.autoDetectColorScheme" = true;
        "workbench.colorTheme" = "Solarized Light";
        "workbench.preferredDarkColorTheme" = "Solarized Dark";
        "workbench.preferredLightColorTheme" = "Solarized Light";

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.formatterPath" = "nixpkgs-fmt";
        "nix.serverSettings" = {
          "nil" = { 
            "formatting" = {
              "command" = ["nixpkgs-fmt"];
            };
          };
        };
      };
    };
  };
}
