import host.sim.dispatch.OkJs

/-! # The acceptance function with literal numbers the program only tests or prints

`okJSLit P okBack D0` is `okJSJ` and two steps both sides compute alike, since a number literal is its own image:
`Number.isInteger` of a literal (`isIntLitB`, `step_num_isInteger_lit`) and a literal returned into a template
(`tmplLitB`, `step_retL_tmpl_lit`). It is a layer over `okJSJ`, unchanged: everything `okJSJ` accepts `okJSLit`
accepts (`okJSJ_lit`). `dispatchJLit` and `stepSimXLBJLit` are its one-step theorems. -/

namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.BufSim

section
variable {F : Ffi}

/-- `Number.isInteger` of a literal. -/
def isIntLitB (s : St F.S) : Bool :=
  match s.ctl with
  | .call (.obj fa) _ args => match s.obj? fa with
    | some o => match o.kind with
      | .fn (.native (.num .isInteger) _) => match arg args 0 with
        | .num (.lit _) => true
        | _ => false
      | _ => false
    | none => false
  | _ => false

/-- A literal returned into a template. -/
def tmplLitB (s : St F.S) : Bool :=
  match s.ctl, s.stack with
  | .ret (.num (.lit _)), .l (.tmpl _ _ _ _) :: _ => true
  | _, _ => false

/-- **The acceptance function with those steps.** -/
def okJSLit (P : JSP F) (okBack : F.S → Arg → Bool) (D0 : Nat) (s : St F.S) (S : SSrv) : Bool :=
  okJSJ P okBack D0 s S || isIntLitB s || tmplLitB s

theorem isIntLitB_spec {s : St F.S} (h : isIntLitB s = true) :
    ∃ fa this args o data x, s.ctl = .call (.obj fa) this args ∧ s.obj? fa = some o ∧
      o.kind = .fn (.native (.num .isInteger) data) ∧ arg args 0 = .num (.lit x) := by
  unfold isIntLitB at h
  split at h
  · rename_i fa this args hc
    split at h
    · rename_i o ho
      split at h
      · rename_i data hk
        split at h
        · rename_i x hx
          exact ⟨fa, this, args, o, data, x, hc, ho, hk, hx⟩
        · cases h
      · cases h
    · cases h
  · cases h

theorem tmplLitB_spec {s : St F.S} (h : tmplLitB s = true) :
    ∃ x acc quasis subs env fs, s.ctl = .ret (.num (.lit x)) ∧ s.stack = .l (.tmpl acc quasis subs env) :: fs := by
  unfold tmplLitB at h
  split at h
  · rename_i x acc quasis subs env fs hc hs
    exact ⟨x, acc, quasis, subs, env, fs, hc, hs⟩
  · cases h

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F} {okBack : F.S → Arg → Bool} {D0 : Nat}

/-- **Agreement**: everything `okJSJ` accepts `okJSLit` accepts. -/
theorem okJSJ_lit (h : okJSJ P okBack D0 s S = true) : okJSLit P okBack D0 s S = true := by
  simp [okJSLit, h]

