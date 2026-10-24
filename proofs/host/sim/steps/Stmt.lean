import host.sim.steps.Props
namespace Host.Ts.Sim

/-! # Statements: execution, statement frames, abrupt completions

Helpers live in `StmtSim` (shared by `Loop` and `Bind`). Block entry allocates one cell
per lexical name and one closure per named function declaration: the counts are side
conditions (`≤ 2 ^ 20`), and closures need `%Function.prototype%` present. Numeric tests
(`if`, loop tests) need bigint operands fixed by the map (`BigFixed`). -/

namespace StmtSim
section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-! ## Unfolding the step -/

theorem step_ex_eq {s : St F.S} {st : Stmt} {env : Env} (hc : s.ctl = .ex st env) :
    step F s = exStep F s st env := by
  simp only [step, hc]

theorem step_ret_eq {s : St F.S} {v : Val} {f : Frame} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = f :: fs) :
    step F s = retStep F { s with stack := fs } f v := by
  simp only [step, hc, stepRet, hs]

theorem step_abr_eq {s : St F.S} {a : Abrupt} {f : Frame} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = f :: fs) :
    step F s = abrStep F { s with stack := fs } f a := by
  simp only [step, hc, stepAbr, hs]

theorem step_bind_eq {s : St F.S} {p : Pat} {v : Val} {env : Env} {m : BindMode} {k : DeclKind}
    (hc : s.ctl = .bind p v env m k) : step F s = bindStep F s p v env m k := by
  simp only [step, hc]

/-- Statement execution on both sides. -/
theorem exTop (h : RelB F FR W stk M ν K s S t C) {st : Stmt} {env : Env} (hc : s.ctl = .ex st env) :
    step F s = exStep F s st env ∧ step F t = exStep F t st (M.env env) ∧
      Supp.env (Present s) S.tab.length env := by
  have htc : t.ctl = .ex st (M.env env) := by rw [h.ctl, hc]; rfl
  refine ⟨step_ex_eq hc, step_ex_eq htc, ?_⟩
  have := h.ctlSupp
  rw [hc] at this
  exact this

/-- A value returning to the top frame, on both sides. -/
theorem retTop (h : RelB F FR W stk M ν K s S t C) {v : Val} {f : Frame} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = f :: fs) :
    step F s = retStep F { s with stack := fs } f v ∧
    step F t = retStep F { t with stack := fs.map M.frame ++ stk } (M.frame f) (M.val v) ∧
    RelB F FR W stk M ν K { s with stack := fs } S { t with stack := fs.map M.frame ++ stk } C ∧
    Supp.val (Present s) S.tab.length v ∧ Supp.frame (Present s) S.tab.length f := by
  obtain ⟨hts, hr⟩ := h.pop hs
  have htc : t.ctl = .ret (M.val v) := by rw [h.ctl, hc]; rfl
  refine ⟨step_ret_eq hc hs, step_ret_eq htc hts, hr, ?_,
    h.stackSupp f (by rw [hs]; exact List.mem_cons_self ..)⟩
  have := h.ctlSupp
  rw [hc] at this
  exact this

/-- An abrupt completion reaching the top frame, on both sides. -/
theorem abrTop (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {f : Frame} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = f :: fs) :
    step F s = abrStep F { s with stack := fs } f a ∧
    step F t = abrStep F { t with stack := fs.map M.frame ++ stk } (M.frame f) (M.abr a) ∧
    RelB F FR W stk M ν K { s with stack := fs } S { t with stack := fs.map M.frame ++ stk } C ∧
    Supp.abr (Present s) S.tab.length a ∧ Supp.frame (Present s) S.tab.length f := by
  obtain ⟨hts, hr⟩ := h.pop hs
  have htc : t.ctl = .abr (M.abr a) := by rw [h.ctl, hc]; rfl
  refine ⟨step_abr_eq hc hs, step_abr_eq htc hts, hr, ?_,
    h.stackSupp f (by rw [hs]; exact List.mem_cons_self ..)⟩
  have := h.ctlSupp
  rw [hc] at this
  exact this

/-! ## Environments -/

theorem lookupEnv_nil (n : Name) : lookupEnv n [] = none := rfl

theorem lookupEnv_cons (n m : Name) (a : Nat) (env : Env) :
    lookupEnv n ((m, a) :: env) = brec (Nat.beq (pack n) (pack m)) (some a) (lookupEnv n env) := rfl

theorem env_lookup_mem {n : Name} : ∀ {env : Env} {c : Nat}, lookupEnv n env = some c → ∃ m, (m, c) ∈ env
  | [], _, hl => by rw [lookupEnv_nil] at hl; cases hl
  | (m, a) :: env, c, hl => by
    rw [lookupEnv_cons] at hl
    cases hb : Nat.beq (pack n) (pack m) with
    | false =>
      rw [hb] at hl
      obtain ⟨m', hm⟩ := env_lookup_mem (env := env) hl
      exact ⟨m', List.mem_cons_of_mem _ hm⟩
    | true =>
      rw [hb] at hl
      cases hl
      exact ⟨m, List.mem_cons_self ..⟩

theorem env_lookup_supp {A : Nat → Prop} {k : Nat} {env : Env} {n : Name} {c : Nat}
    (he : Supp.env A k env) (hl : lookupEnv n env = some c) : A c := by
  obtain ⟨m, hm⟩ := env_lookup_mem hl
  exact he _ hm

theorem lookupEnv_append_some {n : Name} {c : Nat} : ∀ {l1 : Env} (l2 : Env),
    lookupEnv n l1 = some c → lookupEnv n (l1 ++ l2) = some c
  | [], _, hl => by rw [lookupEnv_nil] at hl; cases hl
  | (m, a) :: l1, l2, hl => by
    rw [List.cons_append, lookupEnv_cons]
    rw [lookupEnv_cons] at hl
    revert hl
    cases Nat.beq (pack n) (pack m) <;> intro hl
    · exact lookupEnv_append_some (l1 := l1) l2 hl
    · exact hl

theorem lookupEnv_of_mem {n : Name} : ∀ {l : Env}, n ∈ l.map Prod.fst → ∃ c, lookupEnv n l = some c
  | [], hm => by simp at hm
  | (m, a) :: l, hm => by
    rw [lookupEnv_cons]
    cases hb : Nat.beq (pack n) (pack m) with
    | true => exact ⟨a, rfl⟩
    | false =>
      simp only [List.map_cons, List.mem_cons] at hm
      rcases hm with he | hm
      · rw [he, Nat.beq_refl] at hb
        cases hb
      · exact lookupEnv_of_mem (l := l) hm

theorem lookupEnv_img_some {M : Map} {x : Name} {env : Env} {b : Nat} (hl : lookupEnv x env = some b) :
    lookupEnv x (M.env env) = some (M.a b) := by
  rw [lookupEnv_map, hl]; rfl

theorem lookupEnv_img_none {M : Map} {x : Name} {env : Env} (hl : lookupEnv x env = none) :
    lookupEnv x (M.env env) = none := by
  rw [lookupEnv_map, hl]; rfl

theorem env_append (M : Map) (l1 l2 : Env) : M.env (l1 ++ l2) = M.env l1 ++ M.env l2 :=
  List.map_append ..

/-! ## Small facts -/

theorem lt64 (_h : RelB F FR W stk M ν K s S t C) (hn : s.next < Sim.bound) : s.next < 2 ^ 64 := by
  have hb : Sim.bound = 2 ^ 61 := rfl
  rw [hb] at hn
  omega

theorem lt_of_margin {x : Nat} (hn : x + margin < Sim.bound) : x < Sim.bound := by
  have : 0 < margin := by decide
  omega

/-- Freshly allocated addresses are not framed. -/
theorem fresh_fr_none (h : RelB F FR W stk M ν K s S t C) {a : Nat} (ha : s.next ≤ a) : K.fr a = none := by
  cases hf : K.fr a with
  | none => rfl
  | some p => exact absurd (h.presentBound a (h.framedPresent a p hf)) (by omega)

/-- Resuming a saved completion. -/
theorem resume_rel (h : RelB F FR W stk M ν K s S t C) (c : Comp) (hc : Supp.comp (Present s) S.tab.length c) :
    RelB F FR W stk M ν K (resume s c) S (resume t (M.comp c)) C := by
  cases c with
  | normal v => exact h.ret v hc
  | abrupt a => exact h.go (.abr a) hc

/-! ## Continuing after the map grew

A continuation built from images under `M` meets a relation under an extension `M'`:
supported data have the same images. -/

