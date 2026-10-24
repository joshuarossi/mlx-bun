import host.sim.stage.Under
import host.ts.ast.inference.generation.bindings.PrefillPolicy
import host.ts.ast.inference.models.Capabilities
import host.ts.ast.inference.state.KvScheme
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Ts.Sim.Stage.ChunkSize
open Host.Ts Host.Ts.Sim.Stage

/-! # The `chunkSize` stage template

The prefill policy's `chunkSize(promptTokens)` (the closure `resolveMlxPrefillPolicy` returns,
generation/bindings/prefill-policy.ts:31-35, with `sdpaFallbackBytes`, state/kv-scheme.ts:118-134;
called at generation/autoregressive.ts:137) at a symbolic prompt length `L` (table entry `var 0`).
The driver builds the policy as the binding does (bindings/autoregressive.ts:72) for a graph that
declares a bounded prefill workspace, over the route's attention geometry: 24 heads, 64 layers,
every fourth layer full attention, the rest linear attention, global head dimension 256, no
sliding window; `MLX_BUN_RD_PREFILL_CHUNK` unset. The stage is the call from the driver
(`s1`) to its return (`s3`), checked for every FFI, native state and caller stack, one template
per number of halvings (`K8`: `L ≤ 8`, the fused-SDPA bound; `K2048` … `K64`). -/

namespace Drive
def source : String := "import { resolveMlxPrefillPolicy } from \"./bindings/prefill-policy\";
import { L } from \"sym\";
const layerTypes = [];
for (let i = 0; i < 64; i++) layerTypes.push(i % 4 === 3 ? \"full_attention\" : \"linear_attention\");
const config = { text: { numAttentionHeads: 24, numHiddenLayers: 64, layerTypes, slidingWindow: 0, headDim: 256, globalHeadDim: 256 } };
const graph = { config, graphCapabilities: { prefill: { boundedWorkspace: true } } };
const runtime = { value: (k) => undefined, number: (k, d) => d };
const policy = resolveMlxPrefillPolicy(graph, runtime);
const C = policy.chunkSize(L);
export const out = C;"
source_parse source
source_ast
end Drive

/-- The symbolic prompt length: table entry `0`. -/
def symMod {S : Type} : HMod S := ⟨chars!"sym", pure [(chars!"L", .num (.ref 0))]⟩

def mods : List UMod :=
  [⟨chars!"packages/inference/src/generation/bindings/prefill-policy.ts", Sources.Inference.Generation.Bindings.PrefillPolicy.ast⟩,
   ⟨chars!"packages/inference/src/models/capabilities.ts", Sources.Inference.Models.Capabilities.ast⟩,
   ⟨chars!"packages/inference/src/state/kv-scheme.ts", Sources.Inference.State.KvScheme.ast⟩,
   ⟨chars!"packages/inference/src/generation/__drive.ts", Drive.ast⟩]

def bootS : Option (St nullFfi.S) := boot () mods [symMod] chars!"packages/inference/src/generation/__drive.ts"

/-- A discovery valuation. -/
def ρL (L : Nat) : Nat → F64 := fun _ => F64.ofNat L

host_chain_sym K8 : nullFfi, bootS, [.var 0], ρL 5, 50000, [2298, 100, 1, 12]

kernel_rfl K8.depth : K8.s2.stack.length = 4

stage_rfl K8.b1 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 100 (tpl K8.s1 0 x r) K8.S1 = some (tpl K8.s2 1 x r, K8.S2)

stage_rfl K8.last : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  interpS (step F (tpl K8.s2 1 x r)).run K8.S2 = some (tpl K8.s3 0 x r, K8.S3)

kernel_rfl K8.live : isHalt K8.s2.ctl = false

/-- Class `K8`: the call returns after 101 steps, for every FFI, native state and caller stack. -/
theorem K8.stage (F : Ffi) (x : F.S) (r : List Frame) :
    runS F 101 (tpl K8.s1 0 x r) K8.S1 = some (tpl K8.s3 0 x r, K8.S3) :=
  runS_snoc F (K8.b1 F x r) K8.live (K8.last F x r)

host_chain_sym K2048 : nullFfi, bootS, [.var 0], ρL 4198, 50000, [2298, 5000, 714, 1, 12]

kernel_rfl K2048.depth : K2048.s3.stack.length = 4

stage_rfl K2048.b1 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K2048.s1 0 x r) K2048.S1 = some (tpl K2048.s2 (K2048.s2.stack.length - 3) x r, K2048.S2)

