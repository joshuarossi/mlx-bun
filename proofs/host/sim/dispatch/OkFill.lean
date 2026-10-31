import host.sim.dispatch.OkJs
import host.sim.steps.BufFill

/-! # The acceptance function with `TypedArray.prototype.fill`

`okJSF P okBack D0` is `okJSJ` and a fill of a whole unframed typed array with a literal (`taFillB`,
`step_buf_taFill`). It is a layer over `okJSJ`, unchanged: everything `okJSJ` accepts `okJSF` accepts
(`okJSJ_F`). `dispatchJF` and `stepSimXLBJF` are its one-step theorems. -/

namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.BufSim

section
variable {F : Ffi} (P : JSP F) (okBack : F.S → Arg → Bool) (D0 : Nat)

/-- A fill of a whole unframed typed array with a literal. -/
def taFillB (s : St F.S) : Bool :=
  Nat.blt s.next nextMax && presB s aTypeErrorProto && match s.ctl with
  | .call (.obj fa) (.obj ta) [.num (.lit _)] => match s.obj? fa with
    | some o => match o.kind with
      | .fn (.native (.buf .taFill) _) => frB P ta && match s.obj? ta with
        | some tobj => match tobj.kind with
          | .typed _ _ _ _ => true
          | _ => false
        | none => false
      | _ => false
    | none => false
  | _ => false

/-- **The acceptance function with typed-array fills.** -/
def okJSF (s : St F.S) (S : SSrv) : Bool := okJSJ P okBack D0 s S || taFillB P s

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F} {okBack : F.S → Arg → Bool} {D0 : Nat}

/-- **Agreement**: everything `okJSJ` accepts `okJSF` accepts. -/
theorem okJSJ_F (h : okJSJ P okBack D0 s S = true) : okJSF P okBack D0 s S = true := by
  simp [okJSF, h]

theorem taFillB_spec (h : taFillB P s = true) :
    s.next < nextMax ∧ presB s aTypeErrorProto = true ∧
      ∃ fa ta x o data tobj k b off n, s.ctl = .call (.obj fa) (.obj ta) [.num (.lit x)] ∧ s.obj? fa = some o ∧
        o.kind = .fn (.native (.buf .taFill) data) ∧ frB P ta = true ∧ s.obj? ta = some tobj ∧
        tobj.kind = .typed k b off n := by
  unfold taFillB at h
  simp only [Bool.and_eq_true, Nat.blt_eq] at h
  obtain ⟨⟨hn, hp⟩, h⟩ := h
  refine ⟨hn, hp, ?_⟩
  split at h
  · rename_i fa ta x hc
    split at h
    · rename_i o ho
      split at h
      · rename_i data hk
        simp only [Bool.and_eq_true] at h
        obtain ⟨hfr, h⟩ := h
        split at h
        · rename_i tobj hto
          split at h
          · rename_i k b off n htk
            exact ⟨fa, ta, x, o, data, tobj, k, b, off, n, hc, ho, hk, hfr, hto, htk⟩
          · cases h
        · cases h
      · cases h
    · cases h
  · cases h

/-- **The one-step theorem of `okJSF`.** -/
theorem dispatchJF {okCall0 : F.S → Name → List Arg → Bool} {okBack0 : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} {smallBack : (Nat → F64) → SSrv → F.S → Arg → Prop}
    (hF : FfiSim F FR okCall0 okBack0) (hB : FfiBackSimS F FR okBack smallBack) (hC : FfiCallSim F FR P.okCall small)
    (hsm : ∀ S x name args, P.smallB S x name args = true → small ν S x name args)
    (hsmB : ∀ S x a, P.smallBackB S x a = true → smallBack ν S x a)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hK : Kp P K) (hD : K.D ≤ D0)
    (hW : Wp P W) (h : RelB F FR W stk M ν K s S t C) (hJ : BigJs M)
    (hh : isHalt s.ctl = false) (hok : okJSF P okBack D0 s S = true) (hloc : stk = [] ∨ localB s = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  simp only [okJSF, Bool.or_eq_true] at hok
  rcases hok with hok | hok
  · exact dispatchJS hF hB hC hsm hsmB hFR hL hN hK hD hW h hJ hh hok hloc
  · obtain ⟨hn, hp, fa, ta, x, o, data, tobj, k, b, off, n, hc, ho, hk, hfr, hto, htk⟩ := taFillB_spec hok
    exact MSim.toX (step_buf_taFill h hFR (Nat.lt_of_le_of_lt (Nat.le_add_right _ _) (next_ok (Nat.blt_eq.mpr hn))) (presB_sound hp) hc ho hk hto htk (hK.fr_none hfr))

/-- **The checked runs' one-step theorem of `okJSF`.** -/
theorem stepSimXLBJF {W : Nat → Option WFrame} {stk : List Frame} {okCall0 : F.S → Name → List Arg → Bool}
    {okBack0 : F.S → Arg → Bool} {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop}
    {smallBack : (Nat → F64) → SSrv → F.S → Arg → Prop} {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack0) (hB : FfiBackSimS F FR okBack smallBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hsmallB : ∀ ν S x a, VBOk ν → P.smallBackB S x a = true → smallBack ν S x a)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hW : Wp P W) :
    StepSimXLB F (FRJ FR) (okJSF P okBack D0) (KpJ P D0) W stk VBOk := by
  intro M ν K s S t C s1 S1 hK hν hr hh hloc hok hs
  rcases hr with hr | hd
  · obtain ⟨M', t1, C1, ht, hg, hr1⟩ :=
      MSim.run (dispatchJF hF hB hC (hsmall ν · · · · hν) (hsmallB ν · · · hν) hFR hL hN hK.1 hK.2 hW hr.ofJ
        hr.ffi.2 hh hok hloc) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, RelXB.toJ hr1 (hr.ffi.2.ext hg.ext)⟩
  · have e := RelDB.step_eq hd
    obtain ⟨v, v', r, env, fs, hc, _, hstk, hr⟩ := hd
    rw [e]
    obtain ⟨M', t1, C1, ht, hg, hr1⟩ := MSim.run (step_ret_block hr hc hstk) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, .inl hr1⟩

end

end Host.Ts.Sim.Disp
