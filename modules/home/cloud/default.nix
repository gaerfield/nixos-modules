{ lib, ... }: with lib; {
  imports = [
    ./google-cloud-sdk.nix
    ./kubectl.nix
  ];

  options.gnm.hm.cloud.enable = mkEnableOption "enable gcloud and kubectl support";
}
