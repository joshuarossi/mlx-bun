#!/bin/sh
# Repro: why does the optiq SERVER crash on 26B (curl exit 52 in the h2h
# matrix) when optiq DIRECT works (~55 tok/s)?
#
# Run on a CLEAN machine (reboot first, nothing else open) — 26B is 16.4 GB
# on 24 GB, so a loaded machine OOMs for the wrong reason.
#
#   sh scripts/repro-optiq-26b-server.sh              # baseline (sidecar present)
#   sh scripts/repro-optiq-26b-server.sh --no-sidecar # Josh's test: hide the
#                                                       # vision sidecar first
#
# Captures the optiq server's STDERR (the benchmark discards it) so we see
# the actual cause: a Metal/OOM std::terminate vs a Python kv-config error.
# Reversible: restores the sidecar on exit even if interrupted.
set -u

VENV="${MLX_BUN_ORACLE_VENV:-/Users/joshrossi/Code/mlx-lm/.venv}"
SNAP="$(ls -d "$HOME"/.cache/huggingface/hub/models--mlx-community--gemma-4-26B-A4B-it-OptiQ-4bit/snapshots/*/ 2>/dev/null | head -1)"
PORT=8970
LOG=/tmp/optiq-26b-server.stderr.log
SIDECAR="${SNAP%/}/optiq_vision.safetensors"

[ -n "$SNAP" ] || { echo "26B snapshot not found in HF cache"; exit 1; }
echo "snapshot: $SNAP"
echo "free RAM now:"; vm_stat | awk '/Pages free/{print "  ~"$3*16384/2**30" GB"}'

# --- optional: hide the vision sidecar so optiq can't auto-load it ---
HID=""
if [ "${1:-}" = "--no-sidecar" ] && [ -e "$SIDECAR" ]; then
  mv "$SIDECAR" "$SIDECAR.bak" && HID=1 && echo ">> vision sidecar HIDDEN ($SIDECAR -> .bak)"
fi
restore() {
  [ -n "$HID" ] && [ -e "$SIDECAR.bak" ] && mv "$SIDECAR.bak" "$SIDECAR" && echo ">> vision sidecar restored"
  [ -n "${SRVPID:-}" ] && kill "$SRVPID" 2>/dev/null
}
trap 'restore' EXIT INT TERM

# --- start optiq serve (kv_config leg, matching the failing cell) ---
echo ">> starting: optiq serve --model <26B> --kv-config (stderr -> $LOG)"
"$VENV/bin/optiq" serve --model "$SNAP" --port "$PORT" \
  --kv-config "${SNAP%/}/kv_config.json" >"$LOG" 2>&1 &
SRVPID=$!

# wait up to 6 min for /models to answer
echo ">> waiting for server ready ..."
i=0
until curl -sf "http://127.0.0.1:$PORT/v1/models" >/dev/null 2>&1; do
  i=$((i+1)); [ "$i" -ge 360 ] && { echo "!! never became ready — see $LOG"; tail -30 "$LOG"; exit 2; }
  kill -0 "$SRVPID" 2>/dev/null || { echo "!! server died before ready — see below"; tail -40 "$LOG"; exit 3; }
  sleep 1
done
echo ">> ready. sending one text-only request ..."

# --- the request that fails in the benchmark ---
REQ='{"model":"x","messages":[{"role":"user","content":"Count to five."}],"max_tokens":32,"temperature":0,"stream":true}'
if curl -sf -N "http://127.0.0.1:$PORT/v1/chat/completions" \
     -H 'content-type: application/json' -d "$REQ" | head -c 400; then
  echo; echo ">> RESULT: server produced output — the cell would PASS in this config."
else
  rc=$?
  echo; echo ">> RESULT: request FAILED (curl exit $rc) — same symptom as the benchmark."
  echo ">> optiq server stderr (tail) — THIS is the cause the benchmark hides:"
  echo "------------------------------------------------------------------"
  tail -40 "$LOG"
  echo "------------------------------------------------------------------"
fi
