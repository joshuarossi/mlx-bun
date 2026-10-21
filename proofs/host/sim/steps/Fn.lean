import host.sim.steps.Call
namespace Host.Ts.Sim

/-! # Function frames: values and abrupt completions reaching `Frame.k` frames

Parameter binding, function bodies (block hoisting in lockstep), constructor
boundaries, instance fields and `super()` returns. Boundaries of async
functions and generators, `yield*`/`await` frames, `promiseThen` and native
frames are simulated elsewhere (Async, Builtins). -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-! ## The top frame -/

/-- A value returning to a `Frame.k` frame, on both sides. -/
theorem Rel.kRet (h : Rel F FR M ν K s S t C) {v : Val} {f : FnF} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k f :: fs) :
    step F s = retK F { s with stack := fs } f v ∧
    step F t = retK F { t with stack := fs.map M.frame } (M.fnF f) (M.val v) ∧
    Rel F FR M ν K { s with stack := fs } S { t with stack := fs.map M.frame } C ∧
    Supp.val (Present s) S.tab.length v ∧ Supp.fnF (Present s) S.tab.length f := by
  obtain ⟨hts, hr⟩ := h.pop hs
  have htc : t.ctl = .ret (M.val v) := by rw [h.ctl, hc]; rfl
  refine ⟨by simp only [step, hc, stepRet, hs, retStep], by simp only [step, htc, stepRet, hts, retStep, Map.frame],
    hr, ?_, h.stackSupp (.k f) (by rw [hs]; exact List.mem_cons_self ..)⟩
  have := h.ctlSupp
  rw [hc] at this
  exact this

/-- An abrupt completion reaching a `Frame.k` frame, on both sides. -/
theorem Rel.kAbr (h : Rel F FR M ν K s S t C) {a : Abrupt} {f : FnF} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .k f :: fs) :
    step F s = abrK F { s with stack := fs } f a ∧
    step F t = abrK F { t with stack := fs.map M.frame } (M.fnF f) (M.abr a) ∧
    Rel F FR M ν K { s with stack := fs } S { t with stack := fs.map M.frame } C ∧
    Supp.abr (Present s) S.tab.length a ∧ Supp.fnF (Present s) S.tab.length f := by
  obtain ⟨hts, hr⟩ := h.pop hs
  have htc : t.ctl = .abr (M.abr a) := by rw [h.ctl, hc]; rfl
  refine ⟨by simp only [step, hc, stepAbr, hs, abrStep], by simp only [step, htc, stepAbr, hts, abrStep, Map.frame],
    hr, ?_, h.stackSupp (.k f) (by rw [hs]; exact List.mem_cons_self ..)⟩
  have := h.ctlSupp
  rw [hc] at this
  exact this

theorem sim_pure {s' t' : St F.S} (h : Rel F FR M ν K s' S t' C) :
    MSim (StepPost F FR M ν K S C) S C (Host.Ts.M.pure s') (Host.Ts.M.pure t') :=
  MSim.pure ⟨Grow.refl h.srv, h⟩

/-- Cells at present addresses: the target's is the image (cells are never framed,
and a framed or mapped object is no cell). -/
theorem Rel.cell?_map (h : Rel F FR M ν K s S t C) {a : Nat} (ha : Present s a) :
    t.cell? (M.a a) = (s.cell? a).map (Option.map M.val) := by
  obtain ⟨o, hg⟩ := ha.get
  cases o with
  | cell v => rw [h.cell? (cell?_iff.2 hg), cell?_iff.2 hg]; rfl
  | obj o =>
    have hs : s.cell? a = none := by unfold St.cell?; rw [hg]
    rw [hs]
    cases hfr : K.fr a with
    | none =>
      unfold St.cell?
      rw [h.get hg hfr]
      rfl
    | some p =>
      obtain ⟨pre, pre'⟩ := p
      obtain ⟨o', ht, -⟩ := h.obj?_framed (obj?_iff.2 hg) hfr
      unfold St.cell?
      rw [obj?_iff.1 ht]
      rfl

/-! ## Simple frames -/

/-- A default parameter value evaluated: bind it, then the remaining parameters. -/
theorem step_ret_paramDflt (h : Rel F FR M ν K s S t C) {v : Val} {fn : Func} {p : Pat} {ps : List Pat}
    {args : List Val} {env : Env} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.paramDflt fn p ps args env) :: fs) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, has, he⟩ := h.kRet hc hs
  rw [e1, e2]
  exact sim_pure ((hr.push (.k (.params fn ps args env)) ⟨has, he⟩).go (.bind p v env .init .let_) ⟨hv, he⟩)

/-- Base-class constructor body: enter the explicit constructor with the new instance. -/
theorem step_ret_ctorBody (h : Rel F FR M ν K s S t C) {v o : Val} {fn : Func} {env : Env} {args : List Val}
    {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .k (.ctorBody o fn env args) :: fs)
    (hlen : (paramNames fn).length ≤ 2 ^ 20) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, -, ho, he, has⟩ := h.kRet hc hs
  rw [e1, e2]
  exact enterClosure_sim hr fn env false (home := .undef) (this := o) (b := .ctor o)
    (margin_split hn _ (by decide)) hlen he trivial ho has ho

/-! ## Function boundaries -/

theorem step_ret_fn_call (h : Rel F FR M ν K s S t C) {v : Val} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.fn .call) :: fs) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, -⟩ := h.kRet hc hs
  rw [e1, e2]
  exact sim_pure (hr.ret .undef trivial)

theorem step_ret_fn_ctor (h : Rel F FR M ν K s S t C) {v o : Val} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.fn (.ctor o)) :: fs) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, -, ho⟩ := h.kRet hc hs
  rw [e1, e2]
  exact sim_pure (hr.ret o ho)

/-- A derived constructor's body completed: `this` if `super()` ran, else a `ReferenceError`. -/
theorem step_ret_fn_derived (h : Rel F FR M ν K s S t C) {v : Val} {tc : Nat} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.fn (.derived tc)) :: fs)
    (hP : Present s aReferenceErrorProto) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, -, htc⟩ := h.kRet hc hs
  rw [e1, e2]
  have hcm := hr.cell?_map (a := tc) htc
  simp only [retK, boundaryRet, Map.fnF, Map.bnd, hcm]
  cases hct : (St.cell? { s with stack := fs } tc) with
  | some x =>
    cases x with
    | some w => exact sim_pure (hr.ret w (hr.cell?_supp hct))
    | none => exact refErr_sim hr hr.intr (margin_split hn 0 (Nat.zero_le _)) hP _
  | none => exact refErr_sim hr hr.intr (margin_split hn 0 (Nat.zero_le _)) hP _

end

/-! ## Abrupt completions at function boundaries -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- `return v` / `throw e` at a plain call boundary. -/
theorem step_abr_fn_call (h : Rel F FR M ν K s S t C) {a : Abrupt} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .k (.fn .call) :: fs) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, -⟩ := h.kAbr hc hs
  rw [e1, e2]
  cases a with
  | throw e =>
    simp only [abrK, boundaryAbr, Map.fnF, Map.bnd, Map.abr]
    exact sim_pure (hr.go (.abr (.throw e)) ha)
  | ret v =>
    simp only [abrK, boundaryAbr, Map.fnF, Map.bnd, Map.abr]
    exact sim_pure (hr.ret v ha)
  | brk l => exact MSim.fail _ _
  | cont l => exact MSim.fail _ _

/-- `return v` / `throw e` at a constructor boundary: object results replace the instance. -/
theorem step_abr_fn_ctor (h : Rel F FR M ν K s S t C) {a : Abrupt} {o : Val} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .k (.fn (.ctor o)) :: fs) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, ho⟩ := h.kAbr hc hs
  rw [e1, e2]
  cases a with
  | throw e =>
    simp only [abrK, boundaryAbr, Map.fnF, Map.bnd, Map.abr]
    exact sim_pure (hr.go (.abr (.throw e)) ha)
  | ret v =>
    simp only [abrK, boundaryAbr, Map.fnF, Map.bnd, Map.abr]
    cases v with
    | obj b => exact sim_pure (hr.ret (.obj b) ha)
    | _ => exact sim_pure (hr.ret o ho)
  | brk l => exact MSim.fail _ _
  | cont l => exact MSim.fail _ _

/-- `return v` / `throw e` at a derived-constructor boundary. -/
theorem step_abr_fn_derived (h : Rel F FR M ν K s S t C) {a : Abrupt} {tc : Nat} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .k (.fn (.derived tc)) :: fs)
    (hPT : Present s aTypeErrorProto) (hPR : Present s aReferenceErrorProto)
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, htc⟩ := h.kAbr hc hs
  rw [e1, e2]
  have hn0 := margin_split hn 0 (Nat.zero_le _)
  cases a with
  | throw e =>
    simp only [abrK, boundaryAbr, Map.fnF, Map.bnd, Map.abr]
    exact sim_pure (hr.go (.abr (.throw e)) ha)
  | ret v =>
    simp only [abrK, boundaryAbr, Map.fnF, Map.bnd, Map.abr]
    cases v with
    | obj b => exact sim_pure (hr.ret (.obj b) ha)
    | undef =>
      have hcm := hr.cell?_map (a := tc) htc
      simp only [Map.val, boundaryRet, hcm]
      cases hct : (St.cell? { s with stack := fs } tc) with
      | some x =>
        cases x with
        | some w => exact sim_pure (hr.ret w (hr.cell?_supp hct))
        | none => exact refErr_sim hr hr.intr hn0 hPR _
      | none => exact refErr_sim hr hr.intr hn0 hPR _
    | _ => exact typeErr_sim hr hr.intr hn0 hPT _
  | brk l => exact MSim.fail _ _
  | cont l => exact MSim.fail _ _

/-- Frames that let abrupt completions pass (all but boundaries, natives, `promiseThen`,
modules and the `yield*` resumption frames). -/
def kPass : FnF → Bool
  | .fn _ | .native _ _ | .promiseThen _ | .modules _ | .ystarResume _ _ | .ystarAResume _ _ => false
  | _ => true

theorem kPass_map (M : Map) (f : FnF) : kPass (M.fnF f) = kPass f := by
  cases f <;> rfl

theorem abrK_pass (s : St F.S) {f : FnF} (a : Abrupt) (hf : kPass f = true) :
    abrK F s f a = .pure (s.go (.abr a)) := by
  cases f <;> first | rfl | cases hf

/-- An abrupt completion passes a frame that does not catch it. -/
theorem step_abr_k_pass (h : Rel F FR M ν K s S t C) {a : Abrupt} {f : FnF} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .k f :: fs) (hf : kPass f = true) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, -⟩ := h.kAbr hc hs
  rw [e1, e2, abrK_pass _ a hf, abrK_pass _ _ (by rw [kPass_map]; exact hf)]
  exact sim_pure (hr.go (.abr a) ha)

/-- An abrupt completion of a module body halts. -/
theorem step_abr_modules (h : Rel F FR M ν K s S t C) {a : Abrupt} {r : List (List Stmt × Env)}
    {fs : List Frame} (hc : s.ctl = .abr a) (hs : s.stack = .k (.modules r) :: fs) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, -⟩ := h.kAbr hc hs
  rw [e1, e2]
  exact sim_pure (hr.go (.halt (.abrupt a)) ha)

end

/-! ## Block entry: hoisting in lockstep -/

theorem fn_lookupEnv_supp {A : Nat → Prop} {n : Nat} {x : Name} {env : Env} {b : Nat}
    (he : Supp.env A n env) (hl : lookupEnv x env = some b) : A b := by
  induction env with
  | nil => cases hl
  | cons p env ih =>
    obtain ⟨m, a⟩ := p
    change brec (Nat.beq (pack x) (pack m)) (some a) (lookupEnv x env) = some b at hl
    cases hb : Nat.beq (pack x) (pack m)
    · rw [hb] at hl
      exact ih (fun y hy => he y (List.mem_cons_of_mem _ hy)) hl
    · rw [hb] at hl
      rw [← Option.some.inj hl]
      exact he (m, a) (List.mem_cons_self ..)

/-- The function declaration a statement hoists, with its name. -/
def namedFunc : Stmt → Option (Name × Func)
  | .func f@(.mk (some n) _ _ _ _ _ _) => some (n, f)
  | _ => none

theorem initFuncs_cons {S' : Type} (s : St S') (env : Env) (st : Stmt) (ss : List Stmt) :
    initFuncs s env (st :: ss) = match namedFunc st with
      | some (n, f) => match lookupEnv n env with
        | some c => initFuncs ((closureObj s f env false .undef).2.setCell c
            (.obj (closureObj s f env false .undef).1)) env ss
        | none => initFuncs s env ss
      | none => initFuncs s env ss := by
  cases st
  case func f =>
    obtain ⟨nm, ps, r, b, a, g, pr⟩ := f
    cases nm <;> rfl
  all_goals rfl

