import host.simgraph.mach.Total
import host.route.cert.Fin.Core
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Route.Cert.Fin
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.GlueLayers Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Ref (prefillAt RSt AneNet routeStep drainStep tailStep drainsFrom afterDrains preFinal tailThen prefillState_eq)
open Host.Mlx.SimGraph.Mach
open Host.Ts.Sim.Prefill (PStep chunkC drains tailRows drains_tail)

/-! # The prefill's handles' capacity

`PrefillTyped` forgets the capacity. `prefill_pre`: the prefill's handles at the exact capacity, `prefillTyped_of_schedule`'s invariant
kept. `capsFor_of_pre`: as `CapsFor`, once every handle is populated. -/

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine) (IP : InPlace) (net : AneNet)
  (env : FfiEval.Env InKey) (π : List Nat) {G : Metal.Gpu C} (RP : Host.Mlx.KernelGpu.RoutePipelines G)
  (hK : KR.toKernelContract.apply = Host.Mlx.KernelGpu.apply G) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)

include RP hK leaves typed in
/-- **The prefill's handles at their exact capacity.** -/
theorem prefill_pre (hL1 : 1 ≤ π.length) (hL2 : π.length ≤ 349525) (h : ScheduleTyped P KR NE IP net env π) (tab : List F64) :
    ∃ s, prefillAt P KR NE IP net env π tab = some s ∧
      List.Forall₂ (StagePre (π.length - 1)) (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs := by
  obtain ⟨hd, ht⟩ := h tab
  obtain ⟨s1, e1, h1⟩ := drains_ty P KR NE IP net env π tab hd (drains π.length) 0 ⟨initialHandles, net.surfaces, []⟩
    (by omega) (by rw [Nat.zero_mul]; exact initial_pre _)
  rw [Nat.zero_add] at h1
  have hdt := drains_tail π.length
  unfold prefillAt
  rw [prefillState_eq _ hL1 hL2]
  unfold preFinal afterDrains
  rw [e1, Option.bind_some]
  unfold tailThen
  by_cases h0 : tailRows π.length = 0
  · rw [ite_eq_left h0]
    exact ⟨s1, rfl, by rw [show π.length - 1 = drains π.length * chunkC π.length by omega]; exact h1⟩
  · rw [ite_eq_right h0]
    by_cases hr1 : tailRows π.length = 1
    · obtain ⟨s2, e2, h2⟩ := routeStep_oneK P KR NE IP net env π RP hK leaves typed KvPre kvPre_steps tab
        (tailStep π.length) s1 (by show π.length - 1 - drains π.length * chunkC π.length = 1; omega) h1
      refine ⟨s2, e2, ?_⟩
      rw [show π.length - 1 = (tailStep π.length).start + 1 by
        show _ = drains π.length * chunkC π.length + 1; omega]
      exact h2
    · obtain ⟨s2, e2, h2⟩ := ht (by omega) s1 h1
      exact ⟨s2, e2, h2⟩

/-- A stage's handles, populated, at the capacity. -/
theorem stageCap_of_pre {o : Nat} (ho : 0 < o) {w : StageWeights} {h : Handles} (hp : StagePre o w h)
    (hv : (handleVals h).isSome = true) : StageCap (Host.Mlx.SimGraph.Mach.capL o) w h := by
  cases w with
  | delta d =>
    cases h with
    | attention _ _ => exact hp.elim
    | delta c r =>
      cases c <;> cases r <;> first | exact trivial | simp [handleVals] at hv
  | attention a =>
    cases h with
    | delta _ _ => exact hp.elim
    | attention k v =>
      cases k with
      | none => exact absurd hp.1 (by show ¬ o = 0; omega)
      | some kb =>
        cases v with
        | none => exact absurd hp.2 (by show ¬ o = 0; omega)
        | some vb => exact ⟨hp.1.2.2, hp.2.2.2⟩

/-- **The prefill's handles as `CapsFor`.** -/
theorem capsFor_of_pre {o : Nat} (ho : 0 < o) : ∀ {ws : List StageWeights} {hs : List Handles},
    List.Forall₂ (StagePre o) ws hs → (∀ x ∈ hs, (handleVals x).isSome = true) → CapsFor (Host.Mlx.SimGraph.Mach.capL o) ws hs
  | _, _, .nil, _ => .nil
  | _, _, .cons h t, hv => .cons (stageCap_of_pre ho h (hv _ (List.mem_cons_self ..)))
      (capsFor_of_pre ho t fun x hx => hv x (List.mem_cons_of_mem _ hx))

end Host.Route.Cert.Fin
