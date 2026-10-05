{ pkgs ? import <nixpkgs> { } }:
let
  extensionId = "lmeddoobegbaiopohmpmmobpnpjifpii";
  # This public key makes the runtimeExtensionId stable across builds
  extensionPublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4odRNuTxmAV4BkxS8vSQ4f5XjjEqvYt7yybswNK5TuRf+8sGDju0nUtoWxLdy7F7nieF2P0qxBXg5uz61QzB7qZCfZGcckD9o3zRyCsNpnGV9UKSutH+WTClzz6fJKDuNlbEUdWPYeDk0jjaWBAYEiUHnW78i/lEKWyF8Dkj1ovBgGpRUPgBQ+BewP3hHQ2ifRJgt9omwt6eZrHmXgpEGhUcj/AkVZllkrgofqWBJyUqGl8NsPd3C5fWx+bdppZ+yZcKBZsvlB4KT+ib59I7apOiw3wvtyAAJ/RD5sER8WBKd56bTNpDGCEvyKoGgN2gYsUIiJZGzZM64uquzDamtQIDAQAB";
  # This extensionId is derived from the public key, and is used to identify the extension in Chromium.
  runtimeExtensionId = "iiknpheaicifjgejodgmcolphkbddobl";
  extensionCrx = pkgs.fetchurl {
    url = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=130&x=id%3D${extensionId}%26installsource%3Dondemand%26uc";
    name = "open-in-firefox-browser.crx";
    sha256 = "sha256-e85yx9yT79Iu+zNuc7GbJt07xu3MSKsMAhP23XuvVFI=";
  };
  # CRX files are ZIP payloads wrapped in a small binary header. Skipping the
  # initial 16 bytes leaves the actual ZIP data, which unzip can recover.
  extensionPath = pkgs.runCommand "open-in-firefox-browser-extension" {
    nativeBuildInputs = [ pkgs.libarchive pkgs.jq ];
  } ''
  mkdir -p "$out"
  bsdtar -xf ${extensionCrx} -C "$out"

  jq --arg key "${extensionPublicKey}" \
      '. + { key: $key }' \
      "$out/manifest.json" > "$out/manifest.json.new"
  mv "$out/manifest.json.new" "$out/manifest.json"
  '';
in {
  inherit extensionId runtimeExtensionId extensionPath;
}
