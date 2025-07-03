{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.gnm.hm.vscode;
in {
  options.gnm.hm.vscode.enable = mkEnableOption "Enable Visual Studio Code support";

  config = mkIf cfg.enable {
    # fonts.fontconfig.enable = true;
    # home.packages = [pkgs.nerd-fonts.jetbrains-mono];

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
          # "editor.fontFamily" = "JetBrainsMono Nerd Font";
          "terminal.external.linuxExec" = "${pkgs.kitty}/bin/kitty";
          "terminal.integrated.defaultProfile.linux" = "fish";
          "terminal.integrated.profiles.linux" = {
            bash.path = "${pkgs.bash}/bin/bash";
            fish.path = "${pkgs.fish}/bin/fish";
            sh.path = "${pkgs.bashInteractive}/bin/sh";
            zsh.path = "${pkgs.zsh}/bin/zsh";
          };
          "terminal.integrated.smoothScrolling" = true;
          "window.autoDetectColorScheme" = true;
          #"workbench.colorTheme" = "Solarized Light";
          #"workbench.preferredDarkColorTheme" = "Solarized Dark";
          #"workbench.preferredLightColorTheme" = "Solarized Light";

          # nix-ide: nix language server and formatter
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nixd";
          "nix.formatterPath" = "alejandra";
          "nix.serverSettings" = {
            "nixd" = {
              "formatting" = {
                "command" = ["alejandra"];
              };
            };
          };
        };
      };
    };
  };
}