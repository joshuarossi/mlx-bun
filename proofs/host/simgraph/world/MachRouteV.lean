import host.simgraph.world.MachRoute
import host.simgraph.world.MachV
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Mlx.SimGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (Gr RefRun ForwardAtR refPrompt1 hpOf)
open Host.Mlx.SimGraph.Mach (MRef refPrompt refPrompt_refines Vals CacheValuesV ReadbackValuesV)
open Host.Mlx.SimGraph.Ref (PrefillHolds refPromptModel refPromptModel_one prefillHolds_one prefillAt AneNet)
open Host.Ts.Sim.Prefill (RouteGoalW)

/-! # The route of a prompt at the machine reference, at the route's values

`host.simgraph.world.MachRoute` at values `Vs` (`routeVals` in the route): `machGoalV`, the halts' goal `GFV` at
`refPrompt π`; `route_model_of_machV`: where the prefill's caches are within the model's ranges (`PrefillHolds π`,
proven for `L = 1, 2`) the tokens are the model reference's and the forward results are the model's at the same
values (`GFRV`), by `refPrompt_refines`; `route_model_oneV`: its instance at the one-token prompt. -/

variable {C : M1Max.Contract}

/-- `ForwardAtR` at values `ev`. -/
def ForwardAtRV (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
    (typed : TypedCheckpoint env.weights) (ev : Nat → Option Value) (R : RefRun M K env leaves typed) (tab : List F64)
    (time : Nat) (hb : time ≤ 262144) (cs : List Cache) (out : Nat) : Prop :=
  ∃ hs, (∃ r, ev out = some r ∧ itemUint32 r = some (R tab time hb).token.val) ∧
    ChainHolds (firstPipeline M K env tab leaves typed).graph.stages hs (R tab time hb).cache ∧
    CacheValuesV ev cs hs

/-- **The halted target's conclusions at a model reference**, at values `Vs`. -/
def GFRV (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
    (typed : TypedCheckpoint env.weights) (Vs : Vals) (R : RefRun M K env leaves typed) (L T : Nat) (tab : List F64)
    (x : Host.Mlx.Ffi.St) : Prop :=
  (∀ k (_ : L ≤ k) (_ : k ≤ L + T - 1) (hb : k ≤ 262144), ∃ cs out,
    ForwardAtRV M K env leaves typed (Vs.val tab x) R tab k hb cs out) ∧
  ReadbackValuesV (Vs.val tab x) (CSrv.val ⟨tab⟩) x.items

/-- `GFRV` reads its reference only through its tokens and caches. -/
theorem GFRV.congr {Vs : Vals} {M : MlxContract C} {K : KernelContract C} {env : FfiEval.Env InKey}
    {leaves : Leaves code env.weights} {typed : TypedCheckpoint env.weights} {R R' : RefRun M K env leaves typed}
    {L T : Nat} {tab : List F64} {x : Host.Mlx.Ffi.St}
    (hR : ∀ time hb, (R' tab time hb).token = (R tab time hb).token ∧ (R' tab time hb).cache = (R tab time hb).cache)
    (h : GFRV M K env leaves typed Vs R L T tab x) : GFRV M K env leaves typed Vs R' L T tab x := by
  refine ⟨fun k h1 h2 hb => ?_, h.2⟩
  obtain ⟨cs, out, hs, htok, hh, hv⟩ := h.1 k h1 h2 hb
  obtain ⟨et, ec⟩ := hR k hb
  exact ⟨cs, out, hs, by rw [et]; exact htok, by rw [ec]; exact hh, hv⟩

section
variable (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine) (IP : InPlace) (net : AneNet)
  (env : FfiEval.Env InKey) (π : List Nat) (Vs : Vals)

/-- The machine reference's goal at the halted target: `GFV` at `refPrompt π` with `k` tokens. -/
abbrev machGoalV {Wd : Sim.World} (k : Nat) : St Wd.F.S → CSrv → Prop := fun tF CF =>
  GFV Vs (refPrompt P KR NE IP net env π) π.length k CF.tab (Wd.toMlx tF.ffi)

/-! ## The model-level corollary -/

variable (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
  (parameters : TokenSequenceRanges.Parameters (firstPipeline P.toMlxContract KR.toKernelContract env [] leaves typed))

/-- **The machine goal is the model's** under the refinement. -/
theorem GFRV_of_GFV {π : List Nat} (h : PrefillHolds P KR NE IP net env leaves typed π)
    (hlt : ∀ t ∈ π, t < 248320) (h1 : 1 ≤ π.length) {T : Nat} {tab : List F64} {x : Host.Mlx.Ffi.St}
    (hg : GFV Vs (refPrompt P KR NE IP net env π) π.length T tab x) :
    GFRV P.toMlxContract KR.toKernelContract env leaves typed Vs
      (refPromptModel P KR NE IP net env leaves typed parameters π h) π.length T tab x := by
  refine ⟨fun k h1' h2' hb => ?_, hg.2⟩
  obtain ⟨cs, out, tok, hs, hR, htok, hcv⟩ := hg.1 k h1' h2'
  obtain ⟨rfl, hch⟩ := mach_token_model P KR NE IP net env leaves typed parameters h hlt h1 tab (by omega) hb hR
  exact ⟨cs, out, hs, htok, hch, hcv⟩

/-- **The model-level corollary of the machine route**: where the prefill's caches are within the model's
ranges (`PrefillHolds π`; `prefillHolds_one`, `prefillHolds_two`), the route's tokens are the model
reference's (`refPromptModel π`: the model's greedy tokens after prefilling `π`, `refPromptModel_tokens`)
and the halted target's graph holds the model's forward results (`GFR`). -/
theorem route_model_of_machV {π : List Nat} (h : PrefillHolds P KR NE IP net env leaves typed π)
    (hlt : ∀ t ∈ π, t < 248320) (hπ : 1 ≤ π.length) {Wd : Sim.World} {T : Nat} {tk : Nat → Nat}
    {t0 : St Wd.F.S} {C0 : CSrv} {je : Host.Ts.Env} {nm : Host.Ts.Name}
    (htk : ∀ tab j, j < T → ∃ hs, refPrompt P KR NE IP net env π tab (π.length + j) = some (tk (j + 1), hs))
    (hroute : RouteGoalW t0 C0 je nm T tk (machGoalV P KR NE IP net env π Vs T) (fun k => machGoalV P KR NE IP net env π Vs k)) :
    RouteGoalW t0 C0 je nm T tk
        (fun tF CF => GFRV P.toMlxContract KR.toKernelContract env leaves typed Vs
          (refPromptModel P KR NE IP net env leaves typed parameters π h) π.length T CF.tab (Wd.toMlx tF.ffi))
        (fun k tF CF => GFRV P.toMlxContract KR.toKernelContract env leaves typed Vs
          (refPromptModel P KR NE IP net env leaves typed parameters π h) π.length k CF.tab (Wd.toMlx tF.ffi)) ∧
      ∀ tab j (_ : j < T) (hb : π.length + j ≤ 262144),
        tk (j + 1) = (refPromptModel P KR NE IP net env leaves typed parameters π h tab (π.length + j) hb).token.val := by
  refine ⟨hroute.mono (fun _ _ hg => GFRV_of_GFV P KR NE IP net env Vs leaves typed parameters h hlt hπ hg)
    (fun _ _ _ _ hg => GFRV_of_GFV P KR NE IP net env Vs leaves typed parameters h hlt hπ hg), fun tab j hj hb => ?_⟩
  obtain ⟨hs, hR⟩ := htk tab j hj
  exact (mach_token_model P KR NE IP net env leaves typed parameters h hlt hπ tab (by omega) hb hR).1

/-- **At the one-token prompt** the model-level corollary is about the existing reference `refPrompt1` (the
checkpoint recurrence `(firstContext …).run promptToken` of `source_tokens`): the route's tokens are its
tokens at times `1 … T` and the halted target's graph holds its forward results. -/
theorem route_model_oneV {Wd : Sim.World} {T : Nat} {tk : Nat → Nat} {t0 : St Wd.F.S} {C0 : CSrv} {je : Host.Ts.Env}
    {nm : Host.Ts.Name}
    (htk : ∀ tab j, j < T →
      ∃ hs, refPrompt P KR NE IP net env [promptToken.val] tab (1 + j) = some (tk (j + 1), hs))
    (hroute : RouteGoalW t0 C0 je nm T tk (machGoalV P KR NE IP net env [promptToken.val] Vs T)
      (fun k => machGoalV P KR NE IP net env [promptToken.val] Vs k)) :
    RouteGoalW t0 C0 je nm T tk
        (fun tF CF => GFRV P.toMlxContract KR.toKernelContract env leaves typed Vs
          (refPrompt1 P.toMlxContract KR.toKernelContract env leaves typed parameters) 1 T CF.tab (Wd.toMlx tF.ffi))
        (fun k tF CF => GFRV P.toMlxContract KR.toKernelContract env leaves typed Vs
          (refPrompt1 P.toMlxContract KR.toKernelContract env leaves typed parameters) 1 k CF.tab (Wd.toMlx tF.ffi)) ∧
      ∀ tab j (_ : j < T) (hb : 1 + j ≤ 262144),
        tk (j + 1) = (refPrompt1 P.toMlxContract KR.toKernelContract env leaves typed parameters tab (1 + j) hb).token.val := by
  have h := prefillHolds_one P KR NE IP net env leaves typed
  obtain ⟨hr, hv⟩ := route_model_of_machV P KR NE IP net env Vs leaves typed parameters h
    (fun t ht => by simp only [List.mem_singleton] at ht; subst ht; exact promptToken.isLt) (by simp) htk hroute
  have hone := fun tab => refPromptModel_one (parameters := parameters) h tab
  refine ⟨hr.mono (fun tF CF hg => GFRV.congr (fun time hb => ⟨(hone CF.tab time hb).1.symm, (hone CF.tab time hb).2.symm⟩) hg)
    (fun _ tF CF _ hg => GFRV.congr (fun time hb => ⟨(hone CF.tab time hb).1.symm, (hone CF.tab time hb).2.symm⟩) hg),
    fun tab j hj hb => ?_⟩
  exact (hv tab j hj hb).trans (congrArg Fin.val (hone tab (1 + j) hb).1)

end

end Host.Mlx.SimGraph
