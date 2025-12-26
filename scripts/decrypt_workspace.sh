#!/usr/bin/env bash
set -euo pipefail

# Decrypt an OpenSSL-encrypted archive created by encrypt_workspace.sh and extract it.
# Passphrase is taken from ENCRYPTION_PASSPHRASE, or (fallback) JULES_API_KEY.
#
# Example:
#   export ENCRYPTION_PASSPHRASE='...'
#   ./scripts/decrypt_workspace.sh workspace.tar.gz.enc /path/to/output_dir

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IN_FILE="${1:-${ROOT_DIR}/workspace.tar.gz.enc}"
OUT_DIR="${2:-${ROOT_DIR}/_decrypted_workspace}"
TMP_TAR="${OUT_DIR}/workspace.tar.gz"

PASSPHRASE="${ENCRYPTION_PASSPHRASE:-${JULES_API_KEY:-}}"
if [[ -z "${PASSPHRASE}" ]]; then
  echo "ERROR: Set ENCRYPTION_PASSPHRASE (preferred) or JULES_API_KEY in the environment." >&2
  exit 1
fi

mkdir -p "${OUT_DIR}"

export PASSPHRASE
openssl enc -d -aes-256-gcm -pbkdf2 -iter 200000 \
  -pass env:PASSPHRASE \
  -in "${IN_FILE}" \
  -out "${TMP_TAR}"
unset PASSPHRASE

tar -xzf "${TMP_TAR}" -C "${OUT_DIR}"
rm -f "${TMP_TAR}"

echo "Decrypted workspace extracted to: ${OUT_DIR}"
