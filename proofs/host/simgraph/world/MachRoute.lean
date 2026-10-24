import host.simgraph.world.Mach
import host.simgraph.mach.Refine
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (Gr RefRun ForwardAtR refPrompt1 hpOf)
open Host.Mlx.SimGraph.Mach (MRef ForwardAtM refPrompt refPrompt_refines)
open Host.Mlx.SimGraph.Ref (PrefillHolds refPromptModel refPromptModel_one prefillHolds_one prefillAt AneNet)
open Host.Ts.Sim.Prefill (RouteGoalW)

/-! # The route of a prompt at the machine reference

For an arbitrary prompt the route's reference is the machine's (`refPrompt π`, `host.simgraph.mach.Ref`):
the MMA kernels and the Neural Engine are uninterpreted, so no range analysis bounds their outputs.

* `machGoal`: the halts' goal `GFM` at `refPrompt π` (the halted target's graph holds every forward
  result of times `L … L + k - 1` at the reference and the memoized readbacks' values), the goal of
  `host.route.Final`'s `route_final`; the decode loop's graph obligations are stated at
  `liftG Wd (GxM … (refPrompt π) L)` (`host.simgraph.world.Mach`).
* `route_model_of_mach`: **the model-level corollary**: where the prefill's caches are within the model's
  ranges (`PrefillHolds π`, proven for `L = 1, 2`), the tokens are the model reference's and the forward
  results are the model's (`GFR` at `refPromptModel`), by `refPrompt_refines`.
* `route_model_one`: its instance at the one-token prompt: the existing reference `refPrompt1` (the
  checkpoint recurrence of `source_tokens`). -/

variable {C : M1Max.Contract}

