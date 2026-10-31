import host.sim.dispatch.OkJsLimit
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.BufSim
section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F}
  {okBack : F.S → Arg → Bool} {D0 limit : Nat}

theorem typedJsLimitB_spec {s : St F.S} {S : SSrv} (h : typedJsLimitB P limit D0 s S = true) :
    ∃ a args nt o c p ci proto b ob es, s.ctl = .construct (.obj a) args nt ∧ s.obj? a = some o ∧
      o.kind = .fn (.native (.buf .typedCtor) [.num (.lit c), .num (.lit p)]) ∧ F64.toIndex? c = some ci ∧
      F64.toIndex? p = some proto ∧ Nat.blt s.next nextMax = true ∧ proto < aFirst ∧
      Present s aArrayBufferProto ∧ Present s proto ∧ Present s aTypeErrorProto ∧
      elemsB P s S.tab.length (arg args 0) = true ∧ arg args 0 = .obj b ∧ s.obj? b = some ob ∧
      ob.kind = .array es ∧ ctorElemsLimitB P limit D0 s S (eltOfCode ci) (arg args 0) = true := by
  unfold typedJsLimitB at h
  simp only [Bool.and_eq_true] at h
  obtain ⟨hn, h⟩ := h
  split at h
  · rename_i a args nt hc
    split at h
    · rename_i o ho
      split at h
      · rename_i c p hk
        split at h
        · rename_i ci proto hci hpi
          simp only [Bool.and_eq_true, Nat.blt_eq] at h
          obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := h
          split at h6
          · rename_i b hb
            split at h6
            · rename_i ob hob
              split at h6
              · rename_i es hes
                exact ⟨a, args, nt, o, c, p, ci, proto, b, ob, es, hc, ho, hk, hci, hpi, hn, h1, h2, h3, h4, h5,
                  hb, hob, hes, h6⟩
              · cases h6
            · cases h6
          · cases h6
        · cases h
      · cases h
    · cases h
  · cases h

/-- The cell of a stored element `ctorElemsLimitB` accepts converts alike. -/
theorem ctorElemsLimitB_cell (hlimit : limit ≤ jsSignedLimit) (hK : Kp P K) (hD : K.D ≤ D0) (hN : NativeFacts F FR P) (hJ : BigJs M)
    (h : RelB F FR W stk M ν K s S t C) {k : EltK} {v : Val} (hv : ctorElemsLimitB P limit D0 s S k v = true) :
    ∀ vs S1, interpS (elemsOf F s v).run S = some (some vs, S1) →
      ∀ i, Val.big i ∈ vs → toCellBig k (M.big i) = (toCellBig k i).map M.cell := by
  intro vs S1 hr i hi
  simp only [ctorElemsLimitB, hr] at hv
  have hx := allB_sound hv _ hi
  simp only [Bool.or_eq_true] at hx
  rcases hx with hx | hx
  · exact toCellBig_map h (hK.conv hx i rfl) (convB_range hK hN h hx i rfl)
  · simp only [jsElemLimitB] at hx
    cases hp : jsPtrOf i with
    | none => rw [hp] at hx; cases hx
    | some q =>
      obtain ⟨b, off⟩ := q
      rw [hp] at hx
      simp only [Bool.and_eq_true, Nat.blt_eq] at hx
      obtain ⟨rfl, hb, hoff⟩ := jsPtrOf_some hp
      have himg : M.a b < limit := by
        have h1 := h.bound b (presB_sound hx.1)
        have h2 := h.offset
        have h3 : s.next + D0 < limit := hx.2
        show M.a b < limit
        omega
      exact toCellBig_js_limit hJ hb hoff hlimit himg k

theorem dispatchJSLimit {okCall0 : F.S → Name → List Arg → Bool} {okBack0 : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} {smallBack : (Nat → F64) → SSrv → F.S → Arg → Prop}
    (hlimit : limit ≤ jsSignedLimit) (hF : FfiSim F FR okCall0 okBack0) (hB : FfiBackSimS F FR okBack smallBack) (hC : FfiCallSim F FR P.okCall small)
    (hsm : ∀ S x name args, P.smallB S x name args = true → small ν S x name args)
    (hsmB : ∀ S x a, P.smallBackB S x a = true → smallBack ν S x a)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hK : Kp P K) (hD : K.D ≤ D0)
    (hW : Wp P W) (h : RelB F FR W stk M ν K s S t C) (hJ : BigJs M)
    (hh : isHalt s.ctl = false) (hok : okJSJLimit P limit D0 okBack s S = true) (hloc : stk = [] ∨ localB s = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  simp only [okJSJLimit, Bool.or_eq_true] at hok
  rcases hok with hok | hok
  · exact dispatchJSImage hF hB hC hsm hsmB hFR hL hN hK hD hW h hJ hh hok hloc
  · obtain ⟨a, args, nt, o, c, p, ci, proto, b, ob, es, hc, ho, hk, hci, hpi, hn, h1, h2, h3, h4, h5, hb, hob,
      hes, h6⟩ := typedJsLimitB_spec hok
    exact MSim.toX (step_buf_typedCtor_arr h hFR hF hc ho hk hci hpi (next_ok hn) h1 h2 h3 h4 hb hob hes
      (hK.elems h5) (ctorElemsLimitB_cell hlimit hK hD hN hJ h h6))

theorem stepSimXLBJSLimit {W : Nat → Option WFrame} {stk : List Frame} {okCall0 : F.S → Name → List Arg → Bool}
    {okBack0 : F.S → Arg → Bool} {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop}
    {smallBack : (Nat → F64) → SSrv → F.S → Arg → Prop} {VBOk : (Nat → F64) → Prop}
    (hlimit : limit ≤ jsSignedLimit) (hF : FfiSim F FR okCall0 okBack0) (hB : FfiBackSimS F FR okBack smallBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hsmallB : ∀ ν S x a, VBOk ν → P.smallBackB S x a = true → smallBack ν S x a)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hW : Wp P W) :
    StepSimXLB F (FRJ FR) (okJSJLimit P limit D0 okBack) (KpJ P D0) W stk VBOk := by
  intro M ν K s S t C s1 S1 hK hν hr hh hloc hok hs
  rcases hr with hr | hd
  · obtain ⟨M', t1, C1, ht, hg, hr1⟩ :=
      MSim.run (dispatchJSLimit hlimit hF hB hC (hsmall ν · · · · hν) (hsmallB ν · · · hν) hFR hL hN hK.1 hK.2 hW hr.ofJ
        hr.ffi.2 hh hok hloc) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, RelXB.toJ hr1 (hr.ffi.2.ext hg.ext)⟩
  · have e := RelDB.step_eq hd
    obtain ⟨v, v', r, env, fs, hc, _, hstk, hr⟩ := hd
    rw [e]
    obtain ⟨M', t1, C1, ht, hg, hr1⟩ := MSim.run (step_ret_block hr hc hstk) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, .inl hr1⟩


end
end Host.Ts.Sim.Disp
