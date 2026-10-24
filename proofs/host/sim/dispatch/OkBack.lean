import host.sim.dispatch.OkLast
import host.sim.steps.CbRet
import host.sim.dispatch.Ext
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.BufSim

/-! # The acceptance function with callback continuations

`okJSK P okBack` is `okJS P` and a `JSCallback`'s return to the native call waiting for it
(`step_ret_callbackRet`) when the native continuation `F.back` is accepted by `okBack`
(`cbRetB`). Its one-step theorems are `okJS`'s with the continuation's simulation
`FfiBackSim F FR okBack`; everything `okJS` accepts `okJSK` accepts (`okJS_K`). It also accepts the
steps of `moreB` (`dispatch/Ext.lean`: async `yield*` under frames, native iterators, `Set`s, `new
Promise`, `Math.max`); everything the acceptance without them accepted it accepts (`okJSK_old`). -/

section
variable {F : Ffi} (P : JSP F) (okBack : F.S → Arg → Bool)

/-- `BackOK` on the source run: the decoded result (none for `void`) is accepted by `okBack`
and the continuation's result is `ResOK`. -/
def backB (s : St F.S) (S : SSrv) (rt : Name) (v : Val) : Bool :=
  bif nameEq rt (chars!"void") then okBack s.ffi .null && (match interpS (F.back s.ffi .null).run S with
      | some (r, S2) => resB S2.tab.length r || resCbB P s S2.tab.length r
      | none => true)
  else match interpS (decodeArg F s rt v).run S with
    | some (some a, S1) => okBack s.ffi a && (match interpS (F.back s.ffi a).run S1 with
      | some (r, S2) => resB S2.tab.length r || resCbB P s S2.tab.length r
      | none => true)
    | _ => true

/-- A `JSCallback` returning to its native call (`step_ret_callbackRet`). -/
def cbRetB (s : St F.S) (S : SSrv) : Bool :=
  Nat.blt s.next nextMax && match s.ctl, s.stack with
  | .ret v, .k (.native (.ffi .callbackRet) [.str _, .str rt]) :: fs =>
    argBufB P s S.tab.length v && (!(nameEq rt (chars!"bool")) || bfVB P v) &&
      backB P okBack { s with stack := fs } S rt v
  | _, _ => false

/-- **The acceptance function with callback continuations.** -/
def okJSK (s : St F.S) (S : SSrv) : Bool := okJS P s S || cbRetB P okBack s S || moreB P s S

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F} {okBack : F.S → Arg → Bool}

/-- **Agreement**: every state `okJS` accepts `okJSK` accepts. -/
theorem okJS_K (h : okJS P s S = true) : okJSK P okBack s S = true := by
  simp [okJSK, h]

/-- **Agreement**: everything `okJSK` accepted before `moreB` it accepts. -/
theorem okJSK_old (h : (okJS P s S || cbRetB P okBack s S) = true) : okJSK P okBack s S = true := by
  simp only [okJSK, h, Bool.true_or]

theorem Kp.back (hK : Kp P K) {s : St F.S} {S : SSrv} {rt : Name} {v : Val} (h : backB P okBack s S rt v = true) :
    BackOK F K okBack s S rt v := by
  unfold backB at h
  refine ⟨fun hvd => ?_, fun hvd => ?_⟩
  · simp only [hvd, Bool.cond_true, Bool.and_eq_true] at h
    refine ⟨h.1, fun r S2 hr => ?_⟩
    have h2 := h.2
    simp only [hr, Bool.or_eq_true] at h2
    rcases h2 with h2 | h2
    · exact resB_sound h2
    · exact hK.resCb h2
  · intro a S1 hd
    simp only [hvd, Bool.cond_false, hd, Bool.and_eq_true] at h
    refine ⟨h.1, fun r S2 hr => ?_⟩
    have h2 := h.2
    simp only [hr, Bool.or_eq_true] at h2
    rcases h2 with h2 | h2
    · exact resB_sound h2
    · exact hK.resCb h2

