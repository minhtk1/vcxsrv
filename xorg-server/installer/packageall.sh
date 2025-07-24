#!/bin/bash
# -----------------------------------------------------------------------------
# packageall.sh – build NSIS installers for VcXsrv (fixed patch logic)
# -----------------------------------------------------------------------------
# * Builds 32‑bit and/or 64‑bit installers.
# * Applies noadmin.patch only when it can be applied cleanly (dry‑run test).
# * Reverts the patch only if we really applied it in this run.
# * Uses --binary to avoid CR/LF issues that previously triggered
#   "assertion failed" or "hunk FAILED" errors.
# -----------------------------------------------------------------------------
set -euo pipefail

THIS_DIR=$(dirname "$0")
cd "$THIS_DIR"

# -----------------------------------------------------------------------------
# helper functions -------------------------------------------------------------
# -----------------------------------------------------------------------------
run_nsis() {
  local nsi=$1 exe=$2
  if [[ -f "$exe" ]]; then
    if [[ -f "/mnt/c/Program Files (x86)/NSIS/makensis.exe" ]]; then
      "/mnt/c/Program Files (x86)/NSIS/makensis.exe" "$nsi"
    else
      "/mnt/c/Program Files/NSIS/makensis.exe" "$nsi"
    fi
  fi
}

# Try a dry‑run; if patch applies cleanly, apply for real and return 0
apply_patch_if_needed() {
  if patch --binary -p3 --dry-run < noadmin.patch > /dev/null 2>&1; then
    echo "[patch] applying noadmin.patch"
    patch --binary -p3 < noadmin.patch
    return 0   # applied
  else
    echo "[patch] already applied – skip"
    return 1   # not applied
  fi
}

revert_patch_if_needed() {
  if [[ $1 -eq 0 ]]; then
    echo "[patch] need to revert – doing so"
    patch --binary -p3 -R < noadmin.patch || true
  fi
}

# -----------------------------------------------------------------------------
# 32‑bit (x86) ---------------------------------------------------------------
# -----------------------------------------------------------------------------
if [[ "${1:-}" != "nox86" ]]; then
  echo "=== Packaging 32‑bit ==="
  rm -f vcxsrv.*.installer*.exe

  # copy CRTs (paths assumed set by caller)
  cp "$VCToolsRedistDir/x86/Microsoft.VC143.CRT/msvcp140.dll" .
  cp "$VCToolsRedistDir/x86/Microsoft.VC143.CRT/vcruntime140.dll" .
  cp "$VCToolsRedistDir/debug_nonredist/x86/Microsoft.VC143.DebugCRT/msvcp140d.dll" .
  cp "$VCToolsRedistDir/debug_nonredist/x86/Microsoft.VC143.DebugCRT/vcruntime140d.dll" .

  run_nsis vcxsrv.nsi        "../obj/servrelease/vcxsrv.exe"
  run_nsis vcxsrv-debug.nsi  "../obj/servdebug/vcxsrv.exe"

  if apply_patch_if_needed; then PATCHED_X86=0; else PATCHED_X86=1; fi

  run_nsis vcxsrv.nsi        "../obj/servrelease/vcxsrv.exe"
  run_nsis vcxsrv-debug.nsi  "../obj/servdebug/vcxsrv.exe"

  revert_patch_if_needed $PATCHED_X86

  rm -f vcruntime140*.dll msvcp140*.dll
fi

# -----------------------------------------------------------------------------
# 64‑bit (x64) ---------------------------------------------------------------
# -----------------------------------------------------------------------------
if [[ "${1:-}" != "nox64" ]]; then
  echo "=== Packaging 64‑bit ==="
  rm -f vcxsrv-64.*.installer*.exe

  cp "$VCToolsRedistDir/x64/Microsoft.VC143.CRT/msvcp140.dll" .
  cp "$VCToolsRedistDir/x64/Microsoft.VC143.CRT/vcruntime140.dll" .
  cp "$VCToolsRedistDir/x64/Microsoft.VC143.CRT/vcruntime140_1.dll" .
  cp "$VCToolsRedistDir/debug_nonredist/x64/Microsoft.VC143.DebugCRT/msvcp140d.dll" .
  cp "$VCToolsRedistDir/debug_nonredist/x64/Microsoft.VC143.DebugCRT/vcruntime140d.dll" .
  cp "$VCToolsRedistDir/debug_nonredist/x64/Microsoft.VC143.DebugCRT/vcruntime140_1d.dll" .

  run_nsis vcxsrv-64.nsi        "../obj64/servrelease/vcxsrv.exe"
  run_nsis vcxsrv-64-debug.nsi  "../obj64/servdebug/vcxsrv.exe"

  if apply_patch_if_needed; then PATCHED_X64=0; else PATCHED_X64=1; fi

  run_nsis vcxsrv-64.nsi        "../obj64/servrelease/vcxsrv.exe"
  run_nsis vcxsrv-64-debug.nsi  "../obj64/servdebug/vcxsrv.exe"

  revert_patch_if_needed $PATCHED_X64

  rm -f vcruntime140*.dll msvcp140*.dll vcruntime140_1*.dll
fi