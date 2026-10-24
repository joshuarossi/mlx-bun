import host.simgraph.iter.Exit
import host.simgraph.iter.BaseTpl
import host.sim.extract.CacheEos
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Load.Run.Tpl
open Inference.Models.Qwen

/-! The FINALEC0 EOS final case's graph step: `fgstep_core_at` and `final_cache` (via `fgstepEC_of`)
with the halted end's readback slots (time `T - 1` at `20157`, the EOS token of time `T` at
`22538`), tokens and table entries. -/

kernel_rfl FINALEC0.sF_read : (FINALEC0.s4.ffi : LSt).mlx.items.get 20157 = some (.ref 79)
kernel_rfl FINALEC0.sF_fed : (FINALEC0.s4.ffi : LSt).mlx.items.get 22538 = some (.ref Base.S0.tab.length)
kernel_rfl FINALEC0.sF_pread : ((FINALEC0.s4.ffi : LSt).mlx.nodes.get 20157).isSome = true
kernel_rfl FINALEC0.sF_pfed : ((FINALEC0.s4.ffi : LSt).mlx.nodes.get 22538).isSome = true
kernel_rfl FINALEC0.sF_tok : (FINALEC0.s4.ffi : LSt).mlx.tokens = []
kernel_rfl FINALEC0.SF_79 : nth? FINALEC0.S4.tab 79 = some (.var 14)
kernel_rfl FINALEC0.SF_17 : nth? FINALEC0.S4.tab Base.S0.tab.length = some (.var 17)

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- **The FINALEC0 case's graph step**: the graph conclusions for times `1 … T` at the halt, with
the program's final caches. -/
theorem FINALEC0.fgstep (fixA : List Nat) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hT : 2 ≤ T) (hTb : T ≤ 262144) (hc : cacheCell ∈ fixA) :
    Sim.FinalEGStep (Gx M K env leaves typed parameters tplInputs) Sim.loadP0 fixA FINALEC0.exitCase ρ T tk toks
      (fun tF CF => GFC M K env leaves typed parameters T CF.tab tF) :=
  fgstepEC_of M K env leaves typed parameters fixA FINALEC0.exitCase ρ T tk toks htk hT hTb
    base_s0_read base_s0_fed base_s0_pread base_s0_pfed FINALEC0.sF_read FINALEC0.sF_fed FINALEC0.sF_pread FINALEC0.sF_pfed
    base_s0_tok FINALEC0.sF_tok FINALEC0.SF_79 FINALEC0.SF_17 hc FINALEC0.cachePresent FINALEC0.cacheBind
    FINALEC0.cacheUnframed FINALEC0.cacheOk FINALEC0.caches FINALEC0.cacheNodes

end Host.Mlx.SimGraph.Iter
