{
  app,
  cfg,
  firefoxPackage,
  hyprland,
  jq,
  lib,
  profileDir,
  writeShellApplication,
}:
let
  launcherName = "pwa-firefox-${app.id}";
  windowClass = launcherName;
  waylandSetup = lib.optionalString cfg.enableWayland ''
    if [[ -z "''${MOZ_ENABLE_WAYLAND:-}" ]]; then
      export MOZ_ENABLE_WAYLAND=1
    fi
  '';
  portalSetup = lib.optionalString cfg.usePortals ''
    if [[ -z "''${GTK_USE_PORTAL:-}" ]]; then
      export GTK_USE_PORTAL=1
    fi
  '';
  openArgs = ''
    exec ${firefoxPackage}/bin/firefox --name "${windowClass}" --new-window --profile "$profile_dir" "$target_url"
  '';
in
writeShellApplication {
  name = launcherName;
  text = ''
    profile_dir=${lib.escapeShellArg profileDir}
    default_url=${lib.escapeShellArg app.url}
    forwarded_url="''${1:-}"
    single_instance="${if app.singleInstance then "true" else "false"}"

    mkdir -p "$profile_dir"

    ${waylandSetup}
    ${portalSetup}

    if [[ -n "$forwarded_url" && "$forwarded_url" != "%u" ]]; then
      target_url="$forwarded_url"
    else
      target_url="$default_url"
    fi

    if [[ $single_instance == "true" ]]; then
      existing_addr="$(${hyprland}/bin/hyprctl clients -j 2>/dev/null | ${jq}/bin/jq -r --arg initialClass "${windowClass}" '.[] | select((.initialClass // "") == $initialClass) | .address' | head -n 1)"
      if [[ -n "$existing_addr" ]]; then
        ${hyprland}/bin/hyprctl dispatch "hl.dsp.focus({ window = \"address:$existing_addr\" })"
        exit 0
      fi
    fi
    
    ${openArgs}
  '';


}
