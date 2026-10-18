import host.ts.RenameParametricLookup
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

private theorem beqFalse {a b : Nat} (different : a ≠ b) : Nat.beq a b = false := by
  cases eq : Nat.beq a b with
  | false => rfl
  | true => exact False.elim (different (Nat.eq_of_beq_eq_true eq))

/-- Well-known symbols remain disjoint from strings and allocated symbols. -/
theorem keyEq_wellKnown_symbol_map (R : Ren) (symbol : Nat) (bound : symbol < 16) (key : PKey) :
    keyEq (.sym symbol) (R.key key) = keyEq (.sym symbol) key := by
  cases key with
  | str name => rfl
  | sym other =>
    change Nat.beq (2*symbol+1) (2*R.sym other+1) = Nat.beq (2*symbol+1) (2*other+1)
    by_cases small : other < 16
    · have mapped : R.sym other = other := by
        unfold Ren.sym NameMap.sym
        rw [show Nat.blt other 16 = true from Nat.blt_eq.mpr small]
        rfl
      rw [mapped]
    · have large : 16 ≤ other := Nat.le_of_not_lt small
      have mapped : R.sym other = R.a (other-16)+16 := by
        unfold Ren.sym NameMap.sym
        have flag : Nat.blt other 16 = false := by
          cases eq : Nat.blt other 16 with
          | false => rfl
          | true => have := Nat.blt_eq.mp eq; omega
        rw [flag]
        rfl
      have sourceNe : 2*symbol+1 ≠ 2*other+1 := by omega
      have targetNe : 2*symbol+1 ≠ 2*(R.a (other-16)+16)+1 := by omega
      rw [mapped]
      exact (beqFalse targetNe).trans (beqFalse sourceNe).symm

