import host.sim.full.BridgeClassify

/-! # Scheduling an evaluation under the map

An evaluation (`FfiAne.schedule`) walks the graph from its roots down to the oldest unscheduled or
running reader or writer (`reachOf`: nodes at or above it, each pushed once) and starts the
unscheduled ones it reaches. On related states the target walks the images (`BRel.reach`): the
renaming is strictly monotone below the template's node counter (every node fully corresponds), so
it keeps the comparisons with the bound (`minL`, `pushIns`), and it is injective there, so it keeps
the visited set. The walk only follows inputs below the counter where the template's walk checks
it (`reachOk`, decided on the template). The ordering checks read the touches and the programs,
which the relation keeps (`BRel.eventOk`), and the target's bridge after it is the template's
renamed (`BRel.schedule`). -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim
open Host.Mlx.FfiAne (pushIns reach reachOf minL)

/-- The template's walk, checked: every node it expands has its inputs below the node counter. -/
def reachOk (s : Host.Mlx.Ffi.St) (lo : Nat) : Nat → List Nat → PTrie Bool → Bool
  | 0, _, _ => true
  | _ + 1, [], _ => true
  | f + 1, n :: st, seen => match s.nodes.get n with
    | some nd => nd.ins.all (fun i => Nat.blt i s.nnext) &&
        reachOk s lo f (pushIns lo nd.ins st seen).1 (pushIns lo nd.ins st seen).2
    | none => reachOk s lo f st seen

/-- An evaluation's walk, checked (`schedOk`), unless the evaluation starts nothing. -/
def schedOk (b : BSt) (s : Host.Mlx.Ffi.St) (roots : List Nat) : Bool :=
  roots.all (fun i => Nat.blt i s.nnext) && match b.unscheduled ++ b.running with
  | [] => true
  | t :: ts => reachOk s (minL t ts) (s.nnext + Host.Ts.len roots + 1) (pushIns (minL t ts) roots [] .nil).1
      (pushIns (minL t ts) roots [] .nil).2