theorem cbRetB_spec {s : St F.S} {S : SSrv} (h : cbRetB P okBack s S = true) :
    ∃ v name rt fs, s.ctl = .ret v ∧ s.stack = .k (.native (.ffi .callbackRet) [.str name, .str rt]) :: fs ∧
      Nat.blt s.next nextMax = true ∧ argBufB P s S.tab.length v = true ∧
      (!(nameEq rt (chars!"bool")) || bfVB P v) = true ∧ backB P okBack { s with stack := fs } S rt v = true := by
  unfold cbRetB at h
  simp only [Bool.and_eq_true] at h
  obtain ⟨hn, h⟩ := h
  split at h
  · rename_i v name rt fs hc hs
    simp only [Bool.and_eq_true] at h
    exact ⟨v, name, rt, fs, hc, hs, hn, h.1.1, h.1.2, h.2⟩
  · cases h

/-- The one-step theorem of `okJSK` (`dispatch` with callback continuations). -/
theorem dispatchK {okCall0 : F.S → Name → List Arg → Bool} {okBack0 : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} (hF : FfiSim F FR okCall0 okBack0)
    (hB : FfiBackSim F FR okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsm : ∀ S x name args, P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hK : Kp P K) (hW : Wp P W)
    (h : RelB F FR W stk M ν K s S t C)
    (hh : isHalt s.ctl = false) (hok : okJSK P okBack s S = true) (hloc : stk = [] ∨ localB s = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  simp only [okJSK, Bool.or_eq_true] at hok
  rcases hok with (hok | hok) | hok
  · exact dispatch hF hC hsm hFR hL hN hK hW h hh hok hloc
  · obtain ⟨v, name, rt, fs, hc, hs, hn, h1, h2, h3⟩ := cbRetB_spec hok
    have hbool : BoolOK K rt v := by
      intro hb
      simp only [hb, Bool.not_true, Bool.false_or] at h2
      exact hK.bfBig h2
    have hn' : s.next < Sim.bound := by have := next_ok hn; omega
    exact MSim.toX (step_ret_callbackRet h hFR hF hB hL hc hs hn' (hK.argBuf hW h1) hbool (hK.back h3)
      (fun f hf _ => hN.cb M _ _ _ h.ffi f hf))
  · exact dispatchMore hF hFR hK hW h hok hloc

/-- `stepSimXLB` for `okJSK`. -/
theorem stepSimXLBK {W : Nat → Option WFrame} {stk : List Frame} {okCall0 : F.S → Name → List Arg → Bool}
    {okBack0 : F.S → Arg → Bool} {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop}
    {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack0) (hB : FfiBackSim F FR okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hW : Wp P W) :
    StepSimXLB F FR (okJSK P okBack) (Kp P) W stk VBOk := by
  intro M ν K s S t C s1 S1 hK hν hr hh hloc hok hs
  rcases hr with hr | hd
  · obtain ⟨M', t1, C1, ht, hg, hr1⟩ :=
      MSim.run (dispatchK hF hB hC (hsmall ν · · · · hν) hFR hL hN hK hW hr hh hok hloc) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, hr1⟩
  · have e := RelDB.step_eq hd
    obtain ⟨v, v', r, env, fs, hc, _, hstk, hr⟩ := hd
    rw [e]
    obtain ⟨M', t1, C1, ht, hg, hr1⟩ := MSim.run (step_ret_block hr hc hstk) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, .inl hr1⟩

/-- `stepSimXVB` for `okJSK`. -/
theorem stepSimXVBK {W : Nat → Option WFrame} {stk : List Frame} {okCall0 : F.S → Name → List Arg → Bool}
    {okBack0 : F.S → Arg → Bool} {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop}
    {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack0) (hB : FfiBackSim F FR okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hW : Wp P W) :
    StepSimXVB F FR (okJSK P okBack) (Kp P) W stk VBOk :=
  (stepSimXLBK hF hB hC hsmall hFR hL hN hW).xv

/-- `stepSimXL` for `okJSK`. -/
theorem stepSimXLK {okCall0 : F.S → Name → List Arg → Bool} {okBack0 : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack0) (hB : FfiBackSim F FR okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) :
    StepSimXL F FR (okJSK P okBack) (Kp P) VBOk :=
  (stepSimXLBK (stk := []) hF hB hC hsmall hFR hL hN Wp.free).nil

end
end Host.Ts.Sim.Disp
