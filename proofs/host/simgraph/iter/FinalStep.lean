import host.simgraph.iter.FinalC
import host.simgraph.iter.BaseTpl
import host.sim.template.final.Case
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Load.Run.Tpl
open Inference.Models.Qwen

/-! The FINAL final case's graph step: `fgstep_core` and `final_cache` (via `fgstepC_of`) with the halted end's readback slots
(time `T - 1` at `20157`, time `T` at `22538`), tokens and table entries. -/

kernel_rfl FINAL.sF_read : (FINAL.s3.ffi : LSt).mlx.items.get 20157 = some (.ref 79)
kernel_rfl FINAL.sF_fed : (FINAL.s3.ffi : LSt).mlx.items.get 22538 = some (.ref Base.S0.tab.length)
kernel_rfl FINAL.sF_pread : ((FINAL.s3.ffi : LSt).mlx.nodes.get 20157).isSome = true
kernel_rfl FINAL.sF_pfed : ((FINAL.s3.ffi : LSt).mlx.nodes.get 22538).isSome = true
kernel_rfl FINAL.sF_tok : (FINAL.s3.ffi : LSt).mlx.tokens = []
kernel_rfl FINAL.SF_79 : nth? FINAL.S3.tab 79 = some (.var 14)
kernel_rfl FINAL.SF_17 : nth? FINAL.S3.tab Base.S0.tab.length = some (.var 17)

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- **The FINAL case's graph step**: the general theorem's graph conclusions at the halt, with the
program's final caches. -/
theorem FINAL.fgstep (fixA : List Nat) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hT : 2 ≤ T) (hTb : T ≤ 262144) (hc : cacheCell ∈ fixA) :
    Sim.FinalGStep (Gx M K env leaves typed parameters tplInputs) Sim.loadP0 fixA FINAL.finalCase ρ T tk toks
      (fun tF CF => GFC M K env leaves typed parameters T CF.tab tF) :=
  fgstepC_of M K env leaves typed parameters fixA FINAL.finalCase ρ T tk toks htk hT hTb
    base_s0_read base_s0_fed base_s0_pread base_s0_pfed FINAL.sF_read FINAL.sF_fed FINAL.sF_pread FINAL.sF_pfed
    base_s0_tok FINAL.sF_tok FINAL.SF_79 FINAL.SF_17 hc FINAL.cachePresent FINAL.cacheBind
    FINAL.cacheUnframed FINAL.cacheOk FINAL.caches FINAL.cacheNodes

end Host.Mlx.SimGraph.Iter