theorem namedFunc_names {st : Stmt} {n : Name} {f : Func} (h : namedFunc st = some (n, f)) :
    stmtNames st = [n] := by
  cases st
  case func f =>
    obtain ⟨nm, ps, r, b, a, g, pr⟩ := f
    cases nm with
    | none => cases h
    | some m =>
      simp only [namedFunc, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, -⟩ := h
      rfl
  all_goals cases h

theorem blockNames_cons (st : Stmt) (ss : List Stmt) : blockNames (st :: ss) = stmtNames st ++ blockNames ss := rfl

theorem initFuncs_keeps {S' : Type} (env : Env) : ∀ (ss : List Stmt) (s : St S'),
    (initFuncs s env ss).stack = s.stack
  | [], _ => rfl
  | st :: ss, s => by
    rw [initFuncs_cons]
    cases namedFunc st with
    | none => exact initFuncs_keeps env ss s
    | some p =>
      obtain ⟨n, f⟩ := p
      dsimp only
      cases lookupEnv n env with
      | none => exact initFuncs_keeps env ss s
      | some c => exact initFuncs_keeps env ss _

theorem allocCells_keeps {S' : Type} : ∀ (ns : List Name) (s : St S') (env : Env),
    (allocCells s ns env).2.stack = s.stack
  | [], _, _ => rfl
  | _ :: ns, s, env => by rw [allocCells_cons]; exact allocCells_keeps ns _ _

theorem hoist_eq {S' : Type} (s : St S') (ss : List Stmt) (env : Env) :
    hoist s ss env = bif (blockNames ss).isEmpty then (env, s) else
      ((allocCells s (blockNames ss) env).1,
        initFuncs (allocCells s (blockNames ss) env).2 (allocCells s (blockNames ss) env).1 ss) := by
  unfold hoist
  cases blockNames ss <;> rfl

theorem hoist_keeps {S' : Type} (s : St S') (ss : List Stmt) (env : Env) :
    (hoist s ss env).2.stack = s.stack := by
  rw [hoist_eq]
  cases (blockNames ss).isEmpty
  · show (initFuncs _ _ ss).stack = s.stack
    rw [initFuncs_keeps, allocCells_keeps]
  · rfl

theorem enterBlock_eq {S' : Type} (s : St S') (ss : List Stmt) (env : Env) :
    enterBlock s ss env =
      (((hoist s ss env).2.push (.s (.scope []))).push (.s (.block ss (hoist s ss env).1))).ret .undef := rfl

theorem enterBlock_stack {S' : Type} (s : St S') (ss : List Stmt) (env : Env) :
    (enterBlock s ss env).stack = .s (.block ss (hoist s ss env).1) :: .s (.scope []) :: s.stack := by
  rw [enterBlock_eq]
  show _ :: _ :: (hoist s ss env).2.stack = _
  rw [hoist_keeps]

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {S : SSrv} {C : CSrv}

theorem adv_setCell {s t : St F.S} (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) {a : Nat} {v : Val}
    (ha : Present s a) (hfr : K.fr a = none) (hv : Supp.val (Present s) S.tab.length v) :
    Adv F FR M ν K S C s (s.setCell a v) (t.setCell (M.a a) (M.val v)) 0 :=
  ⟨h.setCell v hn ha hfr hv, fun b hb => Present.set _ (by
    have := h.presentBound a ha
    have := fn_s64 hn
    omega) hb, Nat.le_refl _, Nat.le_refl _⟩

theorem initFuncs_adv (env : Env) : ∀ (ss : List Stmt) (s t : St F.S),
    Rel F FR M ν K s S t C → s.next + (blockNames ss).length < Sim.bound → Present s aFunctionProto →
    Supp.env (Present s) S.tab.length env →
    (∀ n ∈ blockNames ss, ∀ c, lookupEnv n env = some c → K.fr c = none) →
    Adv F FR M ν K S C s (initFuncs s env ss) (initFuncs t (M.env env) ss) (blockNames ss).length
  | [], _, _, h, _, _, _, _ => Adv.refl h
  | st :: ss, s, t, h, hn, hP, he, hfr => by
    have hfr' : ∀ n ∈ blockNames ss, ∀ c, lookupEnv n env = some c → K.fr c = none :=
      fun n hm c hl => hfr n (by rw [blockNames_cons]; exact List.mem_append_right _ hm) c hl
    have hlen : (blockNames (st :: ss)).length = (stmtNames st).length + (blockNames ss).length := by
      rw [blockNames_cons, List.length_append]
    rw [initFuncs_cons, initFuncs_cons]
    cases hnf : namedFunc st with
    | none =>
      exact (initFuncs_adv env ss s t h (by omega) hP he hfr').weaken (by omega)
    | some p =>
      obtain ⟨n, f⟩ := p
      dsimp only
      have hsn := namedFunc_names hnf
      rw [hsn] at hlen
      simp only [List.length_cons, List.length_nil] at hlen
      cases hl : lookupEnv n env with
      | none =>
        rw [lookupEnv_map, hl]
        simp only [Option.map_none]
        exact (initFuncs_adv env ss s t h (by omega) hP he hfr').weaken (by omega)
      | some c =>
        rw [lookupEnv_map, hl]
        simp only [Option.map_some]
        have hn0 : s.next < Sim.bound := by omega
        obtain ⟨e1, -, hp1, a1⟩ := adv_allocObj h hn0 (.fn (.closure f env false .undef)) aFunctionProto []
          (h.intr _ (by decide)) hP ⟨he, trivial⟩ (fun _ hx => nomatch hx)
        have e1' : (closureObj t f (M.env env) false .undef).1 = M.a s.next := e1
        have hc : Present s c := fn_lookupEnv_supp he hl
        have hcfr : K.fr c = none := hfr n (by rw [blockNames_cons, hsn]; exact List.mem_cons_self ..) c hl
        have a2 := adv_setCell a1.rel (a1.lt (show s.next + (1 + 0) < Sim.bound by omega)) (a1.pres c hc) hcfr (v := .obj s.next) hp1
        have a3 := initFuncs_adv env ss _ _ a2.rel
          (by have := a1.next; have := a2.next; show _ < _; omega)
          (a2.pres _ (a1.pres _ hP)) (a2.env (a1.env he)) hfr'
        rw [e1']
        exact ((a1.trans a2).trans a3).weaken (by omega)

/-- Hoisting a block: one cell per declared name and one closure per function declaration. -/
theorem hoist_adv {s t : St F.S} (h : Rel F FR M ν K s S t C) (ss : List Stmt) (env : Env)
    (hn : s.next + 2 * (blockNames ss).length < Sim.bound) (hP : Present s aFunctionProto)
    (he : Supp.env (Present s) S.tab.length env) :
    (hoist t ss (M.env env)).1 = M.env (hoist s ss env).1 ∧
    Adv F FR M ν K S C s (hoist s ss env).2 (hoist t ss (M.env env)).2 (2 * (blockNames ss).length) ∧
    Supp.env (Present (hoist s ss env).2) S.tab.length (hoist s ss env).1 := by
  rw [hoist_eq, hoist_eq]
  cases (blockNames ss).isEmpty
  · obtain ⟨e1, a1, he1⟩ := allocCells_adv (blockNames ss) s t env h (by omega) he
    simp only [Bool.cond_false]
    rw [e1]
    have hfr : ∀ n ∈ blockNames ss, ∀ c, lookupEnv n (allocCells s (blockNames ss) env).1 = some c →
        K.fr c = none := by
      intro n hm c hl
      have hc := allocCells_lookup_mem _ _ _ n c hm hl
      cases hf : K.fr c with
      | none => rfl
      | some p => exact absurd (h.presentBound c (h.framedPresent c p hf)) (by omega)
    have a2 := initFuncs_adv (allocCells s (blockNames ss) env).1 ss _ _ a1.rel
        (a1.lt (show s.next + ((blockNames ss).length + (blockNames ss).length) < Sim.bound by omega))
        (a1.pres _ hP) he1 hfr
    refine ⟨rfl, (a1.trans a2).weaken (by omega), ?_⟩
    exact a2.env he1
  · exact ⟨rfl, (Adv.refl h).weaken (Nat.zero_le _), he⟩

/-- Entering a block: hoisting, then the scope and block frames. -/
theorem enterBlock_adv {s t : St F.S} (h : Rel F FR M ν K s S t C) (ss : List Stmt) (env : Env)
    (hn : s.next + 2 * (blockNames ss).length < Sim.bound) (hP : Present s aFunctionProto)
    (he : Supp.env (Present s) S.tab.length env) :
    Adv F FR M ν K S C s (enterBlock s ss env) (enterBlock t ss (M.env env)) (2 * (blockNames ss).length) := by
  obtain ⟨e1, a1, he1⟩ := hoist_adv h ss env hn hP he
  rw [enterBlock_eq, enterBlock_eq, e1]
  exact ⟨((a1.rel.push (.s (.scope [])) (fun _ hx => nomatch hx)).push (.s (.block ss _)) he1).ret .undef trivial,
    a1.pres, a1.next, a1.mono⟩

end

/-! ## Function bodies -/

/-- The value of a base-constructor boundary on top of a stack. -/
def ctorTop : List Frame → Option Val
  | .k (.fn (.ctor o)) :: _ => some o
  | _ => none

/-- The frames below a function boundary on top of a stack. -/
def fnTop : List Frame → Option (List Frame)
  | .k (.fn _) :: rest => some rest
  | _ => none

/-- The names a function body block hoists. -/
def fnBlockNames : Func → List Name
  | .mk _ _ _ (.block ss) _ _ _ => blockNames ss
  | _ => []

theorem ctorTop_map (M : Map) : ∀ fs : List Frame, ctorTop (fs.map M.frame) = (ctorTop fs).map M.val
  | [] => rfl
  | f :: fs => by
    cases f with
    | k g =>
      cases g with
      | fn b => cases b <;> rfl
      | _ => rfl
    | _ => rfl

theorem fnTop_map (M : Map) : ∀ fs : List Frame, fnTop (fs.map M.frame) = (fnTop fs).map (·.map M.frame)
  | [] => rfl
  | f :: fs => by
    cases f with
    | k g =>
      cases g with
      | fn b => rfl
      | _ => rfl
    | _ => rfl

theorem ctorTop_supp {A : Nat → Prop} {n : Nat} : ∀ {fs : List Frame} {o : Val},
    (∀ f ∈ fs, Supp.frame A n f) → ctorTop fs = some o → Supp.val A n o
  | [], _, _, h => nomatch h
  | f :: fs, o, hs, h => by
    cases f with
    | k g =>
      cases g with
      | fn b =>
        cases b with
        | ctor o' =>
          cases h
          exact hs _ (List.mem_cons_self ..)
        | _ => cases h
      | _ => cases h
    | _ => cases h

theorem fnTop_sub : ∀ {fs rest : List Frame}, fnTop fs = some rest → ∀ f ∈ rest, f ∈ fs
  | [], _, h => nomatch h
  | f :: fs, rest, h => by
    cases f with
    | k g =>
      cases g with
      | fn b =>
        cases h
        exact fun x hx => List.mem_cons_of_mem _ hx
      | _ => cases h
    | _ => cases h

theorem startBody_expr (F : Ffi) (s : St F.S) (nm : Option Name) (ps : List Pat) (r : Option Pat) (e : Expr)
    (a g : Bool) (pr : List Name) (env : Env) :
    startBody F s (.mk nm ps r (.expr e) a g pr) env = .pure ((s.push (.s .ret)).go (.ev e env)) := rfl

theorem startBody_block (F : Ffi) (s : St F.S) (nm : Option Name) (ps : List Pat) (r : Option Pat)
    (ss : List Stmt) (a g : Bool) (pr : List Name) (env : Env) :
    startBody F s (.mk nm ps r (.block ss) a g pr) env =
      match ctorTop s.stack, pr with
      | some o, p :: ps' => .pure (((enterBlock s ss env).push (.k (.paramProps o (p :: ps') env))).ret .undef)
      | _, _ => .pure (enterBlock s ss env) := by
  unfold startBody
  dsimp only
  rw [enterBlock_stack]
  cases hst : s.stack with
  | nil => cases pr <;> rfl
  | cons f fs =>
    cases pr with
    | nil => cases ctorTop (f :: fs) <;> rfl
    | cons p ps' =>
      cases f with
      | k g' =>
        cases g' with
        | fn b => cases b <;> rfl
        | _ => rfl
      | _ => rfl

theorem enterBody_eq (F : Ffi) (s : St F.S) (nm : Option Name) (ps : List Pat) (r : Option Pat) (body : Body)
    (a g : Bool) (pr : List Name) (env : Env) :
    enterBody F s (.mk nm ps r body a g pr) env =
      bif g then (match fnTop s.stack with
        | some rest =>
          retS F { (s.allocObj (.gen (.start (bodyStmts body) env) a [])
            (.obj (bif a then aAsyncGenProto else aGenProto)) []).2 with stack := rest }
            (.obj (s.allocObj (.gen (.start (bodyStmts body) env) a [])
              (.obj (bif a then aAsyncGenProto else aGenProto)) []).1)
        | none => .fail "function boundary")
      else bif a then (match fnTop s.stack with
        | some rest =>
          startBody F ((newPromise { s with stack := rest }).2.push
            (.k (.fn (.async (newPromise { s with stack := rest }).1)))) (.mk nm ps r body a g pr) env
        | none => .fail "function boundary")
      else startBody F s (.mk nm ps r body a g pr) env := by
  cases a <;> cases g
  · rfl
  all_goals
    unfold enterBody
    cases hst : s.stack with
    | nil => rfl
    | cons f fs =>
      cases f with
      | k g' =>
        cases g' with
        | fn b => rfl
        | _ => rfl
      | _ => rfl


section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {S : SSrv} {C : CSrv}

