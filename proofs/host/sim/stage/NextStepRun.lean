import host.sim.stage.Under
import host.ts.ast.inference.contracts.portable.Prefill
set_option Elab.async false
namespace Host.Ts.Sim.Stage.NextStep
open Host.Ts Host.Ts.Sim.Stage

/-! # The `nextPrefillStep` stage template

`nextPrefillStep` (packages/inference/src/contracts/portable/prefill.ts:41-63) called as the
prefill loop calls it (generation/autoregressive.ts:498-499: `length`, `position`, `chunkSize`
numbers, `tailSplit: true`, `snapshotAt` undefined), with `L`, `position` and `C` the number
table's entries `var 0`, `var 1`, `var 2`. A two-line driver module builds the call; its run
from boot is a `host_chain_sym` chain whose state `s1` is the call, `s2` the state before the
return to the driver and `s3` the return. The stage template is `tpl s1 0`, `tpl s2 1`,
`tpl s3 0` (`host.sim.stage.Under`): the driver's frames and the native state become the
parameters `r` and `x`, and each class's checks (`body`, `last`) hold for every FFI, native
state and caller stack. The driver's own run is the stage at its own frames (`drive`).

Classes (the oracle's branch answers; `C ≥ 2`, `tailSplit` on, no snapshot):
* `DCby`: a whole chunk with more than one row after it (`batchYield` true);
* `DCeq`: a whole chunk followed by the final row only (`batchYield` false);
* `DTtail`: the tail, two or more rows (phase `tail`);
* `DTdec`: the tail of one row (phase `decode`);
* `FIN`: the final row (phase `decode`). -/

namespace Drive
def source : String := "import { nextPrefillStep } from \"../contracts/portable/prefill\";
import { L, pos, C } from \"sym\";
const step = nextPrefillStep({ length: L, position: pos, chunkSize: C, tailSplit: true, snapshotAt: undefined });
export const out = step;"
source_parse source
source_ast
end Drive

/-- The symbolic inputs: `L`, `position`, `C` as table entries `0`, `1`, `2`. -/
def symMod {S : Type} : HMod S :=
  ⟨chars!"sym", pure [(chars!"L", .num (.ref 0)), (chars!"pos", .num (.ref 1)), (chars!"C", .num (.ref 2))]⟩

def mods : List UMod :=
  [⟨chars!"packages/inference/src/contracts/portable/prefill.ts", Sources.Inference.Contracts.Portable.Prefill.ast⟩,
   ⟨chars!"packages/inference/src/generation/__drive.ts", Drive.ast⟩]

def bootS : Option (St nullFfi.S) := boot () mods [symMod] chars!"packages/inference/src/generation/__drive.ts"

def tab : List SymE := [.var 0, .var 1, .var 2]

/-- A discovery valuation (generic within its class). -/
def ρd (L p C : Nat) : Nat → F64 := fun i => if i = 0 then F64.ofNat L else if i = 1 then F64.ofNat p else F64.ofNat C

host_chain_sym DCby : nullFfi, bootS, tab, ρd 4198 101 2048, 1000, [24, 225, 1, 12]

stage_rfl DCby.body : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 225 (tpl DCby.s1 0 x r) DCby.S1 = some (tpl DCby.s2 1 x r, DCby.S2)

stage_rfl DCby.last : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  interpS (step F (tpl DCby.s2 1 x r)).run DCby.S2 = some (tpl DCby.s3 0 x r, DCby.S3)

kernel_rfl DCby.live : isHalt DCby.s2.ctl = false

/-- Class `DCby`: the call returns after 226 steps, for every FFI, native state and caller stack. -/
theorem DCby.stage (F : Ffi) (x : F.S) (r : List Frame) :
    runS F 226 (tpl DCby.s1 0 x r) DCby.S1 = some (tpl DCby.s3 0 x r, DCby.S3) :=
  runS_snoc F (DCby.body F x r) DCby.live (DCby.last F x r)

host_chunk DCby 0
host_chunk DCby 3
kernel_rfl DCby.frames : DCby.s3.stack = DCby.s1.stack

/-- The driver's run of class `DCby`: its prefix to the call, the stage under the driver's own
frames and native state, its suffix to the halt. -/
theorem DCby.drive : runS nullFfi (24 + 226 + 12) DCby.s0 DCby.S0 = some (DCby.s4, DCby.S4) := by
  have h1 : tpl (S := nullFfi.S) DCby.s1 0 () DCby.s1.stack = DCby.s1 := tpl_self _ 0 (List.take_append_drop 0 _)
  have h3 : tpl (S := nullFfi.S) DCby.s3 0 () DCby.s1.stack = DCby.s3 := by
    rw [← DCby.frames]; exact tpl_self _ 0 (List.take_append_drop 0 _)
  have hs := DCby.stage nullFfi () DCby.s1.stack
  rw [h1, h3] at hs
  exact runS_trans _ (runS_trans _ DCby.c0 hs) DCby.c3

host_chain_sym DCeq : nullFfi, bootS, tab, ρd 4198 2149 2048, 1000, [24, 225, 1, 12]

stage_rfl DCeq.body : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 225 (tpl DCeq.s1 0 x r) DCeq.S1 = some (tpl DCeq.s2 1 x r, DCeq.S2)

stage_rfl DCeq.last : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  interpS (step F (tpl DCeq.s2 1 x r)).run DCeq.S2 = some (tpl DCeq.s3 0 x r, DCeq.S3)

kernel_rfl DCeq.live : isHalt DCeq.s2.ctl = false

/-- Class `DCeq`: the call returns after 226 steps, for every FFI, native state and caller stack. -/
theorem DCeq.stage (F : Ffi) (x : F.S) (r : List Frame) :
    runS F 226 (tpl DCeq.s1 0 x r) DCeq.S1 = some (tpl DCeq.s3 0 x r, DCeq.S3) :=
  runS_snoc F (DCeq.body F x r) DCeq.live (DCeq.last F x r)

host_chunk DCeq 0
host_chunk DCeq 3
kernel_rfl DCeq.frames : DCeq.s3.stack = DCeq.s1.stack

/-- The driver's run of class `DCeq`: its prefix to the call, the stage under the driver's own
frames and native state, its suffix to the halt. -/
theorem DCeq.drive : runS nullFfi (24 + 226 + 12) DCeq.s0 DCeq.S0 = some (DCeq.s4, DCeq.S4) := by
  have h1 : tpl (S := nullFfi.S) DCeq.s1 0 () DCeq.s1.stack = DCeq.s1 := tpl_self _ 0 (List.take_append_drop 0 _)
  have h3 : tpl (S := nullFfi.S) DCeq.s3 0 () DCeq.s1.stack = DCeq.s3 := by
    rw [← DCeq.frames]; exact tpl_self _ 0 (List.take_append_drop 0 _)
  have hs := DCeq.stage nullFfi () DCeq.s1.stack
  rw [h1, h3] at hs
  exact runS_trans _ (runS_trans _ DCeq.c0 hs) DCeq.c3

host_chain_sym DTtail : nullFfi, bootS, tab, ρd 4198 3000 2048, 1000, [24, 229, 1, 12]

stage_rfl DTtail.body : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 229 (tpl DTtail.s1 0 x r) DTtail.S1 = some (tpl DTtail.s2 1 x r, DTtail.S2)

stage_rfl DTtail.last : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  interpS (step F (tpl DTtail.s2 1 x r)).run DTtail.S2 = some (tpl DTtail.s3 0 x r, DTtail.S3)

kernel_rfl DTtail.live : isHalt DTtail.s2.ctl = false

/-- Class `DTtail`: the call returns after 230 steps, for every FFI, native state and caller stack. -/
theorem DTtail.stage (F : Ffi) (x : F.S) (r : List Frame) :
    runS F 230 (tpl DTtail.s1 0 x r) DTtail.S1 = some (tpl DTtail.s3 0 x r, DTtail.S3) :=
  runS_snoc F (DTtail.body F x r) DTtail.live (DTtail.last F x r)

host_chunk DTtail 0
host_chunk DTtail 3
kernel_rfl DTtail.frames : DTtail.s3.stack = DTtail.s1.stack

/-- The driver's run of class `DTtail`: its prefix to the call, the stage under the driver's own
frames and native state, its suffix to the halt. -/
theorem DTtail.drive : runS nullFfi (24 + 230 + 12) DTtail.s0 DTtail.S0 = some (DTtail.s4, DTtail.S4) := by
  have h1 : tpl (S := nullFfi.S) DTtail.s1 0 () DTtail.s1.stack = DTtail.s1 := tpl_self _ 0 (List.take_append_drop 0 _)
  have h3 : tpl (S := nullFfi.S) DTtail.s3 0 () DTtail.s1.stack = DTtail.s3 := by
    rw [← DTtail.frames]; exact tpl_self _ 0 (List.take_append_drop 0 _)
  have hs := DTtail.stage nullFfi () DTtail.s1.stack
  rw [h1, h3] at hs
  exact runS_trans _ (runS_trans _ DTtail.c0 hs) DTtail.c3

host_chain_sym DTdec : nullFfi, bootS, tab, ρd 4198 4196 2048, 1000, [24, 226, 1, 12]

stage_rfl DTdec.body : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 226 (tpl DTdec.s1 0 x r) DTdec.S1 = some (tpl DTdec.s2 1 x r, DTdec.S2)

stage_rfl DTdec.last : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  interpS (step F (tpl DTdec.s2 1 x r)).run DTdec.S2 = some (tpl DTdec.s3 0 x r, DTdec.S3)

kernel_rfl DTdec.live : isHalt DTdec.s2.ctl = false

/-- Class `DTdec`: the call returns after 227 steps, for every FFI, native state and caller stack. -/
theorem DTdec.stage (F : Ffi) (x : F.S) (r : List Frame) :
    runS F 227 (tpl DTdec.s1 0 x r) DTdec.S1 = some (tpl DTdec.s3 0 x r, DTdec.S3) :=
  runS_snoc F (DTdec.body F x r) DTdec.live (DTdec.last F x r)

host_chunk DTdec 0
host_chunk DTdec 3
kernel_rfl DTdec.frames : DTdec.s3.stack = DTdec.s1.stack

/-- The driver's run of class `DTdec`: its prefix to the call, the stage under the driver's own
frames and native state, its suffix to the halt. -/
theorem DTdec.drive : runS nullFfi (24 + 227 + 12) DTdec.s0 DTdec.S0 = some (DTdec.s4, DTdec.S4) := by
  have h1 : tpl (S := nullFfi.S) DTdec.s1 0 () DTdec.s1.stack = DTdec.s1 := tpl_self _ 0 (List.take_append_drop 0 _)
  have h3 : tpl (S := nullFfi.S) DTdec.s3 0 () DTdec.s1.stack = DTdec.s3 := by
    rw [← DTdec.frames]; exact tpl_self _ 0 (List.take_append_drop 0 _)
  have hs := DTdec.stage nullFfi () DTdec.s1.stack
  rw [h1, h3] at hs
  exact runS_trans _ (runS_trans _ DTdec.c0 hs) DTdec.c3

host_chain_sym FIN : nullFfi, bootS, tab, ρd 4198 4197 2048, 1000, [24, 179, 1, 12]

stage_rfl FIN.body : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  runS F 179 (tpl FIN.s1 0 x r) FIN.S1 = some (tpl FIN.s2 1 x r, FIN.S2)

stage_rfl FIN.last : ∀ (F : Ffi) (x : F.S) (r : List Frame),
  interpS (step F (tpl FIN.s2 1 x r)).run FIN.S2 = some (tpl FIN.s3 0 x r, FIN.S3)

kernel_rfl FIN.live : isHalt FIN.s2.ctl = false

/-- Class `FIN`: the call returns after 180 steps, for every FFI, native state and caller stack. -/
theorem FIN.stage (F : Ffi) (x : F.S) (r : List Frame) :
    runS F 180 (tpl FIN.s1 0 x r) FIN.S1 = some (tpl FIN.s3 0 x r, FIN.S3) :=
  runS_snoc F (FIN.body F x r) FIN.live (FIN.last F x r)

host_chunk FIN 0
host_chunk FIN 3
kernel_rfl FIN.frames : FIN.s3.stack = FIN.s1.stack

/-- The driver's run of class `FIN`: its prefix to the call, the stage under the driver's own
frames and native state, its suffix to the halt. -/
theorem FIN.drive : runS nullFfi (24 + 180 + 12) FIN.s0 FIN.S0 = some (FIN.s4, FIN.S4) := by
  have h1 : tpl (S := nullFfi.S) FIN.s1 0 () FIN.s1.stack = FIN.s1 := tpl_self _ 0 (List.take_append_drop 0 _)
  have h3 : tpl (S := nullFfi.S) FIN.s3 0 () FIN.s1.stack = FIN.s3 := by
    rw [← FIN.frames]; exact tpl_self _ 0 (List.take_append_drop 0 _)
  have hs := FIN.stage nullFfi () FIN.s1.stack
  rw [h1, h3] at hs
  exact runS_trans _ (runS_trans _ FIN.c0 hs) FIN.c3

end Host.Ts.Sim.Stage.NextStep
