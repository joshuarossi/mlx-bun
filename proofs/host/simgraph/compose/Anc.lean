import host.mlx.ane.DepClosed
import host.simgraph.compose.Split
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx
open Host.Mlx.FfiAneEval (deps Anc)

/-! # Ancestors through a certificate

`srcAt_of` (host/mlx/ane/Forward.lean) needs every reader or writer among a fill source's ancestors in the
route's pure graph to be an earlier reader. A closure-aware match (`MatchesED`) pins the route's dependencies
of each carrier (`deps`: compute_g's or a named closure's leaves at a pattern root, else the arguments):

* `deps_carrier`: the dependencies of a non-input node's carrier are the carriers of its arguments (a plain
  carrier is neither a compute_g nor a closure root; a closure carrier is not a compute_g root);
* `anc_carrier`: when the input nodes' carriers are leaves (loads, readers, host data), every route ancestor
  of a carrier is the carrier of an ancestor in the expected graph (`AncE`). With the family's readback
  inputs the only inputs carried by readers, a fill source's touched ancestors are the carriers of the
  readback inputs among its expected ancestors — earlier splits' readers. -/

section
variable {κ : Type} [DecidableEq κ] (kind : Nat → Option Compiled) (G : Nat → Option (RNode Int κ))

/-- Node `k` and its arguments' ancestors in the expected graph. -/
inductive AncE (E : List (RNode Int κ)) (i : Nat) : Nat → Prop
  | self : AncE E i i
  | dep {j k : Nat} (hj : j < E.length) : AncE E i j → k ∈ E[j].ins → AncE E i k

omit [DecidableEq κ] in
theorem replayedExp_some {p : RPrim Int κ} {c : Nat} (h : replayedExp? p = some c) :
    p = .replayed c (.unary chars!"exp") := by
  unfold replayedExp? at h
  split at h
  · rename_i c' op
    by_cases he : op = chars!"exp"
    · subst he; simp at h; rw [h]
    · simp [he] at h
  · cases h

/-- **A carrier's dependencies are its node's arguments' carriers.** -/
theorem deps_carrier (E : List (RNode Int κ)) (cert : List Nat) (hm : MatchesED kind G E cert = true) (k : Nat)
    (hk : k < E.length) (hni : isInputD E[k].prim = false) :
    deps kind G (certAt cert k) = E[k].ins.map (certAt cert) := by
  have hok : nodeOkED kind G cert k E[k] = true := by
    have := List.all_eq_true.mp hm k (List.mem_range.mpr hk)
    rwa [List.getElem?_eq_getElem hk] at this
  generalize E[k] = e at hok hni ⊢
  simp only [nodeOkED, Bool.and_eq_true, hni, Bool.false_eq_true, ↓reduceIte] at hok
  obtain ⟨_, hrest⟩ := hok
  by_cases hc : e.prim = .computeG
  · rw [ite_eq_left hc] at hrest
    have hcg : cgLeaves G (certAt cert k) = some (e.ins.map (certAt cert)) := of_decide_eq_true hrest
    cases hg : G (certAt cert k) with
    | none => simp [cgLeaves, hg] at hcg
    | some nd => simp only [deps, hg, hcg]
  · rw [ite_eq_right hc] at hrest
    cases hcl : closureOf? e.prim with
    | some c =>
      simp only [closureCheck, hcl, Option.map_some, Option.getD_some, decide_eq_true_eq] at hrest
      rw [closureLeavesD_int] at hrest
      have hcg := closure_not_cg kind G (certAt cert k) hrest
      cases hg : G (certAt cert k) with
      | none => simp [closureLeaves, hg] at hrest
      | some nd => simp only [deps, hg, hcg, hrest]
    | none =>
      simp only [closureCheck, hcl, Option.map_none, Option.getD_none, plainCheck, Bool.and_eq_true,
        Bool.not_eq_true'] at hrest
      obtain ⟨hx, hg⟩ := hrest
      cases hr : G (certAt cert k) with
      | none => rw [hr] at hg; cases hg
      | some r =>
        rw [hr] at hg
        obtain ⟨hs, hor, hins⟩ := of_decide_eq_true hg
        have hcg : cgLeaves G (certAt cert k) = none := by
          refine cgLeaves_none G _ r hr ?_
          cases hp : replayedExp? r.prim with
          | none => rfl
          | some c =>
            exfalso
            have he : e.prim = .unary chars!"exp" := by rw [← hs, replayedExp_some hp]; rfl
            simp [isExpD, he] at hx
        have hcl' : closureLeaves kind G (certAt cert k) = none := by
          cases hq : closureLeaves kind G (certAt cert k) with
          | none => rfl
          | some x =>
            exfalso
            unfold closureLeaves at hq
            rw [hr, Option.bind_some] at hq
            obtain ⟨c, p, hp, hel⟩ := closureAux_root kind r _ hq
            rcases hor with hor | hor
            · rw [hp, ← hs, hp] at hor
              exact strip_not_replayed p c p hor.symm
            · rw [← hs, hp] at hor
              simp only [strip] at hor
              rw [elementwise_strip] at hor
              rw [hel] at hor; cases hor
        simp only [deps, hr, hcg, hcl', hins]

/-- **Every route ancestor of a carrier is the carrier of an expected ancestor**, when the input nodes' carriers
are leaves. -/
theorem anc_carrier (E : List (RNode Int κ)) (cert : List Nat) (hm : MatchesED kind G E cert = true)
    (hleaf : ∀ k (hk : k < E.length), isInputD E[k].prim = true → deps kind G (certAt cert k) = []) (i : Nat)
    (hi : i < E.length) : ∀ a, Anc kind G (certAt cert i) a → ∃ j, j < E.length ∧ AncE E i j ∧ certAt cert j = a := by
  intro a ha
  induction ha with
  | self => exact ⟨i, hi, .self, rfl⟩
  | @dep a' b _ hb ih =>
    obtain ⟨j, hj, hanc, rfl⟩ := ih
    cases hin : isInputD E[j].prim with
    | true => rw [hleaf j hj hin] at hb; cases hb
    | false =>
      rw [deps_carrier kind G E cert hm j hj hin] at hb
      obtain ⟨m, hmem, rfl⟩ := List.mem_map.mp hb
      have hlt : m < j := by
        have hok : nodeOkED kind G cert j E[j] = true := by
          have := List.all_eq_true.mp hm j (List.mem_range.mpr hj)
          rwa [List.getElem?_eq_getElem hj] at this
        simp only [nodeOkED, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at hok
        exact hok.1.1 m hmem
      exact ⟨m, by omega, .dep hj hanc hmem, rfl⟩

end

end Host.Mlx.SimGraph
