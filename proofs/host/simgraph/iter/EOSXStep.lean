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

/-! The EOSX exit case's graph step: `egstep_core` and `final_cache` (via `egstepC_of`) with the
halted end's readback slot (the EOS token, time `i + 1`, at `20157`), tokens and table entry. -/

kernel_rfl EOSX.sF_read : (EOSX.s4.ffi : LSt).mlx.items.get 20157 = some (.ref 79)
kernel_rfl EOSX.sF_pread : ((EOSX.s4.ffi : LSt).mlx.nodes.get 20157).isSome = true
kernel_rfl EOSX.sF_tok : (EOSX.s4.ffi : LSt).mlx.tokens = []
kernel_rfl EOSX.SF_79 : nth? EOSX.S4.tab 79 = some (.var 14)

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- **The EOSX case's graph step** at iteration `i`: the graph conclusions for times `1 … i + 2`
at the halt, with the program's final caches. -/
theorem EOSX.egstep (fixA : List Nat) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV) (i : Nat)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hib : i + 2 ≤ 262144) (hc : cacheCell ∈ fixA) :
    Sim.ExitGStep (Gx M K env leaves typed parameters tplInputs) Sim.loadP0 fixA EOSX.exitCase ρ T tk toks i
      (fun tF CF => GFC M K env leaves typed parameters (i + 2) CF.tab tF) :=
  egstepC_of M K env leaves typed parameters fixA EOSX.exitCase ρ T tk toks i htk hib
    base_s0_read base_s0_pread EOSX.sF_read EOSX.sF_pread base_s0_tok EOSX.sF_tok EOSX.SF_79 hc
    EOSX.cachePresent EOSX.cacheBind EOSX.cacheUnframed EOSX.cacheOk EOSX.caches EOSX.cacheNodes

end Host.Mlx.SimGraph.Iter
