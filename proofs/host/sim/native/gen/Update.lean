import host.sim.native.Update
import host.sim.native.gen.Rel
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! `host.sim.native.Update` for the general native relation `G.MR` (`host.sim.native.gen.Rel`):
the same statements and proofs, with the pre-load band bound `NB` threaded through. -/

section

variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : MR P NB M n x y)

include hr

theorem MR.ynext_lt : y.next < 2 ^ 46 := by have := hr.hroom.2; omega

theorem MR.xnext_lt : x.next < 2 ^ 46 := by have := hr.hnext.2; have := hr.ynext_lt; omega

theorem MR.next_pos : 0 < x.next := by have := hr.lo; have := hr.hnext.1; omega

theorem MR.ynnext_lt : y.nnext < 2 ^ 62 := by have := hr.nroom.2.2; omega

theorem MR.xnnext_lt : x.nnext < 2 ^ 62 := by have := hr.nroom.1; have := hr.ynnext_lt; omega

theorem MR.big0 : M.big 0 = 0 := hr.bigFix 0 (by have := hr.lo; omega)

theorem MR.handle0 : M.handle 0 = 0 := by
  show (M.big (Int.ofNat 0)).toNat = 0
  rw [show Int.ofNat 0 = 0 from rfl, hr.big0]; rfl

theorem MR.fresh0 (hE : x.next < P.E) : HMap M x.next y.next := by
  have h1 := hr.hfreshB 0 (by omega)
  have h2 := hr.hfreshR 0 (by have := hr.ynext_lt; omega)
  simp only [Nat.add_zero] at h1 h2
  exact ⟨h1, h2.1, h2.2⟩

theorem MR.handle_next (hE : x.next < P.E) : M.handle x.next = y.next := by
  show (M.big (Int.ofNat x.next)).toNat = y.next
  rw [(hr.fresh0 hE).1]; rfl

theorem MR.handle_eq {h : Nat} (hp : PH x h) : M.big (Int.ofNat h) = Int.ofNat (M.handle h) :=
  (hr.present h hp).1

theorem MR.node_next : M.node x.nnext = y.nnext := by simpa using hr.nfresh 0

theorem MR.not_PH_next : ¬ PH x x.next := fun h => Nat.lt_irrefl _ (hr.hlt _ h)

theorem MR.arrs_none_next : x.arrs.get x.next = none := by
  cases h : x.arrs.get x.next with
  | none => rfl
  | some _ => exact absurd (.inl (by rw [h]; rfl)) hr.not_PH_next

theorem MR.objs_none_next : x.objs.get x.next = none := by
  cases h : x.objs.get x.next with
  | none => rfl
  | some _ => exact absurd (.inr (by rw [h]; rfl)) hr.not_PH_next

theorem MR.nodes_none_next : x.nodes.get x.nnext = none := by
  cases h : x.nodes.get x.nnext with
  | none => rfl
  | some _ => exact absurd (hr.nlt _ (by show (x.nodes.get x.nnext).isSome = true; rw [h]; rfl)) (Nat.lt_irrefl _)

theorem MR.PH_ne_zero {h : Nat} (hp : PH x h) : h ≠ 0 := by
  rintro rfl
  rcases hp with hp | hp
  · rw [hr.absent0.1] at hp; cases hp
  · rw [hr.absent0.2.1] at hp; cases hp

theorem MR.handle_ne_next {h : Nat} (hp : PH x h) : M.handle h ≠ y.next :=
  Nat.ne_of_lt (hr.himg h hp).2

theorem MR.PH_lt {h : Nat} (hp : PH x h) : h < 2 ^ 62 := by
  have := hr.hlt h hp; have := hr.xnext_lt; omega

theorem MR.himg_lt {h : Nat} (hp : PH x h) : M.handle h < 2 ^ 62 := by
  have := (hr.himg h hp).2; have := hr.ynext_lt; omega

