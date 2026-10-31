import host.sim.footprint.HeapBasic

namespace Host.Ts.Sim.HeapFoot
open Host.Ts Host.Ts.Sim Conv BufSim
open Host.Mlx.Ffi.FullKeep (AllX)

/-- A transition allocates or writes only above its initial counter. -/
structure Fresh {S : Type} (s u : St S) : Prop where
  grows : s.next ≤ u.next
  old : ∀ a, Present u a → Present s a ∨ s.next ≤ a
  kept : ∀ a, a < s.next → u.heap.get a = s.heap.get a

variable {S : Type} {s u v : St S}

theorem Fresh.refl (s : St S) : Fresh s s :=
  ⟨Nat.le_refl _, fun _ h => .inl h, fun _ _ => rfl⟩

theorem Fresh.of_same (h : Same s u) : Fresh s u :=
  ⟨by rw [h.2]; exact Nat.le_refl _, fun a ha => .inl (by unfold Present at ha ⊢; rwa [h.1] at ha),
    fun _ _ => by rw [h.1]⟩

theorem Fresh.trans (h : Fresh s u) (h' : Fresh u v) : Fresh s v where
  grows := Nat.le_trans h.grows h'.grows
  old a ha := by
    rcases h'.old a ha with hp | hp
    · exact h.old a hp
    · exact .inr (Nat.le_trans h.grows hp)
  kept a ha := (h'.kept a (Nat.lt_of_lt_of_le ha h.grows)).trans (h.kept a ha)

theorem Fresh.alloc (s : St S) (o : HObj) : Fresh s (s.alloc o).2 where
  grows := Nat.le_succ _
  old a ha := by
    rcases Host.Mlx.Ffi.FullKeep.isSome_set_inv s.heap s.next o a ha with hp | hp
    · exact .inl hp
    · exact .inr (Nat.le_of_eq hp.symm)
  kept a ha := PTrie.get_set_ne' _ _ _ _ (Nat.ne_of_lt ha)

theorem Fresh.write (h : Fresh s u) {a : Nat} (ha : s.next ≤ a) (o : HObj) :
    Fresh s { u with heap := u.heap.set a o } where
  grows := h.grows
  old b hb := by
    rcases Host.Mlx.Ffi.FullKeep.isSome_set_inv u.heap a o b hb with hp | hp
    · exact h.old b hp
    · exact .inr (hp ▸ ha)
  kept b hb := (PTrie.get_set_ne' _ _ _ _ (by omega)).trans (h.kept b hb)

theorem Fresh.foot {M : Map} {t w : St S} (hs : Fresh s u) (ht : Fresh t w) :
    HeapStepFoot M s t u w := ⟨hs.grows, hs.old, fun a ha _ => ht.kept a ha⟩

/-- Property reads may perform number-server work but cannot change the JS heap. -/
theorem ownGet_lawful (F : Ffi) (s : St F.S) (o : Obj) (k : PKey) : Lawful (ownGet F s o k) := by
  unfold ownGet
  cases o.kind <;> repeat' first
    | exact Lawful.pure _
    | exact Lawful.fail _
    | exact typedGet_lawful _ _ _ _ _ _ _
    | refine Lawful.cond _ ?_ ?_
    | split

theorem getChain_lawful (F : Ffi) (s : St F.S) (k : PKey) :
    ∀ fuel a, Lawful (getChain F s k fuel a)
  | 0, _ => Lawful.fail _
  | fuel + 1, a => by
    unfold getChain
    split
    · refine Lawful.bind (ownGet_lawful _ _ _ _) fun p => ?_
      cases p <;> dsimp only
      · split
        · exact getChain_lawful F s k fuel _
        · exact Lawful.pure _
      · exact Lawful.pure _
    · exact Lawful.fail _

theorem lookup_lawful (F : Ffi) (s : St F.S) (recv : Val) (k : PKey) :
    Lawful (lookup F s recv k) := by
  unfold lookup
  cases recv <;> repeat' first
    | exact Lawful.pure _
    | exact getChain_lawful _ _ _ _ _
    | refine Lawful.cond _ ?_ ?_
    | split

theorem dataOf_lawful (F : Ffi) (s : St F.S) (recv : Val) (k : PKey) :
    Lawful (dataOf F s recv k) := by
  unfold dataOf
  refine Lawful.bind (lookup_lawful _ _ _ _) fun p => ?_
  cases p with
  | none => exact Lawful.pure _
  | some p => cases p <;> exact Lawful.pure _

theorem readProp_same (F : Ffi) (s : St F.S) (recv : Val) (p : Option PropV) :
    Same s (readProp F s recv p) := by
  cases p with
  | none => exact ⟨rfl, rfl⟩
  | some p =>
    cases p with
    | data v w e => exact ⟨rfl, rfl⟩
    | acc g st e => cases g <;> exact ⟨rfl, rfl⟩

theorem refErr_fresh (s : St S) (msg : List Char) : AllX (Fresh s) (refErr s msg) :=
  AllX.pure ((Fresh.alloc _ _).trans (Fresh.of_same ⟨rfl, rfl⟩))

theorem readVar_fresh (F : Ffi) (s : St F.S) (n : Name) (env : Env) :
    AllX (Fresh s) (readVar F s n env) := by
  unfold readVar
  split
  · split
    · exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
    · exact refErr_fresh _ _
    · exact allX_fail _ _
  · refine AllX.bind' (getChain_lawful _ _ _ _ _) fun p => ?_
    cases p with
    | none =>
      refine AllX.cond _ ?_ (refErr_fresh _ _)
      exact AllX.pure ((Fresh.alloc _ _).trans (Fresh.of_same ⟨rfl, rfl⟩))
    | some p => exact AllX.pure (Fresh.of_same (readProp_same _ _ _ _))

theorem evLit_fresh (F : Ffi) (s : St F.S) (l : Lit) : AllX (Fresh s) (evLit F s l) := by
  cases l with
  | regex p fl =>
    unfold evLit
    refine AllX.bind' (getChain_lawful _ _ _ _ _) fun r => ?_
    split
    · refine AllX.bind' (dataOf_lawful _ _ _ _) fun r => ?_
      split
      · simp only [hostN, arg, nthD, primStr, Mbind_pure]
        split
        · exact AllX.pure ((Fresh.alloc _ _).trans (Fresh.of_same ⟨rfl, rfl⟩))
        · exact allX_fail _ _
      · exact allX_fail _ _
    · exact allX_fail _ _
  | _ =>
    all_goals simp only [evLit]
    all_goals repeat' first
      | exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
      | exact allX_fail _ _
      | split

theorem arrayNext_fresh (F : Ffi) (s : St F.S) : ∀ (rest : List Elem) (acc : List Val) (env : Env),
    AllX (Fresh s) (arrayNext F s acc rest env)
  | [], _, _ => AllX.pure ((Fresh.alloc _ _).trans (Fresh.of_same ⟨rfl, rfl⟩))
  | .hole :: r, acc, env => arrayNext_fresh F s r (.undef :: acc) env
  | .expr _ :: _, _, _ => AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
  | .spread _ :: _, _, _ => AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)

end Host.Ts.Sim.HeapFoot
