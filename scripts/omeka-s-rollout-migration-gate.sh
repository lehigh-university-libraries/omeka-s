#!/usr/bin/env sh

set -eu

result="$(curl --connect-timeout 2 --max-time 30 -sS -o /dev/null -w '%{http_code} %{redirect_url}' http://127.0.0.1/admin)" || {
  status="$?"
  echo "Unable to inspect Omeka S migration state (curl status ${status})" >&2
  exit "${status}"
}

code="${result%% *}"
redirect="${result#* }"

case "${code}" in
  200 | 301 | 302 | 303 | 307 | 308) ;;
  *)
    echo "Unexpected Omeka S admin response: ${code}" >&2
    exit 3
    ;;
esac

case "${redirect}" in
  */migrate | */migrate/)
    echo "ACTION REQUIRED: Browser migration is required. Keep Traefik stopped, access the app privately, complete the migration, then restart the stack." >&2
    exit 10
    ;;
esac
