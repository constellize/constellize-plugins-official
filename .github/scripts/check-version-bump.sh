#!/usr/bin/env bash
# For every plugin whose plugins/<name>/skills/** changed between <base> and HEAD,
# fail unless that plugin's .claude-plugin/plugin.json "version" differs from the
# version at <base>. A new plugin.json (absent at <base>) passes.
# Usage: check-version-bump.sh <base-ref-or-sha>
set -euo pipefail

base="${1:?usage: check-version-bump.sh <base-ref-or-sha>}"

# First push of a branch (all-zero "before") or a force-push that dropped the old tip.
if [[ "$base" =~ ^0+$ ]] || ! git cat-file -e "${base}^{commit}" 2>/dev/null; then
  echo "SKIP: no usable base revision ($base); first push or force-push, nothing to compare"
  exit 0
fi

version_of() { node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>console.log(JSON.parse(s).version))'; }

status=0
for plugin in $(git diff --name-only "$base" HEAD | sed -n 's#^plugins/\([^/]*\)/skills/.*#\1#p' | sort -u); do
  manifest="plugins/$plugin/.claude-plugin/plugin.json"
  if ! git cat-file -e "$base:$manifest" 2>/dev/null; then
    echo "OK: $plugin has no plugin.json at base (new plugin)"
    continue
  fi
  old="$(git show "$base:$manifest" | version_of)"
  new="$(git show "HEAD:$manifest" | version_of)"
  if [ "$old" = "$new" ]; then
    echo "FAIL: plugins/$plugin/skills changed but $manifest version is still $old" >&2
    status=1
  else
    echo "OK: $plugin $old -> $new"
  fi
done

[ "$status" -eq 0 ] && echo "OK: version-bump check passed"
exit "$status"
