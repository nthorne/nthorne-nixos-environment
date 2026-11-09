#!/usr/bin/env bash
# migrate-hermes-to-system.sh
#
# Make the NixOS-managed Hermes install (/var/lib/hermes, user "hermes") the
# only install on this host, by adopting the state of the per-user install
# (~/.hermes, user "nthorne") and switching the system to it.
#
# Order of operations:
#   1. build the new system closure        (fails here => nothing touched)
#   2. stop + disable the per-user gateway (this ends any running agent turn)
#   3. copy ~/.hermes -> /var/lib/hermes/.hermes, fix ownership
#   4. drop stale pid/lock files from the copy
#   5. nixos-rebuild switch                (re-renders .env + config.yaml)
#   6. verify gateway, webapp port, Discord connection
#   7. provision git identity + deploy key for the hermes user
#
# Usage:  ./migrate-hermes-to-system.sh [--yes]
# Run it as your normal user; it re-executes itself with sudo.

set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_USER="nthorne"
SOURCE_HOME="/home/${SOURCE_USER}"
SOURCE_HERMES="${SOURCE_HOME}/.hermes"
TARGET_USER="hermes"
TARGET_HOME="/var/lib/hermes"
TARGET_HERMES="${TARGET_HOME}/.hermes"
HOST="$(hostname)"
UNIT="hermes-agent.service"
USER_UNIT="hermes-gateway.service"
WEBAPP_PORT=9120
ASSUME_YES=0
[[ "${1:-}" == "--yes" || "${1:-}" == "-y" ]] && ASSUME_YES=1

