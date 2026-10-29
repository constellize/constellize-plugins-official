#!/usr/bin/env bash
# Fail when the diff <base>..HEAD touches plugins/<name>/skills/** without also
# touching plugins/<name>/.claude-plugin/plugin.json.
# Usage: check-version-bump.sh <base-ref>
set -euo pipefail

base="${1:?usage: check-version-bump.sh <base-ref>}"
changed="$(git diff --name-only "$base" HEAD)"

status=0
for plugin in $(printf '%s\n' "$changed" | sed -n 's#^plugins/\([^/]*\)/skills/.*#\1#p' | sort -u); do
  if ! printf '%s\n' "$changed" | grep -qx "plugins/$plugin/.claude-plugin/plugin.json"; then
    echo "FAIL: plugins/$plugin/skills changed but plugins/$plugin/.claude-plugin/plugin.json was not bumped" >&2
    status=1
  fi
done

[ "$status" -eq 0 ] && echo "OK: every changed plugin's plugin.json changed with its skills"
exit "$status"
