import host.sim.steps.Props
namespace Host.Ts.Sim

/-! # Calls and constructions: control `.call` and `.construct`

Closures are entered in lockstep: both sides allocate the `this`/home cells
and one cell per parameter name at the same counters (`allocCells_adv`), so
the new environments correspond. Function objects are never framed (framed
addresses hold arrays). Intrinsic prototypes are fixed by the map (`Rel.intr`). -/

/-- The environment and state after the `this`/home cells of `enterClosure`. -/
def ecEnv {S : Type} (s : St S) (cenv : Env) (arrow : Bool) (home this : Val) : Env × St S :=
  bif arrow then (cenv, s) else
    let (c, s) := s.alloc (.cell (some this))
    let env := (nThis, c) :: cenv
    match home with
    | .undef => (env, s)
    | h => let (c2, s) := s.alloc (.cell (some h)); ((nHome, c2) :: env, s)

theorem enterClosure_eq (F : Ffi) (s : St F.S) (f : Func) (cenv : Env) (arrow : Bool) (home this : Val)
    (args : List Val) (b : Boundary) :
    enterClosure F s f cenv arrow home this args b =
      .pure ((((allocCells (ecEnv s cenv arrow home this).2 (paramNames f) (ecEnv s cenv arrow home this).1).2.push
        (.k (.fn b))).push (.k (.params f (fnParams f) args
          (allocCells (ecEnv s cenv arrow home this).2 (paramNames f) (ecEnv s cenv arrow home this).1).1))).ret .undef) := by
  cases arrow <;> cases home <;> rfl


/-! ## Lockstep updates -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {S : SSrv} {C : CSrv}

