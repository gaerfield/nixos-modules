"""Route a URL to a configured browser command."""

import fnmatch
import os
from pathlib import Path
import shlex
import sys
import tomllib


def main():
    if len(sys.argv) != 2:
        raise ValueError("usage: open-in-browser <url>")

    url = sys.argv[1]
    config_home = os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config"
    config_path = Path(config_home) / "open-in-browser" / "config.toml"
    with config_path.open("rb") as file:
        config = tomllib.load(file)

    executable = next(
        (
            rule["executable"]
            for rule in config.get("urlPatterns", [])
            if fnmatch.fnmatchcase(url, rule["globPattern"])
        ),
        config.get("defaultExecutable"),
    )
    if executable is None:
        raise ValueError("no URL pattern matches and no defaultExecutable is configured")

    if executable == "$BROWSER":
        browser = os.environ.get("BROWSER")
        if not browser:
            raise ValueError("$BROWSER is unset or empty")
        command = shlex.split(browser)
        if command and Path(command[0]).name in ("xdg-open", "open-in-browser"):
            raise ValueError("$BROWSER must point to a browser, not xdg-open or open-in-browser (which would recurse)")
    else:
        command = shlex.split(config["executables"][executable])
    if not command:
        raise ValueError(f"empty command for executable {executable!r}")
    os.execvp(command[0], [*command, url])


if __name__ == "__main__":
    try:
        main()
    except (OSError, KeyError, ValueError, tomllib.TOMLDecodeError) as error:
        print(f"open-in-browser: {error}", file=sys.stderr)
        sys.exit(1)