theorem MR.newObj (o : NObj) (hE : x.next + 1 ≤ P.E) (hs : SObj (· < n) o)
    (hc : ∀ c, o = .cfg c → ∀ p ∈ c.outs, ∀ d ∈ p.1, DimCanon M d) (ht : ∀ i ∈ objTraces o, i < P.NL) :
    MR P NB M n { x with next := x.next + 1, objs := x.objs.set x.next o }
      { y with next := y.next + 1, objs := y.objs.set y.next (M.nobj o) } := by
  have hxk := hr.xnext_lt
  have hyk := hr.ynext_lt
  have gx : ∀ h, (x.objs.set x.next o).get h = if h = x.next then some o else x.objs.get h :=
    PTrie.gs _ _ _ (by omega)
  have gy : ∀ h, (y.objs.set y.next (M.nobj o)).get h = if h = y.next then some (M.nobj o) else y.objs.get h :=
    PTrie.gs _ _ _ (by omega)
  have ph : ∀ h, PH { x with next := x.next + 1, objs := x.objs.set x.next o } h → h = x.next ∨ PH x h := by
    intro h hp
    by_cases e : h = x.next
    · exact .inl e
    · right
      rcases hp with hp | hp
      · exact .inl hp
      · right; simp only [gx, e, ↓reduceIte] at hp; exact hp
  have hE0 : x.next < P.E := by omega
  have hn0 := hr.handle_next hE0
  refine { hr with
    present := ?_
    hinj := ?_
    hlt := ?_
    himg := ?_
    hband := ?_
    hfreshR := ?_
    hnext := ?_
    hroom := ?_
    absent0 := ?_
    yabsent := ?_
    arrs := ?_
    objs := ?_
    cfgCanon := ?_
    traced := ?_
    cl := ?_
    hfreshB := ?_ }
  all_goals try dsimp only at *
  · intro h hp
    rcases ph h hp with rfl | hp
    · rw [hn0]; exact hr.fresh0 hE0
    · exact hr.present h hp
  · intro a b ha hb he
    rcases ph a ha with rfl | ha <;> rcases ph b hb with rfl | hb
    · rfl
    · rw [hn0] at he; exact absurd he.symm (hr.handle_ne_next hb)
    · rw [hn0] at he; exact absurd he (hr.handle_ne_next ha)
    · exact hr.hinj a b ha hb he
  · intro h hp
    rcases ph h hp with rfl | hp
    · exact Nat.lt_succ_self _
    · exact Nat.lt_succ_of_lt (hr.hlt h hp)
  · intro h hp
    rcases ph h hp with rfl | hp
    · rw [hn0]; have := hr.next_pos; have := hr.hnext.2; exact ⟨by omega, Nat.lt_succ_self _⟩
    · exact ⟨(hr.himg h hp).1, Nat.lt_succ_of_lt (hr.himg h hp).2⟩
  · intro h hp hl
    rcases ph h hp with rfl | hp
    · rw [hn0]; have := hr.hnext; omega
    · exact hr.hband h hp hl
  · intro k hk
    have := hr.hfreshR (k + 1) (by omega)
    simpa only [Nat.add_assoc, Nat.add_comm 1 k] using this
  · have := hr.hnext; exact ⟨by omega, by omega⟩
  · have := hr.hroom; exact ⟨hE, by omega⟩
  · refine ⟨hr.absent0.1, ?_, ?_⟩
    · show (x.objs.set x.next o).get 0 = none
      rw [gx]; have := hr.next_pos; simp only [show (0 : Nat) ≠ x.next by omega, ↓reduceIte]
      exact hr.absent0.2.1
    · show (y.objs.set y.next (M.nobj o)).get 0 = none
      rw [gy]; have := hr.next_pos; have := hr.hnext.2
      simp only [show (0 : Nat) ≠ y.next by omega, ↓reduceIte]
      exact hr.absent0.2.2
  · intro h hh
    refine ⟨(hr.yabsent h (by omega)).1, ?_⟩
    show (y.objs.set y.next (M.nobj o)).get h = none
    rw [gy]; simp only [show h ≠ y.next by omega, ↓reduceIte]
    exact (hr.yabsent h (by omega)).2
  · intro h hp
    rcases ph h hp with rfl | hp
    · rw [hn0]; show y.arrs.get y.next = (x.arrs.get x.next).map M.node
      rw [(hr.yabsent _ (Nat.le_refl _)).1, hr.arrs_none_next]; rfl
    · exact hr.arrs h hp
  · intro h hp
    rcases ph h hp with rfl | hp
    · rw [hn0]; show (y.objs.set y.next (M.nobj o)).get y.next = ((x.objs.set x.next o).get x.next).map M.nobj
      rw [gy, gx]; simp
    · show (y.objs.set y.next (M.nobj o)).get (M.handle h) = ((x.objs.set x.next o).get h).map M.nobj
      have e1 : h ≠ x.next := fun e => hr.not_PH_next (e ▸ hp)
      rw [gy, gx]
      simp only [hr.handle_ne_next hp, e1, ↓reduceIte]
      exact hr.objs h hp
  · intro h c hh
    change (x.objs.set x.next o).get h = some (.cfg c) at hh
    rw [gx] at hh
    by_cases e : h = x.next
    · simp only [e, ↓reduceIte, Option.some.injEq] at hh; exact hc c hh
    · simp only [e, ↓reduceIte] at hh; exact hr.cfgCanon h c hh
  · intro h o' hh
    change (x.objs.set x.next o).get h = some o' at hh
    rw [gx] at hh
    by_cases e : h = x.next
    · simp only [e, ↓reduceIte, Option.some.injEq] at hh; subst hh; exact ht
    · simp only [e, ↓reduceIte] at hh; exact hr.traced h o' hh
  · refine ⟨hr.cl.1, ?_, hr.cl.2.2⟩
    intro h o' hh
    change (x.objs.set x.next o).get h = some o' at hh
    rw [gx] at hh
    by_cases e : h = x.next
    · simp only [e, ↓reduceIte, Option.some.injEq] at hh; subst hh; exact hs
    · simp only [e, ↓reduceIte] at hh; exact hr.cl.2.1 h o' hh
  · intro k hk
    have := hr.hfreshB (k + 1) (by omega)
    simpa only [Nat.add_assoc, Nat.add_comm 1 k] using this

