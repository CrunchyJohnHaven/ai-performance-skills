#!/usr/bin/env bash
# Refresh the Quality Judge skill from the latest published ElasticJudge
# package. Safe default behavior:
# - symlink install: update the global npm package only
# - copied skill outside a git worktree: sync files in place
# - repo checkout / git worktree: do not overwrite local files; print the
#   copy command instead so local development changes are never clobbered

set -euo pipefail

PKG="${ELASTICJUDGE_PKG:-elastic-judge}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

global_root_for_check() {
  if command -v npm >/dev/null 2>&1; then
    npm root -g
    return 0
  fi
  if command -v bun >/dev/null 2>&1; then
    local bun_root
    bun_root="$(bun pm ls --global 2>/dev/null | awk '/node_modules/{print $1}' | head -1)"
    if [[ -n "$bun_root" ]]; then
      printf '%s\n' "$bun_root"
    else
      printf '%s/.bun/install/global/node_modules\n' "$HOME"
    fi
    return 0
  fi
  if command -v pnpm >/dev/null 2>&1; then
    pnpm root --global
    return 0
  fi
  if command -v yarn >/dev/null 2>&1; then
    printf '%s/node_modules\n' "$(yarn global dir)"
    return 0
  fi
  return 1
}

current_pkg_version() {
  local global_root pkg_json
  global_root="$(global_root_for_check 2>/dev/null || true)"
  pkg_json="${global_root%/}/$PKG/package.json"

  if [[ -n "$global_root" && -f "$pkg_json" ]]; then
    sed -n 's/^[[:space:]]*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$pkg_json" | head -1
  else
    echo "not installed"
  fi
}

latest_pkg_version() {
  if command -v npm >/dev/null 2>&1; then
    npm show "$PKG" version 2>/dev/null || echo "unknown"
    return 0
  fi
  if command -v pnpm >/dev/null 2>&1; then
    pnpm view "$PKG" version 2>/dev/null || echo "unknown"
    return 0
  fi
  if command -v yarn >/dev/null 2>&1; then
    yarn info "$PKG" version --silent 2>/dev/null || echo "unknown"
    return 0
  fi
  echo "unknown"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      CURRENT="$(current_pkg_version)"
      LATEST="$(latest_pkg_version)"
      echo "current: $CURRENT  latest: $LATEST"
      [[ "$CURRENT" == "$LATEST" ]] && echo "up to date" || echo "update available"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

# Detect available package manager: npm is canonical; bun/pnpm/yarn are accepted.
# If none are present, print a manual fallback and exit cleanly.
PKG_MGR=""
if command -v npm >/dev/null 2>&1; then
  PKG_MGR="npm"
elif command -v bun >/dev/null 2>&1; then
  PKG_MGR="bun"
elif command -v pnpm >/dev/null 2>&1; then
  PKG_MGR="pnpm"
elif command -v yarn >/dev/null 2>&1; then
  PKG_MGR="yarn"
fi

if [[ -z "$PKG_MGR" ]]; then
  echo "error: no supported package manager found (npm / bun / pnpm / yarn)." >&2
  echo "  install Node.js (>=18) and npm, then re-run this script." >&2
  echo "  manual alternative: copy the skill files directly from a release tarball." >&2
  echo "    https://elasticjudge.com/ — see 'Manual install' in the docs." >&2
  exit 1
fi

echo "[elasticjudge] refreshing $PKG via $PKG_MGR"

case "$PKG_MGR" in
  npm)
    npm install -g "${PKG}@latest" || {
      echo "[elasticjudge] global install failed; the package may not be published yet." >&2
      echo "  override with: ELASTICJUDGE_PKG=<scope/name> scripts/update.sh" >&2
      echo "  manual alternative: https://elasticjudge.com/ — see 'Manual install'." >&2
      exit 1
    }
    GLOBAL_ROOT="$(npm root -g)"
    ;;
  bun)
    bun install --global "${PKG}@latest" || {
      echo "[elasticjudge] bun global install failed; the package may not be published yet." >&2
      echo "  fallback: install Node.js + npm and re-run, or set ELASTICJUDGE_PKG." >&2
      exit 1
    }
    GLOBAL_ROOT="$(bun pm ls --global 2>/dev/null | awk '/node_modules/{print $1}' | head -1)"
    if [[ -z "$GLOBAL_ROOT" ]]; then
      GLOBAL_ROOT="$(bun --print 'require("os").homedir()' 2>/dev/null)/.bun/install/global/node_modules"
    fi
    ;;
  pnpm)
    pnpm add --global "${PKG}@latest" || {
      echo "[elasticjudge] pnpm global install failed; the package may not be published yet." >&2
      echo "  fallback: install npm and re-run, or set ELASTICJUDGE_PKG." >&2
      exit 1
    }
    GLOBAL_ROOT="$(pnpm root --global)"
    ;;
  yarn)
    yarn global add "${PKG}@latest" || {
      echo "[elasticjudge] yarn global install failed; the package may not be published yet." >&2
      echo "  fallback: install npm and re-run, or set ELASTICJUDGE_PKG." >&2
      exit 1
    }
    GLOBAL_ROOT="$(yarn global dir)/node_modules"
    ;;
esac

SOURCE_DIR="$GLOBAL_ROOT/$PKG/skills/elasticjudge"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "error: updated skill files not found at $SOURCE_DIR" >&2
  echo "  the global package may not ship the skills/ directory yet." >&2
  exit 1
fi

if [[ -L "$SKILL_DIR" ]]; then
  echo
  echo "[elasticjudge] symlink install detected."
  echo "  global package updated; no further action needed."
  exit 0
fi

if git -C "$SKILL_DIR" rev-parse --show-toplevel >/dev/null 2>&1; then
  echo
  echo "[elasticjudge] git worktree detected; refusing to overwrite local files."
  echo "  copy manually if desired:"
  echo "  cp -R \"$SOURCE_DIR\" \"\$HOME/.claude/skills/elasticjudge\""
  exit 0
fi

if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "$SOURCE_DIR/" "$SKILL_DIR/"
else
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  cp -R "$SOURCE_DIR/." "$TMP_DIR/"
  find "$SKILL_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
  cp -R "$TMP_DIR/." "$SKILL_DIR/"
fi

echo
echo "[elasticjudge] skill files refreshed in $SKILL_DIR"
