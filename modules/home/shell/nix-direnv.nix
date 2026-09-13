{ config, ... }: {
  # https://github.com/nix-community/nix-direnv
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;

      stdlib = ''
        # https://github.com/direnv/direnv/wiki/Customizing-cache-location
        : ''${XDG_CACHE_HOME:=$HOME/.cache}
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
            local hash path
            echo "''${direnv_layout_dirs[$PWD]:=$(
                hash="''$(sha1sum - <<< "$PWD" | head -c40)"
                path="''${PWD//[^a-zA-Z0-9]/-}"
                echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
            )}"
        }
      '';
    };

    fish.functions = {
      "direnv-off" = {
        description = "Temporarily disable direnv in this terminal";
        body = ''
          # Delete the background event listener function
          functions -e __direnv_export_eval
          echo "direnv disabled for this terminal session"
        '';
      };

      "direnv-on" = {
        description = "Re-enable direnv in this terminal";
        body = ''
          direnv hook fish | source
          echo "direnv re-enabled"
        '';
      };
    };
  };

  persistence.directories = with config.xdg; [
    "${cacheHome}/direnv"
    "${dataHome}/direnv"
  ];
}
