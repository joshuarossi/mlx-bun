import host.sim.stage.Under
import host.ts.tests.KvSrc
import host.mlx.FfiExpr
import host.ts.ast.inference.runtime.Resources
import host.ts.ast.inference.state.Leases
import host.ts.ast.inference.generation.Prefill
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Ts.Sim.Stage.Cache
open Host.Ts Host.Ts.Sim.Stage

/-! # The cache stages' templates: KV append and `evalCacheState`

Over the MLX FFI model (`Host.Mlx.Ffi.ffi`, native state concrete), each driver builds a
`KVCache` (state/kv.ts:33-49) as the route does, appends one row through `appendDecode`
(kv.ts:53-56, the decode loop and the final prefill row) or `r` rows through `appendWindow`
(kv.ts:58-61, the prefill drains and tails; the composition's `foldedWindowRead`), both through
`updateAndFetch` (kv.ts:108-150), then evaluates the cache state with `evalCacheState`
(generation/prefill.ts:12-14), as a drain does. The symbolic inputs are the offset `o` (`var 0`),
the buffer capacity `c` (`var 1`, the `keys`/`values` buffers `zeros([1, 4, c, 256])`) and the
rows `r` (`var 2`). Each chain's states: `s1` the append call, `s3` its return, `s4` the
`evalCacheState` call, `s6` its return. Both stages are checked with the caller frames free
(`tplN`, `stage_rfl`); `*.drive` composes the driver's run from them: prefix, append, the
driver's 12 steps between the calls, `evalCacheState`, suffix (sequential composition at a
call boundary). Classes: `KvDFit` (a decode row into room (`o + 1 < cap`)); `KvDFill` (a decode row filling the buffer (`o + 1 = cap`: the views are the buffer)); `KvDGrow` (a decode row at a full buffer (`cap = o`, `o % 256 = 0`): grows by 256); `KvDFirst` (a decode row into a null buffer (`keys = null`, offset 0)); `KvWFit` (a window of `r` rows into room (`o + r < cap`)); `KvWFill` (a window of `r` rows filling the buffer (`o + r = cap`)); `KvWGrow` (a window of `r` rows (`r % 256 ≠ 0`, a tail) at a full buffer: grows by `256·⌈r/256⌉`); `KvWGrow256` (a whole chunk (`r % 256 = 0`) at a full buffer: grows by `r`, the views are the buffer); `KvWFirst` (the first window (`r % 256 ≠ 0`) into a null buffer); `KvWFirst256` (the first whole chunk (`r % 256 = 0`) into a null buffer). The trim branch
(kv.ts:120-127, growth at `o % 256 ≠ 0`) has no class: on the route every growing append starts
at a multiple of 256 (`host.sim.PrefillSched.sched_ok`, `one_ok`; `CacheHolds.route_noTrim`). -/

namespace Drive
def source : String := "import { KVCache } from \"./state/kv\";
import { evalCacheState } from \"./generation/prefill\";
import * as ops from \"@mlx-bun/mlx/ops\";
import { o, c } from \"sym\";
const cache = new KVCache();
cache.keys = ops.zeros([1, 4, c, 256], 12);
cache.values = ops.zeros([1, 4, c, 256], 12);
cache.offset = o;
const k = ops.zeros([1, 4, 1, 256], 12);
const v = ops.zeros([1, 4, 1, 256], 12);
const read = cache.appendDecode(k, v);
evalCacheState([cache]);
export const out = [cache.offset];"
source_parse source
source_ast
end Drive

namespace DFirst
def source : String := "import { KVCache } from \"./state/kv\";
import { evalCacheState } from \"./generation/prefill\";
import * as ops from \"@mlx-bun/mlx/ops\";
const cache = new KVCache();
const k = ops.zeros([1, 4, 1, 256], 12);
const v = ops.zeros([1, 4, 1, 256], 12);
const read = cache.appendDecode(k, v);
evalCacheState([cache]);
export const out = [cache.offset];"
source_parse source
source_ast
end DFirst

namespace DWin
def source : String := "import { KVCache } from \"./state/kv\";
import { foldedWindowRead } from \"./state/attention-read\";
import { evalCacheState } from \"./generation/prefill\";
import * as ops from \"@mlx-bun/mlx/ops\";
import { o, c, r } from \"sym\";
const cache = new KVCache(undefined, undefined, foldedWindowRead);
cache.keys = ops.zeros([1, 4, c, 256], 12);
cache.values = ops.zeros([1, 4, c, 256], 12);
cache.offset = o;
const k = ops.zeros([1, 4, r, 256], 12);
const v = ops.zeros([1, 4, r, 256], 12);
const read = cache.appendWindow(k, v);
evalCacheState([cache]);
export const out = [cache.offset];"
source_parse source
source_ast
end DWin

namespace DWinFirst
def source : String := "import { KVCache } from \"./state/kv\";
import { foldedWindowRead } from \"./state/attention-read\";
import { evalCacheState } from \"./generation/prefill\";
import * as ops from \"@mlx-bun/mlx/ops\";
import { r } from \"sym\";
const cache = new KVCache(undefined, undefined, foldedWindowRead);
const k = ops.zeros([1, 4, r, 256], 12);
const v = ops.zeros([1, 4, r, 256], 12);
const read = cache.appendWindow(k, v);
evalCacheState([cache]);
export const out = [cache.offset];"
source_parse source
source_ast
end DWinFirst

/-- The symbolic inputs: offset `o`, capacity `c`, rows `r` (table entries `0`, `1`, `2`). -/
def symMod {S : Type} : HMod S :=
  ⟨chars!"sym", pure [(chars!"o", .num (.ref 0)), (chars!"c", .num (.ref 1)), (chars!"r", .num (.ref 2))]⟩

