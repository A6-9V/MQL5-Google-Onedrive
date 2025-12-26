#!/usr/bin/env bash
set -euo pipefail

# Encrypt a tar.gz snapshot of the repository (excluding .git) using OpenSSL.
# Passphrase is taken from ENCRYPTION_PASSPHRASE, or (fallback) JULES_API_KEY.
#
# Example:
#   export ENCRYPTION_PASSPHRASE='...'
#   ./scripts/encrypt_workspace.sh
#
# Output:
#   workspace.tar.gz.enc

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_FILE="${1:-${ROOT_DIR}/workspace.tar.gz.enc}"
TMP_TAR="${ROOT_DIR}/workspace.tar.gz"

PASSPHRASE="${ENCRYPTION_PASSPHRASE:-${JULES_API_KEY:-}}"
if [[ -z "${PASSPHRASE}" ]]; then
  echo "ERROR: Set ENCRYPTION_PASSPHRASE (preferred) or JULES_API_KEY in the environment." >&2
  exit 1
fi

trap 'rm -f "${TMP_TAR}"' EXIT

(
  cd "${ROOT_DIR}"
  tar \
    --exclude='.git' \
    --exclude='.env' \
    --exclude='workspace.tar.gz' \
    --exclude='workspace.tar.gz.enc' \
    -czf "${TMP_TAR}" .
)

# Use PBKDF2 to derive a strong key from the passphrase.
export PASSPHRASE
openssl enc -aes-256-gcm -salt -pbkdf2 -iter 200000 \
  -pass env:PASSPHRASE \
  -in "${TMP_TAR}" \
  -out "${OUT_FILE}"
unset PASSPHRASE

echo "Encrypted archive written to: ${OUT_FILE}"
