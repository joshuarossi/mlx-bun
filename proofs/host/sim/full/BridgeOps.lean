import host.sim.full.BridgeA

/-! # The bridge's own calls under the map

`mbane_input`, `mbane_output`, `mbane_eval_async`, `mbane_wait` and `mbane_free` read the bridge's
programs and handles, which the map keeps, and the running readers and writers with their touches,
which it renames (`runningClash_rel`); they change programs and prepend program effects to the log.
On related bridge states each gives related results with the same return (`BRel.input`, …). -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim
open Host.Mlx.FfiAne (Program Effect)

section
variable {M : Map} {nx ny : Nat} {b b' : BSt}

theorem BRel.program? (h : BRel M nx ny b b') (n : Nat) : Host.Mlx.FfiAne.program? b' n = Host.Mlx.FfiAne.program? b n := by
  unfold Host.Mlx.FfiAne.program?
  rw [h.handles, h.programs]

theorem BRel.setProgram (h : BRel M nx ny b b') (q : Nat) (p : Program) :
    BRel M nx ny (Host.Mlx.FfiAne.setProgram b q p) (Host.Mlx.FfiAne.setProgram b' q p) :=
  { h with programs := by show Host.Mlx.Ffi.setAt b'.programs q p = Host.Mlx.Ffi.setAt b.programs q p; rw [h.programs] }

theorem BRel.logCons (h : BRel M nx ny b b') (e : Effect) (he : M.effect e = e) :
    BRel M nx ny { b with log := e :: b.log } { b' with log := e :: b'.log } :=
  { h with log := by show e :: b'.log = (e :: b.log).map M.effect; rw [h.log, List.map_cons, he] }

theorem BRel.touchOf (h : BRel M nx ny b b') {n : Nat} (hn : n < nx) :
    b'.touchOf (M.node n) = b.touchOf n := h.touch n hn

theorem BRel.runningClash (h : BRel M nx ny b b') (X : Nat) (w : Bool) :
    Host.Mlx.FfiAne.runningClash b' X w = Host.Mlx.FfiAne.runningClash b X w := by
  unfold Host.Mlx.FfiAne.runningClash
  rw [h.running, List.any_map]
  refine any_congr_mem fun r hr => ?_
  show (match b'.touchOf (M.node r) with
    | some t => Host.Mlx.FfiAne.memN X t.sids && (w || t.writes)
    | none => false) = _
  rw [h.touchOf (h.queued r (List.mem_append_right _ hr))]
  rfl

theorem BRel.startOk (h : BRel M nx ny b b') (q : Nat) (p : Program) :
    Host.Mlx.FfiAne.startOk b' q p = Host.Mlx.FfiAne.startOk b q p := by
  unfold Host.Mlx.FfiAne.startOk
  simp only [h.runningClash, h.programs]

theorem BRel.pendingClash (h : BRel M nx ny b b') (X : Nat) (w : Bool) :
    Host.Mlx.FfiAne.pendingClash b' X w = Host.Mlx.FfiAne.pendingClash b X w := by
  unfold Host.Mlx.FfiAne.pendingClash; rw [h.programs]

theorem BRel.eventOk (h : BRel M nx ny b b') (l : List Nat) (hl : ∀ n ∈ l, n < nx) :
    Host.Mlx.FfiAne.eventOk b' (l.map M.node) = Host.Mlx.FfiAne.eventOk b l := by
  unfold Host.Mlx.FfiAne.eventOk
  rw [List.all_map]
  refine all_congr_mem fun t ht => ?_
  show (match b'.touchOf (M.node t) with
    | some k => k.sids.all fun X => !Host.Mlx.FfiAne.pendingClash b' X k.writes &&
        !Host.Mlx.FfiAne.runningClash b' X k.writes &&
        (!k.writes || Nat.beq (Host.Ts.len ((l.map M.node).filter fun u => match b'.touchOf u with
          | some k' => Host.Mlx.FfiAne.memN X k'.sids
          | none => false)) 1)
    | none => false) = _
  rw [h.touchOf (hl t ht)]
  cases b.touchOf t with
  | none => rfl
  | some k =>
    simp only []
    refine all_congr_mem fun X _ => ?_
    rw [h.pendingClash, h.runningClash, List.filter_map, Native.len_map]
    congr 3
    congr 1
    exact List.filter_congr fun u hu => by
      show (match b'.touchOf (M.node u) with
        | some k' => Host.Mlx.FfiAne.memN X k'.sids
        | none => false) = _
      rw [h.touchOf (hl u hu)]
      rfl


theorem BRel.input (h : BRel M nx ny b b') {n : Nat} {i : Arg} {b1 : BSt} {r : Ret}
    (e : Host.Mlx.FfiAne.input b n i = some (b1, r)) :
    ∃ b1', Host.Mlx.FfiAne.input b' n i = some (b1', r) ∧ BRel M nx ny b1 b1' := by
  unfold Host.Mlx.FfiAne.input at e ⊢
  rw [h.program? n]
  cases hp : Host.Mlx.FfiAne.program? b n with
  | none => rw [hp] at e; cases e
  | some qp =>
    obtain ⟨q, p⟩ := qp
    cases hi : Host.Mlx.Ffi.argInt i with
    | none => rw [hp, hi] at e; cases e
    | some k =>
      rw [hp, hi] at e
      simp only [] at e ⊢
      cases hc : (decide (0 ≤ k) && Nat.blt k.toNat (Host.Ts.len p.ins))
      · rw [hc, Bool.cond_false] at e; rw [Bool.cond_false]
        cases e
        exact ⟨b', rfl, h⟩
      · rw [hc, Bool.cond_true] at e; rw [Bool.cond_true]
        cases e
        exact ⟨_, rfl, h.setProgram _ _⟩

theorem BRel.output (h : BRel M nx ny b b') {n : Nat} {b1 : BSt} {r : Ret}
    (e : Host.Mlx.FfiAne.output b n = some (b1, r)) :
    ∃ b1', Host.Mlx.FfiAne.output b' n = some (b1', r) ∧ BRel M nx ny b1 b1' := by
  unfold Host.Mlx.FfiAne.output at e ⊢
  rw [h.program? n]
  cases hp : Host.Mlx.FfiAne.program? b n with
  | none => rw [hp] at e; cases e
  | some qp =>
    rw [hp] at e
    obtain ⟨q, p⟩ := qp
    cases e
    exact ⟨_, rfl, h.setProgram _ _⟩

theorem BRel.evalAsync (h : BRel M nx ny b b') {n : Nat} {b1 : BSt} {r : Ret}
    (e : Host.Mlx.FfiAne.evalAsync b n = some (b1, r)) :
    ∃ b1', Host.Mlx.FfiAne.evalAsync b' n = some (b1', r) ∧ BRel M nx ny b1 b1' := by
  unfold Host.Mlx.FfiAne.evalAsync at e ⊢
  rw [h.program? n]
  cases hp : Host.Mlx.FfiAne.program? b n with
  | none => rw [hp] at e; cases e
  | some qp =>
    rw [hp] at e
    obtain ⟨q, p⟩ := qp
    simp only [] at e ⊢
    cases hpe : p.pending
    · rw [hpe, Bool.cond_false] at e; rw [Bool.cond_false]
      rw [h.startOk q p]
      cases hs : Host.Mlx.FfiAne.startOk b q p
      · rw [hs, Bool.cond_false] at e; cases e
      · rw [hs, Bool.cond_true] at e; rw [Bool.cond_true]
        cases e
        exact ⟨_, rfl, (h.setProgram _ _).logCons _ rfl⟩
    · rw [hpe, Bool.cond_true] at e; rw [Bool.cond_true]
      cases e
      exact ⟨b', rfl, h⟩

theorem BRel.wait (h : BRel M nx ny b b') {n : Nat} {b1 : BSt} {r : Ret}
    (e : Host.Mlx.FfiAne.wait b n = some (b1, r)) :
    ∃ b1', Host.Mlx.FfiAne.wait b' n = some (b1', r) ∧ BRel M nx ny b1 b1' := by
  unfold Host.Mlx.FfiAne.wait at e ⊢
  rw [h.program? n]
  cases hp : Host.Mlx.FfiAne.program? b n with
  | none => rw [hp] at e; cases e
  | some qp =>
    rw [hp] at e
    obtain ⟨q, p⟩ := qp
    simp only [] at e ⊢
    cases hpe : p.pending
    · rw [hpe, Bool.cond_false] at e; rw [Bool.cond_false]
      cases e
      exact ⟨b', rfl, h⟩
    · rw [hpe, Bool.cond_true] at e; rw [Bool.cond_true]
      cases e
      exact ⟨_, rfl, (h.setProgram _ _).logCons _ rfl⟩

theorem BRel.free (h : BRel M nx ny b b') {n : Nat} {b1 : BSt} {r : Ret}
    (e : Host.Mlx.FfiAne.free b n = some (b1, r)) :
    ∃ b1', Host.Mlx.FfiAne.free b' n = some (b1', r) ∧ BRel M nx ny b1 b1' := by
  unfold Host.Mlx.FfiAne.free at e ⊢
  rw [h.program? n]
  cases hp : Host.Mlx.FfiAne.program? b n with
  | none => rw [hp] at e; cases e
  | some qp =>
    rw [hp] at e
    obtain ⟨q, p⟩ := qp
    simp only [Option.map_some, Option.some.injEq] at e ⊢
    cases hh : Nat.beq p.holders 1
    · rw [hh, Bool.cond_false] at e; rw [Bool.cond_false]
      cases e
      exact ⟨_, rfl, h.setProgram _ _⟩
    · rw [hh, Bool.cond_true] at e; rw [Bool.cond_true]
      cases e
      refine ⟨_, rfl, ?_⟩
      cases hpe : p.pending
      · simp only [Bool.cond_false]
        exact { h.setProgram q _ with log := h.log }
      · simp only [Bool.cond_true]
        exact (h.setProgram q _).logCons _ rfl

end

end Host.Ts.Sim.Full