stage_rfl K2048.b2 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 714 (tpl K2048.s2 (K2048.s2.stack.length - 3) x r) K2048.S2 = some (tpl K2048.s3 1 x r, K2048.S3)

stage_rfl K2048.last : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  interpS (step F (tpl K2048.s3 1 x r)).run K2048.S3 = some (tpl K2048.s4 0 x r, K2048.S4)

kernel_rfl K2048.live : isHalt K2048.s3.ctl = false

/-- Class `K2048`: the call returns after 5715 steps, for every FFI, native state and caller stack. -/
theorem K2048.stage (F : Ffi) (x : F.S) (r : List Frame) :
    runS F 5715 (tpl K2048.s1 0 x r) K2048.S1 = some (tpl K2048.s4 0 x r, K2048.S4) :=
  runS_snoc F (runS_trans F (K2048.b1 F x r) (K2048.b2 F x r)) K2048.live (K2048.last F x r)

host_chain_sym K1024 : nullFfi, bootS, [.var 0], ρL 15000, 50000, [2298, 5000, 5000, 1417, 1, 12]

kernel_rfl K1024.depth : K1024.s4.stack.length = 4

stage_rfl K1024.b1 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K1024.s1 0 x r) K1024.S1 = some (tpl K1024.s2 (K1024.s2.stack.length - 3) x r, K1024.S2)

stage_rfl K1024.b2 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K1024.s2 (K1024.s2.stack.length - 3) x r) K1024.S2 = some (tpl K1024.s3 (K1024.s3.stack.length - 3) x r, K1024.S3)

stage_rfl K1024.b3 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 1417 (tpl K1024.s3 (K1024.s3.stack.length - 3) x r) K1024.S3 = some (tpl K1024.s4 1 x r, K1024.S4)

stage_rfl K1024.last : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  interpS (step F (tpl K1024.s4 1 x r)).run K1024.S4 = some (tpl K1024.s5 0 x r, K1024.S5)

kernel_rfl K1024.live : isHalt K1024.s4.ctl = false

/-- Class `K1024`: the call returns after 11418 steps, for every FFI, native state and caller stack. -/
theorem K1024.stage (F : Ffi) (x : F.S) (r : List Frame) :
    runS F 11418 (tpl K1024.s1 0 x r) K1024.S1 = some (tpl K1024.s5 0 x r, K1024.S5) :=
  runS_snoc F (runS_trans F (runS_trans F (K1024.b1 F x r) (K1024.b2 F x r)) (K1024.b3 F x r)) K1024.live (K1024.last F x r)

host_chain_sym K512 : nullFfi, bootS, [.var 0], ρL 30000, 50000, [2298, 5000, 5000, 5000, 2120, 1, 12]

kernel_rfl K512.depth : K512.s5.stack.length = 4

stage_rfl K512.b1 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K512.s1 0 x r) K512.S1 = some (tpl K512.s2 (K512.s2.stack.length - 3) x r, K512.S2)

stage_rfl K512.b2 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K512.s2 (K512.s2.stack.length - 3) x r) K512.S2 = some (tpl K512.s3 (K512.s3.stack.length - 3) x r, K512.S3)

stage_rfl K512.b3 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K512.s3 (K512.s3.stack.length - 3) x r) K512.S3 = some (tpl K512.s4 (K512.s4.stack.length - 3) x r, K512.S4)

stage_rfl K512.b4 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 2120 (tpl K512.s4 (K512.s4.stack.length - 3) x r) K512.S4 = some (tpl K512.s5 1 x r, K512.S5)

stage_rfl K512.last : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  interpS (step F (tpl K512.s5 1 x r)).run K512.S5 = some (tpl K512.s6 0 x r, K512.S6)

kernel_rfl K512.live : isHalt K512.s5.ctl = false

