import host.mlx.FfiAneEval
namespace Host.Mlx.FfiAneEval
open Inference.Contracts.Mlx
open Host.Mlx.FfiEval

/-! # A pure value depends only on its dependencies

`pureVal_congr` (FfiAneEval.lean) makes a pure value depend on every fixed
value at or below the node. Over a whole Neural Engine forward that is too
coarse: a split's sources lie above readers that have not run yet when the
split's fills run (aneAffine's z split fills above the qkv split's reader,
which runs with the out split's fills), and the semantics has given those
readers no value then. Here a value depends only on the nodes it is computed
from (`deps`: compute_g's or a named closure's leaves at a pattern root, else
the inputs, as `evalRR` recurses), transitively (`Anc`):

* `evalRR_congrOn`: on a dependency-closed set (`DepClosed`) the route
  evaluation reads the environment only through the set's primitives;
* `pureVal_congrOn`: on the pure graph (readers and writers are leaves, so a
  closed set stops at them) a pure value depends only on the fixed values of
  the readers and writers among its ancestors. -/

section
variable {κ : Type} [DecidableEq κ] (kind : Nat → Option Compiled) (g : Nat → Option (RNode Int κ))

/-- The nodes `evalRR` computes node `i` from. -/
def deps (i : Nat) : List Nat :=
  match g i with
  | none => []
  | some nd => match cgLeaves g i with
    | some leaves => leaves
    | none => match closureLeaves kind g i with
      | some (_, leaves) => leaves
      | none => nd.ins

/-- `S` holds every dependency of its members. -/
def DepClosed (S : Nat → Prop) : Prop := ∀ i, S i → ∀ j ∈ deps kind g i, S j

/-- Node `i` and the nodes it is computed from, transitively. -/
inductive Anc (i : Nat) : Nat → Prop
  | self : Anc i i
  | dep {j k : Nat} : Anc i j → k ∈ deps kind g j → Anc i k

theorem anc_closed (i : Nat) : DepClosed kind g (Anc kind g i) := fun _ hj _ hk => .dep hj hk

/-- A leaf (an input-free node outside the compute_g and closure patterns) has no dependencies. -/
theorem deps_leaf (i : Nat) (p : RPrim Int κ) (hg : g i = some ⟨p, []⟩) (hc : cgLeaves g i = none)
    (hl : closureLeaves kind g i = none) : deps kind g i = [] := by
  simp [deps, hg, hc, hl]

end

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} [DecidableEq κ]
  (kind : Nat → Option Compiled)

/-- **The route evaluation on a dependency-closed set** reads the environment only through the set's primitives. -/
theorem evalRR_congrOn (g : Nat → Option (RNode Int κ)) (env env' : Env κ) (S : Nat → Prop) (hS : DepClosed kind g S)
    (hp : ∀ i, S i → ∀ nd, g i = some nd → ∀ xs, primEvalR P K env nd.prim xs = primEvalR P K env' nd.prim xs) :
    ∀ i, S i → evalRR P K env kind g i = evalRR P K env' kind g i := by
  intro i
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  intro hi
  have hargs : ∀ l : List Nat, (∀ j ∈ l, S j) →
      (l.mapM fun j => if _h : j < i then evalRR P K env kind g j else none) =
      (l.mapM fun j => if _h : j < i then evalRR P K env' kind g j else none) := fun l hl =>
    mapM_congr' l _ _ fun j hj => by
      by_cases hji : j < i
      · simp only [hji, ↓reduceDIte]; exact ih j hji (hl j hj)
      · simp only [hji, ↓reduceDIte]
  have hd := hS i hi
  rw [evalRR_eq, evalRR_eq]
  cases hg : g i with
  | none => rfl
  | some nd =>
    simp only [deps, hg] at hd
    dsimp only
    cases hc : cgLeaves g i with
    | some leaves =>
      simp only [hc] at hd
      dsimp only
      rw [hargs leaves hd]
    | none =>
      simp only [hc] at hd
      dsimp only
      cases hcl : closureLeaves kind g i with
      | some x =>
        obtain ⟨c, leaves⟩ := x
        simp only [hcl] at hd
        dsimp only
        rw [hargs leaves hd]
      | none =>
        simp only [hcl] at hd
        dsimp only
        rw [hargs nd.ins hd]
        congr 1
        funext xs
        exact hp i hi nd hg xs

variable (weights : List Char → List Char → Option Value) (G : Graph)

/-- **A pure value depends only on its ancestors' fixed values**: on a set closed under the pure graph's
dependencies (it stops at readers and writers, leaves there), two memories agreeing on the fixed values of the
set's readers and writers give its members the same pure value. -/
theorem pureVal_congrOn (hG : ∀ j nd, G.node j = some nd → noInput nd.prim = true) (S : Nat → Prop)
    (hS : DepClosed kind G.pure S) (m m' : Mem) (hv : ∀ j, S j → (G.touch j).isSome = true → m.vals j = m'.vals j) :
    ∀ i, S i → pureVal P K weights kind G m i = pureVal P K weights kind G m' i := by
  intro i hi
  unfold pureVal
  refine evalRR_congrOn P K kind G.pure _ _ S hS (fun j hj nd hnd xs => ?_) i hi
  unfold Graph.pure at hnd
  by_cases ht : (G.touch j).isSome = true
  · simp only [ht, ↓reduceIte] at hnd
    cases hnd
    cases xs <;> simp [primEvalR, prefillEval, Option.orElse, primEvalP, primEval, rowsEval, Mem.env, hv j hj ht]
  · simp only [ht] at hnd
    exact primEvalR_env P K weights m.vals m'.vals nd.prim xs (hG j nd hnd)

/-- A reader or writer is a leaf of the pure graph: an ancestor set stops there. -/
theorem deps_pure_touched (j : Nat) (ht : (G.touch j).isSome = true) : deps kind G.pure j = [] := by
  have hp : G.pure j = some ⟨.input j, []⟩ := by simp [Graph.pure, ht]
  refine deps_leaf kind G.pure j _ hp (cgLeaves_none G.pure j _ hp rfl) ?_
  simp [closureLeaves, hp, closureAux]

/-- **Pure values from their ancestors**: two memories agreeing on the fixed values of the readers and writers
among `i`'s ancestors give `i` the same pure value. -/
theorem pureVal_congrAnc (hG : ∀ j nd, G.node j = some nd → noInput nd.prim = true) (m m' : Mem) (i : Nat)
    (hv : ∀ j, Anc kind G.pure i j → (G.touch j).isSome = true → m.vals j = m'.vals j) :
    pureVal P K weights kind G m i = pureVal P K weights kind G m' i :=
  pureVal_congrOn P K kind weights G hG _ (anc_closed kind G.pure i) m m' hv i .self

end

end Host.Mlx.FfiAneEval
