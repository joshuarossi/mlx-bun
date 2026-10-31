import host.route.SingletonReference
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Route.SingletonReferenceStep
open _root_.Host.Ts _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Program
open _root_.Host.Load.Run.Full _root_.Host.Mlx _root_.Host.Mlx.GlueStep _root_.Host.Mlx.FfiEval
open _root_.Host.Mlx.SimGraph _root_.Host.Mlx.SimGraph.Ref
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
  (NE : NeuralEngine) (IP : Host.Mlx.FfiAneEval.InPlace) (net : AneNet) (env : FfiEval.Env InKey)
  (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
  (parameters : TokenSequenceRanges.Parameters
    (firstPipeline P.toMlxContract KR.toKernelContract env [] leaves typed))

/-- Checkpoint ranges construct the actual first cold reference step. -/
theorem trace (input : Fin 248320) :
    let after := (firstContext P.toMlxContract KR.toKernelContract env [] leaves typed parameters).run
      input 1 (by decide)
    ∃ hs, Mach.refPrompt P KR NE IP net env [input.val] [] 1 = some (after.token.val, hs) := by
  let p := firstPipeline P.toMlxContract KR.toKernelContract env [] leaves typed
  let w := weights (firstValues P.toMlxContract KR.toKernelContract env [])
  obtain ⟨hs, he, _⟩ := GlueM1Max.contextStep P.toMlxContract KR.toKernelContract p w
    (firstPipeline_loaded P.toMlxContract KR.toKernelContract env [] leaves typed)
    parameters input 0 (by decide) initialHandles (initialChainHolds p)
  change stepTrace P.toMlxContract KR.toKernelContract w 0 input.val initialHandles =
    some (((firstContext P.toMlxContract KR.toKernelContract env [] leaves typed parameters).run
      input 1 (by decide)).token.val, hs) at he
  exact ⟨hs, (SingletonReference.next P KR NE IP net env input.val []).trans he⟩

/-- The route's getD fallback is eliminated by the constructed cold step. -/
theorem token (input : Fin 248320) :
    Host.Route.machTok P KR NE net env [input.val] 1 =
      ((firstContext P.toMlxContract KR.toKernelContract env [] leaves typed parameters).run
        input 1 (by decide)).token.val := by
  obtain ⟨hs, he⟩ := trace P KR NE KR.inPlace net env leaves typed parameters input
  change ((Mach.refPrompt P KR NE KR.inPlace net env [input.val] [] 1).map Prod.fst).getD 0 = _
  rw [he]
  rfl

end Host.Route.SingletonReferenceStep
