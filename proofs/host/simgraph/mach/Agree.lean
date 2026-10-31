import host.simgraph.mach.Vals
import host.simgraph.world.MachV
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Mlx.SimGraph.Mach
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (Gr)

/-! # The decode evaluation agrees with the route's values

`evalR_routeVal`: **a value of the decode-kernel evaluation is the node's value at the route's values.** Every result
stated at `evalR` on the decode-resolved graph therefore transports: `ForwardAtM.toV`, `ReadbackValues.toV`, and the
halted goal `GFM.toV`. This is how a route whose whole history runs on decode kernels (the one-token prompt's proved
graph facts) reaches the route's goals. -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (env : FfiEval.Env InKey)
  (kind : Nat → Option Compiled) (Z : Nat → Option Value)

local notation "Mx" => P.toMlxContract
local notation "Kx" => KR.toKernelContract

theorem evalR_routeVal (tab : List F64) (x : Ffi.St) :
    ∀ i v, evalR Mx Kx env (Gr tab x) i = some v → routeVal P KR env kind Z tab x i = some v := by
  intro i
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  intro v hv
  have hnode : ∀ j nd, Gr tab x j = some nd → strip nd.prim ≠ .unsupported → GrR tab x j = some nd :=
    fun j nd hj hne => ffiGraph_route _ _ _ j nd hj hne
  have hargs : ∀ (l : List Nat) (ys : List Value),
      (l.mapM fun j => if _h : j < i then evalR Mx Kx env (Gr tab x) j else none) = some ys →
      (l.mapM fun j => if _h : j < i then routeVal P KR env kind Z tab x j else none) = some ys := by
    intro l ys hl
    refine mapM_some_mono l _ _ (fun j _ y hy => ?_) hl
    by_cases hj : j < i
    · simp only [hj, ↓reduceDIte] at hy ⊢
      exact ih j hj y hy
    · simp only [hj, ↓reduceDIte] at hy; cases hy
  rw [evalR_eq] at hv
  cases hg : Gr tab x i with
  | none => rw [hg] at hv; cases hv
  | some nd =>
    rw [hg] at hv
    dsimp only at hv
    cases hc : cgLeaves (Gr tab x) i with
    | some leaves =>
      rw [hc] at hv
      dsimp only at hv
      obtain ⟨xs, hxs, hcl⟩ := Option.bind_eq_some_iff.mp hv
      have hcR := cgLeaves_mono hnode hc
      obtain ⟨r, hr, _⟩ := Option.bind_eq_some_iff.mp hcR
      have hargs' := hargs leaves xs hxs
      show evalZ P KR env kind Z (GrR tab x) i = some v
      rw [evalZ_eq, hr, hcR]
      dsimp only
      have hval : (leaves.mapM fun j => if _h : j < i then evalZ P KR env kind Z (GrR tab x) j else none) = some xs := hargs'
      rw [hval, Option.bind_some]
      have hg' : computeGP P (κ := InKey) xs = some v := by
        simp [computeGP, hcl, Option.orElse]
      rw [hg']
      rfl
    | none =>
      rw [hc] at hv
      dsimp only at hv
      obtain ⟨xs, hxs, hp⟩ := Option.bind_eq_some_iff.mp hv
      have hne : strip nd.prim ≠ .unsupported := by
        have key : ∀ q : RPrim Int InKey, strip q = .unsupported → primEval Mx Kx env q xs = none := by
          intro q
          induction q with
          | unsupported => intro _; cases xs <;> simp [primEval]
          | replayed c q ih =>
            intro h
            have hq := ih h
            simp only [primEval]
            split <;> simp [hq]
          | _ => intro h; simp at h
        intro hu
        rw [key nd.prim hu] at hp
        cases hp
      have hR := hnode i nd hg hne
      have hpR : primEvalR P KR env nd.prim xs = some v :=
        primEvalR_of P KR env (by simp [primEvalP, hp, Option.orElse])
      obtain ⟨hnc, hnk⟩ := no_pattern_of_prim P KR env kind hpR hR
      have hargs' := hargs nd.ins xs hxs
      show evalZ P KR env kind Z (GrR tab x) i = some v
      rw [evalZ_eq, hR]
      dsimp only
      rw [hnc]
      dsimp only
      rw [hnk]
      dsimp only
      have hval : (nd.ins.mapM fun j => if _h : j < i then evalZ P KR env kind Z (GrR tab x) j else none) = some xs := hargs'
      rw [hval, Option.bind_some, hpR]
      rfl

/-- `CacheValues` at the decode evaluation transports to the route's values. -/
theorem CacheValues.toRoute {tab : List F64} {x : Ffi.St} {cs : List Cache} {hs : List Handles}
    (h : CacheValues Mx Kx env (Gr tab x) cs hs) : CacheValuesV (routeVal P KR env kind Z tab x) cs hs := by
  induction h with
  | nil => exact .nil
  | cons hc _ ih =>
    obtain ⟨ta, tb, a, b, ht, hu, hv, ha, hb⟩ := hc
    exact .cons ⟨ta, tb, a, b, ht, hu, hv, evalR_routeVal P KR env kind Z tab x _ _ ha,
      evalR_routeVal P KR env kind Z tab x _ _ hb⟩ ih

/-- `ForwardAtM` at the decode evaluation transports to the route's values. -/
theorem ForwardAtM.toRoute {R : MRef} {tab : List F64} {x : Ffi.St} {time : Nat} {cs : List Cache} {out : Nat}
    (h : ForwardAtM Mx Kx env R tab time cs out (Gr tab x)) :
    ForwardAtV (routeVal P KR env kind Z tab x) R tab time cs out := by
  obtain ⟨tok, hs, hR, ⟨r, hr, ht⟩, hc⟩ := h
  exact ⟨tok, hs, hR, ⟨r, evalR_routeVal P KR env kind Z tab x _ _ hr, ht⟩, CacheValues.toRoute P KR env kind Z hc⟩

/-- `ReadbackValues` at the decode evaluation transports to the route's values. -/
theorem ReadbackValues.toRoute {tab : List F64} {x : Ffi.St} {ν : NumV → Option F64} {items : PTrie NumV}
    (h : ReadbackValues Mx Kx env ν (Gr tab x) items) : ReadbackValuesV (routeVal P KR env kind Z tab x) ν items := by
  intro node value hv
  obtain ⟨token, ht, ⟨r, hr, hi⟩, hn⟩ := h node value hv
  exact ⟨token, ht, ⟨r, evalR_routeVal P KR env kind Z tab x _ _ hr, hi⟩, hn⟩

end

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (env : FfiEval.Env InKey)
  (kind : Nat → Option Compiled) (Z : List F64 → Nat → Option Value)

/-- **The halted goal at the decode evaluation is the goal at the route's values.** -/
theorem GFM.toV {R : MRef} {L T : Nat} {tab : List F64} {x : Ffi.St}
    (h : GFM P.toMlxContract KR.toKernelContract env R L T tab x) :
    GFV (routeVals P KR env kind Z) R L T tab x :=
  ⟨fun k h1 h2 => by
      obtain ⟨cs, out, hf⟩ := h.1 k h1 h2
      exact ⟨cs, out, ForwardAtM.toRoute P KR env kind (Z tab) hf⟩,
    ReadbackValues.toRoute P KR env kind (Z tab) h.2⟩

end

end Host.Mlx.SimGraph.Mach