/-- A state update under the relation: related results, growing presence, at most `k` allocations. -/
structure Adv (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (M : Map) (ν : Nat → F64) (K : Ctx)
    (S : SSrv) (C : CSrv) (s s' t' : St F.S) (k : Nat) : Prop where
  rel : Rel F FR M ν K s' S t' C
  pres : ∀ a, Present s a → Present s' a
  next : s'.next ≤ s.next + k
  mono : s.next ≤ s'.next

theorem Adv.refl {s t : St F.S} (h : Rel F FR M ν K s S t C) : Adv F FR M ν K S C s s t 0 :=
  ⟨h, fun _ hp => hp, Nat.le_refl _, Nat.le_refl _⟩

theorem Adv.trans {s s1 s2 t1 t2 : St F.S} {k1 k2 : Nat} (h1 : Adv F FR M ν K S C s s1 t1 k1)
    (h2 : Adv F FR M ν K S C s1 s2 t2 k2) : Adv F FR M ν K S C s s2 t2 (k1 + k2) :=
  ⟨h2.rel, fun a hp => h2.pres a (h1.pres a hp), by have := h1.next; have := h2.next; omega,
    Nat.le_trans h1.mono h2.mono⟩

theorem Adv.weaken {s s' t' : St F.S} {k k' : Nat} (h : Adv F FR M ν K S C s s' t' k) (hk : k ≤ k') :
    Adv F FR M ν K S C s s' t' k' :=
  ⟨h.rel, h.pres, by have := h.next; omega, h.mono⟩

theorem Adv.lt {s s' t' : St F.S} {k j : Nat} (h : Adv F FR M ν K S C s s' t' k)
    (hn : s.next + (k + j) < Sim.bound) : s'.next + j < Sim.bound := by
  have := h.next; omega

/-- Support transported along an update. -/
theorem Adv.val {s s' t' : St F.S} {k : Nat} (h : Adv F FR M ν K S C s s' t' k) {v : Val}
    (hv : Supp.val (Present s) S.tab.length v) : Supp.val (Present s') S.tab.length v :=
  Supp.val_mono h.pres (Nat.le_refl _) hv

theorem Adv.vals {s s' t' : St F.S} {k : Nat} (h : Adv F FR M ν K S C s s' t' k) {vs : List Val}
    (hv : Supp.vals (Present s) S.tab.length vs) : Supp.vals (Present s') S.tab.length vs :=
  Supp.vals_mono h.pres (Nat.le_refl _) hv

theorem Adv.env {s s' t' : St F.S} {k : Nat} (h : Adv F FR M ν K S C s s' t' k) {e : Env}
    (he : Supp.env (Present s) S.tab.length e) : Supp.env (Present s') S.tab.length e :=
  Supp.env_mono h.pres (Nat.le_refl _) he

/-- Counters below the bound stay inside the stores' range. -/
theorem fn_s64 {s : St F.S} (hn : s.next < Sim.bound) : s.next < 2 ^ 64 := by
  have hb : Sim.bound = 2 ^ 61 := rfl
  rw [hb] at hn
  omega

theorem adv_alloc {s t : St F.S} (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) (o : HObj)
    (ho : Supp.hobj (Present s) S.tab.length o) :
    (t.alloc (M.hobj o)).1 = M.a (s.alloc o).1 ∧ (s.alloc o).1 = s.next ∧ Present (s.alloc o).2 s.next ∧
      Adv F FR M ν K S C s (s.alloc o).2 (t.alloc (M.hobj o)).2 1 := by
  have hs64 := fn_s64 hn
  have hP : ∀ a, Present s a → Present (s.alloc o).2 a := fun _ hp => Present.alloc _ hs64 hp
  obtain ⟨e, hr⟩ := h.alloc o hn (Supp.hobj_mono hP (Nat.le_refl _) ho)
  exact ⟨e, rfl, Present.alloc_next s _ hs64, hr, hP, Nat.le_refl _, Nat.le_succ _⟩

/-- A new cell: the target allocates the image cell at the image address. -/
theorem adv_cell {s t : St F.S} (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) (v : Option Val)
    (hv : Supp.hobj (Present s) S.tab.length (.cell v)) :
    (t.alloc (.cell (v.map M.val))).1 = M.a s.next ∧ Present (s.alloc (.cell v)).2 s.next ∧
      Adv F FR M ν K S C s (s.alloc (.cell v)).2 (t.alloc (.cell (v.map M.val))).2 1 := by
  obtain ⟨e1, _, hp, ha⟩ := adv_alloc h hn (.cell v) hv
  exact ⟨e1, hp, ha⟩

/-- An object with an intrinsic prototype: the target allocates the image at the image address. -/
theorem adv_allocObj {s t : St F.S} (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) (k : Kind)
    (p : Nat) (ps : Props) (hI : M.a p = p) (hp : Present s p)
    (hk : Supp.kind (Present s) S.tab.length k) (hps : Supp.props (Present s) S.tab.length ps) :
    (t.allocObj (M.kind k) (.obj p) (M.props ps)).1 = M.a s.next ∧
      (s.allocObj k (.obj p) ps).1 = s.next ∧ Present (s.allocObj k (.obj p) ps).2 s.next ∧
      Adv F FR M ν K S C s (s.allocObj k (.obj p) ps).2 (t.allocObj (M.kind k) (.obj p) (M.props ps)).2 1 := by
  have hs64 := fn_s64 hn
  have hP : ∀ a, Present s a → Present (s.allocObj k (.obj p) ps).2 a := fun _ ha => Present.alloc _ hs64 ha
  have hv : M.val (.obj p) = .obj p := by show Val.obj (M.a p) = .obj p; rw [hI]
  obtain ⟨e, hr⟩ := h.allocObj k (.obj p) ps hn (Supp.kind_mono hP (Nat.le_refl _) hk) (hP p hp)
    (Supp.props_mono hP (Nat.le_refl _) hps)
  rw [hv] at e hr
  exact ⟨e, rfl, Present.alloc_next s _ hs64, hr, hP, Nat.le_refl _, Nat.le_succ _⟩

/-! ## Cells for names -/

theorem allocCells_cons {S' : Type} (s : St S') (n : Name) (ns : List Name) (env : Env) :
    allocCells s (n :: ns) env = allocCells (s.alloc (.cell none)).2 ns ((n, s.next) :: env) := rfl

theorem allocCells_adv : ∀ (ns : List Name) (s t : St F.S) (env : Env),
    Rel F FR M ν K s S t C → s.next + ns.length < Sim.bound → Supp.env (Present s) S.tab.length env →
    (allocCells t ns (M.env env)).1 = M.env (allocCells s ns env).1 ∧
    Adv F FR M ν K S C s (allocCells s ns env).2 (allocCells t ns (M.env env)).2 ns.length ∧
    Supp.env (Present (allocCells s ns env).2) S.tab.length (allocCells s ns env).1
  | [], _, _, _, h, _, he => ⟨rfl, Adv.refl h, he⟩
  | n :: ns, s, t, env, h, hn, he => by
    have hn0 : s.next < Sim.bound := by simp only [List.length_cons] at hn; omega
    obtain ⟨e1, hp, ha⟩ := adv_cell h hn0 none trivial
    have hn1 : (s.alloc (.cell none)).2.next + ns.length < Sim.bound := by
      show s.next + 1 + ns.length < Sim.bound
      simp only [List.length_cons] at hn; omega
    have he1 : Supp.env (Present (s.alloc (.cell none)).2) S.tab.length ((n, s.next) :: env) := by
      intro x hx
      rcases List.mem_cons.1 hx with rfl | hx
      · exact hp
      · exact ha.pres _ (he x hx)
    obtain ⟨r1, r2, r3⟩ := allocCells_adv ns _ _ _ ha.rel hn1 he1
    have ht : allocCells t (n :: ns) (M.env env) =
        allocCells (t.alloc (.cell none)).2 ns (M.env ((n, s.next) :: env)) := by
      rw [allocCells_cons]
      show allocCells (t.alloc (.cell none)).2 ns ((n, (t.alloc (.cell none)).1) :: M.env env) = _
      rw [show (t.alloc (.cell none)).1 = M.a s.next from e1]
      rfl
    rw [ht, allocCells_cons]
    exact ⟨r1, (ha.trans r2).weaken (by simp only [List.length_cons]; omega), r3⟩

/-- Cells of `allocCells` are fresh: a name of the list resolves to a new cell. -/
theorem allocCells_lookup {S' : Type} : ∀ (ns : List Name) (s : St S') (env : Env) (n : Name) (c : Nat),
    lookupEnv n (allocCells s ns env).1 = some c → s.next ≤ c ∨ lookupEnv n env = some c
  | [], _, _, _, _, hl => .inr hl
  | m :: ns, s, env, n, c, hl => by
    rw [allocCells_cons] at hl
    rcases allocCells_lookup ns _ _ n c hl with h1 | h1
    · exact .inl (Nat.le_of_succ_le h1)
    · change brec (Nat.beq (pack n) (pack m)) (some s.next) (lookupEnv n env) = some c at h1
      cases hb : Nat.beq (pack n) (pack m)
      · rw [hb] at h1; exact .inr h1
      · rw [hb] at h1; exact .inl (Nat.le_of_eq (Option.some.inj h1))

theorem allocCells_lookup_mem {S' : Type} : ∀ (ns : List Name) (s : St S') (env : Env) (n : Name) (c : Nat),
    n ∈ ns → lookupEnv n (allocCells s ns env).1 = some c → s.next ≤ c
  | [], _, _, _, _, hm, _ => absurd hm (List.not_mem_nil)
  | m :: ns, s, env, n, c, hm, hl => by
    rw [allocCells_cons] at hl
    by_cases hn : n ∈ ns
    · exact Nat.le_of_succ_le (allocCells_lookup_mem ns _ _ n c hn hl)
    · have hnm : n = m := by
        rcases List.mem_cons.1 hm with h | h
        · exact h
        · exact absurd h hn
      subst hnm
      rcases allocCells_lookup ns _ _ n c hl with h1 | h1
      · exact Nat.le_of_succ_le h1
      · change brec (Nat.beq (pack n) (pack n)) (some s.next) (lookupEnv n env) = some c at h1
        rw [Nat.beq_refl] at h1
        exact Nat.le_of_eq (Option.some.inj h1)

theorem allocCells_next {S' : Type} : ∀ (ns : List Name) (s : St S') (env : Env),
    (allocCells s ns env).2.next = s.next + ns.length
  | [], _, _ => rfl
  | _ :: ns, s, env => by
    rw [allocCells_cons, allocCells_next ns]
    show s.next + 1 + ns.length = _
    simp only [List.length_cons]; omega

end

/-! ## Entering a closure -/

theorem Map.val_ne_undef (M : Map) {v : Val} (hv : v ≠ .undef) : M.val v ≠ .undef := by
  cases v <;> simp_all [Map.val]

theorem ecEnv_true {S' : Type} (s : St S') (cenv : Env) (home this : Val) :
    ecEnv s cenv true home this = (cenv, s) := rfl

theorem ecEnv_undef {S' : Type} (s : St S') (cenv : Env) (this : Val) :
    ecEnv s cenv false .undef this = ((nThis, s.next) :: cenv, (s.alloc (.cell (some this))).2) := rfl

theorem ecEnv_home {S' : Type} (s : St S') (cenv : Env) {home : Val} (this : Val) (hu : home ≠ .undef) :
    ecEnv s cenv false home this = ((nHome, (s.alloc (.cell (some this))).2.next) :: (nThis, s.next) :: cenv,
      ((s.alloc (.cell (some this))).2.alloc (.cell (some home))).2) := by
  cases home <;> first | exact absurd rfl hu | rfl

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {S : SSrv} {C : CSrv}

theorem ecEnv_adv {s t : St F.S} (h : Rel F FR M ν K s S t C) (hn : s.next + 2 < Sim.bound) (cenv : Env)
    (arrow : Bool) {home this : Val} (hce : Supp.env (Present s) S.tab.length cenv)
    (hh : Supp.val (Present s) S.tab.length home) (hth : Supp.val (Present s) S.tab.length this) :
    (ecEnv t (M.env cenv) arrow (M.val home) (M.val this)).1 = M.env (ecEnv s cenv arrow home this).1 ∧
    Adv F FR M ν K S C s (ecEnv s cenv arrow home this).2
      (ecEnv t (M.env cenv) arrow (M.val home) (M.val this)).2 2 ∧
    Supp.env (Present (ecEnv s cenv arrow home this).2) S.tab.length (ecEnv s cenv arrow home this).1 := by
  cases arrow with
  | true =>
    rw [ecEnv_true, ecEnv_true]
    exact ⟨rfl, (Adv.refl h).weaken (Nat.zero_le _), hce⟩
  | false =>
    obtain ⟨e1, hp1, a1⟩ := adv_cell h (by omega) (some this) hth
    have he1 : Supp.env (Present (s.alloc (.cell (some this))).2) S.tab.length ((nThis, s.next) :: cenv) := by
      intro x hx
      rcases List.mem_cons.1 hx with rfl | hx
      · exact hp1
      · exact a1.pres _ (hce x hx)
    by_cases hu : home = .undef
    · subst hu
      rw [show M.val Val.undef = Val.undef from rfl, ecEnv_undef, ecEnv_undef]
      refine ⟨?_, a1.weaken (by omega), he1⟩
      show (nThis, (t.alloc (.cell (some (M.val this)))).1) :: M.env cenv = _
      rw [show (t.alloc (.cell (some (M.val this)))).1 = M.a s.next from e1]
      rfl
    · rw [ecEnv_home s cenv this hu, ecEnv_home t (M.env cenv) (M.val this) (M.val_ne_undef hu)]
      have hn1 : (s.alloc (.cell (some this))).2.next < Sim.bound := by
        show s.next + 1 < Sim.bound; omega
      obtain ⟨e2, hp2, a2⟩ := adv_cell a1.rel hn1 (some home) (a1.val hh)
      refine ⟨?_, a1.trans a2, ?_⟩
      · show (nHome, (t.alloc (.cell (some (M.val this)))).2.next) ::
          (nThis, (t.alloc (.cell (some (M.val this)))).1) :: M.env cenv = _
        rw [show (t.alloc (.cell (some (M.val this)))).1 = M.a s.next from e1]
        have : (t.alloc (.cell (some (M.val this)))).2.next = M.a (s.alloc (.cell (some this))).2.next := by
          show t.next + 1 = M.a (s.next + 1)
          rw [h.next 1]
        rw [this]
        rfl
      · intro x hx
        rcases List.mem_cons.1 hx with rfl | hx
        · exact hp2
        · exact a2.pres _ (he1 x hx)

theorem margin_split {s : St F.S} {m : Nat} (hn : s.next + m < Sim.bound) (j : Nat) (hj : j ≤ m) :
    s.next + j < Sim.bound := by
  omega

/-- Entering a closure: cells for `this`, the home object and the parameter names, then
the boundary and parameter frames. -/
theorem enterClosure_sim {s t : St F.S} (h : Rel F FR M ν K s S t C) (f : Func) (cenv : Env)
    (arrow : Bool) {home this : Val} {args : List Val} {b : Boundary} (hn : s.next + 2 ^ 21 < Sim.bound)
    (hlen : (paramNames f).length ≤ 2 ^ 20) (hce : Supp.env (Present s) S.tab.length cenv)
    (hh : Supp.val (Present s) S.tab.length home) (hth : Supp.val (Present s) S.tab.length this)
    (has : Supp.vals (Present s) S.tab.length args) (hb : Supp.bnd (Present s) S.tab.length b) :
    MSim (StepPost F FR M ν K S C) S C (enterClosure F s f cenv arrow home this args b)
      (enterClosure F t f (M.env cenv) arrow (M.val home) (M.val this) (M.vals args) (M.bnd b)) := by
  rw [enterClosure_eq, enterClosure_eq]
  obtain ⟨e1, a1, he1⟩ := ecEnv_adv h (margin_split hn 2 (by decide)) cenv arrow hce hh hth
  rw [e1]
  obtain ⟨e2, a2, he2⟩ := allocCells_adv (paramNames f) _ _ _ a1.rel
    (a1.lt (margin_split hn (2 + (paramNames f).length) (by omega))) he1
  rw [e2]
  have a := a1.trans a2
  have hr := ((a.rel.push (.k (.fn b)) (Supp.bnd_mono a.pres (Nat.le_refl _) hb)).push
    (.k (.params f (fnParams f) args _)) ⟨a.vals has, he2⟩).ret .undef trivial
  exact MSim.pure ⟨Grow.refl h.srv, hr⟩

end

/-! ## Function objects -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- Function objects are never framed: the target holds the image. -/
theorem Rel.fnObj (h : Rel F FR M ν K s S t C) {a : Nat} {o : Obj} {c : Code}
    (ho : s.obj? a = some o) (hk : o.kind = .fn c) : t.obj? (M.a a) = some (M.obj o) := by
  cases hfr : K.fr a with
  | none => exact h.obj? ho hfr
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    obtain ⟨_, _, xs, hk', _⟩ := h.obj?_framed ho hfr
    rw [hk] at hk'
    cases hk'

theorem Rel.fnCode_supp (h : Rel F FR M ν K s S t C) {a : Nat} {o : Obj} {c : Code}
    (ho : s.obj? a = some o) (hk : o.kind = .fn c) : Supp.code (Present s) S.tab.length c := by
  have := (h.obj?_supp ho).1
  rw [hk] at this
  exact this

theorem Map.obj_kind_fn (M : Map) {o : Obj} {c : Code} (hk : o.kind = .fn c) :
    (M.obj o).kind = .fn (M.code c) := by
  show M.kind o.kind = _
  rw [hk]
  rfl

/-- A non-function object has a non-function target image (framed or not). -/
theorem Rel.nonFnObj (h : Rel F FR M ν K s S t C) {a : Nat} {o : Obj}
    (ho : s.obj? a = some o) (hk : ∀ c, o.kind ≠ .fn c) :
    ∃ o', t.obj? (M.a a) = some o' ∧ ∀ c, o'.kind ≠ .fn c := by
  cases hfr : K.fr a with
  | none =>
    refine ⟨M.obj o, h.obj? ho hfr, fun c hc => ?_⟩
    change M.kind o.kind = _ at hc
    cases hko : o.kind <;> rw [hko] at hc <;> first | exact hk _ hko | cases hc
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    obtain ⟨o', ht, xs, _, rfl⟩ := h.obj?_framed ho hfr
    exact ⟨_, ht, fun c hc => by cases hc⟩

theorem Rel.callTop (h : Rel F FR M ν K s S t C) {f th : Val} {args : List Val}
    (hc : s.ctl = .call f th args) :
    step F s = callStep F s f th args ∧ step F t = callStep F t (M.val f) (M.val th) (M.vals args) ∧
      Supp.val (Present s) S.tab.length f ∧ Supp.val (Present s) S.tab.length th ∧
      Supp.vals (Present s) S.tab.length args := by
  have htc : t.ctl = .call (M.val f) (M.val th) (M.vals args) := by rw [h.ctl, hc]; rfl
  have hs := h.ctlSupp
  rw [hc] at hs
  exact ⟨by simp only [step, hc], by simp only [step, htc], hs⟩

theorem Rel.constructTop (h : Rel F FR M ν K s S t C) {f nt : Val} {args : List Val}
    (hc : s.ctl = .construct f args nt) :
    step F s = constructStep F s f args nt ∧
      step F t = constructStep F t (M.val f) (M.vals args) (M.val nt) ∧
      Supp.val (Present s) S.tab.length f ∧ Supp.vals (Present s) S.tab.length args ∧
      Supp.val (Present s) S.tab.length nt := by
  have htc : t.ctl = .construct (M.val f) (M.vals args) (M.val nt) := by rw [h.ctl, hc]; rfl
  have hs := h.ctlSupp
  rw [hc] at hs
  exact ⟨by simp only [step, hc], by simp only [step, htc], hs⟩

theorem Supp.vals_append {A : Nat → Prop} {n : Nat} {xs ys : List Val} (hx : Supp.vals A n xs)
    (hy : Supp.vals A n ys) : Supp.vals A n (xs ++ ys) := fun v hv =>
  (List.mem_append.1 hv).elim (hx v) (hy v)

theorem Map.vals_append (M : Map) (xs ys : List Val) : M.vals (xs ++ ys) = M.vals xs ++ M.vals ys :=
  List.map_append

/-! ## Calls -/

/-- Calling a closure enters it (`enterClosure` with the `call` boundary). -/
theorem step_call_closure (h : Rel F FR M ν K s S t C) {a : Nat} {th : Val} {args : List Val} {o : Obj}
    {fn : Func} {cenv : Env} {arrow : Bool} {home : Val}
    (hc : s.ctl = .call (.obj a) th args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.closure fn cenv arrow home))
    (hlen : (paramNames fn).length ≤ 2 ^ 20) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, hth, has⟩ := h.callTop hc
  have hto := h.fnObj ho hk
  have hk' := M.obj_kind_fn hk
  have ⟨hce, hh⟩ := h.fnCode_supp ho hk
  rw [e1, e2]
  simp only [callStep, Map.val, ho, hk, hto, hk', Map.code]
  exact enterClosure_sim h fn cenv arrow (margin_split hn _ (by decide)) hlen hce hh hth has trivial

/-- Calling a bound function calls its target with the bound `this` and arguments first. -/
theorem step_call_bound (h : Rel F FR M ν K s S t C) {a : Nat} {th : Val} {args : List Val} {o : Obj}
    {tg th0 : Val} {as : List Val}
    (hc : s.ctl = .call (.obj a) th args) (ho : s.obj? a = some o) (hk : o.kind = .fn (.bound tg th0 as)) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, -, has⟩ := h.callTop hc
  have hto := h.fnObj ho hk
  have hk' := M.obj_kind_fn hk
  have ⟨htg, hth0, has0⟩ := h.fnCode_supp ho hk
  rw [e1, e2]
  simp only [callStep, Map.val, ho, hk, hto, hk', Map.code]
  have hr := h.go (.call tg th0 (as ++ args)) ⟨htg, hth0, Supp.vals_append has0 has⟩
  rw [show M.ctl (.call tg th0 (as ++ args)) = .call (M.val tg) (M.val th0) (M.vals as ++ M.vals args) by
    simp only [Map.ctl, Map.vals_append]] at hr
  exact MSim.pure ⟨Grow.refl h.srv, hr⟩

/-- Calling a class constructor without `new` throws a `TypeError`. -/
theorem step_call_klass (h : Rel F FR M ν K s S t C) {a : Nat} {th : Val} {args : List Val} {o : Obj}
    {ctor : Option Func} {cenv : Env} {par : Val} {inst : List InstMember}
    (hc : s.ctl = .call (.obj a) th args) (ho : s.obj? a = some o) (hk : o.kind = .fn (.klass ctor cenv par inst))
    (hP : Present s aTypeErrorProto) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -⟩ := h.callTop hc
  have hto := h.fnObj ho hk
  have hk' := M.obj_kind_fn hk
  rw [e1, e2]
  simp only [callStep, Map.val, ho, hk, hto, hk', Map.code]
  exact typeErr_sim h h.intr (margin_split hn 0 (Nat.zero_le _)) hP _

theorem callStep_nonFn (s : St F.S) {a : Nat} {o : Obj} {th : Val} {args : List Val}
    (ho : s.obj? a = some o) (hk : ∀ c, o.kind ≠ .fn c) :
    callStep F s (.obj a) th args = typeErr s (chars!"not a function") := by
  simp only [callStep, ho]

/-- Calling an object that is not a function throws a `TypeError`. -/
theorem step_call_nonFn (h : Rel F FR M ν K s S t C) {a : Nat} {th : Val} {args : List Val} {o : Obj}
    (hc : s.ctl = .call (.obj a) th args) (ho : s.obj? a = some o) (hk : ∀ c, o.kind ≠ .fn c)
    (hP : Present s aTypeErrorProto) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -⟩ := h.callTop hc
  obtain ⟨o', hto, hk'⟩ := h.nonFnObj ho hk
  rw [e1, e2]
  show MSim _ S C (callStep F s (.obj a) th args) (callStep F t (.obj (M.a a)) (M.val th) (M.vals args))
  rw [callStep_nonFn s ho hk, callStep_nonFn t hto hk']
  exact typeErr_sim h h.intr (margin_split hn 0 (Nat.zero_le _)) hP _

/-- Calling a primitive throws a `TypeError`. -/
theorem step_call_prim (h : Rel F FR M ν K s S t C) {f th : Val} {args : List Val}
    (hc : s.ctl = .call f th args) (hf : ∀ a, f ≠ .obj a)
    (hP : Present s aTypeErrorProto) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -⟩ := h.callTop hc
  rw [e1, e2]
  have hm := typeErr_sim h h.intr (margin_split hn 0 (Nat.zero_le _)) hP (chars!"not a function")
  cases f with
  | obj a => exact absurd rfl (hf a)
  | _ => exact hm

end

/-! ## Constructions -/

/-- The prototype of a base-class instance: `newTarget.prototype` if an object. -/
def instProto : Option Val → Val
  | some (.obj p) => .obj p
  | _ => .obj aObjectProto

/-- A base-class construction after reading `newTarget.prototype`. -/
def baseCtor (F : Ffi) (s : St F.S) (ctor : Option Func) (cenv : Env) (inst : List InstMember)
    (args : List Val) (proto : Val) : RS F :=
  let s1 := (s.allocObj .ordinary proto []).2
  let ob := (s.allocObj .ordinary proto []).1
  let s2 := (s1.alloc (.cell (some (.obj ob)))).2
  let tc := (s1.alloc (.cell (some (.obj ob)))).1
  let s3 := match ctor with
    | none => s2.push (.e (.const (.obj ob)))
    | some fn => s2.push (.k (.ctorBody (.obj ob) fn cenv args))
  .pure ((s3.push (.k (.fields ob inst ((nThis, tc) :: cenv)))).ret .undef)

/-- A derived-class construction: cells for `this`, the class and `new.target`. -/
def derivedCtor (F : Ffi) (s : St F.S) (a : Nat) (ctor : Option Func) (cenv : Env) (par : Val)
    (args : List Val) (nt : Val) : RS F :=
  let s1 := (s.alloc (.cell none)).2
  let tc := (s.alloc (.cell none)).1
  let s2 := (s1.alloc (.cell (some (.obj a)))).2
  let cc := (s1.alloc (.cell (some (.obj a)))).1
  let s3 := (s2.alloc (.cell (some nt))).2
  let nc := (s2.alloc (.cell (some nt))).1
  let env := (nThis, tc) :: (nCls, cc) :: (nNt, nc) :: cenv
  match ctor with
  | none => .pure (((s3.push (.k (.fn (.derived tc)))).push (.k (.superRet tc a env))).go (.construct par args nt))
  | some fn => enterClosure F s3 fn env true .undef .undef args (.derived tc)

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

theorem constructStep_base (s : St F.S) {a : Nat} {o : Obj} {args : List Val} {nt : Val}
    {ctor : Option Func} {cenv : Env} {inst : List InstMember}
    (ho : s.obj? a = some o) (hk : o.kind = .fn (.klass ctor cenv .null inst)) :
    constructStep F s (.obj a) args nt =
      .bind (dataOf F s nt kPrototype) fun pr => baseCtor F s ctor cenv inst args (instProto pr) := by
  simp only [constructStep, ho, hk]
  congr

theorem constructStep_derived (s : St F.S) {a : Nat} {o : Obj} {args : List Val} {nt : Val}
    {ctor : Option Func} {cenv : Env} {par : Val} {inst : List InstMember}
    (ho : s.obj? a = some o) (hk : o.kind = .fn (.klass ctor cenv par inst)) (hpar : par ≠ .null) :
    constructStep F s (.obj a) args nt = derivedCtor F s a ctor cenv par args nt := by
  simp only [constructStep, ho, hk]
  cases par <;> first | exact absurd rfl hpar | cases ctor <;> rfl

theorem constructStep_closure (s : St F.S) {a : Nat} {o : Obj} {args : List Val} {nt : Val}
    {fn : Func} {cenv : Env} {home : Val}
    (ho : s.obj? a = some o) (hk : o.kind = .fn (.closure fn cenv false home)) :
    constructStep F s (.obj a) args nt =
      enterClosure F (s.allocObj .ordinary (.obj aObjectProto) []).2 fn cenv false .undef
        (.obj (s.allocObj .ordinary (.obj aObjectProto) []).1) args
        (.ctor (.obj (s.allocObj .ordinary (.obj aObjectProto) []).1)) := by
  simp only [constructStep, ho, hk]

theorem constructStep_nonFn (s : St F.S) {a : Nat} {o : Obj} {args : List Val} {nt : Val}
    (ho : s.obj? a = some o) (hk : ∀ c, o.kind ≠ .fn c) :
    constructStep F s (.obj a) args nt = typeErr s (chars!"not a constructor") := by
  simp only [constructStep, ho]

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

theorem derivedCtor_sim (h : Rel F FR M ν K s S t C) {a : Nat} {ctor : Option Func} {cenv : Env}
    {par : Val} {args : List Val} {nt : Val} (hn : s.next + margin < Sim.bound)
    (hlen : ∀ fn, ctor = some fn → (paramNames fn).length ≤ 2 ^ 20) (ha : Present s a)
    (hce : Supp.env (Present s) S.tab.length cenv) (hpar : Supp.val (Present s) S.tab.length par)
    (has : Supp.vals (Present s) S.tab.length args) (hnt : Supp.val (Present s) S.tab.length nt) :
    MSim (StepPost F FR M ν K S C) S C (derivedCtor F s a ctor cenv par args nt)
      (derivedCtor F t (M.a a) ctor (M.env cenv) (M.val par) (M.vals args) (M.val nt)) := by
  obtain ⟨e1, -, hp1, a1⟩ := adv_alloc h (margin_split hn 0 (Nat.zero_le _)) (.cell none) trivial
  obtain ⟨e2, -, hp2, a2⟩ := adv_alloc a1.rel (a1.lt (margin_split hn (1 + 0) (by decide)))
    (.cell (some (.obj a))) (a1.pres a ha)
  obtain ⟨e3, -, hp3, a3⟩ := adv_alloc a2.rel ((a1.trans a2).lt (margin_split hn (1 + 1 + 0) (by decide)))
    (.cell (some nt)) (a2.val (a1.val hnt))
  have e1' : (t.alloc (.cell none)).1 = M.a (s.alloc (.cell none)).1 := e1
  have e2' : ((t.alloc (.cell none)).2.alloc (.cell (some (.obj (M.a a))))).1 =
      M.a ((s.alloc (.cell none)).2.alloc (.cell (some (.obj a)))).1 := e2
  have e3' : (((t.alloc (.cell none)).2.alloc (.cell (some (.obj (M.a a))))).2.alloc (.cell (some (M.val nt)))).1 =
      M.a ((((s.alloc (.cell none)).2.alloc (.cell (some (.obj a)))).2.alloc (.cell (some nt)))).1 := e3
  have a123 := a1.trans (a2.trans a3)
  have hP1 : Present (((s.alloc (.cell none)).2.alloc (.cell (some (.obj a)))).2.alloc (.cell (some nt))).2
      (s.alloc (.cell none)).1 := a3.pres _ (a2.pres _ hp1)
  have hP2 : Present (((s.alloc (.cell none)).2.alloc (.cell (some (.obj a)))).2.alloc (.cell (some nt))).2
      ((s.alloc (.cell none)).2.alloc (.cell (some (.obj a)))).1 := a3.pres _ hp2
  have hP3 : Present (((s.alloc (.cell none)).2.alloc (.cell (some (.obj a)))).2.alloc (.cell (some nt))).2
      (((s.alloc (.cell none)).2.alloc (.cell (some (.obj a)))).2.alloc (.cell (some nt))).1 := hp3
  have henv : Supp.env (Present (((s.alloc (.cell none)).2.alloc (.cell (some (.obj a)))).2.alloc (.cell (some nt))).2)
      S.tab.length ((nThis, (s.alloc (.cell none)).1) :: (nCls, ((s.alloc (.cell none)).2.alloc (.cell (some (.obj a)))).1) ::
        (nNt, (((s.alloc (.cell none)).2.alloc (.cell (some (.obj a)))).2.alloc (.cell (some nt))).1) :: cenv) := by
    intro x hx
    simp only [List.mem_cons] at hx
    rcases hx with rfl | rfl | rfl | hx
    · exact hP1
    · exact hP2
    · exact hP3
    · exact a123.pres _ (hce x hx)
  unfold derivedCtor
  dsimp only
  rw [e1', e2', e3']
  cases ctor with
  | none =>
    have hr := ((a123.rel.push (.k (.fn (.derived (s.alloc (.cell none)).1))) hP1).push
      (.k (.superRet (s.alloc (.cell none)).1 a _)) ⟨hP1, a123.pres a ha, henv⟩).go
      (.construct par args nt) ⟨a123.val hpar, a123.vals has, a123.val hnt⟩
    exact MSim.pure ⟨Grow.refl h.srv, hr⟩
  | some fn =>
    exact enterClosure_sim a123.rel fn _ true (home := .undef) (this := .undef)
      (b := .derived (s.alloc (.cell none)).1)
      (a123.lt (margin_split hn (1 + (1 + 1) + 2 ^ 21) (by decide))) (hlen fn rfl) henv trivial trivial
      (a123.vals has) hP1

theorem baseCtor_sim (h : Rel F FR M ν K s S t C) {ctor : Option Func} {cenv : Env}
    {inst : List InstMember} {args : List Val} {proto : Val} (hn : s.next + margin < Sim.bound)
    (hce : Supp.env (Present s) S.tab.length cenv) (hinst : Supp.insts (Present s) S.tab.length inst)
    (has : Supp.vals (Present s) S.tab.length args) (hpr : Supp.val (Present s) S.tab.length proto) :
    MSim (StepPost F FR M ν K S C) S C (baseCtor F s ctor cenv inst args proto)
      (baseCtor F t ctor (M.env cenv) (inst.map M.inst) (M.vals args) (M.val proto)) := by
  have hso : Supp.hobj (Present s) S.tab.length (.obj ⟨.ordinary, proto, [], [], true⟩) :=
    by
      refine ⟨trivial, hpr, ?_, ?_⟩
      · intro x hx; exact absurd hx List.not_mem_nil
      · intro x hx; exact absurd hx List.not_mem_nil
  obtain ⟨e1, -, hp1, a1⟩ := adv_alloc h (margin_split hn 0 (Nat.zero_le _)) _ hso
  have e1' : (t.allocObj .ordinary (M.val proto) []).1 = M.a (s.allocObj .ordinary proto []).1 := e1
  obtain ⟨e2, -, hp2, a2⟩ := adv_alloc a1.rel (a1.lt (margin_split hn (1 + 0) (by decide)))
    (.cell (some (.obj (s.allocObj .ordinary proto []).1))) hp1
  have e2' : ((t.allocObj .ordinary (M.val proto) []).2.alloc
      (.cell (some (.obj (M.a (s.allocObj .ordinary proto []).1))))).1 =
      M.a ((s.allocObj .ordinary proto []).2.alloc (.cell (some (.obj (s.allocObj .ordinary proto []).1)))).1 := e2
  have a12 := a1.trans a2
  have hob : Present ((s.allocObj .ordinary proto []).2.alloc (.cell (some (.obj (s.allocObj .ordinary proto []).1)))).2
      (s.allocObj .ordinary proto []).1 := a2.pres _ hp1
  unfold baseCtor
  dsimp only
  rw [e1', e2']
  have hfin : ∀ (s3 : St F.S) (t3 : St F.S), Rel F FR M ν K s3 S t3 C →
      (∀ a, Present ((s.allocObj .ordinary proto []).2.alloc
        (.cell (some (.obj (s.allocObj .ordinary proto []).1)))).2 a → Present s3 a) →
      MSim (StepPost F FR M ν K S C) S C
        (Host.Ts.M.pure ((s3.push (.k (.fields (s.allocObj .ordinary proto []).1 inst
          ((nThis, ((s.allocObj .ordinary proto []).2.alloc
            (.cell (some (.obj (s.allocObj .ordinary proto []).1)))).1) :: cenv)))).ret .undef))
        (Host.Ts.M.pure ((t3.push (.k (.fields (M.a (s.allocObj .ordinary proto []).1) (inst.map M.inst)
          ((nThis, M.a ((s.allocObj .ordinary proto []).2.alloc
            (.cell (some (.obj (s.allocObj .ordinary proto []).1)))).1) :: M.env cenv)))).ret .undef)) := by
    intro s3 t3 hr hP
    have hr' := (hr.push (.k (.fields (s.allocObj .ordinary proto []).1 inst
      ((nThis, ((s.allocObj .ordinary proto []).2.alloc
        (.cell (some (.obj (s.allocObj .ordinary proto []).1)))).1) :: cenv)))
      ⟨hP _ hob, Supp.insts_mono (fun x hx => hP _ (a12.pres _ hx)) (Nat.le_refl _) hinst, fun x hx => by
        rcases List.mem_cons.1 hx with rfl | hx
        · exact hP _ hp2
        · exact hP _ (a12.pres _ (hce x hx))⟩).ret .undef trivial
    exact MSim.pure ⟨Grow.refl h.srv, hr'⟩
  cases ctor with
  | none =>
    exact hfin _ _ (a12.rel.push (.e (.const (.obj (s.allocObj .ordinary proto []).1))) hob) (fun _ hp => hp)
  | some fn =>
    exact hfin _ _ (a12.rel.push (.k (.ctorBody (.obj (s.allocObj .ordinary proto []).1) fn cenv args))
      ⟨hob, a12.env hce, a12.vals has⟩) (fun _ hp => hp)

/-! ### Construction steps -/

/-- `new` of a closure that is not an arrow function: a fresh `this`, then the closure. -/
theorem step_construct_closure (h : Rel F FR M ν K s S t C) {a : Nat} {args : List Val} {nt : Val} {o : Obj}
    {fn : Func} {cenv : Env} {home : Val}
    (hc : s.ctl = .construct (.obj a) args nt) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.closure fn cenv false home))
    (hlen : (paramNames fn).length ≤ 2 ^ 20) (hP : Present s aObjectProto)
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, has, -⟩ := h.constructTop hc
  have hto := h.fnObj ho hk
  have hk' := M.obj_kind_fn hk
  obtain ⟨hce, -⟩ := h.fnCode_supp ho hk
  rw [e1, e2]
  show MSim _ S C (constructStep F s (.obj a) args nt) (constructStep F t (.obj (M.a a)) (M.vals args) (M.val nt))
  rw [constructStep_closure s ho hk, constructStep_closure t hto hk']
  obtain ⟨ea, -, hpa, a1⟩ := adv_allocObj h (margin_split hn 0 (Nat.zero_le _)) .ordinary aObjectProto []
    (h.intr _ (by decide)) hP trivial (fun _ hx => nomatch hx)
  have ea' : (t.allocObj .ordinary (.obj aObjectProto) []).1 = M.a s.next := ea
  rw [ea']
  exact enterClosure_sim a1.rel fn cenv false (home := .undef) (this := .obj s.next) (b := .ctor (.obj s.next))
    (a1.lt (margin_split hn (1 + 2 ^ 21) (by decide))) hlen (a1.env hce) trivial hpa (a1.vals has) hpa

/-- `new` of a bound function: construct its target (`new.target` follows it). -/
theorem step_construct_bound (h : Rel F FR M ν K s S t C) {a : Nat} {args : List Val} {nt : Val} {o : Obj}
    {tg th0 : Val} {as : List Val}
    (hc : s.ctl = .construct (.obj a) args nt) (ho : s.obj? a = some o) (hk : o.kind = .fn (.bound tg th0 as)) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, ha, has, hnt⟩ := h.constructTop hc
  have hto := h.fnObj ho hk
  have hk' := M.obj_kind_fn hk
  obtain ⟨htg, -, has0⟩ := h.fnCode_supp ho hk
  rw [e1, e2]
  have fin : ∀ X, Supp.val (Present s) S.tab.length X →
      MSim (StepPost F FR M ν K S C) S C (Host.Ts.M.pure (s.go (.construct tg (as ++ args) X)))
        (Host.Ts.M.pure (t.go (.construct (M.val tg) (M.vals as ++ M.vals args) (M.val X)))) := by
    intro X hX
    have hr := h.go (.construct tg (as ++ args) X) ⟨htg, Supp.vals_append has0 has, hX⟩
    rw [show M.ctl (.construct tg (as ++ args) X) = .construct (M.val tg) (M.vals as ++ M.vals args) (M.val X) by
      simp only [Map.ctl, Map.vals_append]] at hr
    exact MSim.pure ⟨Grow.refl h.srv, hr⟩
  cases nt with
  | obj b =>
    simp only [constructStep, Map.val, ho, hk, hto, hk', Map.code]
    have hb : Present s b := hnt
    rw [beq_map h.inj ha hb]
    cases Nat.beq a b
    · exact fin (.obj b) hb
    · exact fin tg htg
  | _ =>
    simp only [constructStep, Map.val, ho, hk, hto, hk', Map.code]
    exact fin _ hnt

/-- `new` of a derived class: cells for `this`, the class and `new.target`; then the
explicit constructor (an arrow-like closure) or the parent's construction. -/
theorem step_construct_derived (h : Rel F FR M ν K s S t C) {a : Nat} {args : List Val} {nt : Val} {o : Obj}
    {ctor : Option Func} {cenv : Env} {par : Val} {inst : List InstMember}
    (hc : s.ctl = .construct (.obj a) args nt) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.klass ctor cenv par inst)) (hpar : par ≠ .null)
    (hlen : ∀ fn, ctor = some fn → (paramNames fn).length ≤ 2 ^ 20) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, ha, has, hnt⟩ := h.constructTop hc
  have hto := h.fnObj ho hk
  have hk' := M.obj_kind_fn hk
  obtain ⟨hce, hpa, -⟩ := h.fnCode_supp ho hk
  have hpar' : M.val par ≠ .null := by cases par <;> simp_all [Map.val]
  rw [e1, e2]
  show MSim _ S C (constructStep F s (.obj a) args nt) (constructStep F t (.obj (M.a a)) (M.vals args) (M.val nt))
  rw [constructStep_derived s ho hk hpar, constructStep_derived t hto hk' hpar']
  exact derivedCtor_sim h hn hlen ha hce hpa has hnt

/-- `new` of a base class: the instance's prototype is `newTarget.prototype`; then the
field initializers and the explicit constructor (if any). -/
theorem step_construct_base {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {a : Nat} {args : List Val} {nt : Val}
    {o : Obj} {ctor : Option Func} {cenv : Env} {inst : List InstMember}
    (hc : s.ctl = .construct (.obj a) args nt) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.klass ctor cenv .null inst)) (hP : Present s aObjectProto)
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, has, hnt⟩ := h.constructTop hc
  have hto := h.fnObj ho hk
  have hk' := M.obj_kind_fn hk
  obtain ⟨hce, -, hinst⟩ := h.fnCode_supp ho hk
  rw [e1, e2]
  show MSim _ S C (constructStep F s (.obj a) args nt) (constructStep F t (.obj (M.a a)) (M.vals args) (M.val nt))
  rw [constructStep_base s ho hk, constructStep_base t hto hk']
  refine MSim.bind (dataOf_sim h hF h.intr hnt (k := kPrototype) trivial
    (LookupOK.of_plain (by rfl) (by rfl) nt)) ?_
  rintro M' S' C' r r' ⟨-, hS, hC, rfl, hsupp⟩
  rw [hS, hC]
  have hpr : M.val (instProto r) = instProto (r.map M.val) ∧ Supp.val (Present s) S.tab.length (instProto r) := by
    rcases r with _ | ⟨_ | _ | _ | _ | _ | _ | _ | b | _⟩
    all_goals first
      | exact ⟨show Val.obj (M.a b) = Val.obj (M.a b) from rfl, hsupp _ rfl⟩
      | exact ⟨show Val.obj (M.a aObjectProto) = Val.obj aObjectProto by rw [h.intr _ (by decide)], hP⟩
  rw [← hpr.1]
  exact baseCtor_sim h hn hce hinst has hpr.2

/-- `new` of an arrow function throws a `TypeError`. -/
theorem step_construct_arrow (h : Rel F FR M ν K s S t C) {a : Nat} {args : List Val} {nt : Val} {o : Obj}
    {fn : Func} {cenv : Env} {home : Val}
    (hc : s.ctl = .construct (.obj a) args nt) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.closure fn cenv true home))
    (hP : Present s aTypeErrorProto) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -⟩ := h.constructTop hc
  have hto := h.fnObj ho hk
  have hk' := M.obj_kind_fn hk
  rw [e1, e2]
  simp only [constructStep, Map.val, ho, hk, hto, hk', Map.code]
  exact typeErr_sim h h.intr (margin_split hn 0 (Nat.zero_le _)) hP _

/-- `new` of an object that is not a function throws a `TypeError`. -/
theorem step_construct_nonFn (h : Rel F FR M ν K s S t C) {a : Nat} {args : List Val} {nt : Val} {o : Obj}
    (hc : s.ctl = .construct (.obj a) args nt) (ho : s.obj? a = some o) (hk : ∀ c, o.kind ≠ .fn c)
    (hP : Present s aTypeErrorProto) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -⟩ := h.constructTop hc
  obtain ⟨o', hto, hk'⟩ := h.nonFnObj ho hk
  rw [e1, e2]
  show MSim _ S C (constructStep F s (.obj a) args nt) (constructStep F t (.obj (M.a a)) (M.vals args) (M.val nt))
  rw [constructStep_nonFn s ho hk, constructStep_nonFn t hto hk']
  exact typeErr_sim h h.intr (margin_split hn 0 (Nat.zero_le _)) hP _

/-- `new` of a primitive throws a `TypeError`. -/
theorem step_construct_prim (h : Rel F FR M ν K s S t C) {f nt : Val} {args : List Val}
    (hc : s.ctl = .construct f args nt) (hf : ∀ a, f ≠ .obj a)
    (hP : Present s aTypeErrorProto) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -⟩ := h.constructTop hc
  rw [e1, e2]
  have hm := typeErr_sim h h.intr (margin_split hn 0 (Nat.zero_le _)) hP (chars!"not a constructor")
  cases f with
  | obj a => exact absurd rfl (hf a)
  | _ => exact hm

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- A dangling callee: the source step fails (nothing to simulate). -/
theorem step_call_dangling (h : Rel F FR M ν K s S t C) {a : Nat} {th : Val} {args : List Val}
    (hc : s.ctl = .call (.obj a) th args) (ho : s.obj? a = none) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, -⟩ := h.callTop hc
  rw [e1]
  simp only [callStep, ho]
  exact MSim.fail _ _

theorem step_construct_dangling (h : Rel F FR M ν K s S t C) {a : Nat} {args : List Val} {nt : Val}
    (hc : s.ctl = .construct (.obj a) args nt) (ho : s.obj? a = none) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, -⟩ := h.constructTop hc
  rw [e1]
  simp only [constructStep, ho]
  exact MSim.fail _ _


/-- Dispatch to a native callee (`callNative`), on both sides, with the supports
the builtin simulations need. -/
theorem Rel.callNativeTop (h : Rel F FR M ν K s S t C) {a : Nat} {th : Val} {args : List Val} {o : Obj}
    {n : Native} {data : List Val}
    (hc : s.ctl = .call (.obj a) th args) (ho : s.obj? a = some o) (hk : o.kind = .fn (.native n data)) :
    step F s = callNative F s n data th args ∧
      step F t = callNative F t n (M.vals data) (M.val th) (M.vals args) ∧
      Supp.vals (Present s) S.tab.length data ∧ Supp.val (Present s) S.tab.length th ∧
      Supp.vals (Present s) S.tab.length args := by
  obtain ⟨e1, e2, -, hth, has⟩ := h.callTop hc
  have hto := h.fnObj ho hk
  have hk' := M.obj_kind_fn hk
  refine ⟨?_, ?_, h.fnCode_supp ho hk, hth, has⟩
  · rw [e1]; simp only [callStep, ho, hk]
  · rw [e2]; simp only [callStep, Map.val, hto, hk', Map.code]

/-- Dispatch to a native constructor (`constructNative`), on both sides. -/
theorem Rel.constructNativeTop (h : Rel F FR M ν K s S t C) {a : Nat} {args : List Val} {nt : Val} {o : Obj}
    {n : Native} {data : List Val}
    (hc : s.ctl = .construct (.obj a) args nt) (ho : s.obj? a = some o) (hk : o.kind = .fn (.native n data)) :
    step F s = constructNative F s n data args nt ∧
      step F t = constructNative F t n (M.vals data) (M.vals args) (M.val nt) ∧
      Supp.vals (Present s) S.tab.length data ∧ Supp.vals (Present s) S.tab.length args ∧
      Supp.val (Present s) S.tab.length nt := by
  obtain ⟨e1, e2, -, has, hnt⟩ := h.constructTop hc
  have hto := h.fnObj ho hk
  have hk' := M.obj_kind_fn hk
  refine ⟨?_, ?_, h.fnCode_supp ho hk, has, hnt⟩
  · rw [e1]; simp only [constructStep, ho, hk]
  · rw [e2]; simp only [constructStep, Map.val, hto, hk', Map.code]

end
end Host.Ts.Sim
