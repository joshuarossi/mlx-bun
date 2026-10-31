import host.route.Final
namespace Host.Route.SingletonReference
open Host.Ts Host.Load.Run.Full Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Ref (AneNet)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
  (NE : NeuralEngine) (IP : Host.Mlx.FfiAneEval.InPlace) (net : AneNet) (env : FfiEval.Env InKey)

theorem prefill (token : Nat) (table : List F64) :
    Ref.prefillAt P KR NE IP net env [token] table =
      some ⟨initialHandles, net.surfaces, []⟩ := rfl

theorem start (token : Nat) (table : List F64) :
    Mach.refPrompt P KR NE IP net env [token] table 0 = some (token, initialHandles) := rfl

theorem next (token : Nat) (table : List F64) :
    Mach.refPrompt P KR NE IP net env [token] table 1 =
      stepTrace P.toMlxContract KR.toKernelContract
        (weights (firstValues P.toMlxContract KR.toKernelContract env table))
        0 token initialHandles := by
  have h := Mach.refPrompt_succ P KR NE IP net env [token] table 0
    (by change 0 ≤ 0; exact Nat.le_refl 0)
  simpa only [start, Option.bind_some, Nat.zero_add] using h

/-- The route's first generated token reads the singleton's actual cold trace. -/
theorem token (input : Nat) :
    Host.Route.machTok P KR NE net env [input] 1 =
      ((stepTrace P.toMlxContract KR.toKernelContract
        (weights (firstValues P.toMlxContract KR.toKernelContract env []))
        0 input initialHandles).map Prod.fst).getD 0 := by
  change ((Mach.refPrompt P KR NE KR.inPlace net env [input] [] 1).map Prod.fst).getD 0 = _
  rw [next]

end Host.Route.SingletonReference
