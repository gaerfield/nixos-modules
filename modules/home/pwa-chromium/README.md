# pwa-chromium

This module is mainly used to wrap video conferencing tools like teams, gather.town, etc. Chromium outperforms Firefox
in this area, thats the only reason. For other PWA's (mail, maps, company github) I prefer Firefox.

The relevant features are:
1. one isolated browser profile per app
2. pwa-app-mode (no url-bar)
3. single-instance/focus-existing-window behaviour on Hyprland 
4. per-app policy to:
    i. keep all URLs prefixed by the PWA URL inside the app
    ii. optional add other URLs that should stay in the app
    iii. handover all external links to Firefox via the [open link in firefox chromium extension](https://chromewebstore.google.com/detail/open-in-firefox-browser/lmeddoobegbaiopohmpmmobpnpjifpii)
5. automatic installation of NativeMessagingHost (Thats a small binary that the chromium extension requires to open firefox on the desktop).
6. use ungoogled chromium per default
7. per-app cookie allowlists
8. per-app persistence
9. optional Wayland/PipeWire screen sharing
10. declarative desktop entries/icons
11. configuration directories are excluded from my impermanence setup (Should I include caches as well for performance reasons?)
