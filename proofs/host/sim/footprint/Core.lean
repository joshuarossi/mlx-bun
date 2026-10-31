import host.sim.full.Keep

namespace Host.Mlx.Ffi.Footprint
open Host.Ts
open FullKeep (AllX)

/-- Old handle contents change only in `H`; readback items change only in `I`.
Fresh allocations need no entry in `H`. Nodes below the old counter are immutable. -/
structure Writes (H I : Nat → Prop) (s t : St) : Prop where
  next : s.next ≤ t.next
  nnext : s.nnext ≤ t.nnext
  arrs : ∀ h, h < s.next → ¬ H h → t.arrs.get h = s.arrs.get h
  objs : ∀ h, h < s.next → ¬ H h → t.objs.get h = s.objs.get h
  nodes : ∀ i, i < s.nnext → t.nodes.get i = s.nodes.get i
  items : ∀ i, ¬ I i → t.items.get i = s.items.get i

namespace Writes
variable {H I H' I' : Nat → Prop} {s t u : St}

theorem refl (s : St) : Writes H I s s :=
  ⟨Nat.le_refl _, Nat.le_refl _, fun _ _ _ => rfl, fun _ _ _ => rfl,
    fun _ _ => rfl, fun _ _ => rfl⟩

theorem mono (w : Writes H I s t) (hh : ∀ h, H h → H' h) (hi : ∀ i, I i → I' i) :
    Writes H' I' s t :=
  ⟨w.next, w.nnext, fun h hl hn => w.arrs h hl (fun hp => hn (hh h hp)),
    fun h hl hn => w.objs h hl (fun hp => hn (hh h hp)), w.nodes,
    fun i hn => w.items i (fun hp => hn (hi i hp))⟩

theorem trans (w : Writes H I s t) (v : Writes H I t u) : Writes H I s u where
  next := Nat.le_trans w.next v.next
  nnext := Nat.le_trans w.nnext v.nnext
  arrs h hl hn := (v.arrs h (Nat.lt_of_lt_of_le hl w.next) hn).trans (w.arrs h hl hn)
  objs h hl hn := (v.objs h (Nat.lt_of_lt_of_le hl w.next) hn).trans (w.objs h hl hn)
  nodes i hl := (v.nodes i (Nat.lt_of_lt_of_le hl w.nnext)).trans (w.nodes i hl)
  items i hn := (v.items i hn).trans (w.items i hn)

theorem union (w : Writes H I s t) (v : Writes H' I' t u) :
    Writes (fun h => H h ∨ H' h) (fun i => I i ∨ I' i) s u :=
  (w.mono (fun _ => Or.inl) (fun _ => Or.inl)).trans
    (v.mono (fun _ => Or.inr) (fun _ => Or.inr))

theorem addNode (w : Writes H I s t) (nd : Node) : Writes H I s (t.addNode nd).2 :=
  w.trans ⟨Nat.le_refl _, Nat.le_succ _, fun _ _ _ => rfl, fun _ _ _ => rfl,
    fun _ hi => PTrie.get_set_ne' _ _ _ _ (Nat.ne_of_lt hi), fun _ _ => rfl⟩

theorem newObj (w : Writes H I s t) (o : Obj) : Writes H I s (t.newObj o).2 :=
  w.trans ⟨Nat.le_succ _, Nat.le_refl _, fun _ _ _ => rfl,
    fun _ hl _ => PTrie.get_set_ne' _ _ _ _ (Nat.ne_of_lt hl), fun _ _ => rfl, fun _ _ => rfl⟩

theorem setObj (w : Writes H I s t) (k : Nat) (o : Obj) (hk : H k) : Writes H I s (t.setObj k o) :=
  w.trans ⟨Nat.le_refl _, Nat.le_refl _, fun _ _ _ => rfl,
    fun _ _ hn => PTrie.get_set_ne' _ _ _ _ (fun e => hn (e ▸ hk)), fun _ _ => rfl, fun _ _ => rfl⟩

theorem setArr (w : Writes H I s t) (slot n : Nat) (hs : slot = 0 ∨ H slot) :
    Writes H I s (t.setArr slot n).2 := by
  refine w.trans ?_
  unfold St.setArr
  cases he : Nat.beq slot 0
  · refine ⟨Nat.le_refl _, Nat.le_refl _, ?_, fun _ _ _ => rfl, fun _ _ => rfl, fun _ _ => rfl⟩
    intro h hl hn
    apply PTrie.get_set_ne'
    intro e
    rcases hs with rfl | hp
    · have : Nat.beq 0 0 = false := he; cases this
    · exact hn (e ▸ hp)
  · exact ⟨Nat.le_succ _, Nat.le_refl _, fun h hl _ => PTrie.get_set_ne' _ _ _ _ (Nat.ne_of_lt hl),
      fun _ _ _ => rfl, fun _ _ => rfl, fun _ _ => rfl⟩