def modsOf (d : Module) : List UMod :=
  [⟨chars!"packages/mlx/src/ffi.ts", Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/mlx/src/native.ts", Tests.MlxNative.ast⟩,
   ⟨chars!"packages/mlx/src/command-buffers.ts", Tests.MlxCommandBuffers.ast⟩,
   ⟨chars!"packages/mlx/src/host-buffer.ts", Tests.MlxHostBuffer.ast⟩,
   ⟨chars!"packages/inference/src/state/kv.ts", Sources.Inference.State.Kv.ast⟩,
   ⟨chars!"packages/inference/src/state/attention-read.ts", Sources.Inference.State.AttentionRead.ast⟩,
   ⟨chars!"packages/inference/src/kernels/attention/masks.ts", Tests.KvMasks.ast⟩,
   ⟨chars!"packages/inference/src/state/quantized-kv.ts", Tests.KvQuantized.ast⟩,
   ⟨chars!"packages/inference/src/state/turboquant-attention.ts", Tests.KvTurbo.ast⟩,
   ⟨chars!"packages/inference/src/layers/folded-attention.ts", Tests.KvFolded.ast⟩,
   ⟨chars!"packages/inference/src/runtime/resources.ts", Sources.Inference.Runtime.Resources.ast⟩,
   ⟨chars!"packages/inference/src/state/leases.ts", Sources.Inference.State.Leases.ast⟩,
   ⟨chars!"packages/inference/src/generation/prefill.ts", Sources.Inference.Generation.Prefill.ast⟩,
   ⟨chars!"packages/inference/src/__cache.ts", d⟩]

def bootOf (d : Module) : Option (St Host.Mlx.Ffi.ffi.S) :=
  boot (Host.Mlx.Ffi.init [] [] chars!"applegpu_g13s" []) (modsOf d) [bunFfi, symMod] chars!"packages/inference/src/__cache.ts"

def tab3 : List SymE := [.var 0, .var 1, .var 2]

/-- A discovery valuation. -/
def ρ3 (o c r : Nat) : Nat → F64 := fun i => if i = 0 then F64.ofNat o else if i = 1 then F64.ofNat c else F64.ofNat r

/-! ## Class `KvDFit`: a decode row into room (`o + 1 < cap`) -/

host_chain_sym KvDFit : Host.Mlx.Ffi.ffi, bootOf Drive.ast, tab3, ρ3 1000 1280 1, 20000, [4441, 2759, 1, 12, 945, 1, 13]

kernel_rfl KvDFit.d2 : KvDFit.s2.stack.length = 4
kernel_rfl KvDFit.d5 : KvDFit.s5.stack.length = 3

stage_rfl KvDFit.appendBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 2759 (tplN KvDFit.s1 0 r) KvDFit.S1 = some (tplN KvDFit.s2 1 r, KvDFit.S2)
stage_rfl KvDFit.appendLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvDFit.s2 1 r)).run KvDFit.S2 = some (tplN KvDFit.s3 0 r, KvDFit.S3)
kernel_rfl KvDFit.live2 : isHalt KvDFit.s2.ctl = false

/-- The append of class `KvDFit` under every caller stack. -/
theorem KvDFit.append (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 2760 (tplN KvDFit.s1 0 r) KvDFit.S1 = some (tplN KvDFit.s3 0 r, KvDFit.S3) :=
  runS_snoc _ (KvDFit.appendBody r) KvDFit.live2 (KvDFit.appendLast r)

stage_rfl KvDFit.evalBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 945 (tplN KvDFit.s4 0 r) KvDFit.S4 = some (tplN KvDFit.s5 1 r, KvDFit.S5)
stage_rfl KvDFit.evalLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvDFit.s5 1 r)).run KvDFit.S5 = some (tplN KvDFit.s6 0 r, KvDFit.S6)
kernel_rfl KvDFit.live5 : isHalt KvDFit.s5.ctl = false

/-- `evalCacheState` after the append of class `KvDFit`, under every caller stack. -/
theorem KvDFit.eval (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 946 (tplN KvDFit.s4 0 r) KvDFit.S4 = some (tplN KvDFit.s6 0 r, KvDFit.S6) :=
  runS_snoc _ (KvDFit.evalBody r) KvDFit.live5 (KvDFit.evalLast r)

host_chunk KvDFit 0
host_chunk KvDFit 3
host_chunk KvDFit 6
kernel_rfl KvDFit.frames3 : KvDFit.s3.stack = KvDFit.s1.stack
kernel_rfl KvDFit.frames6 : KvDFit.s6.stack = KvDFit.s4.stack

/-- The driver's run of class `KvDFit`: prefix, the append under the driver's frames, the driver's
steps between the calls, `evalCacheState` under the driver's frames, suffix. -/
theorem KvDFit.drive : runS Host.Mlx.Ffi.ffi (4441 + 2760 + 12 + 946 + 13) KvDFit.s0 KvDFit.S0 = some (KvDFit.s7, KvDFit.S7) := by
  have a := KvDFit.append KvDFit.s1.stack
  rw [show tplN KvDFit.s1 0 KvDFit.s1.stack = KvDFit.s1 from tplN_self KvDFit.s1 0,
    show tplN KvDFit.s3 0 KvDFit.s1.stack = KvDFit.s3 by rw [← KvDFit.frames3]; exact tplN_self KvDFit.s3 0] at a
  have e := KvDFit.eval KvDFit.s4.stack
  rw [show tplN KvDFit.s4 0 KvDFit.s4.stack = KvDFit.s4 from tplN_self KvDFit.s4 0,
    show tplN KvDFit.s6 0 KvDFit.s4.stack = KvDFit.s6 by rw [← KvDFit.frames6]; exact tplN_self KvDFit.s6 0] at e
  exact runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ KvDFit.c0 a) KvDFit.c3) e) KvDFit.c6

/-! ## Class `KvDFill`: a decode row filling the buffer (`o + 1 = cap`: the views are the buffer) -/

