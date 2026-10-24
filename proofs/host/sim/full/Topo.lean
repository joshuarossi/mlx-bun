import host.sim.native.gen.Rel
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Node)

/-! # A recorded trace's order under the map

`traceBack` orders the nodes reachable from a trace's outputs down to its tracers (`Ffi.topo`).
Where the template's traversal succeeds over nodes that correspond fully (`Full P`), the
target's traverses the images in the same order (`MR.topo_map`). -/

/-- The traversal keeps what it has output and what it will output. -/
theorem topo_mem (x : NSt) (stop : List Nat) : ∀ (f : Nat) (st : List (Nat × Bool)) (seen out order : List Nat),
    Host.Mlx.Ffi.topo x stop f st seen out = some order →
      (∀ p ∈ st, p.2 = true → p.1 ∈ order) ∧ ∀ i ∈ out, i ∈ order
  | 0, _, _, _, _, h => by cases h
  | _ + 1, [], _, out, order, h => by
    simp only [Host.Mlx.Ffi.topo, Option.some.injEq] at h
    subst h
    exact ⟨fun _ hp => (by cases hp), fun i hi => List.mem_reverse.mpr hi⟩
  | f + 1, (n, true) :: st, seen, out, order, h => by
    have ih := topo_mem x stop f st seen (n :: out) order h
    refine ⟨fun p hp ht => ?_, fun i hi => ih.2 i (List.mem_cons_of_mem _ hi)⟩
    rcases List.mem_cons.mp hp with rfl | hp
    · exact ih.2 _ List.mem_cons_self
    · exact ih.1 p hp ht
  | f + 1, (n, false) :: st, seen, out, order, h => by
    unfold Host.Mlx.Ffi.topo at h
    cases hb : (seen.any (Nat.beq n) || stop.any (Nat.beq n))
    · rw [hb, Bool.cond_false] at h
      cases hn : x.nodes.get n with
      | none => rw [hn] at h; cases h
      | some nd =>
        rw [hn] at h
        have ih := topo_mem x stop f _ _ out order h
        refine ⟨fun p hp ht => ?_, ih.2⟩
        rcases List.mem_cons.mp hp with rfl | hp
        · cases ht
        · exact ih.1 p (List.mem_append_right _ (List.mem_cons_of_mem _ hp)) ht
    · rw [hb, Bool.cond_true] at h
      have ih := topo_mem x stop f st seen out order h
      refine ⟨fun p hp ht => ?_, ih.2⟩
      rcases List.mem_cons.mp hp with rfl | hp
      · cases ht
      · exact ih.1 p hp ht

section
variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : MR P NB M n x y)
include hr

theorem MR.any_node {l : List Nat} {k : Nat} (hl : ∀ i ∈ l, PN x i) (hk : PN x k) :
    (l.map M.node).any (Nat.beq (M.node k)) = l.any (Nat.beq k) := by
  induction l with
  | nil => rfl
  | cons a l ih =>
    simp only [List.map_cons, List.any_cons]
    rw [ih fun i hi => hl i (List.mem_cons_of_mem _ hi)]
    congr 1
    have ha := hl a List.mem_cons_self
    by_cases e : k = a
    · subst e; simp
    · have e' : M.node k ≠ M.node a := fun h => e (hr.ninj k a hk ha h)
      have h1 : Nat.beq (M.node k) (M.node a) = false := Bool.eq_false_iff.mpr fun h => e' (Nat.eq_of_beq_eq_true h)
      have h2 : Nat.beq k a = false := Bool.eq_false_iff.mpr fun h => e (Nat.eq_of_beq_eq_true h)
      rw [h1, h2]