theorem freeArr (w : Writes H I s t) (k : Nat) (hk : H k) : Writes H I s (t.freeArr k) := by
  unfold St.freeArr
  cases Nat.beq k 0
  · exact w.trans ⟨Nat.le_refl _, Nat.le_refl _,
      fun h _ hn => PTrie.get_set_ne' _ _ _ _ (fun e => hn (e ▸ hk)),
      fun _ _ _ => rfl, fun _ _ => rfl, fun _ _ => rfl⟩
  · exact w

theorem pop (w : Writes H I s t) (k : Nat) (v : NumV) (vs : List NumV) (hk : I k) :
    Writes H I s { t with tokens := vs, items := t.items.set k v } :=
  w.trans ⟨Nat.le_refl _, Nat.le_refl _, fun _ _ _ => rfl, fun _ _ _ => rfl,
    fun _ _ => rfl, fun _ hn => PTrie.get_set_ne' _ _ _ _ (fun e => hn (e ▸ hk))⟩

theorem setVec (w : Writes H I s t) (slot : Nat) (ns : List Nat) (hs : H slot) :
    Writes H I s (Host.Mlx.Ffi.setVec t slot ns).2 := by
  unfold Host.Mlx.Ffi.setVec
  split
  · exact w.setObj slot _ hs
  · exact w.newObj _

theorem outs (kh : Nat) (xs : List Nat) (c : Cfg) : ∀ (t : St) (i : Nat) (os : List (List Dim × Nat)),
    Writes H I s t → Writes H I s (kernelApply.outs kh xs c t i os).1
  | _, _, [], w => w
  | _, i, (shape, dt) :: rest, w => outs kh xs c _ (i + 1) rest (w.addNode ⟨.kernel kh c i, xs, shape, dt⟩)

end Writes

/-- The non-null handle in an output slot, exactly as decoded by the FFI model. -/
def Slot (o : Arg) (h : Nat) : Prop := ∃ b off, slotOf o = some (b, off, h) ∧ h ≠ 0

theorem slot_support {o : Arg} {b off h : Nat} (he : slotOf o = some (b, off, h)) :
    h = 0 ∨ Slot o h := by
  by_cases hz : h = 0
  · exact .inl hz
  · exact .inr ⟨b, off, he, hz⟩

/-- The numerical calls take the output slot as their first argument. -/
def Output (args : List Arg) (h : Nat) : Prop := ∃ o rest, args = o :: rest ∧ Slot o h

theorem output_cons (o : Arg) (rest : List Arg) : ∀ h, Slot o h → Output (o :: rest) h :=
  fun _ hh => ⟨o, rest, rfl, hh⟩

/-- A result footprint, usable on either number server and on projected layered states. -/
def Result {α : Type} (H I : Nat → Prop) (s : St) (f : α → St) :
    Option (α × Ret × List (Nat × Nat × List Byte)) → Prop :=
  fun o => ∀ t r ws, o = some (t, r, ws) → Writes H I s (f t)

theorem result_none {α : Type} {H I : Nat → Prop} {s : St} {f : α → St} :
    AllX (Result H I s f) (M.pure none) :=
  AllX.pure fun _ _ _ e => by cases e

theorem result_some {α : Type} {H I : Nat → Prop} {s : St} {f : α → St}
    {t : α} {r : Ret} {ws : List (Nat × Nat × List Byte)} (w : Writes H I s (f t)) :
    AllX (Result H I s f) (M.pure (some (t, r, ws))) :=
  AllX.pure fun _ _ _ e => by cases e; exact w

theorem result_ok {H I : Nat → Prop} {s t : St} {r : Ret} (w : Writes H I s t) :
    AllX (Result H I s id) (ok t r) := result_some w

theorem result_okW {H I : Nat → Prop} {s t : St} {r : Ret} {ws : List (Nat × Nat × List Byte)}
    (w : Writes H I s t) : AllX (Result H I s id) (okW t r ws) := result_some w

theorem result_stuck {H I : Nat → Prop} {s : St} : AllX (Result H I s id) stuck := result_none

theorem allX_mono {α : Type} {P Q : α → Prop} {m : M α} (hm : AllX P m) (h : ∀ a, P a → Q a) : AllX Q m :=
  ⟨fun S a S' he => h a (hm.1 S a S' he), fun C a C' he => h a (hm.2 C a C' he)⟩

theorem result_mono {α : Type} {H I H' I' : Nat → Prop} {s : St} {f : α → St}
    {m : M (Option (α × Ret × List (Nat × Nat × List Byte)))}
    (hm : AllX (Result H I s f) m) (hh : ∀ h, H h → H' h) (hi : ∀ i, I i → I' i) :
    AllX (Result H' I' s f) m :=
  allX_mono hm fun _ hp t r ws he => (hp t r ws he).mono hh hi

end Host.Mlx.Ffi.Footprint