host_chain_sym KvDFill : Host.Mlx.Ffi.ffi, bootOf Drive.ast, tab3, ρ3 1279 1280 1, 20000, [4441, 2759, 1, 12, 945, 1, 13]

kernel_rfl KvDFill.d2 : KvDFill.s2.stack.length = 4
kernel_rfl KvDFill.d5 : KvDFill.s5.stack.length = 3

stage_rfl KvDFill.appendBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 2759 (tplN KvDFill.s1 0 r) KvDFill.S1 = some (tplN KvDFill.s2 1 r, KvDFill.S2)
stage_rfl KvDFill.appendLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvDFill.s2 1 r)).run KvDFill.S2 = some (tplN KvDFill.s3 0 r, KvDFill.S3)
kernel_rfl KvDFill.live2 : isHalt KvDFill.s2.ctl = false

/-- The append of class `KvDFill` under every caller stack. -/
theorem KvDFill.append (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 2760 (tplN KvDFill.s1 0 r) KvDFill.S1 = some (tplN KvDFill.s3 0 r, KvDFill.S3) :=
  runS_snoc _ (KvDFill.appendBody r) KvDFill.live2 (KvDFill.appendLast r)

stage_rfl KvDFill.evalBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 945 (tplN KvDFill.s4 0 r) KvDFill.S4 = some (tplN KvDFill.s5 1 r, KvDFill.S5)
stage_rfl KvDFill.evalLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvDFill.s5 1 r)).run KvDFill.S5 = some (tplN KvDFill.s6 0 r, KvDFill.S6)
kernel_rfl KvDFill.live5 : isHalt KvDFill.s5.ctl = false

/-- `evalCacheState` after the append of class `KvDFill`, under every caller stack. -/
theorem KvDFill.eval (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 946 (tplN KvDFill.s4 0 r) KvDFill.S4 = some (tplN KvDFill.s6 0 r, KvDFill.S6) :=
  runS_snoc _ (KvDFill.evalBody r) KvDFill.live5 (KvDFill.evalLast r)

host_chunk KvDFill 0
host_chunk KvDFill 3
host_chunk KvDFill 6
kernel_rfl KvDFill.frames3 : KvDFill.s3.stack = KvDFill.s1.stack
kernel_rfl KvDFill.frames6 : KvDFill.s6.stack = KvDFill.s4.stack

/-- The driver's run of class `KvDFill`: prefix, the append under the driver's frames, the driver's
steps between the calls, `evalCacheState` under the driver's frames, suffix. -/
theorem KvDFill.drive : runS Host.Mlx.Ffi.ffi (4441 + 2760 + 12 + 946 + 13) KvDFill.s0 KvDFill.S0 = some (KvDFill.s7, KvDFill.S7) := by
  have a := KvDFill.append KvDFill.s1.stack
  rw [show tplN KvDFill.s1 0 KvDFill.s1.stack = KvDFill.s1 from tplN_self KvDFill.s1 0,
    show tplN KvDFill.s3 0 KvDFill.s1.stack = KvDFill.s3 by rw [← KvDFill.frames3]; exact tplN_self KvDFill.s3 0] at a
  have e := KvDFill.eval KvDFill.s4.stack
  rw [show tplN KvDFill.s4 0 KvDFill.s4.stack = KvDFill.s4 from tplN_self KvDFill.s4 0,
    show tplN KvDFill.s6 0 KvDFill.s4.stack = KvDFill.s6 by rw [← KvDFill.frames6]; exact tplN_self KvDFill.s6 0] at e
  exact runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ KvDFill.c0 a) KvDFill.c3) e) KvDFill.c6

/-! ## Class `KvDGrow`: a decode row at a full buffer (`cap = o`, `o % 256 = 0`): grows by 256 -/

host_chain_sym KvDGrow : Host.Mlx.Ffi.ffi, bootOf Drive.ast, tab3, ρ3 1024 1024 1, 20000, [4441, 4624, 1, 12, 945, 1, 13]

kernel_rfl KvDGrow.d2 : KvDGrow.s2.stack.length = 4
kernel_rfl KvDGrow.d5 : KvDGrow.s5.stack.length = 3

stage_rfl KvDGrow.appendBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 4624 (tplN KvDGrow.s1 0 r) KvDGrow.S1 = some (tplN KvDGrow.s2 1 r, KvDGrow.S2)
stage_rfl KvDGrow.appendLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvDGrow.s2 1 r)).run KvDGrow.S2 = some (tplN KvDGrow.s3 0 r, KvDGrow.S3)
kernel_rfl KvDGrow.live2 : isHalt KvDGrow.s2.ctl = false

/-- The append of class `KvDGrow` under every caller stack. -/
theorem KvDGrow.append (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 4625 (tplN KvDGrow.s1 0 r) KvDGrow.S1 = some (tplN KvDGrow.s3 0 r, KvDGrow.S3) :=
  runS_snoc _ (KvDGrow.appendBody r) KvDGrow.live2 (KvDGrow.appendLast r)

stage_rfl KvDGrow.evalBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 945 (tplN KvDGrow.s4 0 r) KvDGrow.S4 = some (tplN KvDGrow.s5 1 r, KvDGrow.S5)
stage_rfl KvDGrow.evalLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvDGrow.s5 1 r)).run KvDGrow.S5 = some (tplN KvDGrow.s6 0 r, KvDGrow.S6)
kernel_rfl KvDGrow.live5 : isHalt KvDGrow.s5.ctl = false