/-- Starting a function body: an expression body returns its value; a block body is
entered (hoisting in lockstep), with a base constructor's parameter properties first. -/
theorem startBody_sim {s t : St F.S} (h : Rel F FR M ν K s S t C) (fn : Func) (env : Env)
    (hn : s.next + 2 * (fnBlockNames fn).length < Sim.bound) (hP : Present s aFunctionProto)
    (he : Supp.env (Present s) S.tab.length env) :
    MSim (StepPost F FR M ν K S C) S C (startBody F s fn env) (startBody F t fn (M.env env)) := by
  obtain ⟨nm, ps, r, body, a, g, pr⟩ := fn
  cases body with
  | expr e =>
    rw [startBody_expr, startBody_expr]
    exact sim_pure ((h.push (.s .ret) trivial).go (.ev e env) he)
  | block ss =>
    rw [startBody_block, startBody_block, h.stack, ctorTop_map]
    have a1 := enterBlock_adv h ss env hn hP he
    cases hct : ctorTop s.stack with
    | none => exact sim_pure a1.rel
    | some o =>
      have ho : Supp.val (Present s) S.tab.length o := ctorTop_supp h.stackSupp hct
      cases pr with
      | nil => exact sim_pure a1.rel
      | cons p ps' =>
        exact sim_pure ((a1.rel.push (.k (.paramProps o (p :: ps') env)) ⟨a1.val ho, a1.env he⟩).ret .undef trivial)

/-- Entering a function body: plain functions start it; async functions first replace
their call boundary by a promise boundary; generators return a new generator object. -/
theorem enterBody_sim {s t : St F.S} (h : Rel F FR M ν K s S t C) (fn : Func) (env : Env)
    (hn : s.next + (1 + 2 * (fnBlockNames fn).length) < Sim.bound)
    (hIP : ∀ a, 0 < a → a < aFirst → Present s a) (he : Supp.env (Present s) S.tab.length env) :
    MSim (StepPost F FR M ν K S C) S C (enterBody F s fn env) (enterBody F t fn (M.env env)) := by
  obtain ⟨nm, ps, r, body, a, g, pr⟩ := fn
  rw [enterBody_eq, enterBody_eq, h.stack, fnTop_map]
  have hn0 : s.next < Sim.bound := by omega
  cases g with
  | true =>
    cases hft : fnTop s.stack with
    | none => exact MSim.fail _ _
    | some rest =>
      have hrest : ∀ f ∈ rest, Supp.frame (Present s) S.tab.length f :=
        fun f hf => h.stackSupp f (fnTop_sub hft f hf)
      have hgp : Present s (bif a then aAsyncGenProto else aGenProto) := by
        cases a
        · exact hIP _ (by decide) (by decide)
        · exact hIP _ (by decide) (by decide)
      have hgI : M.a (bif a then aAsyncGenProto else aGenProto) = bif a then aAsyncGenProto else aGenProto := by
        cases a
        · exact h.intr _ (by decide)
        · exact h.intr _ (by decide)
      obtain ⟨e1, -, hp1, a1⟩ := adv_allocObj h hn0 (.gen (.start (bodyStmts body) env) a []) _ [] hgI hgp
        ⟨he, fun _ hx => nomatch hx⟩ (fun _ hx => nomatch hx)
      have e1' : (t.allocObj (.gen (.start (bodyStmts body) (M.env env)) a [])
          (.obj (bif a then aAsyncGenProto else aGenProto)) []).1 = M.a s.next := e1
      have hr := (a1.rel.restack rest fun f hf => Supp.frame_mono a1.pres (Nat.le_refl _) (hrest f hf)).ret
        (.obj s.next) hp1
      show MSim _ S C (retS F _ _) (retS F _ (.obj (t.allocObj _ _ _).1))
      rw [e1']
      exact sim_pure hr
  | false =>
    cases a with
    | false =>
      exact startBody_sim h (.mk nm ps r body false false pr) env (by omega) (hIP _ (by decide) (by decide)) he
    | true =>
      cases hft : fnTop s.stack with
      | none => exact MSim.fail _ _
      | some rest =>
        have hrest : ∀ f ∈ rest, Supp.frame (Present s) S.tab.length f :=
          fun f hf => h.stackSupp f (fnTop_sub hft f hf)
        have h0 := h.restack rest hrest
        obtain ⟨e1, -, hp1, a1⟩ := adv_allocObj h0 hn0 (.promise (.pending [])) aPromiseProto []
          (h.intr _ (by decide)) (hIP _ (by decide) (by decide)) (fun _ hx => nomatch hx) (fun _ hx => nomatch hx)
        have e1' : (newPromise { t with stack := rest.map M.frame }).1 = M.a s.next := e1
        have h1 := a1.rel.push (.k (.fn (.async s.next))) hp1
        simp only [Bool.cond_true, Bool.cond_false, Option.map_some]
        rw [e1']
        exact startBody_sim h1 _ env (a1.lt hn)
          (a1.pres _ (hIP _ (by decide) (by decide))) (a1.env he)

end

/-! ## Parameters -/

private theorem nthD_map {α β : Type} (f : α → β) (d : α) : ∀ (l : List α) (i : Nat),
    nthD (f d) (l.map f) i = f (nthD d l i)
  | [], _ => rfl
  | _ :: _, 0 => rfl
  | _ :: l, i + 1 => nthD_map f d l i

theorem nthD_supp {A : Nat → Prop} {n : Nat} {d : Val} (hd : Supp.val A n d) :
    ∀ {l : List Val} {i : Nat}, Supp.vals A n l → Supp.val A n (nthD d l i)
  | [], _, _ => hd
  | _ :: _, 0, hl => hl _ (List.mem_cons_self ..)
  | _ :: l, i + 1, hl => nthD_supp hd (l := l) (i := i) fun x hx => hl x (List.mem_cons_of_mem _ hx)

theorem Map.vals_tail (M : Map) (l : List Val) : (M.vals l).tail = M.vals l.tail := by
  cases l <;> rfl

theorem Supp.vals_tail {A : Nat → Prop} {n : Nat} {l : List Val} (hl : Supp.vals A n l) :
    Supp.vals A n l.tail := by
  cases l with
  | nil => exact hl
  | cons _ l => exact fun x hx => hl x (List.mem_cons_of_mem _ hx)

/-- A default parameter whose argument is missing. -/
def dfltOf : Pat → Val → Option (Pat × Expr)
  | .dflt q d, .undef => some (q, d)
  | _, _ => none

theorem dfltOf_map (M : Map) (p : Pat) (v : Val) : dfltOf p (M.val v) = dfltOf p v := by
  cases p <;> cases v <;> rfl

theorem paramsNext_cons (F : Ffi) (s : St F.S) (fn : Func) (p : Pat) (ps : List Pat) (args : List Val)
    (env : Env) :
    paramsNext F s fn (p :: ps) args env = match dfltOf p (nthD .undef args 0) with
      | some (q, d) => .pure ((s.push (.k (.paramDflt fn q ps args.tail env))).go (.ev d env))
      | none => .pure ((s.push (.k (.params fn ps args.tail env))).go (.bind p (nthD .undef args 0) env .init .let_)) := by
  unfold paramsNext
  dsimp only
  cases p <;> cases nthD .undef args 0 <;> rfl

theorem paramsNext_nil (F : Ffi) (s : St F.S) (fn : Func) (args : List Val) (env : Env) :
    paramsNext F s fn [] args env = match fnRest fn with
      | some r => .pure (((newArray s args).2.push (.k (.params (noRest fn) [] [] env))).go
          (.bind r (.obj (newArray s args).1) env .init .let_))
      | none => enterBody F s fn env := by
  unfold paramsNext
  cases fnRest fn <;> rfl

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- The next parameter: bind it to its argument (or evaluate its default), collect the
rest parameter into an array, or enter the body. -/
theorem step_ret_params (h : Rel F FR M ν K s S t C) {v : Val} {fn : Func} {ps : List Pat}
    {args : List Val} {env : Env} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.params fn ps args env) :: fs)
    (hIP : ∀ a, 0 < a → a < aFirst → Present s a) (hlen : (fnBlockNames fn).length ≤ 2 ^ 20)
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, -, has, he⟩ := h.kRet hc hs
  rw [e1, e2]
  show MSim _ S C (paramsNext F _ fn ps args env) (paramsNext F _ fn ps (M.vals args) (M.env env))
  cases ps with
  | cons p ps =>
    rw [paramsNext_cons, paramsNext_cons, show nthD Val.undef (M.vals args) 0 = M.val (nthD .undef args 0) from
      nthD_map M.val .undef args 0, dfltOf_map, Map.vals_tail]
    have hv := nthD_supp (d := .undef) (i := 0) trivial has
    cases hd : dfltOf p (nthD .undef args 0) with
    | some qd =>
      obtain ⟨q, d⟩ := qd
      exact sim_pure ((hr.push (.k (.paramDflt fn q ps args.tail env)) ⟨Supp.vals_tail has, he⟩).go
        (.ev d env) he)
    | none =>
      exact sim_pure ((hr.push (.k (.params fn ps args.tail env)) ⟨Supp.vals_tail has, he⟩).go
        (.bind p (nthD .undef args 0) env .init .let_) ⟨hv, he⟩)
  | nil =>
    rw [paramsNext_nil, paramsNext_nil]
    cases hrest : fnRest fn with
    | some r =>
      obtain ⟨ea, -, hpa, a1⟩ := adv_allocObj hr (margin_split hn 0 (Nat.zero_le _)) (.array args)
        aArrayProto [] (hr.intr _ (by decide)) (hIP _ (by decide) (by decide)) has (fun _ hx => nomatch hx)
      have ea' : (newArray { t with stack := fs.map M.frame } (M.vals args)).1 = M.a s.next := ea
      rw [ea']
      exact sim_pure ((a1.rel.push (.k (.params (noRest fn) [] [] env)) ⟨(fun _ hx => nomatch hx), a1.env he⟩).go
        (.bind r (.obj s.next) env .init .let_) ⟨hpa, a1.env he⟩)
    | none =>
      exact enterBody_sim hr fn env (margin_split hn _ (by have : margin = 2 ^ 30 := rfl; omega)) hIP he

end

/-! ## Instance fields -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {S : SSrv} {C : CSrv}

theorem defineData_adv {s t : St F.S} (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) {a : Nat}
    {k : PKey} {v : Val} (ha : Present s a) (hfr : K.fr a = none) (hk : Supp.key (Present s) S.tab.length k)
    (hv : Supp.val (Present s) S.tab.length v) :
    Adv F FR M ν K S C s (defineData F s a k v) (defineData F t (M.a a) (M.key k) (M.val v)) 0 := by
  refine ⟨h.defineData hn ha hfr hk hv, ?_, ?_, ?_⟩
  · unfold defineData
    split
    · split <;> exact h.present_set hn ha _
    · exact fun _ hp => hp
  · unfold defineData
    split
    · split <;> exact Nat.le_refl _
    · exact Nat.le_refl _
  · unfold defineData
    split
    · split <;> exact Nat.le_refl _
    · exact Nat.le_refl _

/-- A private member written into an unframed object. -/
theorem adv_setPriv {s t : St F.S} (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) {o : Nat} {ob : Obj}
    (ho : s.obj? o = some ob) (hfr : K.fr o = none) {b : Nat} (nm : Name) {p : PropV} (hb : Present s b)
    (hp : Supp.prop (Present s) S.tab.length p) :
    Adv F FR M ν K S C s (s.setObj o { ob with priv := setPrivL b nm p ob.priv })
      (t.setObj (M.a o) { M.obj ob with priv := setPrivL (M.a b) nm (M.prop p) (M.obj ob).priv }) 0 := by
  have hso := h.obj?_supp ho
  have ha : Present s o := Present.of_get (obj?_iff.1 ho)
  have hr := h.setObj { ob with priv := setPrivL b nm p ob.priv } hn ha hfr
    ⟨hso.1, hso.2.1, hso.2.2.1, setPrivL_supp hb hp hso.2.2.2⟩
  rw [Map.obj_privs, setPrivL_map h.inj nm p hb hso.2.2.2] at hr
  exact ⟨hr, h.present_set hn ha _, Nat.le_refl _, Nat.le_refl _⟩

/-- Instance field initialization runs in one step up to the next initializer. -/
theorem fieldsNext_sim {o : Nat} {env : Env} (hfr : K.fr o = none) : ∀ (ms : List InstMember) (s t : St F.S),
    Rel F FR M ν K s S t C → s.next < Sim.bound → Present s o → Supp.insts (Present s) S.tab.length ms →
    Supp.env (Present s) S.tab.length env →
    MSim (StepPost F FR M ν K S C) S C (fieldsNext F s o ms env) (fieldsNext F t (M.a o) (ms.map M.inst) (M.env env))
  | [], s, t, h, _, _, _, _ => by
    simp only [fieldsNext, List.map_nil]
    exact sim_pure (h.ret .undef trivial)
  | m :: ms, s, t, h, hn, ho, hms, he => by
    have hm : Supp.inst (Present s) S.tab.length m := hms m (List.mem_cons_self ..)
    have hms' : Supp.insts (Present s) S.tab.length ms := fun x hx => hms x (List.mem_cons_of_mem _ hx)
    cases m with
    | field k init =>
      cases init with
      | none =>
        simp only [fieldsNext, List.map_cons, Map.inst]
        have a1 := defineData_adv h hn (v := .undef) ho hfr hm trivial
        exact fieldsNext_sim hfr ms _ _ a1.rel (by have := a1.next; omega) (a1.pres _ ho)
          (Supp.insts_mono a1.pres (Nat.le_refl _) hms') (a1.env he)
      | some e =>
        simp only [fieldsNext, List.map_cons, Map.inst]
        exact sim_pure ((h.push (.k (.fieldVal o k ms env)) ⟨ho, hm, hms', he⟩).go (.ev e env) he)
    | privField b nm init =>
      cases init with
      | none =>
        simp only [fieldsNext, List.map_cons, Map.inst]
        cases hob : s.obj? o with
        | none => exact MSim.fail _ _
        | some ob =>
          rw [h.obj? hob hfr]
          have a1 := adv_setPriv h hn hob hfr nm (p := .data .undef true false) hm trivial
          exact fieldsNext_sim hfr ms _ _ a1.rel (by have := a1.next; omega) (a1.pres _ ho)
            (Supp.insts_mono a1.pres (Nat.le_refl _) hms') (a1.env he)
      | some e =>
        simp only [fieldsNext, List.map_cons, Map.inst]
        exact sim_pure ((h.push (.k (.privVal o b nm ms env)) ⟨ho, hm, hms', he⟩).go (.ev e env) he)
    | privMethod b nm p =>
      simp only [fieldsNext, List.map_cons, Map.inst]
      cases hob : s.obj? o with
      | none => exact MSim.fail _ _
      | some ob =>
        rw [h.obj? hob hfr]
        have a1 := adv_setPriv h hn hob hfr nm hm.1 hm.2
        exact fieldsNext_sim hfr ms _ _ a1.rel (by have := a1.next; omega) (a1.pres _ ho)
          (Supp.insts_mono a1.pres (Nat.le_refl _) hms') (a1.env he)

variable {s t : St F.S}

/-- Instance fields of a new object (the object must be unframed). -/
theorem step_ret_fields (h : Rel F FR M ν K s S t C) {v : Val} {o : Nat} {ms : List InstMember} {env : Env}
    {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .k (.fields o ms env) :: fs)
    (hfr : K.fr o = none) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, -, ho, hms, he⟩ := h.kRet hc hs
  rw [e1, e2]
  exact fieldsNext_sim hfr ms _ _ hr (margin_split hn 0 (Nat.zero_le _)) ho hms he

/-- A field initializer's value is defined on the object; then the next fields. -/
theorem step_ret_fieldVal (h : Rel F FR M ν K s S t C) {v : Val} {o : Nat} {k : PKey} {ms : List InstMember}
    {env : Env} {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .k (.fieldVal o k ms env) :: fs)
    (hfr : K.fr o = none) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, ho, hk, hms, he⟩ := h.kRet hc hs
  rw [e1, e2]
  have hn0 := margin_split hn 0 (Nat.zero_le _)
  have a1 := defineData_adv hr hn0 ho hfr hk hv
  exact fieldsNext_sim hfr ms _ _ a1.rel (a1.lt (margin_split hn (0 + 0) (Nat.zero_le _))) (a1.pres _ ho)
    (Supp.insts_mono a1.pres (Nat.le_refl _) hms) (a1.env he)

/-- A private field initializer's value is stored on the object; then the next fields. -/
theorem step_ret_privVal (h : Rel F FR M ν K s S t C) {v : Val} {o b : Nat} {nm : Name} {ms : List InstMember}
    {env : Env} {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .k (.privVal o b nm ms env) :: fs)
    (hfr : K.fr o = none) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, ho, hb, hms, he⟩ := h.kRet hc hs
  rw [e1, e2]
  have hn0 := margin_split hn 0 (Nat.zero_le _)
  simp only [retK, Map.fnF]
  cases hob : St.obj? { s with stack := fs } o with
  | none => exact MSim.fail _ _
  | some ob =>
    rw [hr.obj? hob hfr]
    have a1 := adv_setPriv hr hn0 hob hfr nm (p := .data v true false) hb hv
    exact fieldsNext_sim hfr ms _ _ a1.rel (a1.lt (margin_split hn (0 + 0) (Nat.zero_le _))) (a1.pres _ ho)
      (Supp.insts_mono a1.pres (Nat.le_refl _) hms) (a1.env he)

end

/-! ## `super()` returns and parameter properties -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- A variable's initialized value: the target's is the image. -/
theorem Rel.cellVal?_map (h : Rel F FR M ν K s S t C) {n : Name} {env : Env}
    (he : Supp.env (Present s) S.tab.length env) :
    cellVal? F t n (M.env env) = (cellVal? F s n env).map M.val := by
  unfold cellVal?
  rw [lookupEnv_map]
  cases hl : lookupEnv n env with
  | none => rfl
  | some c =>
    show (t.cell? (M.a c)).bind id = ((s.cell? c).bind id).map M.val
    rw [h.cell?_map (fn_lookupEnv_supp he hl)]
    cases s.cell? c with
    | none => rfl
    | some x => cases x <;> rfl

theorem Rel.cellVal?_supp (h : Rel F FR M ν K s S t C) {n : Name} {env : Env} {v : Val}
    (hv : cellVal? F s n env = some v) : Supp.val (Present s) S.tab.length v := by
  unfold cellVal? at hv
  cases hl : lookupEnv n env with
  | none => rw [hl] at hv; cases hv
  | some c =>
    rw [hl] at hv
    change (s.cell? c).bind id = some v at hv
    cases hc : s.cell? c with
    | none => rw [hc] at hv; cases hv
    | some x =>
      rw [hc] at hv
      cases x with
      | none => cases hv
      | some w =>
        cases hv
        exact h.cell?_supp hc

/-- `super(...)` returned `v`: initialize `this` (a `ReferenceError` if already
initialized), then the instance fields and parameter properties of the class. The `this`
cell must be a cell (it is allocated as one by `constructStep`). -/
theorem step_ret_super (h : Rel F FR M ν K s S t C) {v : Val} {tc cls : Nat} {env : Env} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.superRet tc cls env) :: fs)
    (hcell : ∃ w, s.cell? tc = some w) (hP : Present s aReferenceErrorProto)
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, htc, hcls, he⟩ := h.kRet hc hs
  rw [e1, e2]
  have hn0 := margin_split hn 0 (Nat.zero_le _)
  simp only [retK, Map.fnF]
  rw [hr.cell?_map htc]
  obtain ⟨w, hw⟩ := hcell
  have hw' : St.cell? { s with stack := fs } tc = some w := hw
  rw [hw']
  cases w with
  | some w =>
    simp only [Option.map_some]
    exact refErr_sim hr hr.intr hn0 hP _
  | none =>
    simp only [Option.map_some, Option.map_none]
    have hfr : K.fr tc = none := hr.fr_cell (cell?_iff.1 hw')
    have a1 := adv_setCell hr hn0 htc hfr hv
    cases v with
    | obj o =>
      cases hob : (St.setCell { s with stack := fs } tc (.obj o)).obj? cls with
      | none => exact MSim.fail _ _
      | some ob =>
        obtain ⟨kd, pr, ps, pv, ex⟩ := ob
        cases kd with
        | fn c =>
          cases c with
          | klass ctor cenv par inst =>
            have hto := a1.rel.fnObj hob rfl
            obtain ⟨hce, -, hinst⟩ := a1.rel.fnCode_supp hob rfl
            have hto' : (St.setCell { t with stack := fs.map M.frame } (M.a tc) (.obj (M.a o))).obj? (M.a cls) =
                some ⟨.fn (.klass ctor (M.env cenv) (M.val par) (inst.map M.inst)), M.val pr, M.props ps,
                  pv.map (fun ((b, n), p) => ((M.a b, n), M.prop p)), ex⟩ := hto
            simp only [Map.val, hto']
            have ho : Present (St.setCell { s with stack := fs } tc (.obj o)) o := a1.val hv
            obtain ⟨ea, -, hpa, a2⟩ := adv_alloc a1.rel (a1.lt (margin_split hn (0 + 0) (Nat.zero_le _)))
              (.cell (some (.obj o))) ho
            have ea' : (thisEnv F (St.setCell { t with stack := fs.map M.frame } (M.a tc) (.obj (M.a o)))
                (.obj (M.a o)) (M.env cenv)).1 =
                M.env (thisEnv F (St.setCell { s with stack := fs } tc (.obj o)) (.obj o) cenv).1 :=
              congrArg (fun x => (nThis, x) :: M.env cenv) ea
            rw [ea']
            have hfe : Supp.env (Present (thisEnv F (St.setCell { s with stack := fs } tc (.obj o)) (.obj o) cenv).2)
                S.tab.length (thisEnv F (St.setCell { s with stack := fs } tc (.obj o)) (.obj o) cenv).1 := by
              intro x hx
              rcases List.mem_cons.1 hx with rfl | hx
              · exact hpa
              · exact a2.pres _ (hce x hx)
            have ho2 := a2.pres _ ho
            exact sim_pure ((((a2.rel.push (.e (.const (.obj o))) ho2).push
              (.k (.paramProps (.obj o) ((ctor.map fnProps).getD []) env)) ⟨ho2, a2.env (a1.env he)⟩).push
              (.k (.fields o inst _)) ⟨ho2, Supp.insts_mono a2.pres (Nat.le_refl _) hinst, hfe⟩).ret .undef trivial)
          | _ => exact MSim.fail _ _
        | _ => exact MSim.fail _ _
    | _ => first | exact MSim.fail _ _ | (simp only []; exact MSim.fail _ _)

/-- Parameter properties of a constructor (`constructor(public x)`): `this.x = x`, one by one. -/
theorem step_ret_paramProps {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR) {v o : Val}
    {ns : List Name} {env : Env} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.paramProps o ns env) :: fs)
    (hP : Present s aTypeErrorProto) (hPR : Present s aRangeErrorProto)
    (hok : ∀ n r, ns = n :: r → ∀ x, cellVal? F s n env = some x → PutOK F K s S o (.str n) x)
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, -, ho, he⟩ := h.kRet hc hs
  rw [e1, e2]
  have hn0 := margin_split hn 0 (Nat.zero_le _)
  cases ns with
  | nil => exact sim_pure (hr.ret .undef trivial)
  | cons n r =>
    simp only [retK, Map.fnF]
    rw [hr.cellVal?_map he]
    cases hx : cellVal? F { s with stack := fs } n env with
    | none => exact MSim.fail _ _
    | some x =>
      simp only [Option.map_some]
      have hp := hr.push (.k (.paramProps o r env)) ⟨ho, he⟩
      exact putV_sim hp hF hFR hp.intr hn0 hP hPR (k := .str n) trivial (hr.cellVal?_supp hx)
        (hok n r rfl x hx)

end

/-! ## Class definitions: members -/

theorem prop_accessorProp (M : Map) (old : Option PropV) (kind : MethodKind) (f : Val) (enum : Bool) :
    M.prop (accessorProp old kind f enum) = accessorProp (old.map M.prop) kind (M.val f) enum := by
  rcases old with _ | ⟨v, w, e⟩ | ⟨g, st, e⟩ <;> cases kind <;> rfl

theorem accessorProp_supp {A : Nat → Prop} {n : Nat} {old : Option PropV} (kind : MethodKind) {f : Val}
    (enum : Bool) (ho : Supp.oprop A n old) (hf : Supp.val A n f) : Supp.prop A n (accessorProp old kind f enum) := by
  rcases old with _ | ⟨v, w, e⟩ | ⟨g, st, e⟩ <;> cases kind
  all_goals first
    | exact hf
    | exact ⟨trivial, trivial⟩
    | exact ⟨hf, trivial⟩
    | exact ⟨trivial, hf⟩
    | exact ⟨hf, ho.2⟩
    | exact ⟨ho.1, hf⟩

/-- The property a private method installs. -/
def pmProp (kind : MethodKind) (old : Option PropV) (c : Val) : PropV :=
  match kind with
  | .method => .data c false false
  | k => accessorProp old k c false

theorem pmProp_map (M : Map) (kind : MethodKind) (old : Option PropV) (c : Val) :
    M.prop (pmProp kind old c) = pmProp kind (old.map M.prop) (M.val c) := by
  cases kind
  · rfl
  · exact prop_accessorProp M old .get c false
  · exact prop_accessorProp M old .set c false

theorem pmProp_supp {A : Nat → Prop} {n : Nat} (kind : MethodKind) {old : Option PropV} {c : Val}
    (ho : Supp.oprop A n old) (hc : Supp.val A n c) : Supp.prop A n (pmProp kind old c) := by
  cases kind
  · exact hc
  · exact accessorProp_supp .get false ho hc
  · exact accessorProp_supp .set false ho hc

theorem privMethodProp_eq (F : Ffi) (s : St F.S) (fn : Func) (env : Env) (home : Nat) (kind : MethodKind)
    (old : Option PropV) :
    privMethodProp F s fn env home kind old =
      (pmProp kind old (.obj (closureObj s fn env false (.obj home)).1), (closureObj s fn env false (.obj home)).2) := by
  cases kind <;> rfl

theorem methodProp_eq' (F : Ffi) (s : St F.S) (tg : Nat) (k : PKey) (kind : MethodKind) (fn : Func) (env : Env)
    (enum : Bool) :
    methodProp F s tg k kind fn env enum =
      match (closureObj s fn env false (.obj tg)).2.obj? tg with
      | some o => (closureObj s fn env false (.obj tg)).2.setObj tg { o with props := (setPropL k
          (accessorProp (findProp k o.props) kind (.obj (closureObj s fn env false (.obj tg)).1) enum) o.props) }
      | none => (closureObj s fn env false (.obj tg)).2 := rfl

section
variable {A : Nat → Prop} {n : Nat} {M : Map}

theorem findInstPriv_map (hinj : ∀ a b, A a → A b → M.a a = M.a b → a = b) {b : Nat} (nm : Name) (hb : A b) :
    ∀ {is : List InstMember}, Supp.insts A n is →
    findInstPriv (M.a b) nm (is.map M.inst) = (findInstPriv b nm is).map M.prop
  | [], _ => rfl
  | i :: is, hi => by
    have ih := findInstPriv_map hinj nm hb (is := is) fun x hx => hi x (List.mem_cons_of_mem _ hx)
    cases i with
    | privMethod c m p =>
      have hc : A c := (hi _ (List.mem_cons_self ..)).1
      show (bif Nat.beq (M.a b) (M.a c) && nameEq nm m then some (M.prop p) else
          findInstPriv (M.a b) nm (is.map M.inst)) =
        (bif Nat.beq b c && nameEq nm m then some p else findInstPriv b nm is).map M.prop
      rw [beq_map hinj hb hc]
      cases Nat.beq b c && nameEq nm m
      · exact ih
      · rfl
    | field k init => exact ih
    | privField c m init => exact ih

theorem findInstPriv_supp {b : Nat} {nm : Name} : ∀ {is : List InstMember} {p : PropV},
    Supp.insts A n is → findInstPriv b nm is = some p → Supp.prop A n p
  | [], _, _, h => nomatch h
  | i :: is, p, hi, h => by
    have hs : Supp.insts A n is := fun x hx => hi x (List.mem_cons_of_mem _ hx)
    cases i with
    | privMethod c m q =>
      change (bif Nat.beq b c && nameEq nm m then some q else findInstPriv b nm is) = some p at h
      cases hb : (Nat.beq b c && nameEq nm m)
      · rw [hb] at h; exact findInstPriv_supp hs h
      · rw [hb] at h; cases h; exact (hi _ (List.mem_cons_self ..)).2
    | field k init => exact findInstPriv_supp hs h
    | privField c m init => exact findInstPriv_supp hs h

theorem dropInstPriv_map (hinj : ∀ a b, A a → A b → M.a a = M.a b → a = b) {b : Nat} (nm : Name) (hb : A b) :
    ∀ {is : List InstMember}, Supp.insts A n is →
    (dropInstPriv b nm is).map M.inst = dropInstPriv (M.a b) nm (is.map M.inst)
  | [], _ => rfl
  | i :: is, hi => by
    have ih := dropInstPriv_map hinj nm hb (is := is) fun x hx => hi x (List.mem_cons_of_mem _ hx)
    cases i with
    | privMethod c m p =>
      have hc : A c := (hi _ (List.mem_cons_self ..)).1
      show (bif Nat.beq b c && nameEq nm m then dropInstPriv b nm is else
          .privMethod c m p :: dropInstPriv b nm is).map M.inst =
        (bif Nat.beq (M.a b) (M.a c) && nameEq nm m then dropInstPriv (M.a b) nm (is.map M.inst) else
          .privMethod (M.a c) m (M.prop p) :: dropInstPriv (M.a b) nm (is.map M.inst))
      rw [beq_map hinj hb hc]
      cases Nat.beq b c && nameEq nm m
      · show M.inst (.privMethod c m p) :: (dropInstPriv b nm is).map M.inst = _
        rw [ih]; rfl
      · exact ih
    | field k init =>
      show M.inst (.field k init) :: (dropInstPriv b nm is).map M.inst = _
      rw [ih]; rfl
    | privField c m init =>
      show M.inst (.privField c m init) :: (dropInstPriv b nm is).map M.inst = _
      rw [ih]; rfl

theorem dropInstPriv_supp {b : Nat} {nm : Name} : ∀ {is : List InstMember},
    Supp.insts A n is → Supp.insts A n (dropInstPriv b nm is)
  | [], _ => fun _ hx => nomatch hx
  | i :: is, hi => by
    have hs : Supp.insts A n is := fun x hx => hi x (List.mem_cons_of_mem _ hx)
    have ih := dropInstPriv_supp (b := b) (nm := nm) hs
    cases i with
    | privMethod c m p =>
      change Supp.insts A n (bif Nat.beq b c && nameEq nm m then dropInstPriv b nm is else
        .privMethod c m p :: dropInstPriv b nm is)
      cases Nat.beq b c && nameEq nm m
      · intro x hx
        rcases List.mem_cons.1 hx with rfl | hx
        · exact hi _ (List.mem_cons_self ..)
        · exact ih x hx
      · exact ih
    | field k init =>
      intro x hx
      rcases List.mem_cons.1 hx with rfl | hx
      · exact hi _ (List.mem_cons_self ..)
      · exact ih x hx
    | privField c m init =>
      intro x hx
      rcases List.mem_cons.1 hx with rfl | hx
      · exact hi _ (List.mem_cons_self ..)
      · exact ih x hx

end

theorem keyOf_str' {k : Key} {key : PKey} (hk : keyOf k = some key) : ∃ a, key = .str a := by
  cases k with
  | id nm => cases hk; exact ⟨_, rfl⟩
  | str raw =>
    simp only [keyOf] at hk
    cases hc : cook raw with
    | none => rw [hc] at hk; cases hk
    | some a => rw [hc] at hk; cases hk; exact ⟨_, rfl⟩
  | num raw =>
    simp only [keyOf] at hk
    cases hf : F64.ofLit raw with
    | none => rw [hf] at hk; cases hk
    | some x =>
      rw [hf] at hk
      simp only [Option.bind_some] at hk
      cases hs : F64.toStr x with
      | none => rw [hs] at hk; cases hk
      | some a => rw [hs] at hk; cases hk; exact ⟨_, rfl⟩
  | priv nm => cases hk
  | computed e => cases hk

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {S : SSrv} {C : CSrv}

theorem Rel.obj?_unframed {s t : St F.S} (h : Rel F FR M ν K s S t C) {a : Nat} (ha : Present s a)
    (hfr : K.fr a = none) : t.obj? (M.a a) = (s.obj? a).map M.obj := by
  obtain ⟨o, hg⟩ := ha.get
  have ht := h.get hg hfr
  cases o with
  | cell v =>
    have e1 : s.obj? a = none := by unfold St.obj?; rw [hg]
    rw [e1]
    unfold St.obj?
    rw [ht]
    rfl
  | obj o =>
    rw [obj?_iff.2 hg, obj?_iff.2 ht]
    rfl

/-- A closure for a method, installed as a property of `tg` (accessors keep their other half). -/
theorem adv_methodProp {s t : St F.S} (h : Rel F FR M ν K s S t C) (hn : s.next + 1 < Sim.bound) {tg : Nat}
    {k : PKey} (kind : MethodKind) (fn : Func) {env : Env} (enum : Bool) (htg : Present s tg)
    (hfr : K.fr tg = none) (hk : Supp.key (Present s) S.tab.length k) (he : Supp.env (Present s) S.tab.length env)
    (hP : Present s aFunctionProto) :
    Adv F FR M ν K S C s (methodProp F s tg k kind fn env enum)
      (methodProp F t (M.a tg) (M.key k) kind fn (M.env env) enum) 1 := by
  rw [methodProp_eq', methodProp_eq']
  have hn0 : s.next < Sim.bound := by omega
  have hn1 : (closureObj s fn env false (.obj tg)).2.next < Sim.bound := hn
  obtain ⟨e1, -, hp1, a1⟩ := adv_allocObj h hn0 (.fn (.closure fn env false (.obj tg))) aFunctionProto []
    (h.intr _ (by decide)) hP ⟨he, htg⟩ (fun _ hx => nomatch hx)
  have e1' : (closureObj t fn (M.env env) false (.obj (M.a tg))).1 = M.a s.next := e1
  have hob := a1.rel.obj?_unframed (a1.pres _ htg) hfr
  have hob' : (closureObj t fn (M.env env) false (.obj (M.a tg))).2.obj? (M.a tg) =
      ((closureObj s fn env false (.obj tg)).2.obj? tg).map M.obj := hob
  rw [hob', e1']
  cases hso : (closureObj s fn env false (.obj tg)).2.obj? tg with
  | none => exact a1
  | some o =>
    have hs := a1.rel.obj?_supp hso
    have hk1 := Supp.key_mono a1.pres (Nat.le_refl _) hk
    have hr := a1.rel.setObj { o with props := (setPropL k
        (accessorProp (findProp k o.props) kind (.obj (closureObj s fn env false (.obj tg)).1) enum) o.props) }
      hn1 (a1.pres _ htg) hfr
      ⟨hs.1, hs.2.1, setPropL_supp hk1 (accessorProp_supp kind enum (f := .obj (closureObj s fn env false (.obj tg)).1)
        (by cases hf : findProp k o.props with
            | none => trivial
            | some q => exact findProp_supp hs.2.2.1 hf) hp1) hs.2.2.1, hs.2.2.2⟩
    rw [Map.obj_props, setPropL_map a1.rel.inj _ hk1 hs.2.2.1, prop_accessorProp,
      ← findProp_map a1.rel.inj hk1 hs.2.2.1] at hr
    exact ⟨hr, fun b hb => a1.rel.present_set hn1
      (a1.pres _ htg) _ b (a1.pres b hb), a1.next, a1.mono⟩

/-- The class's instance members recorded on its constructor. -/
theorem adv_setKlassInst {s t : St F.S} (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) {f : Nat}
    {inst : List InstMember} (hf : Present s f) (hfr : K.fr f = none) (hinst : Supp.insts (Present s) S.tab.length inst) :
    Adv F FR M ν K S C s (setKlassInst F s f inst) (setKlassInst F t (M.a f) (inst.map M.inst)) 0 := by
  unfold setKlassInst
  rw [h.obj?_unframed hf hfr]
  cases hso : s.obj? f with
  | none => exact Adv.refl h
  | some o =>
    have hs := h.obj?_supp hso
    obtain ⟨kd, pr, ps, pv, ex⟩ := o
    cases kd with
    | fn c =>
      cases c with
      | klass c0 e p is =>
        have hk : Supp.code (Present s) S.tab.length (.klass c0 e p is) := hs.1
        have hr := h.setObj { kind := .fn (.klass c0 e p inst), proto := pr, props := ps, priv := pv, extensible := ex }
          hn hf hfr ⟨⟨hk.1, hk.2.1, hinst⟩, hs.2.1, hs.2.2.1, hs.2.2.2⟩
        exact ⟨hr, h.present_set hn hf _, Nat.le_refl _, Nat.le_refl _⟩
      | _ => exact Adv.refl h
    | _ => exact Adv.refl h

/-- `this` for a field initializer: a cell holding the class. -/
theorem thisEnv_adv {s t : St F.S} (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) {v : Val} {env : Env}
    (hv : Supp.val (Present s) S.tab.length v) (he : Supp.env (Present s) S.tab.length env) :
    (thisEnv F t (M.val v) (M.env env)).1 = M.env (thisEnv F s v env).1 ∧
    Adv F FR M ν K S C s (thisEnv F s v env).2 (thisEnv F t (M.val v) (M.env env)).2 1 ∧
    Supp.env (Present (thisEnv F s v env).2) S.tab.length (thisEnv F s v env).1 := by
  obtain ⟨e1, -, hp1, a1⟩ := adv_alloc h hn (.cell (some v)) hv
  refine ⟨congrArg (fun x => (nThis, x) :: M.env env) e1, a1, ?_⟩
  intro x hx
  rcases List.mem_cons.1 hx with rfl | hx
  · exact hp1
  · exact a1.pres _ (he x hx)

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {S : SSrv} {C : CSrv}

theorem Supp.insts_reverse {A : Nat → Prop} {n : Nat} {is : List InstMember} (h : Supp.insts A n is) :
    Supp.insts A n is.reverse := fun x hx => h x (List.mem_reverse.1 hx)

theorem Map.insts_reverse (M : Map) (is : List InstMember) : (is.map M.inst).reverse = is.reverse.map M.inst :=
  (List.map_reverse ..).symm

/-- The members of a class body, processed in one step up to the next computed key or
static initializer. The class `f` and its prototype `p` must be unframed. -/
theorem classNext_sim {f p : Nat} {env : Env} (hffr : K.fr f = none) (hpfr : K.fr p = none) :
    ∀ (ms : List Member) (s t : St F.S) (inst : List InstMember),
    Rel F FR M ν K s S t C → s.next + (ms.length + 1) < Sim.bound → Present s f → Present s p →
    Present s aFunctionProto → Supp.insts (Present s) S.tab.length inst → Supp.env (Present s) S.tab.length env →
    MSim (StepPost F FR M ν K S C) S C (classNext F s f p ms inst env)
      (classNext F t (M.a f) (M.a p) ms (inst.map M.inst) (M.env env))
  | [], s, t, inst, h, hn, hf, _, _, hinst, _ => by
    simp only [classNext]
    have a1 := adv_setKlassInst h (by omega) hf hffr (Supp.insts_reverse hinst)
    rw [Map.insts_reverse]
    exact sim_pure (a1.rel.ret (.obj f) (a1.pres _ hf))
  | m :: ms, s, t, inst, h, hn, hf, hp, hP, hinst, he => by
    have hlen : s.next + 1 + (ms.length + 1) < Sim.bound := by simp only [List.length_cons] at hn; omega
    have hn0 : s.next < Sim.bound := by omega
    have ih0 := fun inst' (hi : Supp.insts (Present s) S.tab.length inst') =>
      classNext_sim (env := env) hffr hpfr ms s t inst' h (by omega) hf hp hP hi he
    cases m with
    | ctor fn =>
      simp only [classNext]
      exact ih0 inst hinst
    | block ss =>
      simp only [classNext]
      exact MSim.fail _ _
    | method static kind k fn =>
      cases k with
      | priv nm =>
        simp only [classNext]
        rw [lookupEnv_map]
        cases hl : lookupEnv (privName nm) env with
        | none => exact MSim.fail _ _
        | some b =>
          have hb : Present s b := fn_lookupEnv_supp he hl
          simp only [Option.map_some]
          cases static with
          | true =>
            simp only [Bool.cond_true]
            rw [h.obj?_unframed hf hffr]
            cases hso : s.obj? f with
            | none => exact MSim.fail _ _
            | some o =>
              have hs := h.obj?_supp hso
              simp only [Option.map_some]
              rw [privMethodProp_eq, privMethodProp_eq, show (M.obj o).priv = M.privs o.priv from rfl,
                findPriv_map h.inj nm hb hs.2.2.2]
              obtain ⟨e1, -, hp1, a1⟩ := adv_allocObj h hn0 (.fn (.closure fn env false (.obj f))) aFunctionProto []
                (h.intr _ (by decide)) hP ⟨he, hf⟩ (fun _ hx => nomatch hx)
              have e1' : (closureObj t fn (M.env env) false (.obj (M.a f))).1 = M.a s.next := e1
              rw [e1']
              have hob := a1.rel.obj?_unframed (a1.pres _ hf) hffr
              have hob' : (closureObj t fn (M.env env) false (.obj (M.a f))).2.obj? (M.a f) =
                  ((closureObj s fn env false (.obj f)).2.obj? f).map M.obj := hob
              rw [hob']
              cases hso1 : (closureObj s fn env false (.obj f)).2.obj? f with
              | none => exact MSim.fail _ _
              | some o1 =>
                simp only [Option.map_some]
                have hpr : Supp.prop (Present (closureObj s fn env false (.obj f)).2) S.tab.length
                    (pmProp kind (findPriv b nm o.priv) (.obj s.next)) :=
                  pmProp_supp kind (by
                    cases hfp : findPriv b nm o.priv with
                    | none => trivial
                    | some q => exact Supp.prop_mono a1.pres (Nat.le_refl _) (findPriv_supp hs.2.2.2 hfp)) hp1
                have hn1 : (closureObj s fn env false (.obj f)).2.next < Sim.bound :=
                  a1.lt (show s.next + (1 + 0) < Sim.bound by omega)
                have a2 := adv_setPriv a1.rel hn1 hso1 hffr nm (a1.pres _ hb) hpr
                have hpm : pmProp kind ((findPriv b nm o.priv).map M.prop) (.obj (M.a s.next)) =
                    M.prop (pmProp kind (findPriv b nm o.priv) (.obj s.next)) := (pmProp_map M kind _ (.obj s.next)).symm
                rw [hpm]
                have a12 := a1.trans a2
                exact classNext_sim hffr hpfr ms _ _ inst a2.rel (a12.lt (by omega)) (a12.pres _ hf)
                  (a12.pres _ hp) (a12.pres _ hP) (Supp.insts_mono a12.pres (Nat.le_refl _) hinst) (a12.env he)
          | false =>
            simp only [Bool.cond_false]
            rw [privMethodProp_eq, privMethodProp_eq, findInstPriv_map h.inj nm hb hinst]
            obtain ⟨e1, -, hp1, a1⟩ := adv_allocObj h hn0 (.fn (.closure fn env false (.obj p))) aFunctionProto []
              (h.intr _ (by decide)) hP ⟨he, hp⟩ (fun _ hx => nomatch hx)
            have e1' : (closureObj t fn (M.env env) false (.obj (M.a p))).1 = M.a s.next := e1
            rw [e1']
            have hpm : pmProp kind ((findInstPriv b nm inst).map M.prop) (.obj (M.a s.next)) =
                M.prop (pmProp kind (findInstPriv b nm inst) (.obj s.next)) := (pmProp_map M kind _ (.obj s.next)).symm
            rw [hpm, ← dropInstPriv_map h.inj nm hb hinst]
            have hpr : Supp.prop (Present (closureObj s fn env false (.obj p)).2) S.tab.length
                (pmProp kind (findInstPriv b nm inst) (.obj s.next)) :=
              pmProp_supp kind (by
                cases hfp : findInstPriv b nm inst with
                | none => trivial
                | some q => exact Supp.prop_mono a1.pres (Nat.le_refl _) (findInstPriv_supp hinst hfp)) hp1
            exact classNext_sim hffr hpfr ms _ _ (.privMethod b nm (pmProp kind (findInstPriv b nm inst) (.obj s.next)) ::
                dropInstPriv b nm inst) a1.rel (a1.lt (by omega)) (a1.pres _ hf) (a1.pres _ hp) (a1.pres _ hP)
              (fun x hx => by
                rcases List.mem_cons.1 hx with rfl | hx
                · exact ⟨a1.pres _ hb, hpr⟩
                · exact Supp.inst_mono a1.pres (Nat.le_refl _) (dropInstPriv_supp hinst x hx))
              (a1.env he)
      | computed e =>
        simp only [classNext]
        exact sim_pure ((h.push (.k (.classKey f p (.method static kind (.computed e) fn) ms inst env))
          ⟨hf, hp, hinst, he⟩).go (.ev e env) he)
      | _ =>
        simp only [classNext]
        rename_i raw
        first
          | (cases hk : keyOf (.id raw) with
              | none => exact MSim.fail _ _
              | some key => ?_)
          | (cases hk : keyOf (.str raw) with
              | none => exact MSim.fail _ _
              | some key => ?_)
          | (cases hk : keyOf (.num raw) with
              | none => exact MSim.fail _ _
              | some key => ?_)
        all_goals
          obtain ⟨a, rfl⟩ := keyOf_str' hk
          dsimp only
          cases static with
          | true =>
            have am := adv_methodProp h (by omega) (k := .str a) kind fn false hf hffr trivial he hP
            exact classNext_sim hffr hpfr ms _ _ inst am.rel (am.lt (by omega)) (am.pres _ hf) (am.pres _ hp)
              (am.pres _ hP) (Supp.insts_mono am.pres (Nat.le_refl _) hinst) (am.env he)
          | false =>
            have am := adv_methodProp h (by omega) (k := .str a) kind fn false hp hpfr trivial he hP
            exact classNext_sim hffr hpfr ms _ _ inst am.rel (am.lt (by omega)) (am.pres _ hf) (am.pres _ hp)
              (am.pres _ hP) (Supp.insts_mono am.pres (Nat.le_refl _) hinst) (am.env he)
    | field static k init =>
      cases k with
      | priv nm =>
        simp only [classNext]
        rw [lookupEnv_map]
        cases hl : lookupEnv (privName nm) env with
        | none => exact MSim.fail _ _
        | some b =>
          have hb : Present s b := fn_lookupEnv_supp he hl
          simp only [Option.map_some]
          cases static with
          | true =>
            simp only [Bool.cond_true]
            cases init with
            | some e =>
              obtain ⟨e1, a1, he1⟩ := thisEnv_adv h hn0 (v := .obj f) hf he
              rw [show thisEnv F t (.obj (M.a f)) (M.env env) =
                (M.env (thisEnv F s (.obj f) env).1, (thisEnv F t (.obj (M.a f)) (M.env env)).2) from Prod.ext e1 rfl]
              exact sim_pure (((a1.rel.push (.k (.privVal f b nm [] _))
                ⟨a1.pres _ hf, a1.pres _ hb, (fun _ hx => nomatch hx), he1⟩).push (.k (.classMembers f p ms inst env))
                ⟨a1.pres _ hf, a1.pres _ hp, Supp.insts_mono a1.pres (Nat.le_refl _) hinst, a1.env he⟩).go
                (.ev e _) he1)
            | none =>
              rw [h.obj?_unframed hf hffr]
              cases hso : s.obj? f with
              | none => exact MSim.fail _ _
              | some o =>
                simp only [Option.map_some]
                have a1 := adv_setPriv h hn0 hso hffr nm (p := .data .undef true false) hb trivial
                exact classNext_sim hffr hpfr ms _ _ inst a1.rel (a1.lt (by omega)) (a1.pres _ hf) (a1.pres _ hp)
                  (a1.pres _ hP) (Supp.insts_mono a1.pres (Nat.le_refl _) hinst) (a1.env he)
          | false =>
            simp only [Bool.cond_false]
            exact ih0 (.privField b nm init :: inst) (fun x hx => by
              rcases List.mem_cons.1 hx with rfl | hx
              · exact hb
              · exact hinst x hx)
      | computed e =>
        simp only [classNext]
        exact sim_pure ((h.push (.k (.classKey f p (.field static (.computed e) init) ms inst env))
          ⟨hf, hp, hinst, he⟩).go (.ev e env) he)
      | _ =>
        simp only [classNext]
        rename_i raw
        first
          | (cases hk : keyOf (.id raw) with
              | none => exact MSim.fail _ _
              | some key => ?_)
          | (cases hk : keyOf (.str raw) with
              | none => exact MSim.fail _ _
              | some key => ?_)
          | (cases hk : keyOf (.num raw) with
              | none => exact MSim.fail _ _
              | some key => ?_)
        all_goals
          obtain ⟨a, rfl⟩ := keyOf_str' hk
          dsimp only
          cases static with
          | true =>
            simp only [Bool.cond_true]
            cases init with
            | some e =>
              obtain ⟨e1, a1, he1⟩ := thisEnv_adv h hn0 (v := .obj f) hf he
              rw [show thisEnv F t (.obj (M.a f)) (M.env env) =
                (M.env (thisEnv F s (.obj f) env).1, (thisEnv F t (.obj (M.a f)) (M.env env)).2) from Prod.ext e1 rfl]
              exact sim_pure ((a1.rel.push (.k (.classStatic f p (.str a) ms inst env))
                ⟨a1.pres _ hf, a1.pres _ hp, trivial, Supp.insts_mono a1.pres (Nat.le_refl _) hinst, a1.env he⟩).go
                (.ev e _) he1)
            | none =>
              have a1 := defineData_adv h hn0 (k := .str a) (v := .undef) hf hffr trivial trivial
              exact classNext_sim hffr hpfr ms _ _ inst a1.rel (a1.lt (by omega)) (a1.pres _ hf) (a1.pres _ hp)
                (a1.pres _ hP) (Supp.insts_mono a1.pres (Nat.le_refl _) hinst) (a1.env he)
          | false =>
            simp only [Bool.cond_false]
            exact ih0 (.field (.str a) init :: inst) (fun x hx => by
              rcases List.mem_cons.1 hx with rfl | hx
              · trivial
              · exact hinst x hx)

end

/-! ## Class definitions: computed keys and static fields -/

section
variable {ν : Nat → F64}

/-- `numConc` asks the server nothing new: both sides get the same value. -/
theorem numConc_read {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (a : NumV) :
    MSim (ReadPost M S C (fun r r' => r' = r)) S C (numConc a) (numConc (M.nv a)) := by
  intro γ δ Q k k' hk
  cases a with
  | lit x => exact hk M S C _ _ ⟨rfl, rfl, rfl, rfl⟩
  | ref i =>
    intro r S' hu
    change interpS (.conc (.ref i) k) S = _ at hu
    rw [interpS_conc] at hu
    cases hva : S.val (.ref i) with
    | none => rw [hva] at hu; cases hu
    | some e =>
      rw [hva] at hu
      cases e with
      | lit x =>
        simp only at hu
        have ca := hs.num.val hva
        obtain ⟨M', b', C', hv, hq⟩ := hk M S C x x ⟨rfl, rfl, rfl, rfl⟩ r S' hu
        refine ⟨M', b', C', ?_, hq⟩
        cases hn : M.nv (.ref i) with
        | lit u =>
          rw [hn] at ca
          simp only [CSrv.val, SymE.eval, Option.some.injEq] at ca
          subst ca
          exact hv
        | ref j =>
          rw [hn] at ca
          show interpC (.conc (.ref j) k') C = _
          rw [interpC_conc, ca]
          exact hv
      | var _ => cases hu
      | bin _ _ _ => cases hu
      | un _ _ => cases hu

/-- `ToString` of a primitive: the same characters on both sides (bigints the map fixes). -/
theorem primStr_read {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (v : Val)
    (hb : ∀ i, v = .big i → M.big i = i) :
    MSim (ReadPost M S C (fun r r' => r' = r)) S C (primStr v) (primStr (M.val v)) := by
  cases v with
  | num x =>
    show MSim _ S C (Host.Ts.M.bind (numConc x) _) (Host.Ts.M.bind (numConc (M.nv x)) _)
    refine MSim.bind (numConc_read hs x) ?_
    rintro M' S' C' r r' ⟨-, hS, hC, hrr⟩
    rw [hS, hC, hrr]
    cases F64.toStr r with
    | none => exact MSim.fail _ _
    | some cs => exact ReadPost.pure rfl
  | big i =>
    show MSim _ S C (Host.Ts.M.pure (some (bigStr i))) (Host.Ts.M.pure (some (bigStr (M.big i))))
    rw [hb i rfl]
    exact ReadPost.pure rfl
  | _ => exact ReadPost.pure rfl

/-- `ToPropertyKey` of a value: symbols map by the map, strings stay. -/
theorem toKey_read {M : Map} {S : SSrv} {C : CSrv} {A : Nat → Prop} (hs : Srv M ν S C) (v : Val)
    (hv : Supp.val A S.tab.length v) (hb : ∀ i, v = .big i → M.big i = i) :
    MSim (ReadPost M S C (fun r r' => r' = r.map M.key ∧ Supp.okey A S.tab.length r)) S C
      (toKey v) (toKey (M.val v)) := by
  have rest : ∀ v : Val, (∀ i, v = .big i → M.big i = i) →
      MSim (ReadPost M S C (fun r r' => r' = r.map M.key ∧ Supp.okey A S.tab.length r)) S C
        (Host.Ts.M.bind (primStr v) fun o => Host.Ts.M.pure (o.map PKey.str))
        (Host.Ts.M.bind (primStr (M.val v)) fun o => Host.Ts.M.pure (o.map PKey.str)) := by
    intro v hb
    refine MSim.bind (primStr_read hs v hb) ?_
    rintro M' S' C' r r' ⟨-, hS, hC, hrr⟩
    rw [hS, hC, hrr]
    cases r with
    | none => exact ReadPost.pure ⟨rfl, trivial⟩
    | some cs => exact ReadPost.pure ⟨rfl, trivial⟩
  cases v with
  | sym i => exact ReadPost.pure ⟨rfl, hv⟩
  | _ => exact rest _ hb

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- A class member with an evaluated computed key. -/
theorem classKeyed_sim (h : Rel F FR M ν K s S t C) {f p : Nat} {m : Member} {key : PKey}
    {ms : List Member} {inst : List InstMember} {env : Env} (hffr : K.fr f = none) (hpfr : K.fr p = none)
    (hn : s.next + (ms.length + 2) < Sim.bound) (hf : Present s f) (hp : Present s p)
    (hP : Present s aFunctionProto) (hk : Supp.key (Present s) S.tab.length key)
    (hinst : Supp.insts (Present s) S.tab.length inst) (he : Supp.env (Present s) S.tab.length env) :
    MSim (StepPost F FR M ν K S C) S C (classKeyed F s f p m key ms inst env)
      (classKeyed F t (M.a f) (M.a p) m (M.key key) ms (inst.map M.inst) (M.env env)) := by
  have hn0 : s.next < Sim.bound := by omega
  cases m with
  | method static kind k0 fn =>
    simp only [classKeyed]
    cases static with
    | true =>
      have am := adv_methodProp h (by omega) kind fn false hf hffr hk he hP
      exact classNext_sim hffr hpfr ms _ _ inst am.rel (am.lt (by omega)) (am.pres _ hf) (am.pres _ hp)
        (am.pres _ hP) (Supp.insts_mono am.pres (Nat.le_refl _) hinst) (am.env he)
    | false =>
      have am := adv_methodProp h (by omega) kind fn false hp hpfr hk he hP
      exact classNext_sim hffr hpfr ms _ _ inst am.rel (am.lt (by omega)) (am.pres _ hf) (am.pres _ hp)
        (am.pres _ hP) (Supp.insts_mono am.pres (Nat.le_refl _) hinst) (am.env he)
  | field static k0 init =>
    cases static with
    | true =>
      cases init with
      | some e =>
        simp only [classKeyed]
        obtain ⟨e1, a1, he1⟩ := thisEnv_adv h hn0 (v := .obj f) hf he
        rw [show thisEnv F t (.obj (M.a f)) (M.env env) =
          (M.env (thisEnv F s (.obj f) env).1, (thisEnv F t (.obj (M.a f)) (M.env env)).2) from Prod.ext e1 rfl]
        exact sim_pure ((a1.rel.push (.k (.classStatic f p key ms inst env))
          ⟨a1.pres _ hf, a1.pres _ hp, Supp.key_mono a1.pres (Nat.le_refl _) hk,
            Supp.insts_mono a1.pres (Nat.le_refl _) hinst, a1.env he⟩).go (.ev e _) he1)
      | none =>
        simp only [classKeyed]
        have a1 := defineData_adv h hn0 (v := .undef) hf hffr hk trivial
        exact classNext_sim hffr hpfr ms _ _ inst a1.rel (a1.lt (by omega)) (a1.pres _ hf) (a1.pres _ hp)
          (a1.pres _ hP) (Supp.insts_mono a1.pres (Nat.le_refl _) hinst) (a1.env he)
    | false =>
      simp only [classKeyed]
      exact classNext_sim hffr hpfr ms s t (.field key init :: inst) h (by omega) hf hp hP
        (fun x hx => by
          rcases List.mem_cons.1 hx with rfl | hx
          · exact hk
          · exact hinst x hx) he
  | ctor fn => exact MSim.fail _ _
  | block ss => exact MSim.fail _ _

/-- Class members after the heritage: methods, accessors and fields, up to the next
computed key or static initializer. -/
theorem step_ret_classMembers (h : Rel F FR M ν K s S t C) {v : Val} {f p : Nat} {ms : List Member}
    {inst : List InstMember} {env : Env} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.classMembers f p ms inst env) :: fs)
    (hffr : K.fr f = none) (hpfr : K.fr p = none) (hP : Present s aFunctionProto)
    (hlen : ms.length ≤ 2 ^ 20) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, -, hf, hp, hinst, he⟩ := h.kRet hc hs
  rw [e1, e2]
  exact classNext_sim hffr hpfr ms _ _ inst hr (margin_split hn _ (by have : margin = 2 ^ 30 := rfl; omega))
    hf hp hP hinst he

/-- A static field's value is defined on the class; then the next members. -/
theorem step_ret_classStatic (h : Rel F FR M ν K s S t C) {v : Val} {f p : Nat} {k : PKey} {ms : List Member}
    {inst : List InstMember} {env : Env} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.classStatic f p k ms inst env) :: fs)
    (hffr : K.fr f = none) (hpfr : K.fr p = none) (hP : Present s aFunctionProto)
    (hlen : ms.length ≤ 2 ^ 20) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf, hp, hk, hinst, he⟩ := h.kRet hc hs
  rw [e1, e2]
  have a1 := defineData_adv hr (margin_split hn 0 (Nat.zero_le _)) hf hffr hk hv
  exact classNext_sim hffr hpfr ms _ _ inst a1.rel
    (a1.lt (margin_split hn _ (by have : margin = 2 ^ 30 := rfl; omega))) (a1.pres _ hf) (a1.pres _ hp)
    (a1.pres _ hP) (Supp.insts_mono a1.pres (Nat.le_refl _) hinst) (a1.env he)

/-- A computed class member key evaluated: convert it, then the member. A bigint key must
be one the map fixes. -/
theorem step_ret_classKey (h : Rel F FR M ν K s S t C) {v : Val} {f p : Nat} {m : Member} {ms : List Member}
    {inst : List InstMember} {env : Env} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.classKey f p m ms inst env) :: fs)
    (hffr : K.fr f = none) (hpfr : K.fr p = none) (hP : Present s aFunctionProto)
    (hbig : ∀ i, v = .big i → BigFixed K.lo K.hi i)
    (hlen : ms.length ≤ 2 ^ 20) (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf, hp, hinst, he⟩ := h.kRet hc hs
  rw [e1, e2]
  simp only [retK, Map.fnF]
  refine MSim.bind (toKey_read (A := Present s) hr.srv v hv (fun i hi => h.bigFixed i (hbig i hi))) ?_
  rintro M' S' C' r r' ⟨-, hS, hC, rfl, hk⟩
  rw [hS, hC]
  cases r with
  | none => exact MSim.fail _ _
  | some key =>
    exact classKeyed_sim hr hffr hpfr (margin_split hn _ (by have : margin = 2 ^ 30 := rfl; omega)) hf hp hP hk
      hinst he

end

/-! ## Class definitions: the class objects -/

/-- The class scope with the private-name brand. -/
def privEnv (members : List Member) (brand : Nat) (env : Env) : Env :=
  (memberPrivs members).foldl (fun e n => (privName n, brand) :: e) env

/-- The class-name binding of a named class. -/
def nameStep {S' : Type} (s : St S') (name : Option Name) (env : Env) : Env × St S' × Option Nat :=
  match name with
  | some n => ((n, (s.alloc (.cell none)).1) :: env, (s.alloc (.cell none)).2, some (s.alloc (.cell none)).1)
  | none => (env, s, none)

/-- The prototype parent and constructor parent of a class. -/
def classParents (F : Ffi) (s : St F.S) (parent : Option Val) : M (Option (Val × Val)) :=
  match parent with
  | none => .pure (some (.obj aObjectProto, .obj aFunctionProto))
  | some .null => .pure (some (.null, .obj aFunctionProto))
  | some (.obj pa) => .bind (dataOf F s (.obj pa) kPrototype) fun
    | some pp => .pure (some (pp, .obj pa))
    | none => .pure none
  | some _ => .pure none

/-- The parent constructor recorded on a class. -/
def parentVal : Option Val → Val
  | some p => p
  | none => .null

/-- The class objects once the parents are known. -/
def classTail (F : Ffi) (s : St F.S) (members : List Member) (env : Env) (parent : Option Val)
    (nameCell : Option Nat) (pp cp : Val) : RS F :=
  let ctor := classCtor members
  let parentV : Val := parentVal parent
  let inst0 : List InstMember := ((ctor.map fnProps).getD []).reverse.map fun n => .field (.str n) none
  let s1 := (s.allocObj .ordinary pp []).2
  let p := (s.allocObj .ordinary pp []).1
  let s2 := (s1.allocObj (.fn (.klass ctor env parentV [])) cp [(kPrototype, .data (.obj p) false false)]).2
  let f := (s1.allocObj (.fn (.klass ctor env parentV [])) cp [(kPrototype, .data (.obj p) false false)]).1
  let s3 := defineProp F s2 p kConstructor (.data (.obj f) true false)
  let s4 := match nameCell with | some c => s3.setCell c (.obj f) | none => s3
  .pure ((s4.push (.k (.classMembers f p members inst0 env))).ret .undef)

theorem defineClass_eq (F : Ffi) (s : St F.S) (name : Option Name) (sup : Option Expr) (members : List Member)
    (parent : Option Val) (env : Env) :
    defineClass F s (.mk name sup members) parent env =
      .bind (classParents F (nameStep (s.alloc (.cell none)).2 name (privEnv members s.next env)).2.1 parent) fun
        | some (pp, cp) => classTail F (nameStep (s.alloc (.cell none)).2 name (privEnv members s.next env)).2.1
            members (nameStep (s.alloc (.cell none)).2 name (privEnv members s.next env)).1 parent
            (nameStep (s.alloc (.cell none)).2 name (privEnv members s.next env)).2.2 pp cp
        | none => typeErr (nameStep (s.alloc (.cell none)).2 name (privEnv members s.next env)).2.1
            (chars!"class extends a non-constructor") := by
  cases name <;> rfl

theorem privEnv_map (M : Map) (members : List Member) (brand : Nat) (env : Env) :
    privEnv members (M.a brand) (M.env env) = M.env (privEnv members brand env) := by
  unfold privEnv
  generalize memberPrivs members = ns
  induction ns generalizing env with
  | nil => rfl
  | cons n ns ih => exact ih ((privName n, brand) :: env)

theorem privEnv_supp {A : Nat → Prop} {n : Nat} (members : List Member) {brand : Nat} {env : Env}
    (hb : A brand) (he : Supp.env A n env) : Supp.env A n (privEnv members brand env) := by
  unfold privEnv
  generalize memberPrivs members = ns
  induction ns generalizing env with
  | nil => exact he
  | cons m ns ih =>
    refine ih ?_
    intro x hx
    rcases List.mem_cons.1 hx with rfl | hx
    · exact hb
    · exact he x hx

theorem inst0_map (M : Map) (ns : List Name) :
    (ns.map fun n => InstMember.field (.str n) none).map M.inst = ns.map fun n => InstMember.field (.str n) none := by
  rw [List.map_map]
  rfl

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {S : SSrv} {C : CSrv}

theorem defineProp_adv {s t : St F.S} (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) {a : Nat}
    {k : PKey} {p : PropV} (ha : Present s a) (hfr : K.fr a = none) (hk : Supp.key (Present s) S.tab.length k)
    (hp : Supp.prop (Present s) S.tab.length p) :
    Adv F FR M ν K S C s (defineProp F s a k p) (defineProp F t (M.a a) (M.key k) (M.prop p)) 0 := by
  refine ⟨h.defineProp hn ha hfr hk hp, ?_, ?_, ?_⟩
  · unfold defineProp
    split
    · exact h.present_set hn ha _
    · exact fun _ hp => hp
  · unfold defineProp
    split <;> exact Nat.le_refl _
  · unfold defineProp
    split <;> exact Nat.le_refl _

/-- Addresses allocated after `s0` are not framed. -/
theorem fresh_unframed {s0 t0 : St F.S} (h0 : Rel F FR M ν K s0 S t0 C) {a : Nat} (ha : s0.next ≤ a) :
    K.fr a = none := by
  cases hf : K.fr a with
  | none => rfl
  | some p => exact absurd (h0.presentBound a (h0.framedPresent a p hf)) (by omega)

theorem classParents_read {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    {s t : St F.S} (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {parent : Option Val}
    (hpar : ∀ v, parent = some v → Supp.val (Present s) S.tab.length v)
    (hPO : Present s aObjectProto) (hPF : Present s aFunctionProto) :
    MSim (ReadPost M S C (fun r r' => r' = r.map (fun x => (M.val x.1, M.val x.2)) ∧
        ∀ x, r = some x → Supp.val (Present s) S.tab.length x.1 ∧ Supp.val (Present s) S.tab.length x.2)) S C
      (classParents F s parent) (classParents F t (parent.map M.val)) := by
  have hO : M.val (.obj aObjectProto) = .obj aObjectProto := by
    show Val.obj (M.a aObjectProto) = _; rw [h.intr _ (by decide)]
  have hFn : M.val (.obj aFunctionProto) = .obj aFunctionProto := by
    show Val.obj (M.a aFunctionProto) = _; rw [h.intr _ (by decide)]
  cases parent with
  | none =>
    exact ReadPost.pure ⟨by simp only [Option.map_some, hO, hFn], fun x hx => by cases hx; exact ⟨hPO, hPF⟩⟩
  | some v =>
    have hv := hpar v rfl
    cases v with
    | null =>
      exact ReadPost.pure ⟨by simp only [Option.map_some, hFn]; rfl, fun x hx => by cases hx; exact ⟨trivial, hPF⟩⟩
    | obj pa =>
      show MSim _ S C (Host.Ts.M.bind (dataOf F s (.obj pa) kPrototype) _)
        (Host.Ts.M.bind (dataOf F t (M.val (.obj pa)) (M.key kPrototype)) _)
      refine MSim.bind (dataOf_sim h hF h.intr hv trivial (LookupOK.of_plain (by rfl) (by rfl) _)) ?_
      rintro M' S' C' r r' ⟨-, hS, hC, hrr, hsupp⟩
      rw [hS, hC, hrr]
      cases r with
      | none => exact ReadPost.pure ⟨rfl, fun x hx => by cases hx⟩
      | some pp => exact ReadPost.pure ⟨rfl, fun x hx => by cases hx; exact ⟨hsupp pp rfl, hv⟩⟩
    | _ => exact ReadPost.pure ⟨rfl, fun x hx => by cases hx⟩

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {S : SSrv} {C : CSrv}

theorem nameStep_adv {s t : St F.S} (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) (name : Option Name)
    (env : Env) (he : Supp.env (Present s) S.tab.length env) :
    (nameStep t name (M.env env)).1 = M.env (nameStep s name env).1 ∧
    (nameStep t name (M.env env)).2.2 = (nameStep s name env).2.2.map M.a ∧
    Adv F FR M ν K S C s (nameStep s name env).2.1 (nameStep t name (M.env env)).2.1 1 ∧
    Supp.env (Present (nameStep s name env).2.1) S.tab.length (nameStep s name env).1 ∧
    (∀ c, (nameStep s name env).2.2 = some c → Present (nameStep s name env).2.1 c ∧ s.next ≤ c) := by
  cases name with
  | none => exact ⟨rfl, rfl, (Adv.refl h).weaken (Nat.zero_le _), he, fun c hc => by cases hc⟩
  | some n =>
    obtain ⟨e1, -, hp1, a1⟩ := adv_alloc h hn (.cell none) trivial
    have e1' : (t.alloc (.cell none)).1 = M.a (s.alloc (.cell none)).1 := e1
    refine ⟨?_, ?_, a1, ?_, fun c hc => ?_⟩
    · show (n, (t.alloc (.cell none)).1) :: M.env env = _
      rw [e1']; rfl
    · show some (t.alloc (.cell none)).1 = _
      rw [e1']; rfl
    · intro x hx
      rcases List.mem_cons.1 hx with rfl | hx
      · exact hp1
      · exact a1.pres _ (he x hx)
    · cases hc
      exact ⟨hp1, Nat.le_refl _⟩

theorem classMembers_push_sim {s t : St F.S} (h : Rel F FR M ν K s S t C) {f p : Nat} {members : List Member}
    {ns : List Name} {env : Env} (hf : Present s f) (hp : Present s p) (he : Supp.env (Present s) S.tab.length env) :
    MSim (StepPost F FR M ν K S C) S C
      (Host.Ts.M.pure ((s.push (.k (.classMembers f p members (ns.map fun n => .field (.str n) none) env))).ret .undef))
      (Host.Ts.M.pure ((t.push (.k (.classMembers (M.a f) (M.a p) members (ns.map fun n => .field (.str n) none)
        (M.env env)))).ret .undef)) := by
  have hr := (h.push (.k (.classMembers f p members (ns.map fun n => .field (.str n) none) env))
    ⟨hf, hp, fun x hx => by
      obtain ⟨n, -, rfl⟩ := List.mem_map.1 hx
      trivial, he⟩).ret .undef trivial
  have e : M.frame (.k (.classMembers f p members (ns.map fun n => .field (.str n) none) env)) =
      .k (.classMembers (M.a f) (M.a p) members (ns.map fun n => .field (.str n) none) (M.env env)) := by
    show Frame.k (FnF.classMembers _ _ members ((ns.map fun n => InstMember.field (.str n) none).map M.inst) _) = _
    rw [inst0_map]
  rw [e] at hr
  exact sim_pure hr

/-- The class objects: prototype, constructor (with `prototype`), `prototype.constructor`,
the class-name binding, then the members. -/
theorem classTail_sim {s t : St F.S} (h : Rel F FR M ν K s S t C) (hn : s.next + 2 < Sim.bound)
    {members : List Member} {env : Env} {parent : Option Val} {nameCell : Option Nat} {pp cp : Val}
    (he : Supp.env (Present s) S.tab.length env)
    (hpar : ∀ v, parent = some v → Supp.val (Present s) S.tab.length v)
    (hpp : Supp.val (Present s) S.tab.length pp) (hcp : Supp.val (Present s) S.tab.length cp)
    (hnc : ∀ c, nameCell = some c → Present s c ∧ K.fr c = none) :
    MSim (StepPost F FR M ν K S C) S C (classTail F s members env parent nameCell pp cp)
      (classTail F t members (M.env env) (parent.map M.val) (nameCell.map M.a) (M.val pp) (M.val cp)) := by
  have hpv : Supp.val (Present s) S.tab.length (parentVal parent) := by
    cases parent with
    | none => trivial
    | some v => exact hpar v rfl
  have hpv' : parentVal (parent.map M.val) = M.val (parentVal parent) := by
    cases parent <;> rfl
  unfold classTail
  dsimp only
  rw [hpv']
  generalize parentVal parent = pv at hpv ⊢
  have hso1 : Supp.hobj (Present s) S.tab.length (.obj ⟨.ordinary, pp, [], [], true⟩) := by
    refine ⟨trivial, hpp, ?_, ?_⟩
    · intro x hx; exact absurd hx List.not_mem_nil
    · intro x hx; exact absurd hx List.not_mem_nil
  obtain ⟨e1, -, hp1, a1⟩ := adv_alloc h (by omega) _ hso1
  replace a1 : Adv F FR M ν K S C s (s.allocObj .ordinary pp []).2 (t.allocObj .ordinary (M.val pp) []).2 1 := a1
  replace hp1 : Present (s.allocObj .ordinary pp []).2 s.next := hp1
  have e1' : (t.allocObj .ordinary (M.val pp) []).1 = M.a s.next := e1
  rw [e1', show (s.allocObj .ordinary pp []).1 = s.next from rfl]
  generalize hs1 : (s.allocObj .ordinary pp []).2 = s1 at a1 hp1 ⊢
  generalize ht1 : (t.allocObj .ordinary (M.val pp) []).2 = t1 at a1 ⊢
  have hs1n : s1.next = s.next + 1 := by rw [← hs1]; rfl
  have hso2 : Supp.hobj (Present s1) S.tab.length
      (.obj ⟨.fn (.klass (classCtor members) env pv []), cp, [(kPrototype, .data (.obj s.next) false false)], [], true⟩) := by
    refine ⟨⟨a1.env he, a1.val hpv, fun _ hx => absurd hx List.not_mem_nil⟩, a1.val hcp, ?_, ?_⟩
    · intro x hx
      rcases List.mem_singleton.1 hx with rfl
      exact ⟨trivial, hp1⟩
    · intro x hx; exact absurd hx List.not_mem_nil
  obtain ⟨e2, -, hp2, a2⟩ := adv_alloc a1.rel (by omega) _ hso2
  replace a2 : Adv F FR M ν K S C s1
      (s1.allocObj (.fn (.klass (classCtor members) env pv [])) cp [(kPrototype, .data (.obj s.next) false false)]).2
      (t1.allocObj (.fn (.klass (classCtor members) (M.env env) (M.val pv) [])) (M.val cp)
        [(kPrototype, .data (.obj (M.a s.next)) false false)]).2 1 := a2
  replace hp2 : Present (s1.allocObj (.fn (.klass (classCtor members) env pv [])) cp
      [(kPrototype, .data (.obj s.next) false false)]).2 s1.next := hp2
  have e2' : (t1.allocObj (.fn (.klass (classCtor members) (M.env env) (M.val pv) [])) (M.val cp)
      [(kPrototype, .data (.obj (M.a s.next)) false false)]).1 = M.a s1.next := e2
  rw [e2', show (s1.allocObj (.fn (.klass (classCtor members) env pv [])) cp
    [(kPrototype, .data (.obj s.next) false false)]).1 = s1.next from rfl]
  generalize hs2 : (s1.allocObj (.fn (.klass (classCtor members) env pv [])) cp
    [(kPrototype, .data (.obj s.next) false false)]).2 = s2 at a2 hp2 ⊢
  generalize ht2 : (t1.allocObj (.fn (.klass (classCtor members) (M.env env) (M.val pv) [])) (M.val cp)
    [(kPrototype, .data (.obj (M.a s.next)) false false)]).2 = t2 at a2 ⊢
  have hs2n : s2.next = s.next + 2 := by rw [← hs2]; show s1.next + 1 = _; omega
  have a3 := defineProp_adv a2.rel (by omega) (k := kConstructor) (p := .data (.obj s1.next) true false)
    (a2.pres _ hp1) (fresh_unframed h (Nat.le_refl _)) trivial hp2
  replace a3 : Adv F FR M ν K S C s2 (defineProp F s2 s.next kConstructor (.data (.obj s1.next) true false))
    (defineProp F t2 (M.a s.next) kConstructor (.data (.obj (M.a s1.next)) true false)) 0 := a3
  have a123 := a1.trans (a2.trans a3)
  generalize defineProp F s2 s.next kConstructor (.data (.obj s1.next) true false) = s3 at a3 a123 ⊢
  generalize defineProp F t2 (M.a s.next) kConstructor (.data (.obj (M.a s1.next)) true false) = t3 at a3 a123 ⊢
  have hf3 : Present s3 s1.next := a3.pres _ hp2
  have hp3 : Present s3 s.next := a3.pres _ (a2.pres _ hp1)
  cases nameCell with
  | none => exact classMembers_push_sim a3.rel hf3 hp3 (a123.env he)
  | some c =>
    obtain ⟨hc, hcfr⟩ := hnc c rfl
    have a4 := adv_setCell a3.rel (by have := a3.next; omega) (a123.pres _ hc) hcfr (v := .obj s1.next) hf3
    exact classMembers_push_sim a4.rel (a4.pres _ hf3) (a4.pres _ hp3) (a4.env (a123.env he))

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- A class definition: brand and name cells, the parents (none: `Object`; `extends null`;
a constructor's `prototype`; else a `TypeError`), then the class objects. -/
theorem defineClass_sim {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (c : Class) {parent : Option Val} {env : Env}
    (hpar : ∀ v, parent = some v → Supp.val (Present s) S.tab.length v) (he : Supp.env (Present s) S.tab.length env)
    (hPO : Present s aObjectProto) (hPF : Present s aFunctionProto) (hPT : Present s aTypeErrorProto)
    (hn : s.next + 4 < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (defineClass F s c parent env)
      (defineClass F t c (parent.map M.val) (M.env env)) := by
  obtain ⟨name, sup, members⟩ := c
  rw [defineClass_eq, defineClass_eq]
  obtain ⟨-, -, hpb, a1⟩ := adv_alloc h (by omega) (.cell none) trivial
  replace a1 : Adv F FR M ν K S C s (s.alloc (.cell none)).2 (t.alloc (.cell none)).2 1 := a1
  have ebr : t.next = M.a s.next := by
    have := h.next 0
    simp only [Nat.add_zero] at this
    exact this.symm
  have hpe : privEnv members t.next (M.env env) = M.env (privEnv members s.next env) := by
    rw [ebr, privEnv_map]
  rw [hpe]
  have he1 := privEnv_supp members hpb (a1.env he)
  obtain ⟨n1, n2, a2, he2, hc2⟩ := nameStep_adv a1.rel (a1.lt (show s.next + (1 + 0) < Sim.bound by omega)) name
    (privEnv members s.next env) he1
  rw [n1, n2]
  have a12 := a1.trans a2
  refine MSim.bind (classParents_read a2.rel hF (parent := parent) (fun w hw => a12.val (hpar w hw))
    (a12.pres _ hPO) (a12.pres _ hPF)) ?_
  rintro M' S' C' r r' ⟨-, hS, hC, hrr, hsupp⟩
  rw [hS, hC, hrr]
  cases r with
  | none =>
    exact typeErr_sim a2.rel a2.rel.intr (a12.lt (show s.next + (1 + 1 + 0) < Sim.bound by omega))
      (a12.pres _ hPT) _
  | some x =>
    obtain ⟨pp, cp⟩ := x
    obtain ⟨hpp, hcp⟩ := hsupp _ rfl
    exact classTail_sim a2.rel (a12.lt (show s.next + (1 + 1 + 2) < Sim.bound by omega)) he2
      (fun w hw => a12.val (hpar w hw)) hpp hcp
      (fun c hc => ⟨(hc2 c hc).1, fresh_unframed h (by have := a1.mono; have := (hc2 c hc).2; omega)⟩)

/-- A class definition after its `extends` clause. -/
theorem step_ret_classHeritage {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {v : Val} {c : Class} {env : Env}
    {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .k (.classHeritage c env) :: fs)
    (hPO : Present s aObjectProto) (hPF : Present s aFunctionProto) (hPT : Present s aTypeErrorProto)
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, he⟩ := h.kRet hc hs
  rw [e1, e2]
  exact defineClass_sim hr hF c (parent := some v) (fun w hw => by cases hw; exact hv) he hPO hPF hPT
    (margin_split hn 4 (by have : margin = 2 ^ 30 := rfl; omega))

end

/-! ## Modules -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- A module body completed: the next module's statements, or the value. -/
theorem step_ret_modules (h : Rel F FR M ν K s S t C) {v : Val} {r : List (List Stmt × Env)} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.modules r) :: fs) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hm⟩ := h.kRet hc hs
  rw [e1, e2]
  cases r with
  | nil => exact sim_pure (hr.ret v hv)
  | cons x r =>
    obtain ⟨ss, env⟩ := x
    have he : Supp.env (Present s) S.tab.length env := hm _ (List.mem_cons_self ..)
    have hr' : Supp.fnF (Present s) S.tab.length (.modules r) := fun y hy => hm y (List.mem_cons_of_mem _ hy)
    exact sim_pure (((hr.push (.k (.modules r)) hr').push (.s (.block ss env)) he).ret .undef trivial)

end
end Host.Ts.Sim
