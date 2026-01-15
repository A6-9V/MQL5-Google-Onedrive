#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT_DIR/mt5/MQL5"
OUT_DIR="$ROOT_DIR/dist"
OUT_ZIP="$OUT_DIR/Exness_MT5_MQL5.zip"

export ROOT_DIR SRC_DIR OUT_ZIP

if [[ ! -d "$SRC_DIR" ]]; then
  echo "ERROR: Missing source directory: $SRC_DIR" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

python3 - <<'PY'
import os
import zipfile

root_dir = os.environ["ROOT_DIR"]
src_dir = os.environ["SRC_DIR"]
out_zip = os.environ["OUT_ZIP"]

def should_include(path: str) -> bool:
    # Package only source code (mq5/mqh) so users compile locally.
    low = path.lower()
    return low.endswith(".mq5") or low.endswith(".mqh")

with zipfile.ZipFile(out_zip, "w", compression=zipfile.ZIP_DEFLATED) as z:
    for dirpath, _, filenames in os.walk(src_dir):
        for fn in filenames:
            full = os.path.join(dirpath, fn)
            if not should_include(full):
                continue
            rel_under_src = os.path.relpath(full, src_dir)
            arcname = os.path.join("MQL5", rel_under_src)
            z.write(full, arcname)

print(f"Created: {out_zip}")
PY

