import host.load.AneWorldTest
import host.mlx.ane.Layers
namespace Host.Load.Ane.AffineTest
open Host.Ts Host.Load Host.Mlx
open Host.Load.Ane.Test
open Host.Mlx.FfiAne (Effect Touch Alias)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # aneAffine's reader grouping through the extended world, on a small instance

`AneWorldTest` checks one MLP split call (its log is `mlpLayer_log`'s). This
is an aneAffine delta layer's grouping: four split calls on four programs with
their own buffers (two inputs of 32 and 16 bytes, a 16-byte output, one
64 KiB surface each), as `AneAffineSplit.forward` makes them: the two writes,
the blocking `evalAll`, `evalAsync`, the GPU rows' asynchronous evaluation,
`wait`, the output's wrap, slice, reshape and cast. The first two calls (qkv,
z) write the same input; the third's (out) input is computed from their two
readers; the fourth's (the MLP's position) from the third's reader; then the
layer's asynchronous evaluation. Checked by the kernel: the bridge logs
`affineDeltaLayer_log`'s effects (the first two readers run with the third
call's writers, the third's with the fourth's, the fourth's at the layer's
evaluation), and the touches of the writers and readers. -/

def affArgs : List Arg :=
  [.jsPtr 20 0 (cstr chars!"mil"), num 0, .null, .null, .null, num 2, .jsPtr 21 0 (u64s [32, 16]), num 16, .null,
   .jsPtr 22 0 (i32s [0]), .jsPtr 23 0 (u64s [0]), num 8]

/-- `AneAffineSplit.forward` through program `h` (wraps made on first use) on input node `src`: the head rows from
node 3, the reader's handle. -/
def affineCall (s : ASt) (h : Arg) (src : Nat) : Option (ASt × Arg) := do
  let (s, a0, _) ← step s chars!"mbane_input" [h, num 0]
  let (s, w0) ← wrapAt s a0
  let (s, a1, _) ← step s chars!"mbane_input" [h, num 1]
  let (s, w1) ← wrapAt s a1
  let (s, d0) ← fill s 6 [3, natOf w0]
  let (s, d1) ← fill s 6 [src, natOf w1]
  let (s, v) ← vecOf s [natOf d0, natOf d1]
  let (s, _, _) ← step s chars!"mlx_eval" [v]
  let (s, ok, _) ← step s chars!"mbane_eval_async" [h]
  match ok with
  | .num x => if x = litN 1 then pure () else none
  | _ => none
  let (s, g) ← vecOf s [4]
  let (s, _, _) ← step s chars!"mlx_async_eval" [g]
  let (s, _, _) ← step s chars!"mbane_wait" [h, .jsPtr 23 0 (u64s [0]), num 8]
  let (s, ao, _) ← step s chars!"mbane_output" [h]
  let (s, wo) ← wrapAt s ao
  let (s, _, ws) ← step s chars!"mlx_slice" [slot, wo, ints [0], .big 1, ints [8], .big 1, ints [1], .big 1, .big 0]
  let (s, _, ws) ← step s chars!"mlx_reshape" [slot, written ws, ints [2, 4], .big 2, .big 0]
  let (s, _, ws) ← step s chars!"mlx_astype" [slot, written ws, num Ffi.dtBf16, .big 0]
  pure (s, written ws)

/-- The layer: the four programs' loads, the four calls, the layer's asynchronous evaluation of the last reader. -/
def layer : Option ASt := do
  let (s, hA, _) ← step s0 chars!"mbane_program_create" affArgs
  let (s, hB, _) ← step s chars!"mbane_program_create" affArgs
  let (s, hC, _) ← step s chars!"mbane_program_create" affArgs
  let (s, hD, _) ← step s chars!"mbane_program_create" affArgs
  let (s, bA) ← affineCall s (argOf hA) 3
  let (s, bB) ← affineCall s (argOf hB) 3
  let (s, _, ws) ← step s chars!"mlx_add" [slot, bA, bB, .big 0]
  let (s, bC) ← affineCall s (argOf hC) (natOf (written ws))
  let (s, bD) ← affineCall s (argOf hD) (natOf bC)
  let (s, v) ← vecOf s [natOf bD]
  let (s, _, _) ← step s chars!"mlx_async_eval" [v]
  pure s

open FfiAneEval in
/-- A call's log entries depend only on its program and its writers' nodes. -/
def callOf (q : Nat) (ds : List Nat) : Call :=
  ⟨q, ds.map fun d => ⟨d, 0, 0, .writeHalf, writeConfig 0, [], [], .float16, [], ([1], .int32)⟩⟩

open FfiAneEval in
/-- A reader's log entry depends only on its node. -/
def readerOf (b : Nat) : Reader := ⟨b, 0, 0, 0, 0, 0⟩

open FfiAneEval in
/-- **The bridge logs an aneAffine delta layer's effects** (oldest first): programs 0–3 with writers 7–8, 15–16,
24–25, 32–33 and readers 12, 20, 29, 37; every reader and writer scheduled, the last reader still running. -/
theorem layer_log : (layer.map fun s => (s.bridge.log.reverse, s.bridge.unscheduled, s.bridge.running)) =
    some (segsLog (affineDeltaLayer (callOf 0 [7, 8]) (callOf 1 [15, 16]) (callOf 2 [24, 25]) (callOf 3 [32, 33])
      (readerOf 12) (readerOf 20) (readerOf 29) (readerOf 37)), [], [37]) := by
  decide +kernel

/-- The writers write their program's input surfaces (0–1, 3–4, 6–7, 9–10), the readers read its output's (2, 5, 8,
11). -/
theorem layer_touch : (layer.map fun s => [7, 8, 12, 15, 16, 20, 24, 25, 29, 32, 33, 37].map s.bridge.touch.get) =
    some [some (.write [0]), some (.write [1]), some (.read [2]), some (.write [3]), some (.write [4]),
      some (.read [5]), some (.write [6]), some (.write [7]), some (.read [8]), some (.write [9]), some (.write [10]),
      some (.read [11])] := by
  decide +kernel

end Host.Load.Ane.AffineTest