say()  { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '    WARN: %s\n' "$*"; }
die()  { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

as_source() { runuser -u "$SOURCE_USER" -- env HOME="$SOURCE_HOME" XDG_RUNTIME_DIR="/run/user/$(id -u "$SOURCE_USER")" "$@"; }
as_target() { runuser -u "$TARGET_USER" -- env HOME="$TARGET_HOME" "$@"; }

# ----------------------------------------------------------------- root ---
if [[ ${EUID} -ne 0 ]]; then
  exec sudo -- "${BASH_SOURCE[0]}" "$@"
fi

# ------------------------------------------------------------- preflight ---
say "Preflight"
[[ -d "$SOURCE_HERMES" ]] || die "source install not found: $SOURCE_HERMES"
[[ -f "$REPO/flake.nix" ]] || die "$REPO is not the config repo"
id -u "$TARGET_USER" >/dev/null 2>&1 || die "user '$TARGET_USER' does not exist — switch a config with services.hermes-agent enabled first"
command -v rsync >/dev/null || die "rsync not found"
command -v nixos-rebuild >/dev/null || die "nixos-rebuild not found"

# Nix shells out to git for a flake inside a repo owned by another user; as
# root that trips the ownership check. Whitelist this one repo for root only.
if ! git config --global --get-all safe.directory 2>/dev/null | grep -qxF "$REPO"; then
  git config --global --add safe.directory "$REPO"
  info "added $REPO to root's git safe.directory"
fi

info "repo:       $REPO"
info "source:     $SOURCE_HERMES ($(du -sh "$SOURCE_HERMES" | cut -f1))"
info "target:     $TARGET_HERMES"
info "flake host: $HOST"
info "webapp:     port $WEBAPP_PORT"

if (( ! ASSUME_YES )); then
  cat <<EOF

This stops the gateway that answers on Discord right now and copies its state
into $TARGET_HERMES. Any running agent turn ends immediately.

The copy is one-way: $SOURCE_HERMES is left untouched, so the old install can
be restarted (see the end of this script) if the switch goes wrong.

EOF
  read -r -p "Type 'yes' to continue: " reply
  [[ "$reply" == "yes" ]] || die "aborted"
fi

# ------------------------------------------------------------------ 1/6 ---
say "1/6  Building the new system closure (nothing has been changed yet)"
# Build as the repo owner: its SSH key is the one that reaches the git flake
# inputs (nix-secrets), which root does not have.
if ! as_source nix build --no-link "$REPO#nixosConfigurations.$HOST.config.system.build.toplevel"; then
  die "build failed — nothing was changed, the current gateway is still running"
fi
# The switch below runs as root, so prove root can evaluate the same flake
# (git's ownership check is the usual failure) before anything is stopped.
if ! nix eval --raw "$REPO#nixosConfigurations.$HOST.config.system.build.toplevel.drvPath" >/dev/null; then
  die "root cannot evaluate $REPO — refusing to stop the gateway"
fi
info "build OK"

# ------------------------------------------------------------------ 2/6 ---
say "2/6  Stopping and disabling the per-user gateway"
if as_source systemctl --user disable --now "$USER_UNIT" 2>/dev/null; then
  info "$USER_UNIT stopped and disabled"
else
  info "$USER_UNIT was not running or not enabled — continuing"
fi

# ------------------------------------------------------------------ 3/6 ---
say "3/6  Copying state into $TARGET_HERMES"
install -d -m 0700 -o "$TARGET_USER" -g "$TARGET_USER" "$TARGET_HERMES"
rsync -a --delete "${SOURCE_HERMES}/" "${TARGET_HERMES}/"
chown -R "${TARGET_USER}:${TARGET_USER}" "$TARGET_HERMES"
info "copied $(du -sh "$TARGET_HERMES" | cut -f1), owned by $TARGET_USER"

# ------------------------------------------------------------------ 4/6 ---
say "4/6  Clearing stale runtime state from the copy"
for f in gateway.lock gateway.pid gateway.sock processes.json.lock auth.lock \
         state.db.quarantine.lock state.db.fts_rebuild.lock; do
  rm -f "${TARGET_HERMES}/${f}"
done
rm -rf "${TARGET_HERMES}/runtime"
info "removed pid/lock files and runtime/"

# ------------------------------------------------------------------ 5/6 ---
say "5/6  Switching the system (activation re-renders .env and config.yaml)"
if ! nixos-rebuild switch --flake "$REPO#$HOST"; then
  cat <<EOF

Switch FAILED and the per-user gateway is stopped, so the bot is offline.
Bring it back with:

  runuser -u $SOURCE_USER -- env XDG_RUNTIME_DIR=/run/user/$(id -u "$SOURCE_USER") \\
    systemctl --user enable --now $USER_UNIT

EOF
  die "nixos-rebuild switch failed"
fi
[[ -L "$REPO/result" ]] && rm -f "$REPO/result" || true
info "switched"

# ------------------------------------------------------------------ 6/6 ---
say "6/6  Verifying"
sleep 8

if systemctl is-active --quiet "$UNIT"; then
  info "$UNIT: active"
else
  die "$UNIT is not active — see: journalctl -u $UNIT -n 50"
fi

if ss -ltn 2>/dev/null | grep -q ":${WEBAPP_PORT} "; then
  info "webapp listening on :${WEBAPP_PORT}"
else
  warn "nothing listening on :${WEBAPP_PORT} — see: journalctl -u $UNIT -n 50"
fi

code=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:${WEBAPP_PORT}/" || true)
info "GET http://127.0.0.1:${WEBAPP_PORT}/ -> HTTP ${code:-no-response}"

if journalctl -u "$UNIT" --since "-3 min" --no-pager 2>/dev/null | grep -qi "Refusing to bind"; then
  warn "the auth gate refused to bind the webapp — check the HERMES_DASHBOARD_BASIC_AUTH_* lines in ${TARGET_HERMES}/.env"
fi
if journalctl -u "$UNIT" --since "-3 min" --no-pager 2>/dev/null | grep -qi "no allowlist is configured"; then
  warn "Discord still reports no allowlist — check DISCORD_ALLOWED_USERS in the sops template"
fi

info "recent gateway log:"
journalctl -u "$UNIT" --since "-3 min" --no-pager 2>/dev/null \
  | grep -iE "discord|webapp|dashboard|error|traceback" | tail -6 | sed 's/^/      /' || true

# ------------------------------------------------------ git + deploy keys ---
say "Git identity and deploy keys for $TARGET_USER"
GIT_NAME="$(as_source git config --global user.name 2>/dev/null || true)"
GIT_MAIL="$(as_source git config --global user.email 2>/dev/null || true)"

if [[ -n "$GIT_MAIL" ]]; then
  as_target git config --global user.name "${GIT_NAME:-Niklas Thorne}" \
    || warn "could not write user.name for $TARGET_USER"
  as_target git config --global user.email "$GIT_MAIL" \
    || warn "could not write user.email for $TARGET_USER"
  info "git identity: ${GIT_NAME:-Niklas Thorne} <$GIT_MAIL>"
else
  warn "no git identity found for $SOURCE_USER — set one before the agent commits:"
  info "  runuser -u $TARGET_USER -- env HOME=$TARGET_HOME git config --global user.email you@example.com"
fi

SSH_DIR="$TARGET_HOME/.ssh"
install -d -m 0700 -o "$TARGET_USER" -g "$TARGET_USER" "$SSH_DIR"

# Two keys, because a GitHub deploy key belongs to exactly one repo.
# nix-secrets is protected: read-only, only enough to fetch the flake input.
# The config repo gets a write key, for branches and PRs — never main.
make_key() {
  local key="$SSH_DIR/$1" comment="$2"
  if [[ -f "$key" ]]; then
    info "reusing $key"
  elif as_target ssh-keygen -t ed25519 -N "" -C "$comment" -f "$key" >/dev/null; then
    info "generated $key (no passphrase: the unit has no ssh-agent)"
  else
    warn "ssh-keygen failed for $key — create it by hand"
  fi
}
make_key id_ed25519_secrets "hermes@${HOST} nix-secrets read-only"
make_key id_ed25519_nixos   "hermes@${HOST} nixos-environment"

if cat > "$SSH_DIR/config" <<EOF
Host github.com
  User git
  IdentityFile $SSH_DIR/id_ed25519_secrets
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new

Host github-nixos
  HostName github.com
  User git
  IdentityFile $SSH_DIR/id_ed25519_nixos
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new
EOF
then
  chown "${TARGET_USER}:${TARGET_USER}" "$SSH_DIR/config"
  chmod 600 "$SSH_DIR/config"
  info "wrote $SSH_DIR/config (github.com -> read-only secrets key, github-nixos -> config-repo key)"
else
  warn "could not write $SSH_DIR/config"
fi

printf '\n    add these as deploy keys in GitHub:\n\n'
printf '      nix-secrets (nthorne/nix-secrets)            read-only — leave "Allow write access" OFF\n'
printf '      nthorne-nixos-environment                    write access\n\n'
printf '    nix-secrets:\n'
sed 's/^/      /' "$SSH_DIR/id_ed25519_secrets.pub" 2>/dev/null || warn "no secrets public key to show"
printf '\n    nixos environment:\n'
sed 's/^/      /' "$SSH_DIR/id_ed25519_nixos.pub" 2>/dev/null || warn "no config public key to show"

# --------------------------------------------------------------- summary ---
say "Done"
cat <<EOF
The managed install is now the only Hermes on this host.

  gateway:  $UNIT   (user $TARGET_USER, HOME $TARGET_HOME)
  home:     $TARGET_HERMES
  webapp:   http://100.113.64.38:${WEBAPP_PORT}  (or http://hex.tail75c8d4.ts.net:${WEBAPP_PORT})
  login:    nthorne — password in $SOURCE_HOME/.hermes-webapp-login
  logs:     journalctl -u $UNIT -f

Only $TARGET_HOME is writable by the agent, so clone repos there. The config
repo goes through the github-nixos alias (its write key); nix-secrets is only
ever fetched as a flake input and stays read-only:

  runuser -u $TARGET_USER -- env HOME=$TARGET_HOME \\
    git clone git@github-nixos:nthorne/nthorne-nixos-environment.git \\
    $TARGET_HOME/src/nthorne-nixos-environment

Per the config repo's AGENTS.md: never push to main — push a branch and open a
pull request, and only when asked.

Rollback (old install back in charge; the switched config stays):

  systemctl stop $UNIT
  runuser -u $SOURCE_USER -- env XDG_RUNTIME_DIR=/run/user/$(id -u "$SOURCE_USER") \\
    systemctl --user enable --now $USER_UNIT
EOF
