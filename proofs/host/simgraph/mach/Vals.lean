import host.simgraph.mach.StepV
import host.sim.extract.Grow
import host.simgraph.family.MatchEmbed
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Mlx.SimGraph.Mach
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (Gr)
open Host.Mlx.Ffi (NGrow)

/-! # The values a run's graph facts are stated at

`Vals`: a table-indexed value function on native states that a run's growth keeps. The world-level graph layer
(`host.simgraph.world.MachV`) is generic in it. `routeVals Z`: the route's values, `Z` the recorded values of the
nodes reading a Neural Engine surface. A node's value under the route's kernels survives growth (`evalZ_grow`); a
recorded value survives where the grown state's primitive still has none (`Ok`, trivial with nothing recorded:
`routeVals_ok_empty`). -/

/-- Values a run's growth keeps, on the states `Ok` holds at. -/
structure Vals where
  val : List F64 → Ffi.St → Nat → Option Value
  Ok : Ffi.St → Prop
  ok_grow : ∀ {x y}, Ok x → NGrow x y → Ok y
  val_grow : ∀ {tab x y}, Ok x → NGrow x y → ∀ i v, i < x.nnext → val tab x i = some v → val tab y i = some v

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} [DecidableEq κ]
  (env : Env κ) (kind : Nat → Option Compiled) (Z : Nat → Option Value)

/-- A node's value from its primitive, `evalZ` without its fallback. -/
noncomputable def structZ (g : Nat → Option (RNode Int κ)) (i : Nat) : Option Value :=
  match g i with
  | none => none
  | some nd =>
    match cgLeaves g i with
    | some leaves => (leaves.mapM fun j => if _h : j < i then evalZ P K env kind Z g j else none).bind
        (computeGP P (κ := κ))
    | none =>
      match closureLeaves kind g i with
      | some (c, leaves) => (leaves.mapM fun j => if _h : j < i then evalZ P K env kind Z g j else none).bind
          (compiledValue P c)
      | none => (nd.ins.mapM fun j => if _h : j < i then evalZ P K env kind Z g j else none).bind
          (primEvalR P K env nd.prim)

theorem evalZ_struct (g : Nat → Option (RNode Int κ)) (i : Nat) :
    evalZ P K env kind Z g i = (structZ P K env kind Z g i).orElse fun _ => Z i :=
  evalZ_eq P K env kind Z g i

/-- A replayed elementwise node has no value of its own: only its closure's root pattern gives one. -/
theorem primEvalR_replayed {c : Nat} {q : RPrim Int κ} (hq : elementwise q = true) (xs : List Value) :
    primEvalR P K env (.replayed c q) xs = none := by
  simp [primEvalR, primEvalP, primEval, rowsEval, prefillEval, hq, Option.orElse]

/-- A node evaluated by its own primitive is the root of no compute_g or closure pattern, in any graph. -/
theorem no_pattern_of_prim {nd : RNode Int κ} {xs : List Value} {v : Value}
    (hp : primEvalR P K env nd.prim xs = some v) {g : Nat → Option (RNode Int κ)} {i : Nat} (hg : g i = some nd) :
    cgLeaves g i = none ∧ closureLeaves kind g i = none := by
  constructor
  · cases hc : cgLeaves g i with
    | none => rfl
    | some l =>
      exfalso
      unfold cgLeaves at hc
      rw [hg, Option.bind_some] at hc
      simp only [cgAux, Option.bind_eq_bind, Option.bind_eq_some_iff] at hc
      obtain ⟨cls, hcls, -⟩ := hc
      cases hr : nd.prim with
      | replayed c q =>
        rw [hr] at hcls hp
        cases q with
        | unary op => rw [primEvalR_replayed P K env (by rfl) xs] at hp; cases hp
        | _ => simp [replayedExp?] at hcls
      | _ => rw [hr] at hcls; simp [replayedExp?] at hcls
  · cases hc : closureLeaves kind g i with
    | none => rfl
    | some x =>
      exfalso
      unfold closureLeaves at hc
      rw [hg, Option.bind_some] at hc
      obtain ⟨c, q, hr, hq⟩ := closureAux_root kind nd _ hc
      rw [hr, primEvalR_replayed P K env hq xs] at hp
      cases hp