/-- Class `K512`: the call returns after 17121 steps, for every FFI, native state and caller stack. -/
theorem K512.stage (F : Ffi) (x : F.S) (r : List Frame) :
    runS F 17121 (tpl K512.s1 0 x r) K512.S1 = some (tpl K512.s6 0 x r, K512.S6) :=
  runS_snoc F (runS_trans F (runS_trans F (runS_trans F (K512.b1 F x r) (K512.b2 F x r)) (K512.b3 F x r)) (K512.b4 F x r)) K512.live (K512.last F x r)

host_chain_sym K256 : nullFfi, bootS, [.var 0], ρL 60000, 50000, [2298, 5000, 5000, 5000, 5000, 2823, 1, 12]

kernel_rfl K256.depth : K256.s6.stack.length = 4

stage_rfl K256.b1 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K256.s1 0 x r) K256.S1 = some (tpl K256.s2 (K256.s2.stack.length - 3) x r, K256.S2)

stage_rfl K256.b2 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K256.s2 (K256.s2.stack.length - 3) x r) K256.S2 = some (tpl K256.s3 (K256.s3.stack.length - 3) x r, K256.S3)

stage_rfl K256.b3 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K256.s3 (K256.s3.stack.length - 3) x r) K256.S3 = some (tpl K256.s4 (K256.s4.stack.length - 3) x r, K256.S4)

stage_rfl K256.b4 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K256.s4 (K256.s4.stack.length - 3) x r) K256.S4 = some (tpl K256.s5 (K256.s5.stack.length - 3) x r, K256.S5)

stage_rfl K256.b5 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 2823 (tpl K256.s5 (K256.s5.stack.length - 3) x r) K256.S5 = some (tpl K256.s6 1 x r, K256.S6)

stage_rfl K256.last : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  interpS (step F (tpl K256.s6 1 x r)).run K256.S6 = some (tpl K256.s7 0 x r, K256.S7)

kernel_rfl K256.live : isHalt K256.s6.ctl = false

/-- Class `K256`: the call returns after 22824 steps, for every FFI, native state and caller stack. -/
theorem K256.stage (F : Ffi) (x : F.S) (r : List Frame) :
    runS F 22824 (tpl K256.s1 0 x r) K256.S1 = some (tpl K256.s7 0 x r, K256.S7) :=
  runS_snoc F (runS_trans F (runS_trans F (runS_trans F (runS_trans F (K256.b1 F x r) (K256.b2 F x r)) (K256.b3 F x r)) (K256.b4 F x r)) (K256.b5 F x r)) K256.live (K256.last F x r)

host_chain_sym K128 : nullFfi, bootS, [.var 0], ρL 120000, 50000, [2298, 5000, 5000, 5000, 5000, 5000, 3526, 1, 12]

kernel_rfl K128.depth : K128.s7.stack.length = 4

stage_rfl K128.b1 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K128.s1 0 x r) K128.S1 = some (tpl K128.s2 (K128.s2.stack.length - 3) x r, K128.S2)

stage_rfl K128.b2 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K128.s2 (K128.s2.stack.length - 3) x r) K128.S2 = some (tpl K128.s3 (K128.s3.stack.length - 3) x r, K128.S3)

stage_rfl K128.b3 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K128.s3 (K128.s3.stack.length - 3) x r) K128.S3 = some (tpl K128.s4 (K128.s4.stack.length - 3) x r, K128.S4)

stage_rfl K128.b4 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K128.s4 (K128.s4.stack.length - 3) x r) K128.S4 = some (tpl K128.s5 (K128.s5.stack.length - 3) x r, K128.S5)

stage_rfl K128.b5 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K128.s5 (K128.s5.stack.length - 3) x r) K128.S5 = some (tpl K128.s6 (K128.s6.stack.length - 3) x r, K128.S6)

stage_rfl K128.b6 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 3526 (tpl K128.s6 (K128.s6.stack.length - 3) x r) K128.S6 = some (tpl K128.s7 1 x r, K128.S7)

stage_rfl K128.last : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  interpS (step F (tpl K128.s7 1 x r)).run K128.S7 = some (tpl K128.s8 0 x r, K128.S8)

kernel_rfl K128.live : isHalt K128.s7.ctl = false