/-- `evalCacheState` after the append of class `KvDGrow`, under every caller stack. -/
theorem KvDGrow.eval (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 946 (tplN KvDGrow.s4 0 r) KvDGrow.S4 = some (tplN KvDGrow.s6 0 r, KvDGrow.S6) :=
  runS_snoc _ (KvDGrow.evalBody r) KvDGrow.live5 (KvDGrow.evalLast r)

host_chunk KvDGrow 0
host_chunk KvDGrow 3
host_chunk KvDGrow 6
kernel_rfl KvDGrow.frames3 : KvDGrow.s3.stack = KvDGrow.s1.stack
kernel_rfl KvDGrow.frames6 : KvDGrow.s6.stack = KvDGrow.s4.stack

/-- The driver's run of class `KvDGrow`: prefix, the append under the driver's frames, the driver's
steps between the calls, `evalCacheState` under the driver's frames, suffix. -/
theorem KvDGrow.drive : runS Host.Mlx.Ffi.ffi (4441 + 4625 + 12 + 946 + 13) KvDGrow.s0 KvDGrow.S0 = some (KvDGrow.s7, KvDGrow.S7) := by
  have a := KvDGrow.append KvDGrow.s1.stack
  rw [show tplN KvDGrow.s1 0 KvDGrow.s1.stack = KvDGrow.s1 from tplN_self KvDGrow.s1 0,
    show tplN KvDGrow.s3 0 KvDGrow.s1.stack = KvDGrow.s3 by rw [← KvDGrow.frames3]; exact tplN_self KvDGrow.s3 0] at a
  have e := KvDGrow.eval KvDGrow.s4.stack
  rw [show tplN KvDGrow.s4 0 KvDGrow.s4.stack = KvDGrow.s4 from tplN_self KvDGrow.s4 0,
    show tplN KvDGrow.s6 0 KvDGrow.s4.stack = KvDGrow.s6 by rw [← KvDGrow.frames6]; exact tplN_self KvDGrow.s6 0] at e
  exact runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ KvDGrow.c0 a) KvDGrow.c3) e) KvDGrow.c6

/-! ## Class `KvDFirst`: a decode row into a null buffer (`keys = null`, offset 0) -/

host_chain_sym KvDFirst : Host.Mlx.Ffi.ffi, bootOf DFirst.ast, tab3, ρ3 0 0 1, 20000, [4004, 3451, 1, 12, 945, 1, 13]

kernel_rfl KvDFirst.d2 : KvDFirst.s2.stack.length = 4
kernel_rfl KvDFirst.d5 : KvDFirst.s5.stack.length = 3

stage_rfl KvDFirst.appendBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 3451 (tplN KvDFirst.s1 0 r) KvDFirst.S1 = some (tplN KvDFirst.s2 1 r, KvDFirst.S2)
stage_rfl KvDFirst.appendLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvDFirst.s2 1 r)).run KvDFirst.S2 = some (tplN KvDFirst.s3 0 r, KvDFirst.S3)
kernel_rfl KvDFirst.live2 : isHalt KvDFirst.s2.ctl = false

/-- The append of class `KvDFirst` under every caller stack. -/
theorem KvDFirst.append (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 3452 (tplN KvDFirst.s1 0 r) KvDFirst.S1 = some (tplN KvDFirst.s3 0 r, KvDFirst.S3) :=
  runS_snoc _ (KvDFirst.appendBody r) KvDFirst.live2 (KvDFirst.appendLast r)

stage_rfl KvDFirst.evalBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 945 (tplN KvDFirst.s4 0 r) KvDFirst.S4 = some (tplN KvDFirst.s5 1 r, KvDFirst.S5)
stage_rfl KvDFirst.evalLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvDFirst.s5 1 r)).run KvDFirst.S5 = some (tplN KvDFirst.s6 0 r, KvDFirst.S6)
kernel_rfl KvDFirst.live5 : isHalt KvDFirst.s5.ctl = false

/-- `evalCacheState` after the append of class `KvDFirst`, under every caller stack. -/
theorem KvDFirst.eval (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 946 (tplN KvDFirst.s4 0 r) KvDFirst.S4 = some (tplN KvDFirst.s6 0 r, KvDFirst.S6) :=
  runS_snoc _ (KvDFirst.evalBody r) KvDFirst.live5 (KvDFirst.evalLast r)

host_chunk KvDFirst 0
host_chunk KvDFirst 3
host_chunk KvDFirst 6
kernel_rfl KvDFirst.frames3 : KvDFirst.s3.stack = KvDFirst.s1.stack
kernel_rfl KvDFirst.frames6 : KvDFirst.s6.stack = KvDFirst.s4.stack

/-- The driver's run of class `KvDFirst`: prefix, the append under the driver's frames, the driver's
steps between the calls, `evalCacheState` under the driver's frames, suffix. -/
theorem KvDFirst.drive : runS Host.Mlx.Ffi.ffi (4004 + 3452 + 12 + 946 + 13) KvDFirst.s0 KvDFirst.S0 = some (KvDFirst.s7, KvDFirst.S7) := by
  have a := KvDFirst.append KvDFirst.s1.stack
  rw [show tplN KvDFirst.s1 0 KvDFirst.s1.stack = KvDFirst.s1 from tplN_self KvDFirst.s1 0,
    show tplN KvDFirst.s3 0 KvDFirst.s1.stack = KvDFirst.s3 by rw [← KvDFirst.frames3]; exact tplN_self KvDFirst.s3 0] at a
  have e := KvDFirst.eval KvDFirst.s4.stack
  rw [show tplN KvDFirst.s4 0 KvDFirst.s4.stack = KvDFirst.s4 from tplN_self KvDFirst.s4 0,
    show tplN KvDFirst.s6 0 KvDFirst.s4.stack = KvDFirst.s6 by rw [← KvDFirst.frames6]; exact tplN_self KvDFirst.s6 0] at e
  exact runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ KvDFirst.c0 a) KvDFirst.c3) e) KvDFirst.c6

/-! ## Class `KvWFit`: a window of `r` rows into room (`o + r < cap`) -/

host_chain_sym KvWFit : Host.Mlx.Ffi.ffi, bootOf DWin.ast, tab3, ρ3 1024 1536 300, 20000, [4446, 2760, 1, 12, 945, 1, 13]