/-- Visited sets under the map, below the template's node counter. -/
def SeenR (M : Map) (X : Nat) (seen seen' : PTrie Bool) : Prop := ∀ n, n < X → seen'.get (M.node n) = seen.get n

section
variable {P : LoadP} {NB : Nat} {M : Map} {k : Nat} {x y : NSt} (hr : G.MR P NB M k x y)
  (hF : ∀ i, Full P i) (hd : ∀ i, i < x.nnext → PN x i)
include hr hF hd

theorem minL_map : ∀ (m : Nat) (l : List Nat), m < x.nnext → (∀ i ∈ l, i < x.nnext) →
    minL (M.node m) (l.map M.node) = M.node (minL m l)
  | _, [], _, _ => rfl
  | m, i :: l, hm, hl => by
    have hi := hl i List.mem_cons_self
    simp only [List.map_cons, minL]
    have e : Nat.blt (M.node i) (M.node m) = Nat.blt i m := by
      rw [Bool.eq_iff_iff, Nat.blt_eq, Nat.blt_eq]; exact (hr.bnode_mono hF hd hi hm).symm
    rw [e]
    have hm' : (bif Nat.blt i m then i else m) < x.nnext := by cases Nat.blt i m <;> assumption
    have := minL_map (bif Nat.blt i m then i else m) l hm' fun j hj => hl j (List.mem_cons_of_mem _ hj)
    cases hc : Nat.blt i m <;> rw [hc] at this <;> exact this

theorem SeenR.set {seen seen' : PTrie Bool} (h : SeenR M x.nnext seen seen') {i : Nat} (hi : i < x.nnext) :
    SeenR M x.nnext (seen.set i true) (seen'.set (M.node i) true) := by
  intro n hn
  by_cases e : n = i
  · subst e
    rw [get_set_eq_of_lt _ _ (hr.bnode_lt62 hF hd hn), get_set_eq_of_lt _ _ (by have := hr.xnnext_lt; omega)]
  · have e' : M.node n ≠ M.node i := fun h' => e (hr.bnode_inj hF hd hn hi h')
    rw [PTrie.get_set_ne' _ _ _ _ e', PTrie.get_set_ne' _ _ _ _ e]
    exact h n hn

theorem pushIns_rel {lo : Nat} (hlo : lo < x.nnext) : ∀ (is st : List Nat) {seen seen' : PTrie Bool},
    (∀ i ∈ is, i < x.nnext) → SeenR M x.nnext seen seen' →
      (pushIns (M.node lo) (is.map M.node) (st.map M.node) seen').1 = (pushIns lo is st seen).1.map M.node ∧
      SeenR M x.nnext (pushIns lo is st seen).2 (pushIns (M.node lo) (is.map M.node) (st.map M.node) seen').2 ∧
      ∀ n ∈ (pushIns lo is st seen).1, n ∈ st ∨ n ∈ is
  | [], st, _, _, _, h => ⟨rfl, h, fun n hn => .inl hn⟩
  | i :: is, st, seen, seen', hi, h => by
    have hi0 := hi i List.mem_cons_self
    have his : ∀ j ∈ is, j < x.nnext := fun j hj => hi j (List.mem_cons_of_mem _ hj)
    simp only [List.map_cons, pushIns]
    have e1 : Nat.blt (M.node i) (M.node lo) = Nat.blt i lo := by
      rw [Bool.eq_iff_iff, Nat.blt_eq, Nat.blt_eq]; exact (hr.bnode_mono hF hd hi0 hlo).symm
    rw [e1, h i hi0]
    cases hc : (Nat.blt i lo || (seen.get i).isSome)
    · simp only [Bool.cond_false]
      have := pushIns_rel hlo is (i :: st) his (h.set hr hF hd hi0)
      simp only [List.map_cons] at this
      refine ⟨this.1, this.2.1, fun n hn => ?_⟩
      rcases this.2.2 n hn with e | e
      · rcases List.mem_cons.mp e with rfl | e
        · exact .inr List.mem_cons_self
        · exact .inl e
      · exact .inr (List.mem_cons_of_mem _ e)
    · simp only [Bool.cond_true]
      have := pushIns_rel hlo is st his h
      refine ⟨this.1, this.2.1, fun n hn => ?_⟩
      rcases this.2.2 n hn with e | e
      · exact .inl e
      · exact .inr (List.mem_cons_of_mem _ e)

/-- **The walk under the map**, with at least the template's fuel. -/
theorem reach_rel {lo : Nat} (hlo : lo < x.nnext) : ∀ (f : Nat) (st : List Nat) {seen seen' : PTrie Bool} {r : PTrie Bool},
    (∀ n ∈ st, n < x.nnext) → SeenR M x.nnext seen seen' → reachOk x lo f st seen = true →
      reach x lo f st seen = some r → ∀ f', f ≤ f' →
        ∃ r', reach y (M.node lo) f' (st.map M.node) seen' = some r' ∧ SeenR M x.nnext r r'
  | 0, _, _, _, _, _, _, _, e, _, _ => by cases e
  | f + 1, [], _, _, _, _, h, _, e, f', hf => by
    obtain ⟨g, rfl⟩ : ∃ g, f' = g + 1 := ⟨f' - 1, by omega⟩
    cases e
    exact ⟨_, rfl, h⟩
  | f + 1, n :: st, seen, seen', r, hst, h, hok, e, f', hf => by
    obtain ⟨g, rfl⟩ : ∃ g, f' = g + 1 := ⟨f' - 1, by omega⟩
    have hn := hst n List.mem_cons_self
    have hst' : ∀ m ∈ st, m < x.nnext := fun m hm => hst m (List.mem_cons_of_mem _ hm)
    obtain ⟨nd, hnd⟩ := Option.isSome_iff_exists.mp (hd n hn)
    obtain ⟨nd', hnd', hnr⟩ := hr.nodes n nd hnd
    have hins := (hnr.2.2.2 (hF n)).2
    unfold reachOk at hok
    rw [hnd] at hok
    dsimp only at hok
    rw [Bool.and_eq_true] at hok
    obtain ⟨hall, hok⟩ := hok
    have hall' : ∀ i ∈ nd.ins, i < x.nnext := fun i hi => by
      have := List.all_eq_true.mp hall i hi; rw [Nat.blt_eq] at this; exact this
    obtain ⟨p1, p2, p3⟩ := pushIns_rel hr hF hd hlo nd.ins st hall' h
    unfold reach at e
    rw [hnd] at e
    dsimp only at e
    generalize hp : pushIns lo nd.ins st seen = pp at e p1 p2 p3 hok
    obtain ⟨st1, seen1⟩ := pp
    dsimp only at e p1 p2 p3 hok
    have hst2 : ∀ m ∈ st1, m < x.nnext := fun m hm => by
      rcases p3 m hm with e | e
      · exact hst' m e
      · exact hall' m e
    obtain ⟨r', hr', hrr⟩ := reach_rel hlo f st1 hst2 p2 hok e g (by omega)
    refine ⟨r', ?_, hrr⟩
    rw [List.map_cons]
    unfold reach
    rw [hnd']
    dsimp only
    rw [hins]
    generalize hp' : pushIns (M.node lo) (nd.ins.map M.node) (st.map M.node) seen' = pp' at p1 p2 hr' ⊢
    obtain ⟨st1', seen1'⟩ := pp'
    dsimp only at p1 p2 hr' ⊢
    rw [p1]
    exact hr'

end

end Host.Ts.Sim.Full