/-- A closure's root is a multiply or an astype; a compute_g's is an `exp`. -/
theorem closure_not_cg {g : Nat → Option (RNode Int κ)} {i : Nat} {x : Compiled × List Nat} {l : List Nat}
    (h1 : closureLeaves kind g i = some x) (h2 : cgLeaves g i = some l) : False := by
  unfold closureLeaves at h1
  unfold cgLeaves at h2
  obtain ⟨r, hr, h1⟩ := Option.bind_eq_some_iff.mp h1
  rw [hr, Option.bind_some] at h2
  simp only [cgAux, Option.bind_eq_bind, Option.bind_eq_some_iff] at h2
  obtain ⟨cls, hcls, -⟩ := h2
  cases hp : r.prim with
  | replayed c q =>
    rw [hp] at hcls
    cases q with
    | unary op =>
      unfold closureAux at h1
      rw [hp] at h1
      simp only [elementwise, ↓reduceIte] at h1
      unfold closureBody at h1
      simp only [Option.bind_eq_bind, Option.bind_eq_some_iff] at h1
      obtain ⟨k, _, h⟩ := h1
      clear hcls hr hp
      cases k <;> simp at h
    | _ => simp [replayedExp?] at hcls
  | _ => rw [hp] at hcls; simp [replayedExp?] at hcls