kernel_rfl KvWFit.d2 : KvWFit.s2.stack.length = 4
kernel_rfl KvWFit.d5 : KvWFit.s5.stack.length = 3

stage_rfl KvWFit.appendBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 2760 (tplN KvWFit.s1 0 r) KvWFit.S1 = some (tplN KvWFit.s2 1 r, KvWFit.S2)
stage_rfl KvWFit.appendLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvWFit.s2 1 r)).run KvWFit.S2 = some (tplN KvWFit.s3 0 r, KvWFit.S3)
kernel_rfl KvWFit.live2 : isHalt KvWFit.s2.ctl = false

/-- The append of class `KvWFit` under every caller stack. -/
theorem KvWFit.append (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 2761 (tplN KvWFit.s1 0 r) KvWFit.S1 = some (tplN KvWFit.s3 0 r, KvWFit.S3) :=
  runS_snoc _ (KvWFit.appendBody r) KvWFit.live2 (KvWFit.appendLast r)

stage_rfl KvWFit.evalBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 945 (tplN KvWFit.s4 0 r) KvWFit.S4 = some (tplN KvWFit.s5 1 r, KvWFit.S5)
stage_rfl KvWFit.evalLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvWFit.s5 1 r)).run KvWFit.S5 = some (tplN KvWFit.s6 0 r, KvWFit.S6)
kernel_rfl KvWFit.live5 : isHalt KvWFit.s5.ctl = false

/-- `evalCacheState` after the append of class `KvWFit`, under every caller stack. -/
theorem KvWFit.eval (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 946 (tplN KvWFit.s4 0 r) KvWFit.S4 = some (tplN KvWFit.s6 0 r, KvWFit.S6) :=
  runS_snoc _ (KvWFit.evalBody r) KvWFit.live5 (KvWFit.evalLast r)

host_chunk KvWFit 0
host_chunk KvWFit 3
host_chunk KvWFit 6
kernel_rfl KvWFit.frames3 : KvWFit.s3.stack = KvWFit.s1.stack
kernel_rfl KvWFit.frames6 : KvWFit.s6.stack = KvWFit.s4.stack

/-- The driver's run of class `KvWFit`: prefix, the append under the driver's frames, the driver's
steps between the calls, `evalCacheState` under the driver's frames, suffix. -/
theorem KvWFit.drive : runS Host.Mlx.Ffi.ffi (4446 + 2761 + 12 + 946 + 13) KvWFit.s0 KvWFit.S0 = some (KvWFit.s7, KvWFit.S7) := by
  have a := KvWFit.append KvWFit.s1.stack
  rw [show tplN KvWFit.s1 0 KvWFit.s1.stack = KvWFit.s1 from tplN_self KvWFit.s1 0,
    show tplN KvWFit.s3 0 KvWFit.s1.stack = KvWFit.s3 by rw [← KvWFit.frames3]; exact tplN_self KvWFit.s3 0] at a
  have e := KvWFit.eval KvWFit.s4.stack
  rw [show tplN KvWFit.s4 0 KvWFit.s4.stack = KvWFit.s4 from tplN_self KvWFit.s4 0,
    show tplN KvWFit.s6 0 KvWFit.s4.stack = KvWFit.s6 by rw [← KvWFit.frames6]; exact tplN_self KvWFit.s6 0] at e
  exact runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ KvWFit.c0 a) KvWFit.c3) e) KvWFit.c6

/-! ## Class `KvWFill`: a window of `r` rows filling the buffer (`o + r = cap`) -/

host_chain_sym KvWFill : Host.Mlx.Ffi.ffi, bootOf DWin.ast, tab3, ρ3 1236 1536 300, 20000, [4446, 2760, 1, 12, 945, 1, 13]

kernel_rfl KvWFill.d2 : KvWFill.s2.stack.length = 4
kernel_rfl KvWFill.d5 : KvWFill.s5.stack.length = 3

stage_rfl KvWFill.appendBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 2760 (tplN KvWFill.s1 0 r) KvWFill.S1 = some (tplN KvWFill.s2 1 r, KvWFill.S2)
stage_rfl KvWFill.appendLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvWFill.s2 1 r)).run KvWFill.S2 = some (tplN KvWFill.s3 0 r, KvWFill.S3)
kernel_rfl KvWFill.live2 : isHalt KvWFill.s2.ctl = false

/-- The append of class `KvWFill` under every caller stack. -/
theorem KvWFill.append (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 2761 (tplN KvWFill.s1 0 r) KvWFill.S1 = some (tplN KvWFill.s3 0 r, KvWFill.S3) :=
  runS_snoc _ (KvWFill.appendBody r) KvWFill.live2 (KvWFill.appendLast r)

stage_rfl KvWFill.evalBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 945 (tplN KvWFill.s4 0 r) KvWFill.S4 = some (tplN KvWFill.s5 1 r, KvWFill.S5)
stage_rfl KvWFill.evalLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvWFill.s5 1 r)).run KvWFill.S5 = some (tplN KvWFill.s6 0 r, KvWFill.S6)
kernel_rfl KvWFill.live5 : isHalt KvWFill.s5.ctl = false