theorem MR.setObj {h : Nat} (hp : PH x h) (o : NObj) (hs : SObj (· < n) o)
    (hc : ∀ c, o = .cfg c → ∀ p ∈ c.outs, ∀ d ∈ p.1, DimCanon M d) (ht : ∀ i ∈ objTraces o, i < P.NL) :
    MR P NB M n { x with objs := x.objs.set h o } { y with objs := y.objs.set (M.handle h) (M.nobj o) } := by
  have gx : ∀ a, (x.objs.set h o).get a = if a = h then some o else x.objs.get a :=
    PTrie.gs _ _ _ (hr.PH_lt hp)
  have gy : ∀ a, (y.objs.set (M.handle h) (M.nobj o)).get a =
      if a = M.handle h then some (M.nobj o) else y.objs.get a :=
    PTrie.gs _ _ _ (hr.himg_lt hp)
  have ph : ∀ a, PH { x with objs := x.objs.set h o } a → PH x a := by
    intro a ha
    by_cases e : a = h
    · exact e ▸ hp
    · rcases ha with ha | ha
      · exact .inl ha
      · right; simp only [gx, e, ↓reduceIte] at ha; exact ha
  refine { hr with
    present := fun a ha => hr.present a (ph a ha)
    hinj := fun a b ha hb => hr.hinj a b (ph a ha) (ph b hb)
    hlt := fun a ha => hr.hlt a (ph a ha)
    himg := fun a ha => hr.himg a (ph a ha)
    hband := fun a ha => hr.hband a (ph a ha)
    absent0 := ?_
    yabsent := ?_
    arrs := fun a ha => hr.arrs a (ph a ha)
    objs := ?_
    cfgCanon := ?_
    traced := ?_
    cl := ?_ }
  all_goals try dsimp only at *
  · refine ⟨hr.absent0.1, ?_, ?_⟩
    · show (x.objs.set h o).get 0 = none
      rw [gx]; simp only [show (0 : Nat) ≠ h from fun e => hr.PH_ne_zero hp e.symm, ↓reduceIte]
      exact hr.absent0.2.1
    · show (y.objs.set (M.handle h) (M.nobj o)).get 0 = none
      rw [gy]; simp only [show (0 : Nat) ≠ M.handle h by have := (hr.himg h hp).1; omega, ↓reduceIte]
      exact hr.absent0.2.2
  · intro a ha
    refine ⟨(hr.yabsent a ha).1, ?_⟩
    show (y.objs.set (M.handle h) (M.nobj o)).get a = none
    rw [gy]; simp only [show a ≠ M.handle h by have := (hr.himg h hp).2; omega, ↓reduceIte]
    exact (hr.yabsent a ha).2
  · intro a ha
    have ha' := ph a ha
    show (y.objs.set (M.handle h) (M.nobj o)).get (M.handle a) = ((x.objs.set h o).get a).map M.nobj
    rw [gy, gx]
    by_cases e : a = h
    · subst e; simp
    · have e' : M.handle a ≠ M.handle h := fun he => e (hr.hinj a h ha' hp he)
      simp only [e, e', ↓reduceIte]
      exact hr.objs a ha'
  · intro a c ha
    change (x.objs.set h o).get a = some (.cfg c) at ha
    rw [gx] at ha
    by_cases e : a = h
    · simp only [e, ↓reduceIte, Option.some.injEq] at ha; exact hc c ha
    · simp only [e, ↓reduceIte] at ha; exact hr.cfgCanon a c ha
  · intro a o' ha
    change (x.objs.set h o).get a = some o' at ha
    rw [gx] at ha
    by_cases e : a = h
    · simp only [e, ↓reduceIte, Option.some.injEq] at ha; subst ha; exact ht
    · simp only [e, ↓reduceIte] at ha; exact hr.traced a o' ha
  · refine ⟨hr.cl.1, ?_, hr.cl.2.2⟩
    intro a o' ha
    change (x.objs.set h o).get a = some o' at ha
    rw [gx] at ha
    by_cases e : a = h
    · simp only [e, ↓reduceIte, Option.some.injEq] at ha; subst ha; exact hs
    · simp only [e, ↓reduceIte] at ha; exact hr.cl.2.1 a o' ha

theorem MR.newArr (k : Nat) (hE : x.next + 1 ≤ P.E) :
    MR P NB M n { x with next := x.next + 1, arrs := x.arrs.set x.next k }
      { y with next := y.next + 1, arrs := y.arrs.set y.next (M.node k) } := by
  have hxk := hr.xnext_lt
  have hyk := hr.ynext_lt
  have gx : ∀ h, (x.arrs.set x.next k).get h = if h = x.next then some k else x.arrs.get h :=
    PTrie.gs _ _ _ (by omega)
  have gy : ∀ h, (y.arrs.set y.next (M.node k)).get h = if h = y.next then some (M.node k) else y.arrs.get h :=
    PTrie.gs _ _ _ (by omega)
  have ph : ∀ h, PH { x with next := x.next + 1, arrs := x.arrs.set x.next k } h → h = x.next ∨ PH x h := by
    intro h hp
    by_cases e : h = x.next
    · exact .inl e
    · right
      rcases hp with hp | hp
      · left; simp only [gx, e, ↓reduceIte] at hp; exact hp
      · exact .inr hp
  have hE0 : x.next < P.E := by omega
  have hn0 := hr.handle_next hE0
  refine { hr with
    present := ?_
    hinj := ?_
    hlt := ?_
    himg := ?_
    hband := ?_
    hfreshR := ?_
    hnext := ?_
    hroom := ?_
    absent0 := ?_
    yabsent := ?_
    arrs := ?_
    objs := ?_
    hfreshB := ?_ }
  all_goals try dsimp only at *
  · intro h hp
    rcases ph h hp with rfl | hp
    · rw [hn0]; exact hr.fresh0 hE0
    · exact hr.present h hp
  · intro a b ha hb he
    rcases ph a ha with rfl | ha <;> rcases ph b hb with rfl | hb
    · rfl
    · rw [hn0] at he; exact absurd he.symm (hr.handle_ne_next hb)
    · rw [hn0] at he; exact absurd he (hr.handle_ne_next ha)
    · exact hr.hinj a b ha hb he
  · intro h hp
    rcases ph h hp with rfl | hp
    · exact Nat.lt_succ_self _
    · exact Nat.lt_succ_of_lt (hr.hlt h hp)
  · intro h hp
    rcases ph h hp with rfl | hp
    · rw [hn0]; have := hr.next_pos; have := hr.hnext.2; exact ⟨by omega, Nat.lt_succ_self _⟩
    · exact ⟨(hr.himg h hp).1, Nat.lt_succ_of_lt (hr.himg h hp).2⟩
  · intro h hp hl
    rcases ph h hp with rfl | hp
    · rw [hn0]; have := hr.hnext; omega
    · exact hr.hband h hp hl
  · intro j hj
    have := hr.hfreshR (j + 1) (by omega)
    simpa only [Nat.add_assoc, Nat.add_comm 1 j] using this
  · have := hr.hnext; exact ⟨by omega, by omega⟩
  · have := hr.hroom; exact ⟨hE, by omega⟩
  · refine ⟨?_, hr.absent0.2.1, hr.absent0.2.2⟩
    show (x.arrs.set x.next k).get 0 = none
    rw [gx]; have := hr.next_pos; simp only [show (0 : Nat) ≠ x.next by omega, ↓reduceIte]
    exact hr.absent0.1
  · intro h hh
    refine ⟨?_, (hr.yabsent h (by omega)).2⟩
    show (y.arrs.set y.next (M.node k)).get h = none
    rw [gy]; simp only [show h ≠ y.next by omega, ↓reduceIte]
    exact (hr.yabsent h (by omega)).1
  · intro h hp
    rcases ph h hp with rfl | hp
    · rw [hn0]; show (y.arrs.set y.next (M.node k)).get y.next = ((x.arrs.set x.next k).get x.next).map M.node
      rw [gy, gx]; simp
    · show (y.arrs.set y.next (M.node k)).get (M.handle h) = ((x.arrs.set x.next k).get h).map M.node
      have e1 : h ≠ x.next := fun e => hr.not_PH_next (e ▸ hp)
      rw [gy, gx]
      simp only [hr.handle_ne_next hp, e1, ↓reduceIte]
      exact hr.arrs h hp
  · intro h hp
    rcases ph h hp with rfl | hp
    · rw [hn0]; show y.objs.get y.next = (x.objs.get x.next).map M.nobj
      rw [(hr.yabsent _ (Nat.le_refl _)).2, hr.objs_none_next]; rfl
    · exact hr.objs h hp
  · intro j hj
    have := hr.hfreshB (j + 1) (by omega)
    simpa only [Nat.add_assoc, Nat.add_comm 1 j] using this

theorem MR.setArr {h : Nat} (hp : PH x h) (k : Nat) :
    MR P NB M n { x with arrs := x.arrs.set h k } { y with arrs := y.arrs.set (M.handle h) (M.node k) } := by
  have gx : ∀ a, (x.arrs.set h k).get a = if a = h then some k else x.arrs.get a :=
    PTrie.gs _ _ _ (hr.PH_lt hp)
  have gy : ∀ a, (y.arrs.set (M.handle h) (M.node k)).get a =
      if a = M.handle h then some (M.node k) else y.arrs.get a :=
    PTrie.gs _ _ _ (hr.himg_lt hp)
  have ph : ∀ a, PH { x with arrs := x.arrs.set h k } a → PH x a := by
    intro a ha
    by_cases e : a = h
    · exact e ▸ hp
    · rcases ha with ha | ha
      · left; simp only [gx, e, ↓reduceIte] at ha; exact ha
      · exact .inr ha
  refine { hr with
    present := fun a ha => hr.present a (ph a ha)
    hinj := fun a b ha hb => hr.hinj a b (ph a ha) (ph b hb)
    hlt := fun a ha => hr.hlt a (ph a ha)
    himg := fun a ha => hr.himg a (ph a ha)
    hband := fun a ha => hr.hband a (ph a ha)
    absent0 := ?_
    yabsent := ?_
    arrs := ?_
    objs := fun a ha => hr.objs a (ph a ha) }
  all_goals try dsimp only at *
  · refine ⟨?_, hr.absent0.2.1, hr.absent0.2.2⟩
    show (x.arrs.set h k).get 0 = none
    rw [gx]; simp only [show (0 : Nat) ≠ h from fun e => hr.PH_ne_zero hp e.symm, ↓reduceIte]
    exact hr.absent0.1
  · intro a ha
    refine ⟨?_, (hr.yabsent a ha).2⟩
    show (y.arrs.set (M.handle h) (M.node k)).get a = none
    rw [gy]; simp only [show a ≠ M.handle h by have := (hr.himg h hp).2; omega, ↓reduceIte]
    exact (hr.yabsent a ha).1
  · intro a ha
    have ha' := ph a ha
    show (y.arrs.set (M.handle h) (M.node k)).get (M.handle a) = ((x.arrs.set h k).get a).map M.node
    rw [gy, gx]
    by_cases e : a = h
    · subst e; simp
    · have e' : M.handle a ≠ M.handle h := fun he => e (hr.hinj a h ha' hp he)
      simp only [e, e', ↓reduceIte]
      exact hr.arrs a ha'

theorem MR.addNode (nd : Node) (hNE : x.nnext + 1 ≤ P.NE) (hs : SNode (· < n) nd)
    (hc : ∀ d ∈ nd.shape, DimCanon M d) :
    MR P NB M n { x with nnext := x.nnext + 1, nodes := x.nodes.set x.nnext nd }
      { y with nnext := y.nnext + 1, nodes := y.nodes.set y.nnext (M.nnode nd) } := by
  have hxk := hr.xnnext_lt
  have hyk := hr.ynnext_lt
  have gx : ∀ i, (x.nodes.set x.nnext nd).get i = if i = x.nnext then some nd else x.nodes.get i :=
    PTrie.gs _ _ _ hxk
  have gy : ∀ i, (y.nodes.set y.nnext (M.nnode nd)).get i =
      if i = y.nnext then some (M.nnode nd) else y.nodes.get i :=
    PTrie.gs _ _ _ hyk
  have pn : ∀ i, PN { x with nnext := x.nnext + 1, nodes := x.nodes.set x.nnext nd } i → i = x.nnext ∨ PN x i := by
    intro i hi
    by_cases e : i = x.nnext
    · exact .inl e
    · right
      change ((x.nodes.set x.nnext nd).get i).isSome = true at hi
      rw [gx] at hi; simp only [e, ↓reduceIte] at hi; exact hi
  have hn0 := hr.node_next
  have hne : ∀ i, PN x i → M.node i ≠ y.nnext := fun i hi => Nat.ne_of_lt (hr.nimg i hi)
  have hxne : ∀ i, PN x i → i ≠ x.nnext := fun i hi => Nat.ne_of_lt (hr.nlt i hi)
  refine { hr with
    nodes := ?_
    ninj := ?_
    nlt := ?_
    nimg := ?_
    nfresh := ?_
    nall := ?_
    norder := ?_
    nband := ?_
    nroom := ?_
    items := ?_
    itemsPresent := ?_
    yitems := ?_
    cl := ?_ }
  all_goals try dsimp only at *
  · intro j hj
    by_cases e : j = x.nnext
    · subst e; rw [hn0]; exact Nat.lt_succ_self _
    · exact Nat.lt_succ_of_lt (hr.nall j (by omega))
  · intro i hi hf j hj
    rcases pn i hi with rfl | hi
    · rw [hn0]; exact hr.nall j hj
    · exact hr.norder i hi hf j hj
  · intro i nd' hi
    change (x.nodes.set x.nnext nd).get i = some nd' at hi
    rw [gx] at hi
    by_cases e : i = x.nnext
    · subst e
      simp only [↓reduceIte, Option.some.injEq] at hi
      subst hi
      refine ⟨M.nnode nd, ?_, rfl, rfl, hc, fun _ => ⟨.inl rfl, rfl⟩⟩
      show (y.nodes.set y.nnext (M.nnode nd)).get (M.node x.nnext) = _
      rw [hn0, gy]; simp
    · simp only [e, ↓reduceIte] at hi
      obtain ⟨nd'', h1, h2⟩ := hr.nodes i nd' hi
      refine ⟨nd'', ?_, h2⟩
      show (y.nodes.set y.nnext (M.nnode nd)).get (M.node i) = _
      rw [gy]; simp only [hne i (by show (x.nodes.get i).isSome = true; rw [hi]; rfl), ↓reduceIte]; exact h1
  · intro a b ha hb he
    rcases pn a ha with rfl | ha <;> rcases pn b hb with rfl | hb
    · rfl
    · rw [hn0] at he; exact absurd he.symm (hne b hb)
    · rw [hn0] at he; exact absurd he (hne a ha)
    · exact hr.ninj a b ha hb he
  · intro i hi
    rcases pn i hi with rfl | hi
    · exact Nat.lt_succ_self _
    · exact Nat.lt_succ_of_lt (hr.nlt i hi)
  · intro i hi
    rcases pn i hi with rfl | hi
    · rw [hn0]; exact Nat.lt_succ_self _
    · exact Nat.lt_succ_of_lt (hr.nimg i hi)
  · intro k
    have := hr.nfresh (k + 1)
    simpa only [Nat.add_assoc, Nat.add_comm 1 k] using this
  · have := hr.nband; exact ⟨this.1, by omega⟩
  · have := hr.nroom; exact ⟨by omega, hNE, by omega⟩
  · intro k hk
    rcases pn k hk with rfl | hk
    · rw [hn0, hr.yitems _ (Nat.le_refl _)]
      cases h : x.items.get x.nnext with
      | none => rfl
      | some _ => exact absurd (hr.itemsPresent _ (by rw [h]; rfl)) (fun hp => hxne _ hp rfl)
    · exact hr.items k hk
  · intro k hk
    have := hr.itemsPresent k hk
    change ((x.nodes.set x.nnext nd).get k).isSome = true
    rw [gx]
    by_cases e : k = x.nnext
    · simp [e]
    · simp only [e, ↓reduceIte]; exact this
  · intro k hk; exact hr.yitems k (by omega)
  · refine ⟨?_, hr.cl.2⟩
    intro i nd' hi
    change (x.nodes.set x.nnext nd).get i = some nd' at hi
    rw [gx] at hi
    by_cases e : i = x.nnext
    · simp only [e, ↓reduceIte, Option.some.injEq] at hi; subst hi; exact hs
    · simp only [e, ↓reduceIte] at hi; exact hr.cl.1 i nd' hi

end

section

variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : MR P NB M n x y)