/-- `Number.isInteger` of a literal: the same test on both sides. -/
theorem step_num_isInteger_lit (h : RelB F FR W stk M ν K s S t C) {fa : Nat} {this : Val} {args : List Val} {o : Obj}
    {data : List Val} {x : F64} (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.num .isInteger) data)) (hx : arg args 0 = .num (.lit x)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, _⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  simp only [callNative, numN, numN.litTest, bi_arg_map, hx, Map.val, Map.nv]
  exact bi_ret h (.bool _) trivial

/-- A literal's text: the same on both sides, nothing grows. -/
theorem primStr_lit (x : F64) :
    MSim (fun M' S' C' r r' => r' = r ∧ M' = M ∧ S' = S ∧ C' = C) S C
      (primStr (.num (.lit x))) (primStr (.num (.lit x))) := by
  show MSim _ S C (Host.Ts.M.bind (numConc (.lit x)) _) (Host.Ts.M.bind (numConc (.lit x)) _)
  refine MSim.bind (P := fun M' S' C' a b => b = a ∧ M' = M ∧ S' = S ∧ C' = C) (MSim.pure ⟨rfl, rfl, rfl, rfl⟩) ?_
  rintro M' S' C' f f' ⟨rfl, rfl, rfl, rfl⟩
  cases hstr : F64.toStr f' with
  | some cs => exact MSim.pure ⟨rfl, rfl, rfl, rfl⟩
  | none => exact MSim.fail _ _

/-- A literal returned into a template: the same text on both sides, then the template's next piece. -/
theorem step_retL_tmpl_lit (h : RelB F FR W stk M ν K s S t C) {x : F64} {acc : List Char} {quasis : List (List Char)}
    {subs : List Expr} {env : Env} {fs : List Frame} (hc : s.ctl = .ret (.num (.lit x)))
    (hs : s.stack = .l (.tmpl acc quasis subs env) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, -, he⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  show MSim _ S C (Host.Ts.M.bind (primStr (.num (.lit x))) _) (Host.Ts.M.bind (primStr (.num (.lit x))) _)
  refine MSim.bind (primStr_lit (M := M) x) ?_
  rintro M' S' C' o o' ⟨rfl, rfl, rfl, rfl⟩
  cases o' with
  | none => exact MSim.fail _ _
  | some piece =>
    cases quasis with
    | nil => exact MSim.fail _ _
    | cons q qs =>
      dsimp only
      cases hq : cook q with
      | none => exact MSim.fail _ _
      | some c => exact tmplNext_sim hr he

/-- **The one-step theorem of `okJSLit`.** -/
theorem dispatchJLit {okCall0 : F.S → Name → List Arg → Bool} {okBack0 : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} {smallBack : (Nat → F64) → SSrv → F.S → Arg → Prop}
    (hF : FfiSim F FR okCall0 okBack0) (hB : FfiBackSimS F FR okBack smallBack) (hC : FfiCallSim F FR P.okCall small)
    (hsm : ∀ S x name args, P.smallB S x name args = true → small ν S x name args)
    (hsmB : ∀ S x a, P.smallBackB S x a = true → smallBack ν S x a)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hK : Kp P K) (hD : K.D ≤ D0)
    (hW : Wp P W) (h : RelB F FR W stk M ν K s S t C) (hJ : BigJs M)
    (hh : isHalt s.ctl = false) (hok : okJSLit P okBack D0 s S = true) (hloc : stk = [] ∨ localB s = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  simp only [okJSLit, Bool.or_eq_true] at hok
  rcases hok with (hok | hok) | hok
  · exact dispatchJS hF hB hC hsm hsmB hFR hL hN hK hD hW h hJ hh hok hloc
  · obtain ⟨fa, this, args, o, data, x, hc, ho, hk, hx⟩ := isIntLitB_spec hok
    exact MSim.toX (step_num_isInteger_lit h hc ho hk hx)
  · obtain ⟨x, acc, quasis, subs, env, fs, hc, hs⟩ := tmplLitB_spec hok
    exact MSim.toX (step_retL_tmpl_lit h hc hs)

/-- **The checked runs' one-step theorem of `okJSLit`.** -/
theorem stepSimXLBJLit {W : Nat → Option WFrame} {stk : List Frame} {okCall0 : F.S → Name → List Arg → Bool}
    {okBack0 : F.S → Arg → Bool} {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop}
    {smallBack : (Nat → F64) → SSrv → F.S → Arg → Prop} {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack0) (hB : FfiBackSimS F FR okBack smallBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hsmallB : ∀ ν S x a, VBOk ν → P.smallBackB S x a = true → smallBack ν S x a)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hW : Wp P W) :
    StepSimXLB F (FRJ FR) (okJSLit P okBack D0) (KpJ P D0) W stk VBOk := by
  intro M ν K s S t C s1 S1 hK hν hr hh hloc hok hs
  rcases hr with hr | hd
  · obtain ⟨M', t1, C1, ht, hg, hr1⟩ :=
      MSim.run (dispatchJLit hF hB hC (hsmall ν · · · · hν) (hsmallB ν · · · hν) hFR hL hN hK.1 hK.2 hW hr.ofJ
        hr.ffi.2 hh hok hloc) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, RelXB.toJ hr1 (hr.ffi.2.ext hg.ext)⟩
  · have e := RelDB.step_eq hd
    obtain ⟨v, v', r, env, fs, hc, _, hstk, hr⟩ := hd
    rw [e]
    obtain ⟨M', t1, C1, ht, hg, hr1⟩ := MSim.run (step_ret_block hr hc hstk) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, .inl hr1⟩

end

end Host.Ts.Sim.Disp