/-- `evalCacheState` after the append of class `KvWFill`, under every caller stack. -/
theorem KvWFill.eval (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 946 (tplN KvWFill.s4 0 r) KvWFill.S4 = some (tplN KvWFill.s6 0 r, KvWFill.S6) :=
  runS_snoc _ (KvWFill.evalBody r) KvWFill.live5 (KvWFill.evalLast r)

host_chunk KvWFill 0
host_chunk KvWFill 3
host_chunk KvWFill 6
kernel_rfl KvWFill.frames3 : KvWFill.s3.stack = KvWFill.s1.stack
kernel_rfl KvWFill.frames6 : KvWFill.s6.stack = KvWFill.s4.stack

/-- The driver's run of class `KvWFill`: prefix, the append under the driver's frames, the driver's
steps between the calls, `evalCacheState` under the driver's frames, suffix. -/
theorem KvWFill.drive : runS Host.Mlx.Ffi.ffi (4446 + 2761 + 12 + 946 + 13) KvWFill.s0 KvWFill.S0 = some (KvWFill.s7, KvWFill.S7) := by
  have a := KvWFill.append KvWFill.s1.stack
  rw [show tplN KvWFill.s1 0 KvWFill.s1.stack = KvWFill.s1 from tplN_self KvWFill.s1 0,
    show tplN KvWFill.s3 0 KvWFill.s1.stack = KvWFill.s3 by rw [← KvWFill.frames3]; exact tplN_self KvWFill.s3 0] at a
  have e := KvWFill.eval KvWFill.s4.stack
  rw [show tplN KvWFill.s4 0 KvWFill.s4.stack = KvWFill.s4 from tplN_self KvWFill.s4 0,
    show tplN KvWFill.s6 0 KvWFill.s4.stack = KvWFill.s6 by rw [← KvWFill.frames6]; exact tplN_self KvWFill.s6 0] at e
  exact runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ KvWFill.c0 a) KvWFill.c3) e) KvWFill.c6

/-! ## Class `KvWGrow`: a window of `r` rows (`r % 256 ≠ 0`, a tail) at a full buffer: grows by `256·⌈r/256⌉` -/

host_chain_sym KvWGrow : Host.Mlx.Ffi.ffi, bootOf DWin.ast, tab3, ρ3 1024 1024 300, 20000, [4446, 4625, 1, 12, 945, 1, 13]

kernel_rfl KvWGrow.d2 : KvWGrow.s2.stack.length = 4
kernel_rfl KvWGrow.d5 : KvWGrow.s5.stack.length = 3

stage_rfl KvWGrow.appendBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 4625 (tplN KvWGrow.s1 0 r) KvWGrow.S1 = some (tplN KvWGrow.s2 1 r, KvWGrow.S2)
stage_rfl KvWGrow.appendLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvWGrow.s2 1 r)).run KvWGrow.S2 = some (tplN KvWGrow.s3 0 r, KvWGrow.S3)
kernel_rfl KvWGrow.live2 : isHalt KvWGrow.s2.ctl = false

/-- The append of class `KvWGrow` under every caller stack. -/
theorem KvWGrow.append (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 4626 (tplN KvWGrow.s1 0 r) KvWGrow.S1 = some (tplN KvWGrow.s3 0 r, KvWGrow.S3) :=
  runS_snoc _ (KvWGrow.appendBody r) KvWGrow.live2 (KvWGrow.appendLast r)

stage_rfl KvWGrow.evalBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 945 (tplN KvWGrow.s4 0 r) KvWGrow.S4 = some (tplN KvWGrow.s5 1 r, KvWGrow.S5)
stage_rfl KvWGrow.evalLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvWGrow.s5 1 r)).run KvWGrow.S5 = some (tplN KvWGrow.s6 0 r, KvWGrow.S6)
kernel_rfl KvWGrow.live5 : isHalt KvWGrow.s5.ctl = false

/-- `evalCacheState` after the append of class `KvWGrow`, under every caller stack. -/
theorem KvWGrow.eval (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 946 (tplN KvWGrow.s4 0 r) KvWGrow.S4 = some (tplN KvWGrow.s6 0 r, KvWGrow.S6) :=
  runS_snoc _ (KvWGrow.evalBody r) KvWGrow.live5 (KvWGrow.evalLast r)

host_chunk KvWGrow 0
host_chunk KvWGrow 3
host_chunk KvWGrow 6
kernel_rfl KvWGrow.frames3 : KvWGrow.s3.stack = KvWGrow.s1.stack
kernel_rfl KvWGrow.frames6 : KvWGrow.s6.stack = KvWGrow.s4.stack

/-- The driver's run of class `KvWGrow`: prefix, the append under the driver's frames, the driver's
steps between the calls, `evalCacheState` under the driver's frames, suffix. -/
theorem KvWGrow.drive : runS Host.Mlx.Ffi.ffi (4446 + 4626 + 12 + 946 + 13) KvWGrow.s0 KvWGrow.S0 = some (KvWGrow.s7, KvWGrow.S7) := by
  have a := KvWGrow.append KvWGrow.s1.stack
  rw [show tplN KvWGrow.s1 0 KvWGrow.s1.stack = KvWGrow.s1 from tplN_self KvWGrow.s1 0,
    show tplN KvWGrow.s3 0 KvWGrow.s1.stack = KvWGrow.s3 by rw [← KvWGrow.frames3]; exact tplN_self KvWGrow.s3 0] at a
  have e := KvWGrow.eval KvWGrow.s4.stack
  rw [show tplN KvWGrow.s4 0 KvWGrow.s4.stack = KvWGrow.s4 from tplN_self KvWGrow.s4 0,
    show tplN KvWGrow.s6 0 KvWGrow.s4.stack = KvWGrow.s6 by rw [← KvWGrow.frames6]; exact tplN_self KvWGrow.s6 0] at e
  exact runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ KvWGrow.c0 a) KvWGrow.c3) e) KvWGrow.c6

/-! ## Class `KvWGrow256`: a whole chunk (`r % 256 = 0`) at a full buffer: grows by `r`, the views are the buffer -/

host_chain_sym KvWGrow256 : Host.Mlx.Ffi.ffi, bootOf DWin.ast, tab3, ρ3 1024 1024 512, 20000, [4446, 4625, 1, 12, 945, 1, 13]

kernel_rfl KvWGrow256.d2 : KvWGrow256.s2.stack.length = 4
kernel_rfl KvWGrow256.d5 : KvWGrow256.s5.stack.length = 3

