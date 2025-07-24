#!/usr/bin/env bash
# ------------------------------------------------------------------
# packageall.sh – converted from packageall.bat (same logic)
# ------------------------------------------------------------------
set -euo pipefail
THIS_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$THIS_DIR"

# ---------------------------------------------------------------
# helper: chạy NSIS chỉ khi file exe tồn tại                  #
# ---------------------------------------------------------------
run_nsis() {
  local nsi=$1           # file .nsi
  local exe=$2           # exe cần kiểm tra
  if [[ -f "$exe" ]]; then
    if [[ -f "/mnt/c/Program Files (x86)/NSIS/makensis.exe" ]]; then
      "/mnt/c/Program Files (x86)/NSIS/makensis.exe" "$nsi"
    else
      "/mnt/c/Program Files/NSIS/makensis.exe" "$nsi"
    fi
  fi
}
# :contentReference[oaicite:0]{index=0}

# ---------------------------------------------------------------
# 32-bit (x86)                                                   #
# ---------------------------------------------------------------
if [[ "${1:-}" == "nox86" ]]; then
  echo "=== Packaging 32-bit ==="
  rm -f vcxsrv.*.installer*.exe

  # copy CRTs
  cp "$VCToolsRedistDir/x86/Microsoft.VC143.CRT/msvcp140.dll" .
  cp "$VCToolsRedistDir/x86/Microsoft.VC143.CRT/vcruntime140.dll" .
  cp "$VCToolsRedistDir/debug_nonredist/x86/Microsoft.VC143.DebugCRT/msvcp140d.dll" .
  cp "$VCToolsRedistDir/debug_nonredist/x86/Microsoft.VC143.DebugCRT/vcruntime140d.dll" .
  # :contentReference[oaicite:1]{index=1}

  run_nsis vcxsrv.nsi       "../obj/servrelease/vcxsrv.exe"
  run_nsis vcxsrv-debug.nsi "../obj/servdebug/vcxsrv.exe"

  rm -f vcruntime140*.dll msvcp140*.dll
fi

# ---------------------------------------------------------------
# 64-bit (x64)                                                   #
# ---------------------------------------------------------------
if [[ "${1:-}" == "nox64" ]]; then
  echo "=== Packaging 64-bit ==="
  rm -f vcxsrv-64.*.installer*.exe

  cp "$VCToolsRedistDir/x64/Microsoft.VC143.CRT/msvcp140.dll" .
  cp "$VCToolsRedistDir/x64/Microsoft.VC143.CRT/vcruntime140.dll" .
  cp "$VCToolsRedistDir/x64/Microsoft.VC143.CRT/vcruntime140_1.dll" .
  cp "$VCToolsRedistDir/debug_nonredist/x64/Microsoft.VC143.DebugCRT/msvcp140d.dll" .
  cp "$VCToolsRedistDir/debug_nonredist/x64/Microsoft.VC143.DebugCRT/vcruntime140d.dll" .
  cp "$VCToolsRedistDir/debug_nonredist/x64/Microsoft.VC143.DebugCRT/vcruntime140_1d.dll" .
  # :contentReference[oaicite:2]{index=2}

  run_nsis vcxsrv-64.nsi       "../obj64/servrelease/vcxsrv.exe"
  run_nsis vcxsrv-64-debug.nsi "../obj64/servdebug/vcxsrv.exe"

  rm -f vcruntime140*.dll msvcp140*.dll vcruntime140_1*.dll
fi
