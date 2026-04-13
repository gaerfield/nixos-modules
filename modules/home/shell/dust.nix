{pkgs, ...}: {
  home.packages = [pkgs.dust];
  programs.fish.shellAbbrs = {
    dust-no-recurse = "dust --depth 1";
  };
}