include hr

/-- `mlx_array_set_` on an out-param slot: a new handle for the null slot, else reassignment. -/
theorem MR.setArr_map {sl : Nat} (hsl : sl = 0 ∨ PH x sl) (hE : sl = 0 → x.next + 1 ≤ P.E) (k : Nat) :
    ∃ h x' h' y', x.setArr sl k = (h, x') ∧ y.setArr (M.handle sl) (M.node k) = (h', y') ∧
      MR P NB M n x' y' ∧ M.big (Int.ofNat h) = Int.ofNat h' := by
  rcases hsl with rfl | hp
  · refine ⟨_, _, _, _, rfl, ?_, hr.newArr k (hE rfl), (hr.fresh0 (by have := hE rfl; omega)).1⟩
    rw [hr.handle0]; rfl
  · have h1 : Nat.beq sl 0 = false := by
      cases e : Nat.beq sl 0
      · rfl
      · exact absurd (Nat.eq_of_beq_eq_true e) (hr.PH_ne_zero hp)
    have h2 : Nat.beq (M.handle sl) 0 = false := by
      cases e : Nat.beq (M.handle sl) 0
      · rfl
      · exact absurd (Nat.eq_of_beq_eq_true e) (Nat.ne_of_gt (hr.himg sl hp).1)
    refine ⟨sl, _, M.handle sl, _, ?_, ?_, hr.setArr hp k, (hr.present sl hp).1⟩
    · unfold Host.Mlx.Ffi.St.setArr; rw [h1]; rfl
    · unfold Host.Mlx.Ffi.St.setArr; rw [h2]; rfl