theorem go' {M' : Map} {S' : SSrv} {C' : CSrv} (h : RelB F FR W stk M' ν K s S' t C')
    (hx : Ext M M' S.tab.length) (hle : S.tab.length ≤ S'.tab.length) (c : Ctl)
    (hc : Supp.ctl (Present s) S.tab.length c) :
    RelB F FR W stk M' ν K (s.go c) S' (t.go (M.ctl c)) C' := by
  rw [Map.ctl_agree (Ext.agree (A := Present s) hx) hc]
  exact h.go c (Supp.ctl_mono (fun _ hp => hp) hle hc)

theorem ret' {M' : Map} {S' : SSrv} {C' : CSrv} (h : RelB F FR W stk M' ν K s S' t C')
    (hx : Ext M M' S.tab.length) (hle : S.tab.length ≤ S'.tab.length) (v : Val)
    (hv : Supp.val (Present s) S.tab.length v) :
    RelB F FR W stk M' ν K (s.ret v) S' (t.ret (M.val v)) C' := by
  rw [Map.val_agree (Ext.agree (A := Present s) hx) hv]
  exact h.ret v (Supp.val_mono (fun _ hp => hp) hle hv)

theorem push' {M' : Map} {S' : SSrv} {C' : CSrv} (h : RelB F FR W stk M' ν K s S' t C')
    (hx : Ext M M' S.tab.length) (hle : S.tab.length ≤ S'.tab.length) (f : Frame)
    (hf : Supp.frame (Present s) S.tab.length f) :
    RelB F FR W stk M' ν K (s.push f) S' (t.push (M.frame f)) C' := by
  rw [Map.frame_agree (Ext.agree (A := Present s) hx) hf]
  exact h.push f (Supp.frame_mono (fun _ hp => hp) hle hf)

/-! ## Truthiness -/

/-- `ToBoolean` under the map; bigints must be fixed by it. -/
theorem truthyM_sim (hs : Srv M ν S C) (v : Val) (hb : ∀ i, v = .big i → (M.big i == 0) = (i == 0)) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C (truthy v) (truthy (M.val v)) := by
  cases v with
  | num x => exact numTest_sim hs .truthy x zeroN
  | big i =>
    show MSim _ S C (Host.Ts.M.pure _) (Host.Ts.M.pure (!(M.big i == 0)))
    rw [hb i rfl]
    exact MSim.pure ⟨rfl, Grow.refl hs⟩
  | undef => exact MSim.pure ⟨rfl, Grow.refl hs⟩
  | null => exact MSim.pure ⟨rfl, Grow.refl hs⟩
  | bool b => exact MSim.pure ⟨rfl, Grow.refl hs⟩
  | str cs => exact MSim.pure ⟨rfl, Grow.refl hs⟩
  | sym i => exact MSim.pure ⟨rfl, Grow.refl hs⟩
  | obj a => exact MSim.pure ⟨rfl, Grow.refl hs⟩
  | ptr m off => exact MSim.pure ⟨rfl, Grow.refl hs⟩

/-- Bigints the map fixes keep their zeroness. -/
theorem fixed_zero (h : RelB F FR W stk M ν K s S t C) {v : Val} (hb : ∀ i, v = .big i → BigFixed K.lo K.hi i) :
    ∀ i, v = .big i → (M.big i == 0) = (i == 0) :=
  fun i hi => by rw [h.bigFixed i (hb i hi)]

/-- A step that first computes a Boolean through the servers (numeric tests). -/
theorem bool_step (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) {m m' : Host.Ts.M Bool}
    (hm : MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C m m')
    {k : Bool → RS F} {k' : Bool → RS F}
    (hk : ∀ (b : Bool) M' S' C', Grow M ν S C M' S' C' → RelB F FR W stk M' ν K s S' t C' →
      MSim (StepPostB F FR W stk M' ν K S' C') S' C' (k b) (k' b)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (Host.Ts.M.bind m k) (Host.Ts.M.bind m' k') := by
  refine MSim.bind hm ?_
  intro M' S' C' b b' hbb
  obtain ⟨hbe, hg⟩ := hbb
  rw [hbe]
  exact MSim.mono (hk b M' S' C' hg (h.grow hFR hg)) fun M'' S'' C'' a a' ⟨hg', hr⟩ =>
    ⟨hg.trans hg', hr⟩

/-- Branch on a value's truthiness: related continuations on both outcomes give a
related step. -/
theorem truthy_step (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) (v : Val)
    (hb : ∀ i, v = .big i → (M.big i == 0) = (i == 0))
    {k : Bool → RS F} {k' : Bool → RS F}
    (hk : ∀ (b : Bool) M' S' C', Grow M ν S C M' S' C' → RelB F FR W stk M' ν K s S' t C' →
      MSim (StepPostB F FR W stk M' ν K S' C') S' C' (k b) (k' b)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (Host.Ts.M.bind (truthy v) k) (Host.Ts.M.bind (truthy (M.val v)) k') := by
  refine MSim.bind (truthyM_sim h.srv v hb) ?_
  intro M' S' C' b b' hbb
  obtain ⟨hbe, hg⟩ := hbb
  rw [hbe]
  exact MSim.mono (hk b M' S' C' hg (h.grow hFR hg)) fun M'' S'' C'' a a' ⟨hg', hr⟩ =>
    ⟨hg.trans hg', hr⟩

/-! ## Allocation -/

theorem cells_cons {S' : Type} (s : St S') (n : Name) (ns : List Name) (env : Env) :
    allocCells s (n :: ns) env =
      allocCells (s.alloc (.cell none)).2 ns ((n, (s.alloc (.cell none)).1) :: env) := rfl

/-- `allocCells` prepends fresh cells, one per name, newest first. -/
theorem cells_shape {S' : Type} : ∀ (ns : List Name) (s : St S') (env : Env),
    ∃ pre : Env, (allocCells s ns env).1 = pre ++ env ∧ pre.map Prod.fst = ns.reverse ∧
      (∀ x ∈ pre, s.next ≤ x.2) ∧ (allocCells s ns env).2.next = s.next + ns.length
  | [], s, env => by
    refine ⟨[], rfl, rfl, ?_, rfl⟩
    intro x hx
    cases hx
  | n :: ns, s, env => by
    obtain ⟨pre, h1, h2, h3, h4⟩ :=
      cells_shape ns (s.alloc (.cell none)).2 ((n, (s.alloc (.cell none)).1) :: env)
    refine ⟨pre ++ [(n, s.next)], ?_, ?_, ?_, ?_⟩
    · rw [cells_cons, h1, List.append_assoc]
      rfl
    · rw [List.map_append, h2, List.reverse_cons]
      rfl
    · intro x hx
      rcases List.mem_append.1 hx with hx | hx
      · have := h3 x hx
        have e : (s.alloc (.cell none)).2.next = s.next + 1 := rfl
        omega
      · rw [List.mem_singleton] at hx
        subst hx
        exact Nat.le_refl _
    · rw [cells_cons, h4]
      show s.next + 1 + ns.length = s.next + (ns.length + 1)
      omega

/-- Allocating uninitialized cells for `ns` on both sides. -/
theorem cells_rel : ∀ (ns : List Name) {s t : St F.S} (_h : RelB F FR W stk M ν K s S t C) (env : Env),
    s.next + ns.length < Sim.bound → Supp.env (Present s) S.tab.length env →
    (Host.Ts.allocCells t ns (M.env env)).1 = M.env (Host.Ts.allocCells s ns env).1 ∧
    RelB F FR W stk M ν K (Host.Ts.allocCells s ns env).2 S (Host.Ts.allocCells t ns (M.env env)).2 C ∧
    Supp.env (Present (Host.Ts.allocCells s ns env).2) S.tab.length (Host.Ts.allocCells s ns env).1 ∧
    (∀ a, Present s a → Present (Host.Ts.allocCells s ns env).2 a)
  | [], _, _, h, _, _, he => ⟨rfl, h, he, fun _ hp => hp⟩
  | n :: ns, s, t, h, env, hn, he => by
    have hn0 : s.next < Sim.bound := by
      simp only [List.length_cons] at hn
      omega
    have h64 := lt64 h hn0
    obtain ⟨ha, h1⟩ := h.alloc (.cell none) hn0 trivial
    have ha' : (t.alloc (.cell none)).1 = M.a (s.alloc (.cell none)).1 := ha
    have hP : ∀ a, Present s a → Present (s.alloc (.cell none)).2 a :=
      fun _ hp => Present.alloc _ h64 hp
    have he1 : Supp.env (Present (s.alloc (.cell none)).2) S.tab.length
        ((n, (s.alloc (.cell none)).1) :: env) := by
      intro x hx
      rcases List.mem_cons.1 hx with rfl | hx
      · exact Present.alloc_next s _ h64
      · exact hP _ (he x hx)
    have hn1 : (s.alloc (.cell none)).2.next + ns.length < Sim.bound := by
      show s.next + 1 + ns.length < Sim.bound
      simp only [List.length_cons] at hn
      omega
    obtain ⟨e, h2, he2, hP2⟩ := cells_rel ns h1 _ hn1 he1
    have key : Host.Ts.allocCells t (n :: ns) (M.env env) =
        Host.Ts.allocCells (t.alloc (M.hobj (.cell none))).2 ns (M.env ((n, (s.alloc (.cell none)).1) :: env)) := by
      rw [cells_cons, ha']
      rfl
    rw [key, cells_cons]
    exact ⟨e, h2, he2, fun a hp => hP2 a (hP a hp)⟩

/-- A closure object (prototype `%Function.prototype%`). -/
theorem closure_rel (h : RelB F FR W stk M ν K s S t C)
    (hpf : Present s aFunctionProto) (f : Func) (env : Env) (arrow : Bool) (home : Val)
    (he : Supp.env (Present s) S.tab.length env) (hh : Supp.val (Present s) S.tab.length home)
    (hn : s.next < Sim.bound) :
    (Host.Ts.closureObj t f (M.env env) arrow (M.val home)).1 = M.a (Host.Ts.closureObj s f env arrow home).1 ∧
    RelB F FR W stk M ν K (Host.Ts.closureObj s f env arrow home).2 S
      (Host.Ts.closureObj t f (M.env env) arrow (M.val home)).2 C := by
  have h64 := lt64 h hn
  have hP : ∀ a, Present s a →
      Present (s.allocObj (.fn (.closure f env arrow home)) (.obj aFunctionProto) []).2 a :=
    fun _ hp => Present.alloc _ h64 hp
  obtain ⟨ha, hr⟩ := h.allocObj (.fn (.closure f env arrow home)) (.obj aFunctionProto) [] hn
    ⟨Supp.env_mono hP (Nat.le_refl _) he, Supp.val_mono hP (Nat.le_refl _) hh⟩ (hP _ hpf)
    (fun _ hx => nomatch hx)
  have hv : M.val (.obj aFunctionProto) = .obj aFunctionProto := by
    show Val.obj (M.a aFunctionProto) = _
    rw [h.intr _ (by decide)]
  rw [hv] at ha hr
  exact ⟨ha, hr⟩

/-- Statements whose block entry allocates (named function declarations). -/
def isFuncDecl : Stmt → Bool
  | .func (.mk (some _) _ _ _ _ _ _) => true
  | _ => false

theorem initF_other {S' : Type} (s : St S') (env : Env) (st : Stmt) (ss : List Stmt)
    (hst : isFuncDecl st = false) : initFuncs s env (st :: ss) = initFuncs s env ss := by
  cases st
  case func f =>
    obtain ⟨nm, ps, r, b, a, g, pr⟩ := f
    cases nm with
    | none => rfl
    | some n => cases hst
  all_goals rfl

theorem initF_none {S' : Type} (s : St S') (env : Env) (n : Name) (ps : List Pat) (r : Option Pat)
    (b : Body) (a g : Bool) (pr : List Name) (ss : List Stmt) (hl : lookupEnv n env = none) :
    initFuncs s env (.func (.mk (some n) ps r b a g pr) :: ss) = initFuncs s env ss := by
  simp only [initFuncs, hl]

theorem initF_some {S' : Type} (s : St S') (env : Env) (n : Name) (ps : List Pat) (r : Option Pat)
    (b : Body) (a g : Bool) (pr : List Name) (ss : List Stmt) {c : Nat} (hl : lookupEnv n env = some c) :
    initFuncs s env (.func (.mk (some n) ps r b a g pr) :: ss) =
      initFuncs ((closureObj s (.mk (some n) ps r b a g pr) env false .undef).2.setCell c
        (.obj (closureObj s (.mk (some n) ps r b a g pr) env false .undef).1)) env ss := by
  simp only [initFuncs, hl]

/-- Initializing a block's function declarations on both sides. -/
theorem initFuncs_rel (env : Env) : ∀ (ss : List Stmt) {s t : St F.S} (_h : RelB F FR W stk M ν K s S t C),
    Supp.env (Present s) S.tab.length env →
    (∀ n c, n ∈ blockNames ss → lookupEnv n env = some c → K.fr c = none) →
    (ss.any isFuncDecl = true → Present s aFunctionProto) →
    s.next + ss.length < Sim.bound →
    RelB F FR W stk M ν K (Host.Ts.initFuncs s env ss) S (Host.Ts.initFuncs t (M.env env) ss) C ∧
      (∀ a, Present s a → Present (Host.Ts.initFuncs s env ss) a)
  | [], _, _, h, _, _, _, _ => ⟨h, fun _ hp => hp⟩
  | st :: ss, s, t, h, he, hfr, hI, hn => by
    have hfr' : ∀ n c, n ∈ blockNames ss → lookupEnv n env = some c → K.fr c = none :=
      fun n c hm hl => hfr n c (List.mem_append_right _ hm) hl
    have hn' : s.next + ss.length < Sim.bound := by
      simp only [List.length_cons] at hn
      omega
    cases hst : isFuncDecl st with
    | false =>
      rw [initF_other _ _ _ _ hst, initF_other _ _ _ _ hst]
      exact initFuncs_rel env ss h he hfr'
        (fun ha => hI (by simp only [List.any_cons, hst, Bool.false_or]; exact ha)) hn'
    | true =>
      have hI' := hI (by simp only [List.any_cons, hst, Bool.true_or])
      cases st
      case func f =>
        obtain ⟨nm, ps, r, b, a, g, pr⟩ := f
        cases nm with
        | none => cases hst
        | some n =>
          cases hl : lookupEnv n env with
          | none =>
            rw [initF_none _ _ _ _ _ _ _ _ _ _ hl,
              initF_none _ _ _ _ _ _ _ _ _ _ (lookupEnv_img_none hl)]
            exact initFuncs_rel env ss h he hfr'
              (fun ha => hI (by simp only [List.any_cons, Bool.or_eq_true]; exact .inr ha)) hn'
          | some c =>
            have hn0 : s.next < Sim.bound := by omega
            have h64 := lt64 h hn0
            obtain ⟨ea, h1⟩ := closure_rel h hI' (.mk (some n) ps r b a g pr) env false .undef he trivial hn0
            have hP1 : ∀ x, Present s x → Present (Host.Ts.closureObj s (.mk (some n) ps r b a g pr) env false .undef).2 x :=
              fun _ hp => Present.alloc _ h64 hp
            have hc : Present s c := env_lookup_supp he hl
            have hfc : K.fr c = none := hfr n c (by simp [blockNames, stmtNames]) hl
            have hn1 : (Host.Ts.closureObj s (.mk (some n) ps r b a g pr) env false .undef).2.next < Sim.bound := by
              have e1 : (Host.Ts.closureObj s (.mk (some n) ps r b a g pr) env false .undef).2.next = s.next + 1 := rfl
              rw [e1]
              simp only [List.length_cons] at hn
              omega
            have h2 := h1.setCell (.obj (Host.Ts.closureObj s (.mk (some n) ps r b a g pr) env false .undef).1) hn1 (hP1 c hc) hfc
              (Present.alloc_next s _ h64)
            have ev : M.val (.obj (Host.Ts.closureObj s (.mk (some n) ps r b a g pr) env false .undef).1) =
                .obj (Host.Ts.closureObj t (.mk (some n) ps r b a g pr) (M.env env) false .undef).1 := by
              show Val.obj (M.a _) = _
              rw [← ea]
              rfl
            rw [ev] at h2
            have hP2 : ∀ x, Present s x → Present ((Host.Ts.closureObj s (.mk (some n) ps r b a g pr) env false .undef).2.setCell c
                (.obj (Host.Ts.closureObj s (.mk (some n) ps r b a g pr) env false .undef).1)) x :=
              fun x hp => Present.set _ (by have := h.presentBound c hc; omega) (hP1 x hp)
            rw [initF_some _ _ _ _ _ _ _ _ _ _ hl,
              initF_some _ _ _ _ _ _ _ _ _ _ (lookupEnv_img_some hl)]
            have hn2 : ((Host.Ts.closureObj s (.mk (some n) ps r b a g pr) env false .undef).2.setCell c
                (.obj (Host.Ts.closureObj s (.mk (some n) ps r b a g pr) env false .undef).1)).next + ss.length < Sim.bound := by
              show s.next + 1 + ss.length < Sim.bound
              simp only [List.length_cons] at hn
              omega
            obtain ⟨h3, hP3⟩ := initFuncs_rel env ss h2 (Supp.env_mono hP2 (Nat.le_refl _) he) hfr'
              (fun _ => hP2 _ hI') hn2
            exact ⟨h3, fun x hp => hP3 x (hP2 x hp)⟩
      all_goals cases hst

theorem hoist_cond {S' : Type} (s : St S') (ss : List Stmt) (env : Env) :
    hoist s ss env = bif (blockNames ss).isEmpty then (env, s) else
      ((allocCells s (blockNames ss) env).1,
        initFuncs (allocCells s (blockNames ss) env).2 (allocCells s (blockNames ss) env).1 ss) := by
  unfold hoist
  cases blockNames ss <;> rfl

/-- Block entry: the declarations' cells and the function declarations. -/
theorem hoist_rel (h : RelB F FR W stk M ν K s S t C) (ss : List Stmt) (env : Env)
    (he : Supp.env (Present s) S.tab.length env)
    (hI : ss.any isFuncDecl = true → Present s aFunctionProto)
    (hn : s.next + (blockNames ss).length + ss.length < Sim.bound) :
    (Host.Ts.hoist t ss (M.env env)).1 = M.env (Host.Ts.hoist s ss env).1 ∧
    RelB F FR W stk M ν K (Host.Ts.hoist s ss env).2 S (Host.Ts.hoist t ss (M.env env)).2 C ∧
    Supp.env (Present (Host.Ts.hoist s ss env).2) S.tab.length (Host.Ts.hoist s ss env).1 ∧
    (∀ a, Present s a → Present (Host.Ts.hoist s ss env).2 a) := by
  rw [hoist_cond, hoist_cond]
  cases (blockNames ss).isEmpty
  · obtain ⟨pre, epre, hnames, hfresh, hlen⟩ := cells_shape (blockNames ss) s env
    obtain ⟨e, h1, he1, hP1⟩ := cells_rel (blockNames ss) h env (by omega) he
    simp only [Bool.cond_false]
    rw [e]
    have hfr : ∀ n c, n ∈ blockNames ss → lookupEnv n (Host.Ts.allocCells s (blockNames ss) env).1 = some c →
        K.fr c = none := by
      intro n c hm hl
      have hm' : n ∈ pre.map Prod.fst := by rw [hnames]; exact List.mem_reverse.2 hm
      obtain ⟨c', hl'⟩ := lookupEnv_of_mem hm'
      rw [epre, lookupEnv_append_some env hl'] at hl
      cases hl
      obtain ⟨m, hmc⟩ := env_lookup_mem hl'
      exact fresh_fr_none h (hfresh _ hmc)
    obtain ⟨h2, hP2⟩ := initFuncs_rel (Host.Ts.allocCells s (blockNames ss) env).1 ss h1 he1 hfr
      (fun ha => hP1 _ (hI ha)) (by rw [hlen]; omega)
    exact ⟨rfl, h2, Supp.env_mono hP2 (Nat.le_refl _) he1, fun a hp => hP2 a (hP1 a hp)⟩
  · exact ⟨rfl, h, he, fun _ hp => hp⟩

/-- Entering a block on both sides. -/
theorem enterBlock_rel (h : RelB F FR W stk M ν K s S t C) (ss : List Stmt) (env : Env)
    (he : Supp.env (Present s) S.tab.length env)
    (hI : ss.any isFuncDecl = true → Present s aFunctionProto)
    (hn : s.next + (blockNames ss).length + ss.length < Sim.bound) :
    RelB F FR W stk M ν K (Host.Ts.enterBlock s ss env) S (Host.Ts.enterBlock t ss (M.env env)) C := by
  obtain ⟨e, h1, he1, _⟩ := hoist_rel h ss env he hI hn
  have es : Host.Ts.enterBlock s ss env = ((((Host.Ts.hoist s ss env).2.push (.s (.scope []))).push
      (.s (.block ss (Host.Ts.hoist s ss env).1))).ret .undef) := rfl
  have et : Host.Ts.enterBlock t ss (M.env env) = ((((Host.Ts.hoist t ss (M.env env)).2.push (.s (.scope []))).push
      (.s (.block ss (Host.Ts.hoist t ss (M.env env)).1))).ret .undef) := rfl
  rw [es, et, e]
  exact ((h1.push (.s (.scope [])) (fun _ hx => nomatch hx)).push (.s (.block ss _)) he1).ret .undef trivial


/-! ## Errors, declarations, completions -/

/-- The next declarator of a declaration. -/
theorem declNext_sim (h : RelB F FR W stk M ν K s S t C) (kind : DeclKind) (ds : List (Pat × Option Expr))
    (env : Env) (he : Supp.env (Present s) S.tab.length env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (Host.Ts.declNext F s kind ds env)
      (Host.Ts.declNext F t kind ds (M.env env)) := by
  match ds with
  | [] => exact MSim.pure ⟨Grow.refl h.srv, h.ret .undef trivial⟩
  | (p, some e) :: r =>
    exact MSim.pure ⟨Grow.refl h.srv, (h.push (.s (.decl kind p r env)) he).go (.ev e env) he⟩
  | (p, none) :: r =>
    exact MSim.pure ⟨Grow.refl h.srv,
      (h.push (.s (.declNext kind r env)) he).go (.bind p .undef env .init kind) ⟨trivial, he⟩⟩

/-- Run a `finally` block or resume the saved completion. -/
theorem finOrResume_sim (h : RelB F FR W stk M ν K s S t C) (fin : Option (List Stmt)) (env : Env) (c : Comp)
    (he : Supp.env (Present s) S.tab.length env) (hc : Supp.comp (Present s) S.tab.length c)
    (hI : ∀ ss, fin = some ss → ss.any isFuncDecl = true →
      Present s aFunctionProto)
    (hn : ∀ ss, fin = some ss → s.next + (blockNames ss).length + ss.length < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (Host.Ts.finOrResume F s fin env c)
      (Host.Ts.finOrResume F t fin (M.env env) (M.comp c)) := by
  cases fin with
  | none => exact MSim.pure ⟨Grow.refl h.srv, resume_rel h c hc⟩
  | some ss =>
    exact MSim.pure ⟨Grow.refl h.srv,
      enterBlock_rel (h.push (.s (.finally_ c)) hc) ss env he (hI ss rfl) (hn ss rfl)⟩

theorem margin_bound {x k : Nat} (hn : x + margin < Sim.bound) (hk : k ≤ 2 ^ 20) : x + k < Sim.bound := by
  have hm : margin = 2 ^ 30 := rfl
  omega

/-! ## `using` registration -/

def isScopeF : Frame → Bool
  | .s (.scope _) => true
  | _ => false

theorem isScopeF_map (M : Map) (f : Frame) : isScopeF (M.frame f) = isScopeF f := by
  cases f
  case s g => cases g <;> rfl
  all_goals rfl

theorem addUsing_other (r : Val × Val) (f : Frame) (fs : List Frame) (hf : isScopeF f = false) :
    addUsing r (f :: fs) = (addUsing r fs).map (f :: ·) := by
  cases f
  case s g => cases g <;> first | rfl | cases hf
  all_goals rfl

theorem addUsing_map (M : Map) (x m : Val) : ∀ fs : List Frame,
    addUsing (M.val x, M.val m) (fs.map M.frame) = (addUsing (x, m) fs).map (List.map M.frame)
  | [] => rfl
  | f :: fs => by
    cases hf : isScopeF f with
    | false =>
      rw [List.map_cons, addUsing_other _ _ _ (by rw [isScopeF_map]; exact hf),
        addUsing_other _ _ _ hf, addUsing_map M x m fs]
      cases addUsing (x, m) fs <;> rfl
    | true =>
      cases f
      case s g =>
        cases g
        case scope res => rfl
        all_goals cases hf
      all_goals cases hf

/-- Some frame of the list is a scope frame. -/
def scopeB (fs : List Frame) : Bool := fs.any isScopeF

/-- A registration found in `fs` is found the same below any further frames. -/
theorem addUsing_append (r : Val × Val) (stk : List Frame) : ∀ {fs st : List Frame}, addUsing r fs = some st →
    addUsing r (fs ++ stk) = some (st ++ stk)
  | [], _, h => by cases h
  | f :: fs, st, h => by
    cases hf : isScopeF f with
    | false =>
      rw [addUsing_other _ _ _ hf] at h
      cases hu : addUsing r fs with
      | none => rw [hu] at h; cases h
      | some l =>
        rw [hu] at h
        cases h
        rw [List.cons_append, addUsing_other _ _ _ hf, addUsing_append r stk hu]
        rfl
    | true =>
      cases f
      case s g =>
        cases g
        case scope res => cases h; rfl
        all_goals cases hf
      all_goals cases hf

theorem addUsing_isSome (r : Val × Val) : ∀ {fs : List Frame}, scopeB fs = true → (addUsing r fs).isSome = true
  | [], h => by cases h
  | f :: fs, h => by
    cases hf : isScopeF f with
    | false =>
      have h' : scopeB fs = true := by simpa [scopeB, List.any_cons, hf] using h
      rw [addUsing_other _ _ _ hf]
      have := addUsing_isSome r h'
      cases hu : addUsing r fs with
      | none => rw [hu] at this; cases this
      | some _ => rfl
    | true =>
      cases f
      case s g =>
        cases g
        case scope res => rfl
        all_goals cases hf
      all_goals cases hf

theorem addUsing_supp {A : Nat → Prop} {n : Nat} {r : Val × Val} (hr : Supp.val A n r.1 ∧ Supp.val A n r.2) :
    ∀ {fs fs' : List Frame}, (∀ f ∈ fs, Supp.frame A n f) → addUsing r fs = some fs' →
      ∀ f ∈ fs', Supp.frame A n f
  | [], _, _, he => by cases he
  | f :: fs, fs', hfs, he => by
    cases hf : isScopeF f with
    | false =>
      rw [addUsing_other _ _ _ hf] at he
      cases hu : addUsing r fs with
      | none => rw [hu] at he; cases he
      | some l =>
        rw [hu] at he
        cases he
        intro g hg
        rcases List.mem_cons.1 hg with rfl | hg
        · exact hfs g (List.mem_cons_self ..)
        · exact addUsing_supp hr (fun g hg => hfs g (List.mem_cons_of_mem _ hg)) hu g hg
    | true =>
      cases f
      case s g =>
        cases g
        case scope res =>
          cases he
          intro g hg
          rcases List.mem_cons.1 hg with rfl | hg
          · intro y hy
            rcases List.mem_cons.1 hy with rfl | hy
            · exact hr
            · exact hfs _ (List.mem_cons_self ..) y hy
          · exact hfs g (List.mem_cons_of_mem _ hg)
        all_goals cases hf
      all_goals cases hf

/-! ## Reads followed by steps -/

theorem read_bind {α β α' β' : Type} {R : α → β → Prop} {R' : α' → β' → Prop}
    {m : Host.Ts.M α} {m' : Host.Ts.M β} {k : α → Host.Ts.M α'} {k' : β → Host.Ts.M β'}
    (hm : MSim (ReadPost M S C R) S C m m') (hk : ∀ a b, R a b → MSim (ReadPost M S C R') S C (k a) (k' b)) :
    MSim (ReadPost M S C R') S C (Host.Ts.M.bind m k) (Host.Ts.M.bind m' k') :=
  MSim.bind hm fun _ _ _ a b ⟨hM, hS, hC, hR⟩ => by
    subst hM hS hC
    exact hk a b hR

theorem read_step {α β : Type} {R : α → β → Prop} {m : Host.Ts.M α} {m' : Host.Ts.M β}
    {k : α → RS F} {k' : β → RS F}
    (hm : MSim (ReadPost M S C R) S C m m') (hk : ∀ a b, R a b → MSim (StepPostB F FR W stk M ν K S C) S C (k a) (k' b)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (Host.Ts.M.bind m k) (Host.Ts.M.bind m' k') :=
  MSim.bind hm fun _ _ _ a b ⟨hM, hS, hC, hR⟩ => by
    subst hM hS hC
    exact hk a b hR

/-- Results of a `using` registration: none, or the stack with the resource added. -/
def UsingR (M : Map) (stk : List Frame) (A : Nat → Prop) (n : Nat) (s1 t1 : St F.S) (r r' : Option (St F.S)) : Prop :=
  (r = none ∧ r' = none) ∨ ∃ st : List Frame, r = some { s1 with stack := st } ∧
    r' = some { t1 with stack := st.map M.frame ++ stk } ∧ ∀ f ∈ st, Supp.frame A n f

theorem using_obj {A : Nat → Prop} {n : Nat} {stk : List Frame} (s1 t1 : St F.S) (x : Val) (a : Nat) (fs : List Frame)
    (hx : Supp.val A n x) (ha : A a) (hfs : ∀ f ∈ fs, Supp.frame A n f) (hsc : stk = [] ∨ scopeB fs = true) :
    UsingR M stk A n s1 t1 ((addUsing (x, .obj a) fs).map fun st => { s1 with stack := st })
      ((addUsing (M.val x, .obj (M.a a)) (fs.map M.frame ++ stk)).map fun st => { t1 with stack := st }) := by
  have e := addUsing_map M x (.obj a) fs
  rw [show M.val (.obj a) = .obj (M.a a) from rfl] at e
  cases hu : addUsing (x, .obj a) fs with
  | none =>
    rcases hsc with rfl | hsc
    · rw [List.append_nil, e, hu]; exact .inl ⟨rfl, rfl⟩
    · have := addUsing_isSome (x, .obj a) hsc; rw [hu] at this; cases this
  | some st =>
    have e' : addUsing (M.val x, .obj (M.a a)) (fs.map M.frame) = some (st.map M.frame) := by rw [e, hu]; rfl
    rw [addUsing_append _ stk e']
    exact .inr ⟨st, rfl, rfl, addUsing_supp (r := (x, .obj a)) ⟨hx, ha⟩ hfs hu⟩

end
end StmtSim

open StmtSim

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

/-! ## Statements -/

theorem step_ex_expr (h : RelB F FR W stk M ν K s S t C) {e : Expr} {env : Env} (hc : s.ctl = .ex (.expr e) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, he⟩ := exTop h hc
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, h.go (.ev e env) he⟩

theorem step_ex_decl (h : RelB F FR W stk M ν K s S t C) {kind : DeclKind} {ds : List (Pat × Option Expr)}
    {env : Env} (hc : s.ctl = .ex (.decl kind ds) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, he⟩ := exTop h hc
  rw [e1, e2]
  exact declNext_sim h kind ds env he

theorem step_ex_func (h : RelB F FR W stk M ν K s S t C) {f : Func} {env : Env} (hc : s.ctl = .ex (.func f) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _⟩ := exTop h hc
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, h.ret .undef trivial⟩

theorem step_ex_cls (h : RelB F FR W stk M ν K s S t C) {c : Class} {env : Env} (hc : s.ctl = .ex (.cls c) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, he⟩ := exTop h hc
  rw [e1, e2]
  obtain ⟨nm, sup, ms⟩ := c
  cases nm with
  | none => exact MSim.pure ⟨Grow.refl h.srv, h.go (.ev (.cls (.mk none sup ms)) env) he⟩
  | some n =>
    exact MSim.pure ⟨Grow.refl h.srv,
      (h.push (.s (.decl .let_ (.id n) [] env)) he).go (.ev (.cls (.mk (some n) sup ms)) env) he⟩

theorem step_ex_ret (h : RelB F FR W stk M ν K s S t C) {e : Option Expr} {env : Env}
    (hc : s.ctl = .ex (.ret e) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, he⟩ := exTop h hc
  rw [e1, e2]
  cases e with
  | none => exact MSim.pure ⟨Grow.refl h.srv, h.go (.abr (.ret .undef)) trivial⟩
  | some e => exact MSim.pure ⟨Grow.refl h.srv, (h.push (.s .ret) trivial).go (.ev e env) he⟩

theorem step_ex_if (h : RelB F FR W stk M ν K s S t C) {c : Expr} {st : Stmt} {e : Option Stmt} {env : Env}
    (hc : s.ctl = .ex (.if_ c st e) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, he⟩ := exTop h hc
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, (h.push (.s (.if_ st e env)) he).go (.ev c env) he⟩

/-- A block. `hI` (the function prototype is present) is needed only when the block
declares named functions; `ss.any isFuncDecl = false` discharges it. -/
theorem step_ex_block (h : RelB F FR W stk M ν K s S t C) {ss : List Stmt} {env : Env}
    (hc : s.ctl = .ex (.block ss) env) (hn : s.next + margin < Sim.bound)
    (hsz : (blockNames ss).length + ss.length ≤ 2 ^ 20)
    (hI : ss.any isFuncDecl = true → Present s aFunctionProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, he⟩ := exTop h hc
  rw [e1, e2]
  have hn' := margin_bound hn hsz
  exact MSim.pure ⟨Grow.refl h.srv, enterBlock_rel h ss env he hI (by omega)⟩

theorem step_ex_try (h : RelB F FR W stk M ν K s S t C) {b : List Stmt} {hd : Option (Option Pat × List Stmt)}
    {fin : Option (List Stmt)} {env : Env} (hc : s.ctl = .ex (.try_ b hd fin) env)
    (hn : s.next + margin < Sim.bound) (hsz : (blockNames b).length + b.length ≤ 2 ^ 20)
    (hI : b.any isFuncDecl = true → Present s aFunctionProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, he⟩ := exTop h hc
  rw [e1, e2]
  have hn' := margin_bound hn hsz
  exact MSim.pure ⟨Grow.refl h.srv,
    enterBlock_rel (h.push (.s (.try_ hd fin env)) he) b env he hI (by dsimp only [St.push]; omega)⟩

theorem step_ex_switch (h : RelB F FR W stk M ν K s S t C) {d : Expr} {cs : List (Option Expr × List Stmt)}
    {env : Env} (hc : s.ctl = .ex (.switch d cs) env) (hn : s.next + margin < Sim.bound)
    (hsz : (blockNames (caseStmts cs)).length + (caseStmts cs).length ≤ 2 ^ 20)
    (hI : (caseStmts cs).any isFuncDecl = true →
      Present s aFunctionProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, he⟩ := exTop h hc
  rw [e1, e2]
  have hn' := margin_bound hn hsz
  obtain ⟨e, h1, he1, hPh⟩ := hoist_rel h (caseStmts cs) env he hI (by omega)
  have es : exStep F s (.switch d cs) env = Host.Ts.M.pure (((((Host.Ts.hoist s (caseStmts cs) env).2.push
      (.s (.scope []))).push (.s (.switchD cs (Host.Ts.hoist s (caseStmts cs) env).1)))).go (.ev d env)) := rfl
  have et : exStep F t (.switch d cs) (M.env env) = Host.Ts.M.pure (((((Host.Ts.hoist t (caseStmts cs)
      (M.env env)).2.push (.s (.scope []))).push (.s (.switchD cs (Host.Ts.hoist t (caseStmts cs)
      (M.env env)).1)))).go (.ev d (M.env env))) := rfl
  rw [es, et, e]
  exact MSim.pure ⟨Grow.refl h.srv, ((h1.push (.s (.scope [])) (fun _ hx => nomatch hx)).push
    (.s (.switchD cs _)) he1).go (.ev d env) (Supp.env_mono hPh (Nat.le_refl _) he)⟩

theorem step_ex_throw (h : RelB F FR W stk M ν K s S t C) {e : Expr} {env : Env}
    (hc : s.ctl = .ex (.throw e) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, he⟩ := exTop h hc
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, (h.push (.s .throw) trivial).go (.ev e env) he⟩

theorem step_ex_break (h : RelB F FR W stk M ν K s S t C) {l : Option Name} {env : Env}
    (hc : s.ctl = .ex (.break l) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _⟩ := exTop h hc
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, h.go (.abr (.brk l)) trivial⟩

theorem step_ex_continue (h : RelB F FR W stk M ν K s S t C) {l : Option Name} {env : Env}
    (hc : s.ctl = .ex (.continue l) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _⟩ := exTop h hc
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, h.go (.abr (.cont l)) trivial⟩

theorem step_ex_empty (h : RelB F FR W stk M ν K s S t C) {env : Env} (hc : s.ctl = .ex .empty env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _⟩ := exTop h hc
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, h.ret .undef trivial⟩

/-! ## Values returning to statement frames -/

theorem step_ret_block (h : RelB F FR W stk M ν K s S t C) {v : Val} {rest : List Stmt} {env : Env}
    {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .s (.block rest env) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  cases rest with
  | nil => exact MSim.pure ⟨Grow.refl h.srv, hr.ret .undef trivial⟩
  | cons st r => exact MSim.pure ⟨Grow.refl h.srv, (hr.push (.s (.block r env)) hf).go (.ex st env) hf⟩

theorem step_ret_declNext (h : RelB F FR W stk M ν K s S t C) {v : Val} {kind : DeclKind}
    {rest : List (Pat × Option Expr)} {env : Env} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .s (.declNext kind rest env) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact declNext_sim hr kind rest env hf

/-- A declarator's value, outside `using` declarations: bind the pattern. -/
theorem step_ret_decl (h : RelB F FR W stk M ν K s S t C) {v : Val} {kind : DeclKind} {p : Pat}
    {rest : List (Pat × Option Expr)} {env : Env} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .s (.decl kind p rest env) :: fs) (hk : isUsing kind = false) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := retTop h hc hs
  rw [e1, e2]
  cases kind <;> first
    | exact MSim.pure ⟨Grow.refl h.srv,
        (hr.push (.s (.declNext _ rest env)) hf).go (.bind p v env .init _) ⟨hv, hf⟩⟩
    | cases hk


/-- A `using` declarator of an object: look up `[Symbol.dispose]` and register the
resource in the innermost scope; a missing method throws a `TypeError`. -/
theorem step_ret_decl_using (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) {v : Val}
    {p : Pat} {rest : List (Pat × Option Expr)} {env : Env} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .s (.decl .using p rest env) :: fs) (hv0 : isNullish v = false)
    (hn : s.next + margin < Sim.bound) (hP : Present s aTypeErrorProto) (hnw : LookupNoW F K W s v)
    (hsc : stk = [] ∨ scopeB fs = true) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := retTop h hc hs
  rw [e1, e2]
  have hfs : ∀ g ∈ fs, Supp.frame (Present s) S.tab.length g :=
    fun g hg => h.stackSupp g (by rw [hs]; exact List.mem_cons_of_mem _ hg)
  have hkey : M.key (.sym symDispose) = .sym symDispose := by
    show PKey.sym (M.sym symDispose) = _
    rw [Map.sym_lt M (by decide)]
  have hd := dataOf_sim hr hF h.intr hv (k := .sym symDispose) (fun h16 => absurd h16 (by decide)) (LookupOK.of_noW rfl rfl (LookupNoW.congr (fun _ => rfl) hnw))
  rw [hkey] at hd
  have hn0 := lt_of_margin hn
  show MSim _ S C (retSt F { s with stack := fs } (.decl .using p rest env) _)
    (retSt F { t with stack := fs.map M.frame ++ stk } (.decl .using p rest (M.env env)) _)
  cases v
  case undef => cases hv0
  case null => cases hv0
  all_goals
    simp only [retSt, isUsing, Bool.cond_true]
    refine read_step (R := UsingR M stk (Present s) S.tab.length { s with stack := fs }
      { t with stack := fs.map M.frame ++ stk }) (read_bind hd ?_) ?_
    · intro r r' hR
      obtain ⟨rfl, hsupp⟩ := hR
      rcases r with _ | ⟨_ | _ | _ | _ | _ | _ | _ | a | _⟩
      case obj =>
        exact ReadPost.pure (using_obj _ _ _ a fs hv (hsupp _ rfl) hfs hsc)
      all_goals exact ReadPost.pure (.inl ⟨rfl, rfl⟩)
    · intro r r' hR
      rcases hR with ⟨rfl, rfl⟩ | ⟨st, rfl, rfl, hst⟩
      · exact typeErr_sim hr h.intr hn0 hP _
      · exact MSim.pure ⟨Grow.refl h.srv, ((hr.restack st hst).push (.s (.declNext .using rest env)) hf).go
          (.bind p _ env .init .using) ⟨hv, hf⟩⟩

/-- A `using` declarator of `undefined` or `null` registers nothing. -/
theorem step_ret_decl_using_nullish (h : RelB F FR W stk M ν K s S t C) {v : Val} {p : Pat}
    {rest : List (Pat × Option Expr)} {env : Env} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .s (.decl .using p rest env) :: fs) (hv0 : isNullish v = true) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := retTop h hc hs
  rw [e1, e2]
  cases v
  case undef => exact MSim.pure ⟨Grow.refl h.srv,
    (hr.push (.s (.declNext .using rest env)) hf).go (.bind p .undef env .init .using) ⟨hv, hf⟩⟩
  case null => exact MSim.pure ⟨Grow.refl h.srv,
    (hr.push (.s (.declNext .using rest env)) hf).go (.bind p .null env .init .using) ⟨hv, hf⟩⟩
  all_goals cases hv0

theorem step_ret_ret (h : RelB F FR W stk M ν K s S t C) {v : Val} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .s .ret :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, _⟩ := retTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.ret v)) hv⟩

theorem step_ret_throw (h : RelB F FR W stk M ν K s S t C) {v : Val} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .s .throw :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, _⟩ := retTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.throw v)) hv⟩

/-- The test of an `if`: bigint tests need the bigint fixed by the map. -/
theorem step_ret_if (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) {v : Val} {st : Stmt}
    {e : Option Stmt} {env : Env} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .s (.if_ st e env) :: fs) (hb : ∀ i, v = .big i → BigFixed K.lo K.hi i) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  refine truthy_step hr hFR v (fixed_zero h hb) (fun b M' S' C' hg hr' => ?_)
  cases b with
  | true => exact MSim.pure ⟨Grow.refl hr'.srv, go' hr' hg.ext hg.len (.ex st env) hf⟩
  | false =>
    cases e with
    | some e => exact MSim.pure ⟨Grow.refl hr'.srv, go' hr' hg.ext hg.len (.ex e env) hf⟩
    | none => exact MSim.pure ⟨Grow.refl hr'.srv, hr'.ret .undef trivial⟩

/-- A scope's body completed normally: dispose its `using` resources, newest first. -/
theorem step_ret_scope (h : RelB F FR W stk M ν K s S t C) {v : Val} {res : List (Val × Val)} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .s (.scope res) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := retTop h hc hs
  rw [e1, e2]
  cases res with
  | nil => exact MSim.pure ⟨Grow.refl h.srv, hr.ret v hv⟩
  | cons p r =>
    obtain ⟨x, m⟩ := p
    have hp := hf (x, m) (List.mem_cons_self ..)
    have hr' : Supp.pairs (Present s) S.tab.length r := fun y hy => hf y (List.mem_cons_of_mem _ hy)
    exact MSim.pure ⟨Grow.refl h.srv, (hr.push (.s (.dispose r (.normal v))) ⟨hr', hv⟩).go
      (.call m x []) ⟨hp.2, hp.1, fun _ hx => nomatch hx⟩⟩

/-- A `[Symbol.dispose]()` call returned: dispose the next resource or resume. -/
theorem step_ret_dispose (h : RelB F FR W stk M ν K s S t C) {v : Val} {rest : List (Val × Val)} {c : Comp}
    {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .s (.dispose rest c) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  cases rest with
  | nil => exact MSim.pure ⟨Grow.refl h.srv, resume_rel hr c hf.2⟩
  | cons p r =>
    obtain ⟨x, m⟩ := p
    have hp := hf.1 (x, m) (List.mem_cons_self ..)
    have hr' : Supp.pairs (Present s) S.tab.length r := fun y hy => hf.1 y (List.mem_cons_of_mem _ hy)
    exact MSim.pure ⟨Grow.refl h.srv, (hr.push (.s (.dispose r c)) ⟨hr', hf.2⟩).go
      (.call m x []) ⟨hp.2, hp.1, fun _ hx => nomatch hx⟩⟩

theorem step_ret_finally (h : RelB F FR W stk M ν K s S t C) {v : Val} {c : Comp} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .s (.finally_ c) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, resume_rel hr c hf⟩

/-- A `try` block completed normally: run the `finally` block, if any. -/
theorem step_ret_try (h : RelB F FR W stk M ν K s S t C) {v : Val} {hd : Option (Option Pat × List Stmt)}
    {fin : Option (List Stmt)} {env : Env} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .s (.try_ hd fin env) :: fs) (hn : s.next + margin < Sim.bound)
    (hsz : ∀ ss, fin = some ss → (blockNames ss).length + ss.length ≤ 2 ^ 20)
    (hI : ∀ ss, fin = some ss → ss.any isFuncDecl = true →
      Present s aFunctionProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact finOrResume_sim hr fin env (.normal .undef) hf trivial hI
    (fun ss hss => by have := margin_bound hn (hsz ss hss); dsimp only; omega)

theorem step_ret_catch (h : RelB F FR W stk M ν K s S t C) {v : Val} {fin : Option (List Stmt)} {env : Env}
    {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .s (.catch_ fin env) :: fs)
    (hn : s.next + margin < Sim.bound)
    (hsz : ∀ ss, fin = some ss → (blockNames ss).length + ss.length ≤ 2 ^ 20)
    (hI : ∀ ss, fin = some ss → ss.any isFuncDecl = true →
      Present s aFunctionProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact finOrResume_sim hr fin env (.normal .undef) hf trivial hI
    (fun ss hss => by have := margin_bound hn (hsz ss hss); dsimp only; omega)

theorem step_ret_label (h : RelB F FR W stk M ν K s S t C) {v : Val} {l : Name} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .s (.label l) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, _⟩ := retTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, hr.ret .undef trivial⟩

theorem step_ret_switchBody (h : RelB F FR W stk M ν K s S t C) {v : Val} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .s .switchBody :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, _⟩ := retTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, hr.ret .undef trivial⟩

/-! ## Abrupt completions reaching statement frames -/

/-- Frames that let an abrupt completion through unchanged. -/
theorem stmt_abr_pass (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {f : StmtF} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .s f :: fs)
    (e : ∀ (G : Ffi) (x : St G.S), abrSt G x f a = Host.Ts.M.pure (x.go (.abr a)))
    (e' : ∀ (G : Ffi) (x : St G.S), abrSt G x (M.stmtF f) (M.abr a) = Host.Ts.M.pure (x.go (.abr (M.abr a)))) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, _⟩ := abrTop h hc hs
  rw [e1, e2]
  show MSim _ S C (abrSt F _ f a) (abrSt F _ (M.stmtF f) (M.abr a))
  rw [e, e']
  exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr a) ha⟩

theorem step_abr_block (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {rest : List Stmt} {env : Env}
    {fs : List Frame} (hc : s.ctl = .abr a) (hs : s.stack = .s (.block rest env) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) :=
  stmt_abr_pass h hc hs (fun _ _ => rfl) (fun _ _ => rfl)

theorem step_abr_if (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {st : Stmt} {e : Option Stmt} {env : Env}
    {fs : List Frame} (hc : s.ctl = .abr a) (hs : s.stack = .s (.if_ st e env) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) :=
  stmt_abr_pass h hc hs (fun _ _ => rfl) (fun _ _ => rfl)

theorem step_abr_decl (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {kind : DeclKind} {p : Pat}
    {rest : List (Pat × Option Expr)} {env : Env} {fs : List Frame} (hc : s.ctl = .abr a)
    (hs : s.stack = .s (.decl kind p rest env) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) :=
  stmt_abr_pass h hc hs (fun _ _ => rfl) (fun _ _ => rfl)

theorem step_abr_declNext (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {kind : DeclKind}
    {rest : List (Pat × Option Expr)} {env : Env} {fs : List Frame} (hc : s.ctl = .abr a)
    (hs : s.stack = .s (.declNext kind rest env) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) :=
  stmt_abr_pass h hc hs (fun _ _ => rfl) (fun _ _ => rfl)

theorem step_abr_ret (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {fs : List Frame} (hc : s.ctl = .abr a)
    (hs : s.stack = .s .ret :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) :=
  stmt_abr_pass h hc hs (fun _ _ => rfl) (fun _ _ => rfl)

theorem step_abr_throw (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {fs : List Frame} (hc : s.ctl = .abr a)
    (hs : s.stack = .s .throw :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) :=
  stmt_abr_pass h hc hs (fun _ _ => rfl) (fun _ _ => rfl)

theorem step_abr_finally (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {c : Comp} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .s (.finally_ c) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) :=
  stmt_abr_pass h hc hs (fun _ _ => rfl) (fun _ _ => rfl)

/-- An abrupt completion leaving a scope: dispose its resources first. -/
theorem step_abr_scope (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {res : List (Val × Val)}
    {fs : List Frame} (hc : s.ctl = .abr a) (hs : s.stack = .s (.scope res) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, hf⟩ := abrTop h hc hs
  rw [e1, e2]
  cases res with
  | nil => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr a) ha⟩
  | cons p r =>
    obtain ⟨x, m⟩ := p
    have hp := hf (x, m) (List.mem_cons_self ..)
    have hr' : Supp.pairs (Present s) S.tab.length r := fun y hy => hf y (List.mem_cons_of_mem _ hy)
    exact MSim.pure ⟨Grow.refl h.srv, (hr.push (.s (.dispose r (.abrupt a))) ⟨hr', ha⟩).go
      (.call m x []) ⟨hp.2, hp.1, fun _ hx => nomatch hx⟩⟩

theorem step_abr_catch (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {fin : Option (List Stmt)} {env : Env}
    {fs : List Frame} (hc : s.ctl = .abr a) (hs : s.stack = .s (.catch_ fin env) :: fs)
    (hn : s.next + margin < Sim.bound)
    (hsz : ∀ ss, fin = some ss → (blockNames ss).length + ss.length ≤ 2 ^ 20)
    (hI : ∀ ss, fin = some ss → ss.any isFuncDecl = true →
      Present s aFunctionProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, hf⟩ := abrTop h hc hs
  rw [e1, e2]
  exact finOrResume_sim hr fin env (.abrupt a) hf ha hI
    (fun ss hss => by have := margin_bound hn (hsz ss hss); dsimp only; omega)

/-- An abrupt completion of a `try` block: a throw enters the handler (binding its parameter
in fresh cells); anything else runs the `finally` block. -/
theorem step_abr_try (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {hd : Option (Option Pat × List Stmt)}
    {fin : Option (List Stmt)} {env : Env} {fs : List Frame} (hc : s.ctl = .abr a)
    (hs : s.stack = .s (.try_ hd fin env) :: fs) (hn : s.next + margin < Sim.bound)
    (hsz : ∀ ss, fin = some ss → (blockNames ss).length + ss.length ≤ 2 ^ 20)
    (hszh : ∀ q body, hd = some (q, body) →
      (blockNames body).length + body.length ≤ 2 ^ 20 ∧ ∀ p, q = some p → (patNames p).length ≤ 2 ^ 20)
    (hI : ∀ ss, (fin = some ss ∨ ∃ q, hd = some (q, ss)) → ss.any isFuncDecl = true →
      Present s aFunctionProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, hf⟩ := abrTop h hc hs
  rw [e1, e2]
  have hfin : MSim (StepPostB F FR W stk M ν K S C) S C
      (Host.Ts.finOrResume F { s with stack := fs } fin env (.abrupt a))
      (Host.Ts.finOrResume F { t with stack := fs.map M.frame ++ stk } fin (M.env env) (M.comp (.abrupt a))) :=
    finOrResume_sim hr fin env (.abrupt a) hf ha (fun ss hss => hI ss (.inl hss))
      (fun ss hss => by have := margin_bound hn (hsz ss hss); dsimp only; omega)
  cases a with
  | throw e =>
    cases hd with
    | none => exact hfin
    | some hb =>
      obtain ⟨q, body⟩ := hb
      obtain ⟨hszb, hszp⟩ := hszh q body rfl
      cases q with
      | none =>
        have hn' := margin_bound hn hszb
        exact MSim.pure ⟨Grow.refl h.srv, enterBlock_rel (hr.push (.s (.catch_ fin env)) hf) body env hf
          (hI body (.inr ⟨none, rfl⟩)) (by dsimp only [St.push]; omega)⟩
      | some p =>
        have hn' := margin_bound hn (hszp p rfl)
        obtain ⟨ee, h1, he1, hP1⟩ := cells_rel (patNames p) hr env (by omega) hf
        have es : abrStep F { s with stack := fs } (.s (.try_ (some (some p, body)) fin env)) (.throw e) =
            Host.Ts.M.pure ((((Host.Ts.allocCells { s with stack := fs } (patNames p) env).2.push
              (.s (.catch_ fin env))).push (.s (.block [.block body]
                (Host.Ts.allocCells { s with stack := fs } (patNames p) env).1))).go
                (.bind p e (Host.Ts.allocCells { s with stack := fs } (patNames p) env).1 .init .let_)) := rfl
        have et : abrStep F { t with stack := fs.map M.frame ++ stk } (M.frame (.s (.try_ (some (some p, body)) fin env)))
            (M.abr (.throw e)) =
            Host.Ts.M.pure ((((Host.Ts.allocCells { t with stack := fs.map M.frame ++ stk } (patNames p) (M.env env)).2.push
              (.s (.catch_ fin (M.env env)))).push (.s (.block [.block body]
                (Host.Ts.allocCells { t with stack := fs.map M.frame ++ stk } (patNames p) (M.env env)).1))).go
                (.bind p (M.val e) (Host.Ts.allocCells { t with stack := fs.map M.frame ++ stk } (patNames p)
                  (M.env env)).1 .init .let_)) := rfl
        rw [es, et, ee]
        exact MSim.pure ⟨Grow.refl h.srv, ((h1.push (.s (.catch_ fin env))
          (Supp.env_mono hP1 (Nat.le_refl S.tab.length) (show Supp.env (Present s) S.tab.length env from hf))).push (.s (.block [.block body] _)) he1).go
          (.bind p e _ .init .let_) ⟨Supp.val_mono hP1 (Nat.le_refl S.tab.length) (show Supp.val (Present s) S.tab.length e from ha), he1⟩⟩
  | ret v => cases hd <;> exact hfin
  | brk l => cases hd <;> exact hfin
  | cont l => cases hd <;> exact hfin

/-- A labelled statement: `break` to its label completes it. -/
theorem step_abr_label (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {l : Name} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .s (.label l) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, _⟩ := abrTop h hc hs
  rw [e1, e2]
  cases a with
  | brk m =>
    cases m with
    | none => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.brk none)) trivial⟩
    | some m =>
      show MSim _ S C (bif nameEq l m then _ else _) (bif nameEq l m then _ else _)
      cases nameEq l m
      · exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.brk (some m))) trivial⟩
      · exact MSim.pure ⟨Grow.refl h.srv, hr.ret .undef trivial⟩
  | throw e => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.throw e)) ha⟩
  | ret v => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.ret v)) ha⟩
  | cont m => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.cont m)) trivial⟩

theorem step_abr_switchBody (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .s .switchBody :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, _⟩ := abrTop h hc hs
  rw [e1, e2]
  cases a with
  | brk m =>
    cases m with
    | none => exact MSim.pure ⟨Grow.refl h.srv, hr.ret .undef trivial⟩
    | some m => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.brk (some m))) trivial⟩
  | throw e => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.throw e)) ha⟩
  | ret v => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.ret v)) ha⟩
  | cont m => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.cont m)) trivial⟩


/-- Disposing the remaining resources of a scope, then resuming `c`. -/
theorem dispose_sim (h : RelB F FR W stk M ν K s S t C) (rest : List (Val × Val)) (c : Comp) (v : Val)
    (hr : Supp.pairs (Present s) S.tab.length rest) (hc : Supp.comp (Present s) S.tab.length c) :
    MSim (StepPostB F FR W stk M ν K S C) S C (retSt F s (.dispose rest c) v)
      (retSt F t (.dispose (M.pairs rest) (M.comp c)) (M.val v)) := by
  cases rest with
  | nil => exact MSim.pure ⟨Grow.refl h.srv, resume_rel h c hc⟩
  | cons p r =>
    obtain ⟨x, m⟩ := p
    have hp := hr (x, m) (List.mem_cons_self ..)
    have hr' : Supp.pairs (Present s) S.tab.length r := fun y hy => hr y (List.mem_cons_of_mem _ hy)
    exact MSim.pure ⟨Grow.refl h.srv, (h.push (.s (.dispose r c)) ⟨hr', hc⟩).go
      (.call m x []) ⟨hp.2, hp.1, fun _ hx => nomatch hx⟩⟩

theorem defineProp_keeps (s : St F.S) (a : Nat) (k : PKey) (p : PropV) (ha : a < 2 ^ 64) :
    (defineProp F s a k p).next = s.next ∧ ∀ b, Present s b → Present (defineProp F s a k p) b := by
  unfold defineProp
  cases s.obj? a with
  | none => exact ⟨rfl, fun _ hb => hb⟩
  | some o => exact ⟨rfl, fun b hb => Present.set _ ha hb⟩

/-- An abrupt completion during disposal: a throw while a throw is saved becomes a
`SuppressedError` (`hP`: its prototype is present); other throws replace the saved
completion; anything else passes. -/
theorem step_abr_dispose (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {rest : List (Val × Val)} {c : Comp}
    {fs : List Frame} (hc : s.ctl = .abr a) (hs : s.stack = .s (.dispose rest c) :: fs)
    (hn : s.next + margin < Sim.bound) (hP : Present s aSuppressedProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, hf⟩ := abrTop h hc hs
  rw [e1, e2]
  cases a with
  | throw e =>
    cases c with
    | normal w =>
      exact dispose_sim hr rest (.abrupt (.throw e)) .undef hf.1 ha
    | abrupt b =>
      cases b with
      | throw e0 =>
        have hm : margin = 2 ^ 30 := rfl
        have hn0 : s.next < Sim.bound := by omega
        have h64 := lt64 h hn0
        let s1 : St F.S := { s with stack := fs }
        let t1 : St F.S := { t with stack := fs.map M.frame ++ stk }
        have hP1 : ∀ x, Present s x → Present (s1.allocObj .ordinary (.obj aSuppressedProto) []).2 x :=
          fun _ hp => Present.alloc _ h64 hp
        obtain ⟨hal, h1⟩ := hr.allocObj .ordinary (.obj aSuppressedProto) [] hn0 trivial (hP1 _ hP)
          (fun _ hx => nomatch hx)
        have hv : M.val (.obj aSuppressedProto) = .obj aSuppressedProto := by
          show Val.obj (M.a aSuppressedProto) = _
          rw [h.intr _ (by decide)]
        rw [hv] at hal h1
        have hle := Nat.le_refl S.tab.length
        let a0 := (s1.allocObj .ordinary (.obj aSuppressedProto) []).1
        have ha0 : Present (s1.allocObj .ordinary (.obj aSuppressedProto) []).2 a0 := Present.alloc_next s1 _ h64
        have hfr0 : K.fr a0 = none := fresh_fr_none hr (Nat.le_refl _)
        have h64' : a0 < 2 ^ 64 := h64
        have hn1 : (s1.allocObj .ordinary (.obj aSuppressedProto) []).2.next < Sim.bound := by
          show s.next + 1 < Sim.bound
          omega
        have he : Supp.val (Present s) S.tab.length e := ha
        have he0 : Supp.val (Present s) S.tab.length e0 := hf.2
        have h2 := h1.defineProp hn1 ha0 hfr0 (k := .str (chars!"error")) (p := .data e true false) trivial
          (Supp.val_mono hP1 hle he)
        obtain ⟨hnx2, hP2⟩ := defineProp_keeps (s1.allocObj .ordinary (.obj aSuppressedProto) []).2 a0
          (.str (chars!"error")) (.data e true false) h64'
        have h3 := h2.defineProp (by rw [hnx2]; exact hn1) (hP2 _ ha0) hfr0 (k := .str (chars!"suppressed"))
          (p := .data e0 true false) trivial (Supp.val_mono (fun x hx => hP2 x (hP1 x hx)) hle he0)
        obtain ⟨_, hP3⟩ := defineProp_keeps (defineProp F (s1.allocObj .ordinary (.obj aSuppressedProto) []).2 a0
          (.str (chars!"error")) (.data e true false)) a0 (.str (chars!"suppressed")) (.data e0 true false) h64'
        have hP4 : ∀ x, Present s x → Present (defineProp F (defineProp F (s1.allocObj .ordinary
            (.obj aSuppressedProto) []).2 a0 (.str (chars!"error")) (.data e true false)) a0
            (.str (chars!"suppressed")) (.data e0 true false)) x := fun x hx => hP3 x (hP2 x (hP1 x hx))
        have hd := dispose_sim h3 rest (.abrupt (.throw (.obj a0))) .undef
          (Supp.pairs_mono hP4 hle hf.1) (hP3 _ (hP2 _ ha0))
        rw [show M.comp (.abrupt (.throw (.obj a0))) = .abrupt (.throw (.obj (M.a a0))) from rfl, ← hal] at hd
        exact hd
      | ret w => exact dispose_sim hr rest (.abrupt (.throw e)) .undef hf.1 ha
      | brk l => exact dispose_sim hr rest (.abrupt (.throw e)) .undef hf.1 ha
      | cont l => exact dispose_sim hr rest (.abrupt (.throw e)) .undef hf.1 ha
  | ret w => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.ret w)) ha⟩
  | brk l => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.brk l)) trivial⟩
  | cont l => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.cont l)) trivial⟩


/-! ## `switch` -/

theorem switchNext_sim (h : RelB F FR W stk M ν K s S t C) (d : Val) (all : List (Option Expr × List Stmt)) (env : Env)
    (hd : Supp.val (Present s) S.tab.length d) (he : Supp.env (Present s) S.tab.length env) :
    ∀ cs : List (Option Expr × List Stmt), MSim (StepPostB F FR W stk M ν K S C) S C (switchNext F s d cs all env)
      (switchNext F t (M.val d) cs all (M.env env))
  | [] => by
    cases hfd : fromDefault all with
    | none =>
      simp only [switchNext, hfd]
      exact MSim.pure ⟨Grow.refl h.srv, h.ret .undef trivial⟩
    | some r =>
      simp only [switchNext, hfd]
      exact MSim.pure ⟨Grow.refl h.srv, ((h.push (.s .switchBody) trivial).push
        (.s (.block (caseStmts r) env)) he).ret .undef trivial⟩
  | (none, ss) :: r => by
    simp only [switchNext]
    exact switchNext_sim h d all env hd he r
  | (some te, ss) :: r => by
    simp only [switchNext]
    exact MSim.pure ⟨Grow.refl h.srv, (h.push (.s (.switchCase d ((some te, ss) :: r) all env))
      ⟨hd, he⟩).go (.ev te env) he⟩

theorem step_ret_switchD (h : RelB F FR W stk M ν K s S t C) {v : Val} {cs : List (Option Expr × List Stmt)}
    {env : Env} {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .s (.switchD cs env) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact switchNext_sim hr v cs env hv hf cs

/-- A case test's value: strict equality with the discriminant (`hok`: bigint and native
pointer comparisons the map keeps). -/
theorem step_ret_switchCase (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) {v d : Val}
    {cs all : List (Option Expr × List Stmt)} {env : Env} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .s (.switchCase d cs all env) :: fs) (hok : StrictOK K d v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := retTop h hc hs
  rw [e1, e2]
  cases cs with
  | nil => exact MSim.fail _ _
  | cons c r =>
    obtain ⟨te, ss⟩ := c
    refine bool_step hr hFR (strictEq_sim hr hf.1 hv hok) (fun b M' S' C' hg hr' => ?_)
    have hA : Agree (Present s) S.tab.length M M' := hg.ext.agree
    cases b with
    | true =>
      exact MSim.pure ⟨Grow.refl hr'.srv, (push' (hr'.push (.s .switchBody) trivial) hg.ext hg.len
        (.s (.block (caseStmts ((te, ss) :: r)) env)) hf.2).ret .undef trivial⟩
    | false =>
      have := switchNext_sim hr' d all env (Supp.val_mono (fun _ hp => hp) hg.len hf.1) hf.2 r
      rw [← Map.val_agree hA hf.1, ← Map.env_agree hA hf.2] at this
      exact this


theorem step_abr_switchD (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {cs : List (Option Expr × List Stmt)}
    {env : Env} {fs : List Frame} (hc : s.ctl = .abr a) (hs : s.stack = .s (.switchD cs env) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) :=
  stmt_abr_pass h hc hs (fun _ _ => rfl) (fun _ _ => rfl)

theorem step_abr_switchCase (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {d : Val}
    {cs all : List (Option Expr × List Stmt)} {env : Env} {fs : List Frame} (hc : s.ctl = .abr a)
    (hs : s.stack = .s (.switchCase d cs all env) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) :=
  stmt_abr_pass h hc hs (fun _ _ => rfl) (fun _ _ => rfl)

end
end Host.Ts.Sim
