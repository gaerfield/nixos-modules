{
  profileDir,
  command,
  pkgs,
  writeShellApplication,
}:
let
  package = writeShellApplication {
    name = command;
    runtimeInputs = [ pkgs.xdg-utils ];
    text = ''
      target=""
      for arg in "$@"; do
        case "$arg" in
          http://*|https://*|ftp://*|file://*|mailto:*) target="$arg" ;;
        esac
      done

      if [[ -z "$target" ]]; then
        target="''${1:-about:blank}"
      fi

      exec ${pkgs.xdg-utils}/bin/xdg-open "$target"
    '';
  };

  shimDir = "${profileDir}/.pwa-firefox-shims";
in {
  inherit command package shimDir;
}