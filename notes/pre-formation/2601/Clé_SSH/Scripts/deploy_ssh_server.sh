#!/usr/bin/env bash
# deploy_ssh_server.sh - Ubuntu/Debian template to prepare SSH + key auth safely
#
# What it does:
# - Installs and enables openssh-server
# - Creates a non-root user (optional)
# - Enables password auth temporarily (to allow first connection)
# - Enables pubkey auth, disables root login
# - Validates sshd config BEFORE restarting (sshd -t)
# - Optionally installs/appends a provided public key for the user (idempotent)
#
# Usage:
#   sudo ./deploy_ssh_server.sh --user gloaguen --pubkey /tmp/id_ed25519.pub
#   sudo ./deploy_ssh_server.sh --user adminlab
#
# After you confirmed key auth works, you can disable passwords:
#   sudo ./deploy_ssh_server.sh --user gloaguen --harden --disable-password

set -euo pipefail

USER_NAME=""
PUBKEY_FILE=""
HARDEN="0"
DISABLE_PASSWORD="0"

usage() {
  cat <<'EOF'
Usage:
  sudo ./deploy_ssh_server.sh --user <username> [--pubkey <file>] [--harden] [--disable-password]

Options:
  --user <username>         Required. Non-root username to ensure/create.
  --pubkey <file>           Optional. Path to a public key to add to authorized_keys.
  --harden                  Optional. Add extra hardening toggles (no X11, no forwarding, etc.).
  --disable-password        Optional. Set PasswordAuthentication no (only after key auth works).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user) USER_NAME="${2:-}"; shift 2 ;;
    --pubkey) PUBKEY_FILE="${2:-}"; shift 2 ;;
    --harden) HARDEN="1"; shift ;;
    --disable-password) DISABLE_PASSWORD="1"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

if [[ -z "$USER_NAME" ]]; then
  echo "ERROR: --user is required" >&2
  usage
  exit 2
fi

if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: must be run as root (use sudo)." >&2
  exit 1
fi

echo "[1/8] Installing OpenSSH server..."
apt-get update -y
apt-get install -y openssh-server

echo "[2/8] Enabling SSH service..."
systemctl enable --now ssh

echo "[3/8] Ensuring user exists (non-root)..."
if ! id "$USER_NAME" >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" "$USER_NAME"
  echo "User created: $USER_NAME"
fi

# Optional: give sudo rights (comment out if you prefer not)
if ! id -nG "$USER_NAME" | tr ' ' '\n' | grep -qx "sudo"; then
  usermod -aG sudo "$USER_NAME"
fi

echo "[4/8] Preparing SSH server config (safe drop-in)..."
DROPIN_DIR="/etc/ssh/sshd_config.d"
DROPIN_FILE="$DROPIN_DIR/99-lab-hardening.conf"

mkdir -p "$DROPIN_DIR"

# Backup current drop-in if any
if [[ -f "$DROPIN_FILE" ]]; then
  cp -a "$DROPIN_FILE" "$DROPIN_FILE.bak.$(date +%Y%m%d-%H%M%S)"
fi

# Base settings (keep password auth enabled by default to allow first login)
cat >"$DROPIN_FILE" <<EOF
# Lab hardening (managed by deploy_ssh_server.sh)
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication yes
EOF

# Optional extra hardening toggles
if [[ "$HARDEN" == "1" ]]; then
  cat >>"$DROPIN_FILE" <<'EOF'
# Optional hardening
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
X11Forwarding no
AllowTcpForwarding no
EOF
fi

# Disable password auth only when explicitly asked (idempotent)
if [[ "$DISABLE_PASSWORD" == "1" ]]; then
  if grep -qE '^PasswordAuthentication ' "$DROPIN_FILE"; then
    sed -i 's/^PasswordAuthentication .*/PasswordAuthentication no/' "$DROPIN_FILE"
  else
    echo 'PasswordAuthentication no' >>"$DROPIN_FILE"
  fi
fi

echo "[5/8] Validating sshd config (no restart if invalid)..."
SSHD_BIN="$(command -v sshd || true)"
if [[ -z "$SSHD_BIN" && -x /usr/sbin/sshd ]]; then
  SSHD_BIN="/usr/sbin/sshd"
fi
if [[ -z "$SSHD_BIN" ]]; then
  echo "ERROR: sshd binary not found." >&2
  exit 1
fi

if ! "$SSHD_BIN" -t; then
  echo "ERROR: sshd config invalid. Not restarting." >&2
  echo "Hint: check with: sudo $SSHD_BIN -t && sudo journalctl -xeu ssh.service" >&2
  exit 1
fi

echo "[6/8] Restarting SSH service..."
systemctl restart ssh

echo "[7/8] Installing public key (optional)..."
if [[ -n "$PUBKEY_FILE" ]]; then
  if [[ ! -f "$PUBKEY_FILE" ]]; then
    echo "ERROR: pubkey file not found: $PUBKEY_FILE" >&2
    exit 2
  fi

  HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
  if [[ -z "$HOME_DIR" ]]; then
    echo "ERROR: could not resolve home dir for user: $USER_NAME" >&2
    exit 1
  fi

  install -d -m 700 -o "$USER_NAME" -g "$USER_NAME" "$HOME_DIR/.ssh"

  AUTH_KEYS="$HOME_DIR/.ssh/authorized_keys"
  touch "$AUTH_KEYS"
  chown "$USER_NAME:$USER_NAME" "$AUTH_KEYS"
  chmod 600 "$AUTH_KEYS"

  PUBKEY_LINE="$(tr -d '\r\n' < "$PUBKEY_FILE")"
  if [[ -z "$PUBKEY_LINE" ]]; then
    echo "ERROR: pubkey file is empty: $PUBKEY_FILE" >&2
    exit 2
  fi

  if ! grep -qxF "$PUBKEY_LINE" "$AUTH_KEYS"; then
    echo "$PUBKEY_LINE" >> "$AUTH_KEYS"
  fi

  echo "authorized_keys updated for $USER_NAME"
else
  echo "No --pubkey provided: skipping authorized_keys install."
fi

echo "[8/8] Status summary:"
systemctl --no-pager --full status ssh | sed -n '1,18p' || true
ss -lntp | grep -E ':(22)\s' || true

cat <<EOF

DONE.
Next steps:
- From your client, test SSH:
    ssh $USER_NAME@<vm-ip>
  or (VirtualBox port-forward):
    ssh -p 2224 $USER_NAME@127.0.0.1
- After key auth works, re-run with:
    sudo ./deploy_ssh_server.sh --user $USER_NAME --harden --disable-password
EOF
