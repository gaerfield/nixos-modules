{
  writeShellApplication,
  coreutils,
  glib,
}:
writeShellApplication {
  name = "track-working-day";
  runtimeInputs = [coreutils glib];
  text = ''
    USAGE_INFO="Usage: track-working-day [start|info|help]"
    if [[ $1 != "info" && $1 != "start" && $1 != "help" ]]; then
      echo "$USAGE_INFO"
      exit 1
    fi

    if [[ $1 == "help" ]]; then echo "$USAGE_INFO;" exit 0; fi

    TRACKING_DATA_HOME="$XDG_DATA_HOME/track-working-day"
    CURRENT_TRACKING_FILE="$TRACKING_DATA_HOME/$(date +%Y-%m)"
    if [[ $1 == "info" ]]; then
      cat "$CURRENT_TRACKING_FILE"
      exit 0
    fi

    track_event() {
      mkdir -p "$TRACKING_DATA_HOME"
      echo "$(date +%Y-%m-%d),$(date +%R),$(date +%z),\"$*\"" >> "$CURRENT_TRACKING_FILE"
    }

    track_shutdown() { track_event "shutdown"; echo "exiting ..."; }

    trap track_shutdown SIGINT SIGTERM
    echo "starting ..."
    track_event "bootup"

    while read -r line
    do
        case "$line" in
            *"{'LockedHint': <true>}"*) track_event "logged out";;
            *"{'LockedHint': <false>}"*) track_event "logged in";;
        esac
    done < <(gdbus monitor -y -d org.freedesktop.login1)
  '';
}