theorem PropsR.find_symbol {NR : NumV → NumV → Prop} {R : Ren} {ps ps' : Props}
    (h : PropsR NR R ps ps') (symbol : Nat) (bound : symbol < 16) :
    OptionRel (PropR NR R) (findProp (.sym symbol) ps) (findProp (.sym symbol) ps') := by
  rw [findProp_eq_linear,findProp_eq_linear]
  induction ps generalizing ps' with
  | nil => have := h.nil_left; subst ps'; exact .none
  | cons q rest ih =>
    obtain ⟨k,p⟩ := q
    obtain ⟨k',p',rest',rfl,hk,hp,hr⟩ := h.cons
    have he : keyEq (.sym symbol) k' = keyEq (.sym symbol) k := by rw [hk.eq_map]; exact keyEq_wellKnown_symbol_map R symbol bound k
    simp only [findPropLinear_cons]
    change OptionRel (PropR NR R) (brec (keyEq (.sym symbol) k) _ _) (brec (keyEq (.sym symbol) k') _ _)
    rw [he]
    cases keyEq (.sym symbol) k
    · exact ih hr
    · exact .some hp

theorem PropsR.support_find_symbol {live : Nat → Prop} {ps : Props} {p : PropV}
    (hs : treeSupport live (Encode.props ps)) (symbol : Nat)
    (hp : findProp (.sym symbol) ps = some p) : treeSupport live (Encode.prop p) := by
  rw [findProp_eq_linear] at hp
  induction ps with
  | nil => cases hp
  | cons q rest ih =>
    obtain ⟨k,v⟩ := q
    change (treeSupport live (Encode.key k) ∧ treeSupport live (Encode.prop v) ∧ True) ∧
      forestSupport live (rest.map fun (k,p) => .node "prop" [Encode.key k,Encode.prop p]) at hs
    rw [findPropLinear_cons] at hp
    change brec (keyEq (.sym symbol) k) (some v) (findPropLinear (.sym symbol) rest) = some p at hp
    cases hb : keyEq (.sym symbol) k <;> rw [hb] at hp
    · exact ih hs.2 hp
    · obtain rfl := Option.some.inj hp
      exact hs.1.2.1

/-- A source prototype path records heap observations, not a target computation
or a machine-step simulation. Every object traversed here is ordinary. -/
inductive OrdinarySymbolLookup {S : Type} (s : St S) (symbol : Nat) : Nat → Nat → Option PropV → Prop where
  | hit (fuel a : Nat) (o : Obj) (p : PropV) :
      s.heap.get a = some (.obj o) → o.kind = .ordinary → findProp (.sym symbol) o.props = some p →
      OrdinarySymbolLookup s symbol (fuel+1) a (some p)
  | next (fuel a b : Nat) (o : Obj) {p : Option PropV} :
      s.heap.get a = some (.obj o) → o.kind = .ordinary → findProp (.sym symbol) o.props = none →
      o.proto = .obj b → OrdinarySymbolLookup s symbol fuel b p → OrdinarySymbolLookup s symbol (fuel+1) a p
  | stop (fuel a : Nat) (o : Obj) :
      s.heap.get a = some (.obj o) → o.kind = .ordinary → findProp (.sym symbol) o.props = none →
      o.proto = .null → OrdinarySymbolLookup s symbol (fuel+1) a none

private theorem ValueR.symbolLookup_obj_target {NR : NumV → NumV → Prop} {R : Ren} {a : Nat} {v : Val}
    (h : ValueR NR R (.obj a) v) : v = .obj (R.a a) := by cases h; rfl
private theorem ValueR.symbolLookup_null_target {NR : NumV → NumV → Prop} {R : Ren} {v : Val}
    (h : ValueR NR R .null v) : v = .null := by cases h; rfl

theorem ObjectR.symbolLookup_prototype {NR : NumV → NumV → Prop} {R : Ren} {o o' : Obj}
    (h : ObjectR NR R o o') : ValueR NR R o.proto o'.proto := by
  cases h with | node tag hs =>
    cases hs with | cons hk hs =>
      cases hs with | cons hp hs =>
        cases hp with | value hp => exact hp

private theorem symbolLookup_hit_eq (F : Ffi) (s : St F.S) (symbol : Nat) (fuel a : Nat) (o : Obj) (p : PropV)
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .ordinary)
    (hp : findProp (.sym symbol) o.props = some p) :
    getChain F s (.sym symbol) (fuel+1) a = M.pure (some p) := by
  have ho' : s.obj? a = some o := by simp only [St.obj?,ho]
  rw [getChain,ho']
  simp only [ownGet,hk,hp]
  rfl

private theorem symbolLookup_next_eq (F : Ffi) (s : St F.S) (symbol : Nat) (fuel a b : Nat) (o : Obj)
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .ordinary)
    (hp : findProp (.sym symbol) o.props = none) (hproto : o.proto = .obj b) :
    getChain F s (.sym symbol) (fuel+1) a = getChain F s (.sym symbol) fuel b := by
  have ho' : s.obj? a = some o := by simp only [St.obj?,ho]
  rw [getChain,ho']
  simp only [ownGet,hk,hp,hproto]
  rfl

private theorem symbolLookup_stop_eq (F : Ffi) (s : St F.S) (symbol : Nat) (fuel a : Nat) (o : Obj)
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .ordinary)
    (hp : findProp (.sym symbol) o.props = none) (hproto : o.proto = .null) :
    getChain F s (.sym symbol) (fuel+1) a = M.pure none := by
  have ho' : s.obj? a = some o := by simp only [St.obj?,ho]
  rw [getChain,ho']
  simp only [ownGet,hk,hp,hproto]
  rfl

/-- Transport the real prototype traversal. Live support proves each next
prototype address is in the heap relation; ordered properties determine the
related descriptor, including an accessor getter. -/
theorem OrdinarySymbolLookup.transport (F : Ffi) {NR : NumV → NumV → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {s₀ s : St F.S}
    (heap : HeapR NR R live framed before after s₀ s)
    (symbol : Nat) (symbolBound : symbol < 16)
    {fuel a : Nat} {p₀ : Option PropV} (path : OrdinarySymbolLookup s₀ symbol fuel a p₀) (ha : live a) :
    ∃ p, getChain F s₀ (.sym symbol) fuel a = M.pure p₀ ∧
      getChain F s (.sym symbol) fuel (R.a a) = M.pure p ∧
      OptionRel (PropR NR R) p₀ p ∧
      (∀ q, p₀ = some q → treeSupport live (Encode.prop q)) := by
  induction path with
  | hit fuel a o₀ p₀ ho hk hp =>
    obtain ⟨o,ho',hr,hl⟩ := heap.readOrdinary a o₀ ha ho hk
    have hprops := hr.properties.find_symbol symbol symbolBound
    rw [hp] at hprops
    generalize hh : findProp (.sym symbol) o.props = p at hprops
    cases hprops with
    | some hprop =>
      refine ⟨_,symbolLookup_hit_eq F s₀ symbol fuel a o₀ p₀ ho hk hp,
        symbolLookup_hit_eq F s symbol fuel (R.a a) o _ ho' (hr.ordinary hk) hh,.some hprop,?_⟩
      intro q hq
      obtain rfl := Option.some.inj hq
      exact PropsR.support_find_symbol hl.2.2.1 symbol hp
  | next fuel a b o₀ ho hk hp hproto path ih =>
    obtain ⟨o,ho',hr,hl⟩ := heap.readOrdinary a o₀ ha ho hk
    have hb : live b := by have hv := hl.2.1; rw [hproto] at hv; exact hv
    obtain ⟨p,hs₀,hs,hrel,hsupport⟩ := ih hb
    have hprops := hr.properties.find_symbol symbol symbolBound
    rw [hp] at hprops
    generalize hh : findProp (.sym symbol) o.props = found at hprops
    cases hprops with
    | none =>
      have hproto' := hr.symbolLookup_prototype
      rw [hproto] at hproto'
      have hb' : o.proto = .obj (R.a b) := hproto'.symbolLookup_obj_target
      refine ⟨p,?_,?_,hrel,hsupport⟩
      · rw [symbolLookup_next_eq F s₀ symbol fuel a b o₀ ho hk hp hproto]; exact hs₀
      · rw [symbolLookup_next_eq F s symbol fuel (R.a a) (R.a b) o ho' (hr.ordinary hk) hh hb']; exact hs
  | stop fuel a o₀ ho hk hp hproto =>
    obtain ⟨o,ho',hr,hl⟩ := heap.readOrdinary a o₀ ha ho hk
    have hprops := hr.properties.find_symbol symbol symbolBound
    rw [hp] at hprops
    generalize hh : findProp (.sym symbol) o.props = found at hprops
    cases hprops with
    | none =>
      have hproto' := hr.symbolLookup_prototype
      rw [hproto] at hproto'
      have hn : o.proto = .null := hproto'.symbolLookup_null_target
      refine ⟨none,symbolLookup_stop_eq F s₀ symbol fuel a o₀ ho hk hp hproto,
        symbolLookup_stop_eq F s symbol fuel (R.a a) o ho' (hr.ordinary hk) hh hn,.none,?_⟩
      intro q hq
      cases hq

theorem OrdinarySymbolLookup.withStack {S : Type} {s : St S} {symbol : Nat} {fuel a : Nat} {p : Option PropV}
    (h : OrdinarySymbolLookup s symbol fuel a p) (fs : List Frame) :
    OrdinarySymbolLookup {s with stack := fs} symbol fuel a p := by
  induction h with
  | hit fuel a o p ho hk hp => exact .hit fuel a o p ho hk hp
  | next fuel a b o ho hk hp ht path ih => exact .next fuel a b o ho hk hp ht ih
  | stop fuel a o ho hk hp ht => exact .stop fuel a o ho hk hp ht


end Host.Ts.Owned.Parametric
