{ pkgs, ... }:
pkgs.writeTextFile {
  name = "open-in-browser";
  destination = "/bin/open-in-browser";
  executable = true;
  text = "#!${pkgs.python3}/bin/python3\n" + builtins.readFile ./open-in-browser.py;
}