/-- `mlx_vector_array_set_` on an out-param slot. -/
theorem MR.setVec_map {sl : Nat} (hsl : sl = 0 ∨ PH x sl) (hE : x.next + 1 ≤ P.E) (ns : List Nat) :
    ∃ h x' h' y', Host.Mlx.Ffi.setVec x sl ns = (h, x') ∧
      Host.Mlx.Ffi.setVec y (M.handle sl) (ns.map M.node) = (h', y') ∧
      MR P NB M n x' y' ∧ M.big (Int.ofNat h) = Int.ofNat h' := by
  have hnew : Host.Mlx.Ffi.St.obj? x sl = none ∨ (∃ o, Host.Mlx.Ffi.St.obj? x sl = some o ∧ ∀ v, o ≠ .vec v) →
      Host.Mlx.Ffi.St.obj? y (M.handle sl) = none ∨
        (∃ o, Host.Mlx.Ffi.St.obj? y (M.handle sl) = some o ∧ ∀ v, o ≠ .vec v) →
      ∃ h x' h' y', Host.Mlx.Ffi.setVec x sl ns = (h, x') ∧
        Host.Mlx.Ffi.setVec y (M.handle sl) (ns.map M.node) = (h', y') ∧
        MR P NB M n x' y' ∧ M.big (Int.ofNat h) = Int.ofNat h' := by
    intro hx hy
    have ex : Host.Mlx.Ffi.setVec x sl ns = x.newObj (.vec ns) := by
      unfold Host.Mlx.Ffi.setVec
      rcases hx with hx | ⟨o, hx, ho⟩
      · rw [hx]
      · rw [hx]; cases o <;> first | rfl | exact absurd rfl (ho _)
    have ey : Host.Mlx.Ffi.setVec y (M.handle sl) (ns.map M.node) = y.newObj (.vec (ns.map M.node)) := by
      unfold Host.Mlx.Ffi.setVec
      rcases hy with hy | ⟨o, hy, ho⟩
      · rw [hy]
      · rw [hy]; cases o <;> first | rfl | exact absurd rfl (ho _)
    refine ⟨_, _, _, _, ex, ey, hr.newObj (.vec ns) hE trivial (fun c h => by cases h) (fun i h => by cases h),
      (hr.fresh0 (by omega)).1⟩
  rcases hsl with rfl | hp
  · refine hnew (.inl hr.absent0.2.1) (.inl ?_)
    rw [hr.handle0]; exact hr.absent0.2.2
  · have hy := hr.objs sl hp
    cases ho : x.objs.get sl with
    | none =>
      rw [ho] at hy
      exact hnew (.inl ho) (.inl hy)
    | some o =>
      rw [ho] at hy
      cases o with
      | vec v =>
        refine ⟨sl, _, M.handle sl, _, ?_, ?_, hr.setObj hp (.vec ns) trivial (fun c h => by cases h)
          (fun i h => by cases h), (hr.present sl hp).1⟩
        · unfold Host.Mlx.Ffi.setVec; show (match x.objs.get sl with | some (.vec _) => _ | _ => _) = _; rw [ho]; rfl
        · unfold Host.Mlx.Ffi.setVec; show (match y.objs.get (M.handle sl) with | some (.vec _) => _ | _ => _) = _
          rw [hy]; rfl
      | _ => exact hnew (.inr ⟨_, ho, fun v h => by cases h⟩) (.inr ⟨_, hy, fun v h => by cases h⟩)