/-- **The halted target's conclusions at a model reference** (`GFL` over any mlx state): the forward
result of every time `L … L + T - 1` at `R` and the memoized readbacks' values. -/
def GFR (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
    (typed : TypedCheckpoint env.weights) (R : RefRun M K env leaves typed) (L T : Nat) (tab : List F64)
    (x : Host.Mlx.Ffi.St) : Prop :=
  (∀ k (_ : L ≤ k) (_ : k ≤ L + T - 1) (hb : k ≤ 262144), ∃ cs out,
    ForwardAtR M K env leaves typed R tab k hb cs out (Gr tab x)) ∧
  ReadbackValues M K env (CSrv.val ⟨tab⟩) (Gr tab x) x.items

/-- `GFR` reads its reference only through its tokens and caches. -/
theorem GFR.congr {M : MlxContract C} {K : KernelContract C} {env : FfiEval.Env InKey}
    {leaves : Leaves code env.weights} {typed : TypedCheckpoint env.weights} {R R' : RefRun M K env leaves typed}
    {L T : Nat} {tab : List F64} {x : Host.Mlx.Ffi.St}
    (hR : ∀ time hb, (R' tab time hb).token = (R tab time hb).token ∧ (R' tab time hb).cache = (R tab time hb).cache)
    (h : GFR M K env leaves typed R L T tab x) : GFR M K env leaves typed R' L T tab x := by
  refine ⟨fun k h1 h2 hb => ?_, h.2⟩
  obtain ⟨cs, out, hs, htok, hh, hv⟩ := h.1 k h1 h2 hb
  obtain ⟨et, ec⟩ := hR k hb
  exact ⟨cs, out, hs, by rw [et]; exact htok, by rw [ec]; exact hh, hv⟩

section
variable (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine) (IP : InPlace) (net : AneNet)
  (env : FfiEval.Env InKey) (π : List Nat)

/-- The machine reference's goal at the halted target: `GFM` at `refPrompt π` with `k` tokens. -/
abbrev machGoal {Wd : Sim.World} (k : Nat) : St Wd.F.S → CSrv → Prop := fun tF CF =>
  GFM P.toMlxContract KR.toKernelContract env (refPrompt P KR NE IP net env π) π.length k CF.tab (Wd.toMlx tF.ffi)

/-! ## The model-level corollary -/

variable (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
  (parameters : TokenSequenceRanges.Parameters (firstPipeline P.toMlxContract KR.toKernelContract env [] leaves typed))

/-- **A machine token is the model's** where the prefill's caches are within the model's ranges: from
`L - 1` on, the machine reference's token is the model reference's and its handles hold the model's
cache (`refPrompt_refines`). -/
theorem mach_token_model {π : List Nat} (h : PrefillHolds P KR NE IP net env leaves typed π)
    (hlt : ∀ t ∈ π, t < 248320) (h1 : 1 ≤ π.length) (tab : List F64) {k tok : Nat} {hs : List Handles}
    (hk : π.length - 1 ≤ k) (hb : k ≤ 262144) (hR : refPrompt P KR NE IP net env π tab k = some (tok, hs)) :
    tok = (refPromptModel P KR NE IP net env leaves typed parameters π h tab k hb).token.val ∧
      ChainHolds (firstPipeline P.toMlxContract KR.toKernelContract env tab leaves typed).graph.stages hs
        (refPromptModel P KR NE IP net env leaves typed parameters π h tab k hb).cache := by
  obtain ⟨m, rfl⟩ : ∃ m, k = π.length - 1 + m := ⟨k - (π.length - 1), by omega⟩
  obtain ⟨hs', hR', hch⟩ := refPrompt_refines P KR NE IP net env leaves typed parameters h hlt h1 tab m hb
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Option.some.inj (hR.symm.trans hR'))
  exact ⟨rfl, hch⟩

/-- **The machine goal is the model's** under the refinement. -/
theorem GFR_of_GFM {π : List Nat} (h : PrefillHolds P KR NE IP net env leaves typed π)
    (hlt : ∀ t ∈ π, t < 248320) (h1 : 1 ≤ π.length) {T : Nat} {tab : List F64} {x : Host.Mlx.Ffi.St}
    (hg : GFM P.toMlxContract KR.toKernelContract env (refPrompt P KR NE IP net env π) π.length T tab x) :
    GFR P.toMlxContract KR.toKernelContract env leaves typed
      (refPromptModel P KR NE IP net env leaves typed parameters π h) π.length T tab x := by
  refine ⟨fun k h1' h2' hb => ?_, hg.2⟩
  obtain ⟨cs, out, tok, hs, hR, htok, hcv⟩ := hg.1 k h1' h2'
  obtain ⟨rfl, hch⟩ := mach_token_model P KR NE IP net env leaves typed parameters h hlt h1 tab (by omega) hb hR
  exact ⟨cs, out, hs, htok, hch, hcv⟩

/-- **The model-level corollary of the machine route**: where the prefill's caches are within the model's
ranges (`PrefillHolds π`; `prefillHolds_one`, `prefillHolds_two`), the route's tokens are the model
reference's (`refPromptModel π`: the model's greedy tokens after prefilling `π`, `refPromptModel_tokens`)
and the halted target's graph holds the model's forward results (`GFR`). -/
theorem route_model_of_mach {π : List Nat} (h : PrefillHolds P KR NE IP net env leaves typed π)
    (hlt : ∀ t ∈ π, t < 248320) (hπ : 1 ≤ π.length) {Wd : Sim.World} {T : Nat} {tk : Nat → Nat}
    {t0 : St Wd.F.S} {C0 : CSrv} {je : Host.Ts.Env} {nm : Host.Ts.Name}
    (htk : ∀ tab j, j < T → ∃ hs, refPrompt P KR NE IP net env π tab (π.length + j) = some (tk (j + 1), hs))
    (hroute : RouteGoalW t0 C0 je nm T tk (machGoal P KR NE IP net env π T) (fun k => machGoal P KR NE IP net env π k)) :
    RouteGoalW t0 C0 je nm T tk
        (fun tF CF => GFR P.toMlxContract KR.toKernelContract env leaves typed
          (refPromptModel P KR NE IP net env leaves typed parameters π h) π.length T CF.tab (Wd.toMlx tF.ffi))
        (fun k tF CF => GFR P.toMlxContract KR.toKernelContract env leaves typed
          (refPromptModel P KR NE IP net env leaves typed parameters π h) π.length k CF.tab (Wd.toMlx tF.ffi)) ∧
      ∀ tab j (_ : j < T) (hb : π.length + j ≤ 262144),
        tk (j + 1) = (refPromptModel P KR NE IP net env leaves typed parameters π h tab (π.length + j) hb).token.val := by
  refine ⟨hroute.mono (fun _ _ hg => GFR_of_GFM P KR NE IP net env leaves typed parameters h hlt hπ hg)
    (fun _ _ _ _ hg => GFR_of_GFM P KR NE IP net env leaves typed parameters h hlt hπ hg), fun tab j hj hb => ?_⟩
  obtain ⟨hs, hR⟩ := htk tab j hj
  exact (mach_token_model P KR NE IP net env leaves typed parameters h hlt hπ tab (by omega) hb hR).1

/-- **At the one-token prompt** the model-level corollary is about the existing reference `refPrompt1` (the
checkpoint recurrence `(firstContext …).run promptToken` of `source_tokens`): the route's tokens are its
tokens at times `1 … T` and the halted target's graph holds its forward results. -/
theorem route_model_one {Wd : Sim.World} {T : Nat} {tk : Nat → Nat} {t0 : St Wd.F.S} {C0 : CSrv} {je : Host.Ts.Env}
    {nm : Host.Ts.Name}
    (htk : ∀ tab j, j < T →
      ∃ hs, refPrompt P KR NE IP net env [promptToken.val] tab (1 + j) = some (tk (j + 1), hs))
    (hroute : RouteGoalW t0 C0 je nm T tk (machGoal P KR NE IP net env [promptToken.val] T)
      (fun k => machGoal P KR NE IP net env [promptToken.val] k)) :
    RouteGoalW t0 C0 je nm T tk
        (fun tF CF => GFR P.toMlxContract KR.toKernelContract env leaves typed
          (refPrompt1 P.toMlxContract KR.toKernelContract env leaves typed parameters) 1 T CF.tab (Wd.toMlx tF.ffi))
        (fun k tF CF => GFR P.toMlxContract KR.toKernelContract env leaves typed
          (refPrompt1 P.toMlxContract KR.toKernelContract env leaves typed parameters) 1 k CF.tab (Wd.toMlx tF.ffi)) ∧
      ∀ tab j (_ : j < T) (hb : 1 + j ≤ 262144),
        tk (j + 1) = (refPrompt1 P.toMlxContract KR.toKernelContract env leaves typed parameters tab (1 + j) hb).token.val := by
  have h := prefillHolds_one P KR NE IP net env leaves typed
  obtain ⟨hr, hv⟩ := route_model_of_mach P KR NE IP net env leaves typed parameters h
    (fun t ht => by simp only [List.mem_singleton] at ht; subst ht; exact promptToken.isLt) (by simp) htk hroute
  have hone := fun tab => refPromptModel_one (parameters := parameters) h tab
  refine ⟨hr.mono (fun tF CF hg => GFR.congr (fun time hb => ⟨(hone CF.tab time hb).1.symm, (hone CF.tab time hb).2.symm⟩) hg)
    (fun _ tF CF _ hg => GFR.congr (fun time hb => ⟨(hone CF.tab time hb).1.symm, (hone CF.tab time hb).2.symm⟩) hg),
    fun tab j hj hb => ?_⟩
  exact (hv tab j hj hb).trans (congrArg Fin.val (hone tab (1 + j) hb).1)

end

end Host.Mlx.SimGraph
