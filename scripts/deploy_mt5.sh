#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load local secrets (optional). Do not echo values.
if [[ -f "$ROOT_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
  set +a
fi

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 \"/path/to/MT5/Data/Folder\"" >&2
  echo "In MT5: File -> Open Data Folder (use that path)." >&2
  exit 2
fi

MT5_DATA_DIR="$1"

SRC_BASE="$ROOT_DIR/mt5/MQL5"

if [[ ! -d "$SRC_BASE" ]]; then
  echo "ERROR: Missing source directory: $SRC_BASE" >&2
  exit 1
fi

if [[ ! -d "$MT5_DATA_DIR" ]]; then
  echo "ERROR: MT5 data folder does not exist: $MT5_DATA_DIR" >&2
  exit 1
fi

mkdir -p "$MT5_DATA_DIR/MQL5/Indicators" "$MT5_DATA_DIR/MQL5/Experts"

cp -f "$SRC_BASE/Indicators/SMC_TrendBreakout_MTF.mq5" "$MT5_DATA_DIR/MQL5/Indicators/"
cp -f "$SRC_BASE/Experts/SMC_TrendBreakout_MTF_EA.mq5" "$MT5_DATA_DIR/MQL5/Experts/"

echo "Deployed mq5 files to:"
echo "  $MT5_DATA_DIR/MQL5/Indicators/"
echo "  $MT5_DATA_DIR/MQL5/Experts/"
echo
echo "Next: open MetaEditor (F4) and compile, then Navigator -> Refresh."