/-- Reading back a node's value for the first time consumes a token. -/
theorem MR.readToken {k : Nat} (hk : PN x k) {t : NumV} {ts : List NumV} (ht : x.tokens = t :: ts) :
    ∃ ts', y.tokens = M.nv t :: ts' ∧
      MR P NB M n { x with tokens := ts, items := x.items.set k t }
        { y with tokens := ts', items := y.items.set (M.node k) (M.nv t) } := by
  have hrest := hr.tokensX
  rw [ht] at hrest
  refine ⟨ts.map M.nv ++ P.rest, by rw [hrest]; rfl, ?_⟩
  have hxk : k < 2 ^ 62 := by have := hr.nlt k hk; have := hr.xnnext_lt; omega
  have hyk : M.node k < 2 ^ 62 := by have := hr.nimg k hk; have := hr.ynnext_lt; omega
  have gx : ∀ i, (x.items.set k t).get i = if i = k then some t else x.items.get i := PTrie.gs _ _ _ hxk
  have gy : ∀ i, (y.items.set (M.node k) (M.nv t)).get i = if i = M.node k then some (M.nv t) else y.items.get i :=
    PTrie.gs _ _ _ hyk
  have hct := hr.cl.2.2.1
  rw [ht] at hct
  refine { hr with
    tokens := ⟨P.rest, rfl⟩
    tokensX := rfl
    items := ?_
    itemsPresent := ?_
    yitems := ?_
    cl := ?_ }
  all_goals try dsimp only at *
  · intro i hi
    rw [gy, gx]
    by_cases e : i = k
    · subst e; simp
    · have e' : M.node i ≠ M.node k := fun h => e (hr.ninj i k hi hk h)
      simp only [e, e', ↓reduceIte]
      exact hr.items i hi
  · intro i hi
    rw [gx] at hi
    by_cases e : i = k
    · exact e ▸ hk
    · simp only [e, ↓reduceIte] at hi; exact hr.itemsPresent i hi
  · intro i hi
    rw [gy]
    simp only [show i ≠ M.node k by have := hr.nimg k hk; omega, ↓reduceIte]
    exact hr.yitems i hi
  · refine ⟨hr.cl.1, hr.cl.2.1, fun u hu => hct u (List.mem_cons_of_mem _ hu), ?_, hr.cl.2.2.2.2⟩
    intro i u hu
    rw [gx] at hu
    by_cases e : i = k
    · simp only [e, ↓reduceIte, Option.some.injEq] at hu
      subst hu; exact hct t (List.mem_cons_self ..)
    · simp only [e, ↓reduceIte] at hu; exact hr.cl.2.2.2.1 i u hu

end

end Host.Ts.Sim.G