stage_rfl KvWGrow256.appendBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 4625 (tplN KvWGrow256.s1 0 r) KvWGrow256.S1 = some (tplN KvWGrow256.s2 1 r, KvWGrow256.S2)
stage_rfl KvWGrow256.appendLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvWGrow256.s2 1 r)).run KvWGrow256.S2 = some (tplN KvWGrow256.s3 0 r, KvWGrow256.S3)
kernel_rfl KvWGrow256.live2 : isHalt KvWGrow256.s2.ctl = false

/-- The append of class `KvWGrow256` under every caller stack. -/
theorem KvWGrow256.append (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 4626 (tplN KvWGrow256.s1 0 r) KvWGrow256.S1 = some (tplN KvWGrow256.s3 0 r, KvWGrow256.S3) :=
  runS_snoc _ (KvWGrow256.appendBody r) KvWGrow256.live2 (KvWGrow256.appendLast r)

stage_rfl KvWGrow256.evalBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 945 (tplN KvWGrow256.s4 0 r) KvWGrow256.S4 = some (tplN KvWGrow256.s5 1 r, KvWGrow256.S5)
stage_rfl KvWGrow256.evalLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvWGrow256.s5 1 r)).run KvWGrow256.S5 = some (tplN KvWGrow256.s6 0 r, KvWGrow256.S6)
kernel_rfl KvWGrow256.live5 : isHalt KvWGrow256.s5.ctl = false

/-- `evalCacheState` after the append of class `KvWGrow256`, under every caller stack. -/
theorem KvWGrow256.eval (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 946 (tplN KvWGrow256.s4 0 r) KvWGrow256.S4 = some (tplN KvWGrow256.s6 0 r, KvWGrow256.S6) :=
  runS_snoc _ (KvWGrow256.evalBody r) KvWGrow256.live5 (KvWGrow256.evalLast r)

host_chunk KvWGrow256 0
host_chunk KvWGrow256 3
host_chunk KvWGrow256 6
kernel_rfl KvWGrow256.frames3 : KvWGrow256.s3.stack = KvWGrow256.s1.stack
kernel_rfl KvWGrow256.frames6 : KvWGrow256.s6.stack = KvWGrow256.s4.stack

/-- The driver's run of class `KvWGrow256`: prefix, the append under the driver's frames, the driver's
steps between the calls, `evalCacheState` under the driver's frames, suffix. -/
theorem KvWGrow256.drive : runS Host.Mlx.Ffi.ffi (4446 + 4626 + 12 + 946 + 13) KvWGrow256.s0 KvWGrow256.S0 = some (KvWGrow256.s7, KvWGrow256.S7) := by
  have a := KvWGrow256.append KvWGrow256.s1.stack
  rw [show tplN KvWGrow256.s1 0 KvWGrow256.s1.stack = KvWGrow256.s1 from tplN_self KvWGrow256.s1 0,
    show tplN KvWGrow256.s3 0 KvWGrow256.s1.stack = KvWGrow256.s3 by rw [← KvWGrow256.frames3]; exact tplN_self KvWGrow256.s3 0] at a
  have e := KvWGrow256.eval KvWGrow256.s4.stack
  rw [show tplN KvWGrow256.s4 0 KvWGrow256.s4.stack = KvWGrow256.s4 from tplN_self KvWGrow256.s4 0,
    show tplN KvWGrow256.s6 0 KvWGrow256.s4.stack = KvWGrow256.s6 by rw [← KvWGrow256.frames6]; exact tplN_self KvWGrow256.s6 0] at e
  exact runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ KvWGrow256.c0 a) KvWGrow256.c3) e) KvWGrow256.c6

/-! ## Class `KvWFirst`: the first window (`r % 256 ≠ 0`) into a null buffer -/

host_chain_sym KvWFirst : Host.Mlx.Ffi.ffi, bootOf DWinFirst.ast, tab3, ρ3 0 0 300, 20000, [4009, 3452, 1, 12, 945, 1, 13]

kernel_rfl KvWFirst.d2 : KvWFirst.s2.stack.length = 4
kernel_rfl KvWFirst.d5 : KvWFirst.s5.stack.length = 3

stage_rfl KvWFirst.appendBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 3452 (tplN KvWFirst.s1 0 r) KvWFirst.S1 = some (tplN KvWFirst.s2 1 r, KvWFirst.S2)
stage_rfl KvWFirst.appendLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvWFirst.s2 1 r)).run KvWFirst.S2 = some (tplN KvWFirst.s3 0 r, KvWFirst.S3)
kernel_rfl KvWFirst.live2 : isHalt KvWFirst.s2.ctl = false

/-- The append of class `KvWFirst` under every caller stack. -/
theorem KvWFirst.append (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 3453 (tplN KvWFirst.s1 0 r) KvWFirst.S1 = some (tplN KvWFirst.s3 0 r, KvWFirst.S3) :=
  runS_snoc _ (KvWFirst.appendBody r) KvWFirst.live2 (KvWFirst.appendLast r)

stage_rfl KvWFirst.evalBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 945 (tplN KvWFirst.s4 0 r) KvWFirst.S4 = some (tplN KvWFirst.s5 1 r, KvWFirst.S5)
stage_rfl KvWFirst.evalLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvWFirst.s5 1 r)).run KvWFirst.S5 = some (tplN KvWFirst.s6 0 r, KvWFirst.S6)
kernel_rfl KvWFirst.live5 : isHalt KvWFirst.s5.ctl = false

