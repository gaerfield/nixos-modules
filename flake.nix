{
  description = "gaerfields default configurations for nixos";

  outputs = _: {
    hm =
      let
        import = path: path; # let the module system know what we are exporting
      in
      {
        basicTest = import ./basic-test.nix;
      };
  };
}