/-- Class `K128`: the call returns after 28527 steps, for every FFI, native state and caller stack. -/
theorem K128.stage (F : Ffi) (x : F.S) (r : List Frame) :
    runS F 28527 (tpl K128.s1 0 x r) K128.S1 = some (tpl K128.s8 0 x r, K128.S8) :=
  runS_snoc F (runS_trans F (runS_trans F (runS_trans F (runS_trans F (runS_trans F (K128.b1 F x r) (K128.b2 F x r)) (K128.b3 F x r)) (K128.b4 F x r)) (K128.b5 F x r)) (K128.b6 F x r)) K128.live (K128.last F x r)

host_chain_sym K64 : nullFfi, bootS, [.var 0], ρL 250000, 50000, [2298, 5000, 5000, 5000, 5000, 5000, 5000, 4229, 1, 12]

kernel_rfl K64.depth : K64.s8.stack.length = 4

stage_rfl K64.b1 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K64.s1 0 x r) K64.S1 = some (tpl K64.s2 (K64.s2.stack.length - 3) x r, K64.S2)

stage_rfl K64.b2 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K64.s2 (K64.s2.stack.length - 3) x r) K64.S2 = some (tpl K64.s3 (K64.s3.stack.length - 3) x r, K64.S3)

stage_rfl K64.b3 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K64.s3 (K64.s3.stack.length - 3) x r) K64.S3 = some (tpl K64.s4 (K64.s4.stack.length - 3) x r, K64.S4)

stage_rfl K64.b4 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K64.s4 (K64.s4.stack.length - 3) x r) K64.S4 = some (tpl K64.s5 (K64.s5.stack.length - 3) x r, K64.S5)

stage_rfl K64.b5 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K64.s5 (K64.s5.stack.length - 3) x r) K64.S5 = some (tpl K64.s6 (K64.s6.stack.length - 3) x r, K64.S6)

stage_rfl K64.b6 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 5000 (tpl K64.s6 (K64.s6.stack.length - 3) x r) K64.S6 = some (tpl K64.s7 (K64.s7.stack.length - 3) x r, K64.S7)

stage_rfl K64.b7 : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 4229 (tpl K64.s7 (K64.s7.stack.length - 3) x r) K64.S7 = some (tpl K64.s8 1 x r, K64.S8)

stage_rfl K64.last : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  interpS (step F (tpl K64.s8 1 x r)).run K64.S8 = some (tpl K64.s9 0 x r, K64.S9)

kernel_rfl K64.live : isHalt K64.s8.ctl = false

/-- Class `K64`: the call returns after 34230 steps, for every FFI, native state and caller stack. -/
theorem K64.stage (F : Ffi) (x : F.S) (r : List Frame) :
    runS F 34230 (tpl K64.s1 0 x r) K64.S1 = some (tpl K64.s9 0 x r, K64.S9) :=
  runS_snoc F (runS_trans F (runS_trans F (runS_trans F (runS_trans F (runS_trans F (runS_trans F (K64.b1 F x r) (K64.b2 F x r)) (K64.b3 F x r)) (K64.b4 F x r)) (K64.b5 F x r)) (K64.b6 F x r)) (K64.b7 F x r)) K64.live (K64.last F x r)

host_chunk K8 0
host_chunk K8 3
kernel_rfl K8.frames : K8.s3.stack = K8.s1.stack

/-- The driver's run (class `K8`): its prefix to the call, the stage under the driver's own frames
and native state, its suffix to the halt. -/
theorem K8.drive : runS nullFfi (2298 + 101 + 12) K8.s0 K8.S0 = some (K8.s4, K8.S4) := by
  have h1 : tpl (S := nullFfi.S) K8.s1 0 () K8.s1.stack = K8.s1 := tpl_self _ 0 (List.take_append_drop 0 _)
  have h3 : tpl (S := nullFfi.S) K8.s3 0 () K8.s1.stack = K8.s3 := by
    rw [← K8.frames]; exact tpl_self _ 0 (List.take_append_drop 0 _)
  have hs := K8.stage nullFfi () K8.s1.stack
  rw [h1, h3] at hs
  exact runS_trans _ (runS_trans _ K8.c0 hs) K8.c3

end Host.Ts.Sim.Stage.ChunkSize
