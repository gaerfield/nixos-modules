{lib, ...}:
with lib; {
  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = mkDefault true;
    dates = mkDefault "weekly";
    options = mkDefault "--delete-older-than 7d";
  };
}