/-- **A prefix-keeping graph keeps its nodes' values.** `Gx` below `n` is `Gy`'s, and a recorded value holds in `Gy`. -/
theorem evalZ_grow_graph {Gx Gy : Nat → Option (RNode Int κ)} {n : Nat}
    (hnode : ∀ j nd, j < n → Gx j = some nd → Gy j = some nd)
    (hZ : ∀ j v, Z j = some v → evalZ P K env kind Z Gy j = some v) :
    ∀ i v, i < n → evalZ P K env kind Z Gx i = some v → evalZ P K env kind Z Gy i = some v := by
  intro i
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  intro v hi hv
  rw [evalZ_struct] at hv
  cases hs : structZ P K env kind Z Gx i with
  | none =>
    rw [hs] at hv
    exact hZ i v hv
  | some w =>
    rw [hs] at hv
    have hwv : w = v := by simpa [Option.orElse] using hv
    subst hwv
    rw [evalZ_struct]
    suffices h : structZ P K env kind Z Gy i = some w by rw [h]; rfl
    have hargs : ∀ (l : List Nat) (ys : List Value),
        (l.mapM fun j => if _h : j < i then evalZ P K env kind Z Gx j else none) = some ys →
        (l.mapM fun j => if _h : j < i then evalZ P K env kind Z Gy j else none) = some ys := by
      intro l ys hl
      refine mapM_some_mono l _ _ (fun j _ y hy => ?_) hl
      by_cases hj : j < i
      · simp only [hj, ↓reduceDIte] at hy ⊢
        exact ih j hj y (by omega) hy
      · simp only [hj, ↓reduceDIte] at hy; cases hy
    let B : Nat → Option (RNode Int κ) := fun j => if j < n then Gx j else none
    have hB : ∀ j, j ≤ i → B j = Gx j := fun j hj => by simp only [B, show j < n by omega, ↓reduceIte]
    have emb : Embeds (fun j => j) (fun h => h) B Gy := by
      refine ⟨fun j r hr => ?_, fun _ _ _ h => h⟩
      have hj : j < n := by
        by_contra hj
        simp [B, hj] at hr
      simp only [B, hj, ↓reduceIte] at hr
      rw [renameN_self]
      exact hnode j r hj hr
    have hread : (fun j => if j < i then B j else none) = fun j => if j < i then Gx j else none := by
      funext j
      by_cases hj : j < i
      · simp only [hj, ↓reduceIte, hB j (by omega)]
      · simp only [hj, ↓reduceIte]
    have hcgB : cgLeaves B i = cgLeaves Gx i := cgLeaves_congr _ _ i hB
    have hclB : closureLeaves kind B i = closureLeaves kind Gx i := by
      unfold closureLeaves
      rw [hB i (Nat.le_refl i), hread]
    unfold structZ at hs ⊢
    cases hg : Gx i with
    | none => rw [hg] at hs; cases hs
    | some nd =>
      rw [hg] at hs
      dsimp only at hs
      rw [hnode i nd hi hg]
      dsimp only
      cases hc : cgLeaves Gx i with
      | some leaves =>
        rw [hc] at hs
        dsimp only at hs
        have hcy := cgLeaves_embed B Gy emb i leaves (hcgB.trans hc)
        simp only [List.map_id'] at hcy
        rw [hcy]
        dsimp only
        obtain ⟨xs, hxs, hcv⟩ := Option.bind_eq_some_iff.mp hs
        rw [hargs leaves xs hxs, Option.bind_some, hcv]
      | none =>
        rw [hc] at hs
        dsimp only at hs
        cases hk : closureLeaves kind Gx i with
        | some x =>
          obtain ⟨cc, leaves⟩ := x
          rw [hk] at hs
          dsimp only at hs
          have hky := closureLeaves_embed kind kind (fun _ => rfl) B Gy emb i (cc, leaves) (hclB.trans hk)
          simp only [List.map_id'] at hky
          obtain ⟨xs, hxs, hcv⟩ := Option.bind_eq_some_iff.mp hs
          have hnc : cgLeaves Gy i = none := by
            cases hcg : cgLeaves Gy i with
            | none => rfl
            | some l =>
              exfalso
              -- a closure root is elementwise and a compute_g root is `exp`: they are told apart by the body
              exact closure_not_cg kind hky hcg
          rw [hnc]
          dsimp only
          rw [hky]
          dsimp only
          rw [hargs leaves xs hxs, Option.bind_some, hcv]
        | none =>
          rw [hk] at hs
          dsimp only at hs
          obtain ⟨xs, hxs, hp⟩ := Option.bind_eq_some_iff.mp hs
          obtain ⟨hnc, hnk⟩ := no_pattern_of_prim P K env kind hp (hnode i nd hi hg)
          rw [hnc]
          dsimp only
          rw [hnk]
          dsimp only
          rw [hargs nd.ins xs hxs, Option.bind_some, hp]

end

section
variable {x y : Ffi.St}

theorem routeKernelName_grow (hg : NGrow x y) (S : KernelSources) (k : Nat) (name : List Char)
    (hk : routeKernelName? S x k = some name) : routeKernelName? S y k = some name := by
  unfold routeKernelName? at hk ⊢
  cases ho : x.obj? k with
  | none => rw [ho] at hk; cases hk
  | some o =>
    rw [ho] at hk
    cases o with
    | kernel nm sc hd a b =>
      rw [show y.obj? k = some (.kernel nm sc hd a b) from hg.kernels k _ ho ⟨nm, sc, hd, a, b, rfl⟩]
      exact hk
    | _ => cases hk

/-- Growth keeps the route graph's nodes below the counter. -/
theorem ffiGraphR_grow {κ : Type} (N : Nums Int) (S : KernelSources) (hg : NGrow x y) (j : Nat) (nd : RNode Int κ)
    (hj : j < x.nnext) (h : ffiGraphR N S x j = some nd) : ffiGraphR N S y j = some nd := by
  unfold ffiGraphR at h ⊢
  obtain ⟨n, hn, hr⟩ := Option.bind_eq_some_iff.mp h
  rw [hg.nodes j hj, hn, Option.bind_some]
  unfold resolveNodeP at hr ⊢
  obtain ⟨q, hq, rfl⟩ := Option.map_eq_some_iff.mp hr
  rw [resolvePrimP_mono N (routeKernelName_grow hg S) _ _ _ q hq]
  rfl

end

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
  (env : FfiEval.Env InKey) (kind : Nat → Option Compiled)

/-- **The route's values**: `evalZ` on `ffiGraphR`, with the recorded values `Z`. -/
noncomputable def routeVals (Z : List F64 → Nat → Option Value) : Vals where
  val tab x := routeVal P KR env kind (Z tab) tab x
  Ok x := ∀ y, NGrow x y → ∀ tab j v, Z tab j = some v → routeVal P KR env kind (Z tab) tab y j = some v
  ok_grow h hg := fun z hz => h z (hg.trans hz)
  val_grow {tab x y} hok hg i v hi hv := evalZ_grow_graph P KR env kind (Z tab)
    (fun j nd hj h => ffiGraphR_grow _ _ hg j nd hj h) (fun j w hw => hok y hg tab j w hw) i v hi hv

/-- With nothing recorded every state is fine, and the values are `evalRR`'s on `ffiGraphR`. -/
theorem routeVals_ok_empty (x : Ffi.St) : (routeVals P KR env kind fun _ _ => none).Ok x := by
  intro y _ tab j v h
  cases h

theorem routeVals_empty (tab : List F64) (x : Ffi.St) (i : Nat) :
    (routeVals P KR env kind fun _ _ => none).val tab x i = evalRR P KR env kind (GrR tab x) i :=
  evalZ_empty P KR env kind (GrR tab x) i

end

end Host.Mlx.SimGraph.Mach
