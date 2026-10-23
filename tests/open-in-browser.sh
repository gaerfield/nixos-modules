#!/usr/bin/env bash
set -euo pipefail

launcher="$1"
export XDG_CONFIG_HOME="$(dirname "$0")/fixtures"

[[ "$("$launcher" 'https://mail.posteo.de/inbox?a=1&b=2')" == 'private https://mail.posteo.de/inbox?a=1&b=2' ]]
[[ "$("$launcher" 'https://example.org/project')" == 'work https://example.org/project' ]]
[[ "$("$launcher" 'https://other.example/')" == 'fallback https://other.example/' ]]

export XDG_CONFIG_HOME="$(dirname "$0")/fixtures/browser-fallback"
export BROWSER="echo browser-default"
[[ "$("$launcher" 'https://other.example/')" == 'browser-default https://other.example/' ]]
[[ "$("$launcher" 'https://mail.posteo.de/inbox')" == 'private https://mail.posteo.de/inbox' ]]

unset BROWSER
if "$launcher" 'https://other.example/' 2>/dev/null; then
	echo 'expected an error when BROWSER is unset' >&2
	exit 1
fi