/-- `evalCacheState` after the append of class `KvWFirst`, under every caller stack. -/
theorem KvWFirst.eval (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 946 (tplN KvWFirst.s4 0 r) KvWFirst.S4 = some (tplN KvWFirst.s6 0 r, KvWFirst.S6) :=
  runS_snoc _ (KvWFirst.evalBody r) KvWFirst.live5 (KvWFirst.evalLast r)

host_chunk KvWFirst 0
host_chunk KvWFirst 3
host_chunk KvWFirst 6
kernel_rfl KvWFirst.frames3 : KvWFirst.s3.stack = KvWFirst.s1.stack
kernel_rfl KvWFirst.frames6 : KvWFirst.s6.stack = KvWFirst.s4.stack

/-- The driver's run of class `KvWFirst`: prefix, the append under the driver's frames, the driver's
steps between the calls, `evalCacheState` under the driver's frames, suffix. -/
theorem KvWFirst.drive : runS Host.Mlx.Ffi.ffi (4009 + 3453 + 12 + 946 + 13) KvWFirst.s0 KvWFirst.S0 = some (KvWFirst.s7, KvWFirst.S7) := by
  have a := KvWFirst.append KvWFirst.s1.stack
  rw [show tplN KvWFirst.s1 0 KvWFirst.s1.stack = KvWFirst.s1 from tplN_self KvWFirst.s1 0,
    show tplN KvWFirst.s3 0 KvWFirst.s1.stack = KvWFirst.s3 by rw [← KvWFirst.frames3]; exact tplN_self KvWFirst.s3 0] at a
  have e := KvWFirst.eval KvWFirst.s4.stack
  rw [show tplN KvWFirst.s4 0 KvWFirst.s4.stack = KvWFirst.s4 from tplN_self KvWFirst.s4 0,
    show tplN KvWFirst.s6 0 KvWFirst.s4.stack = KvWFirst.s6 by rw [← KvWFirst.frames6]; exact tplN_self KvWFirst.s6 0] at e
  exact runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ KvWFirst.c0 a) KvWFirst.c3) e) KvWFirst.c6

/-! ## Class `KvWFirst256`: the first whole chunk (`r % 256 = 0`) into a null buffer -/

host_chain_sym KvWFirst256 : Host.Mlx.Ffi.ffi, bootOf DWinFirst.ast, tab3, ρ3 0 0 512, 20000, [4009, 3452, 1, 12, 945, 1, 13]

kernel_rfl KvWFirst256.d2 : KvWFirst256.s2.stack.length = 4
kernel_rfl KvWFirst256.d5 : KvWFirst256.s5.stack.length = 3

stage_rfl KvWFirst256.appendBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 3452 (tplN KvWFirst256.s1 0 r) KvWFirst256.S1 = some (tplN KvWFirst256.s2 1 r, KvWFirst256.S2)
stage_rfl KvWFirst256.appendLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvWFirst256.s2 1 r)).run KvWFirst256.S2 = some (tplN KvWFirst256.s3 0 r, KvWFirst256.S3)
kernel_rfl KvWFirst256.live2 : isHalt KvWFirst256.s2.ctl = false

/-- The append of class `KvWFirst256` under every caller stack. -/
theorem KvWFirst256.append (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 3453 (tplN KvWFirst256.s1 0 r) KvWFirst256.S1 = some (tplN KvWFirst256.s3 0 r, KvWFirst256.S3) :=
  runS_snoc _ (KvWFirst256.appendBody r) KvWFirst256.live2 (KvWFirst256.appendLast r)

stage_rfl KvWFirst256.evalBody : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 945 (tplN KvWFirst256.s4 0 r) KvWFirst256.S4 = some (tplN KvWFirst256.s5 1 r, KvWFirst256.S5)
stage_rfl KvWFirst256.evalLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN KvWFirst256.s5 1 r)).run KvWFirst256.S5 = some (tplN KvWFirst256.s6 0 r, KvWFirst256.S6)
kernel_rfl KvWFirst256.live5 : isHalt KvWFirst256.s5.ctl = false

/-- `evalCacheState` after the append of class `KvWFirst256`, under every caller stack. -/
theorem KvWFirst256.eval (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 946 (tplN KvWFirst256.s4 0 r) KvWFirst256.S4 = some (tplN KvWFirst256.s6 0 r, KvWFirst256.S6) :=
  runS_snoc _ (KvWFirst256.evalBody r) KvWFirst256.live5 (KvWFirst256.evalLast r)

host_chunk KvWFirst256 0
host_chunk KvWFirst256 3
host_chunk KvWFirst256 6
kernel_rfl KvWFirst256.frames3 : KvWFirst256.s3.stack = KvWFirst256.s1.stack
kernel_rfl KvWFirst256.frames6 : KvWFirst256.s6.stack = KvWFirst256.s4.stack

/-- The driver's run of class `KvWFirst256`: prefix, the append under the driver's frames, the driver's
steps between the calls, `evalCacheState` under the driver's frames, suffix. -/
theorem KvWFirst256.drive : runS Host.Mlx.Ffi.ffi (4009 + 3453 + 12 + 946 + 13) KvWFirst256.s0 KvWFirst256.S0 = some (KvWFirst256.s7, KvWFirst256.S7) := by
  have a := KvWFirst256.append KvWFirst256.s1.stack
  rw [show tplN KvWFirst256.s1 0 KvWFirst256.s1.stack = KvWFirst256.s1 from tplN_self KvWFirst256.s1 0,
    show tplN KvWFirst256.s3 0 KvWFirst256.s1.stack = KvWFirst256.s3 by rw [← KvWFirst256.frames3]; exact tplN_self KvWFirst256.s3 0] at a
  have e := KvWFirst256.eval KvWFirst256.s4.stack
  rw [show tplN KvWFirst256.s4 0 KvWFirst256.s4.stack = KvWFirst256.s4 from tplN_self KvWFirst256.s4 0,
    show tplN KvWFirst256.s6 0 KvWFirst256.s4.stack = KvWFirst256.s6 by rw [← KvWFirst256.frames6]; exact tplN_self KvWFirst256.s6 0] at e
  exact runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ KvWFirst256.c0 a) KvWFirst256.c3) e) KvWFirst256.c6

end Host.Ts.Sim.Stage.Cache