/-- **The order under the map**: where the template's traversal succeeds over fully corresponding
nodes, the target's gives the images. -/
theorem MR.topo_map {stop : List Nat} (hstop : ∀ i ∈ stop, PN x i) :
    ∀ (f : Nat) (st : List (Nat × Bool)) (seen out order : List Nat),
      (∀ i ∈ seen, PN x i) → (∀ i ∈ out, PN x i) → (∀ p ∈ st, p.2 = true → PN x p.1) →
      Host.Mlx.Ffi.topo x stop f st seen out = some order → (∀ i ∈ order, Full P i) →
      Host.Mlx.Ffi.topo y (stop.map M.node) f (st.map fun p => (M.node p.1, p.2)) (seen.map M.node)
        (out.map M.node) = some (order.map M.node)
  | 0, _, _, _, _, _, _, _, h, _ => by cases h
  | _ + 1, [], _, out, order, _, _, _, h, _ => by
    simp only [Host.Mlx.Ffi.topo, Option.some.injEq] at h
    subst h
    show some (List.map M.node out).reverse = some (List.map M.node out.reverse)
    rw [List.map_reverse]
  | f + 1, (k, true) :: st, seen, out, order, hseen, hout, hst, h, hfull => by
    have hk : PN x k := hst _ List.mem_cons_self rfl
    have := MR.topo_map hstop f st seen (k :: out) order hseen
      (fun i hi => by rcases List.mem_cons.mp hi with rfl | hi; exact hk; exact hout i hi)
      (fun p hp ht => hst p (List.mem_cons_of_mem _ hp) ht) h hfull
    exact this
  | f + 1, (k, false) :: st, seen, out, order, hseen, hout, hst, h, hfull => by
    have hmem := topo_mem x stop (f + 1) _ seen out order h
    unfold Host.Mlx.Ffi.topo at h ⊢
    cases hb : (seen.any (Nat.beq k) || stop.any (Nat.beq k))
    · rw [hb, Bool.cond_false] at h
      cases hn : x.nodes.get k with
      | none => rw [hn] at h; cases h
      | some nd =>
        rw [hn] at h
        have hk : PN x k := by unfold PN; rw [hn]; rfl
        have hb' : ((seen.map M.node).any (Nat.beq (M.node k)) || (stop.map M.node).any (Nat.beq (M.node k))) =
            false := by rw [hr.any_node hseen hk, hr.any_node hstop hk]; exact hb
        simp only [List.map_cons]
        rw [hb', Bool.cond_false]
        have hko : k ∈ order := (topo_mem x stop f _ _ out order h).1 (k, true)
          (List.mem_append_right _ List.mem_cons_self) rfl
        obtain ⟨nd', hn', hnr⟩ := hr.nodes k nd hn
        have hins := (hnr.2.2.2 (hfull k hko)).2
        rw [hn']
        dsimp only
        have := MR.topo_map hstop f (nd.ins.map (·, false) ++ (k, true) :: st) (k :: seen) out order
          (fun i hi => by rcases List.mem_cons.mp hi with rfl | hi; exact hk; exact hseen i hi) hout
          (fun p hp ht => by
            rcases List.mem_append.mp hp with hp | hp
            · obtain ⟨i, -, rfl⟩ := List.mem_map.mp hp; cases ht
            · rcases List.mem_cons.mp hp with rfl | hp
              · exact hk
              · exact hst p (List.mem_cons_of_mem _ hp) ht) h hfull
        simp only [List.map_append, List.map_map, List.map_cons] at this
        rw [hins, List.map_map]
        exact this
    · rw [hb, Bool.cond_true] at h
      have hk : PN x k := by
        simp only [Bool.or_eq_true, List.any_eq_true] at hb
        rcases hb with ⟨i, hi, hki⟩ | ⟨i, hi, hki⟩ <;> obtain rfl := Nat.eq_of_beq_eq_true hki
        · exact hseen _ hi
        · exact hstop _ hi
      have hb' : ((seen.map M.node).any (Nat.beq (M.node k)) || (stop.map M.node).any (Nat.beq (M.node k))) =
          true := by rw [hr.any_node hseen hk, hr.any_node hstop hk]; exact hb
      simp only [List.map_cons]
      rw [hb', Bool.cond_true]
      exact MR.topo_map hstop f st seen out order hseen hout
        (fun p hp ht => hst p (List.mem_cons_of_mem _ hp) ht) h hfull

end

end Host.Ts.Sim.G
