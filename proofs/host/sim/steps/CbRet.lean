import host.sim.steps.FfiJs
namespace Host.Ts.Sim

/-! # A `JSCallback`'s return to the native call that invoked it

A native call whose result invokes a `JSCallback` (`ffiCallback`) waits in the frame
`.native (.ffi .callbackRet) [name, rt]`. When the callback returns `v`, the frame decodes it
as an `rt` (nothing for `void`), the native call continues with it (`F.back`) and completes
(`ffiDone`). `FfiBackSim` is the continuation's simulation (`FfiSim.back` for the arguments
an `okBack` accepts); `BackOK` states the side conditions on the source run, like `SymOK`. -/

/-- Native continuations on related states with mapped arguments give related results. -/
structure FfiBackSim (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (okBack : F.S → Arg → Bool) : Prop where
  back : ∀ M ν S C x y a, Srv M ν S C → FR M S.tab.length x y → okBack x a = true →
    Supp.arg (fun _ => True) S.tab.length a →
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR FR M' S'.tab.length r r') S C
      (F.back x a) (F.back y (M.arg a))

/-- Every `FfiSim` gives the `FfiBackSim` of its `okBack`. -/
theorem FfiSim.backSim {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {okCall : F.S → Name → List Arg → Bool}
    {okBack : F.S → Arg → Bool} (h : FfiSim F FR okCall okBack) : FfiBackSim F FR okBack := ⟨h.back⟩

/-- `FfiBackSim` with a smallness premise `small ν S x a` on the continuation (decided by the
acceptance's `JSP.smallBackB` on the server after decoding, as `FfiCallSim`'s `small` for calls). -/
structure FfiBackSimS (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (okBack : F.S → Arg → Bool)
    (small : (Nat → F64) → SSrv → F.S → Arg → Prop) : Prop where
  back : ∀ M ν S C x y a, Srv M ν S C → FR M S.tab.length x y → okBack x a = true →
    Supp.arg (fun _ => True) S.tab.length a → small ν S x a →
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR FR M' S'.tab.length r r') S C
      (F.back x a) (F.back y (M.arg a))

/-- An `FfiBackSim` is an `FfiBackSimS` at every smallness premise (it does not use it). -/
theorem FfiBackSim.toS {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {okBack : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Arg → Prop} (h : FfiBackSim F FR okBack) : FfiBackSimS F FR okBack small :=
  ⟨fun M ν S C x y a hs hr hok hsu _ => h.back M ν S C x y a hs hr hok hsu⟩

namespace BufSim

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool}
  {okBack okBack' : F.S → Arg → Bool}

/-- The side condition of a callback continuation, about the source run on the state `s` below the
frame: the decoded result is accepted by `okBack`, and the continuation's result is `ResOK`. -/
def BackOK (F : Ffi) (K : Ctx) (okBack : F.S → Arg → Bool) (s : St F.S) (S : SSrv) (rt : Name) (v : Val) : Prop :=
  (nameEq rt (chars!"void") = true → okBack s.ffi .null = true ∧
    ∀ r S2, interpS (F.back s.ffi .null).run S = some (r, S2) → ResOK F K s S2.tab.length r) ∧
  (nameEq rt (chars!"void") = false → ∀ a S1, interpS (decodeArg F s rt v).run S = some (some a, S1) →
    okBack s.ffi a = true ∧ ∀ r S2, interpS (F.back s.ffi a).run S1 = some (r, S2) → ResOK F K s S2.tab.length r)

/-- `BackOK` with the continuation's smallness `sm` on the server it runs on. -/
def BackOKS (F : Ffi) (K : Ctx) (okBack : F.S → Arg → Bool) (sm : SSrv → F.S → Arg → Prop) (s : St F.S) (S : SSrv)
    (rt : Name) (v : Val) : Prop :=
  (nameEq rt (chars!"void") = true → okBack s.ffi .null = true ∧ sm S s.ffi .null ∧
    ∀ r S2, interpS (F.back s.ffi .null).run S = some (r, S2) → ResOK F K s S2.tab.length r) ∧
  (nameEq rt (chars!"void") = false → ∀ a S1, interpS (decodeArg F s rt v).run S = some (some a, S1) →
    okBack s.ffi a = true ∧ sm S1 s.ffi a ∧
      ∀ r S2, interpS (F.back s.ffi a).run S1 = some (r, S2) → ResOK F K s S2.tab.length r)

theorem BackOK.toS {K : Ctx} {s : St F.S} {S : SSrv} {rt : Name} {v : Val} (h : BackOK F K okBack s S rt v) :
    BackOKS F K okBack (fun _ _ _ => True) s S rt v :=
  ⟨fun hv => ⟨(h.1 hv).1, trivial, (h.1 hv).2⟩, fun hv a S1 hd => ⟨(h.2 hv a S1 hd).1, trivial, (h.2 hv a S1 hd).2⟩⟩

theorem BackOKS.mono {K : Ctx} {s : St F.S} {S : SSrv} {rt : Name} {v : Val} {sm sm' : SSrv → F.S → Arg → Prop}
    (hm : ∀ S x a, sm S x a → sm' S x a) (h : BackOKS F K okBack sm s S rt v) : BackOKS F K okBack sm' s S rt v :=
  ⟨fun hv => ⟨(h.1 hv).1, hm _ _ _ (h.1 hv).2.1, (h.1 hv).2.2⟩,
    fun hv a S1 hd => ⟨(h.2 hv a S1 hd).1, hm _ _ _ (h.2 hv a S1 hd).2.1, (h.2 hv a S1 hd).2.2⟩⟩

theorem BackOKS.old {K : Ctx} {s : St F.S} {S : SSrv} {rt : Name} {v : Val} {sm : SSrv → F.S → Arg → Prop}
    (h : BackOKS F K okBack sm s S rt v) : BackOK F K okBack s S rt v :=
  ⟨fun hv => ⟨(h.1 hv).1, (h.1 hv).2.2⟩, fun hv a S1 hd => ⟨(h.2 hv a S1 hd).1, (h.2 hv a S1 hd).2.2⟩⟩

/-- The continuation `F.back` on the decoded result, then the call's completion, under the smallness premise. -/
theorem back_simS {small : (Nat → F64) → SSrv → F.S → Arg → Prop} (h : RelB F FR W stk M ν K s S t C)
    (hFR : FRLaws FR) (hB : FfiBackSimS F FR okBack' small)
    (hL : FfiLawful F) (hn : s.next < Sim.bound) {name : Name} {a : Arg}
    (ha : Supp.arg (Present s) S.tab.length a) (hok : okBack' s.ffi a = true) (hsm : small ν S s.ffi a)
    (hres : ∀ r S2, interpS (F.back s.ffi a).run S = some (r, S2) → ResOK F K s S2.tab.length r)
    (hcbr : ∀ f, cbBase ≤ f → Present s (f - cbBase) → M.region f = cbBase + M.a (f - cbBase)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (Host.Ts.M.bind (F.back s.ffi a) (ffiDone F s name [a]))
      (Host.Ts.M.bind (F.back t.ffi (M.arg a)) (ffiDone F t name [M.arg a])) := by
  have hb := hB.back M ν S C s.ffi t.ffi a h.srv h.ffi hok (Supp.arg_mono (fun _ _ => trivial) (Nat.le_refl _) ha) hsm
  refine MSim.bind (MSim.withRun hb (hL.back _ _) (hL.back _ _)) ?_
  rintro M2 S2 C2 cr cr' ⟨⟨g2, hcr⟩, hrun2⟩
  have h2 := h.grow hFR g2
  have ha2 : Supp.arg (Present s) S2.tab.length a := Supp.arg_mono (fun _ h => h) g2.len ha
  have hmap : M.arg a = M2.arg a := Map.arg_agree (g2.ext.agree (A := Present s)) ha
  rw [hmap]
  exact StepPost.after g2 (ffiDone_sim (as := [a]) h2 hn (fun x hx => by
    rcases List.mem_singleton.1 hx with rfl; exact ha2) (by rw [g2.ext.region, g2.ext.a]; exact hcbr) hcr
    (hres cr S2 hrun2))

/-- **A `JSCallback` returned** `v` to the native call `name` waiting with result type `rt`, its
continuation under the smallness premise `small`. -/
theorem _root_.Host.Ts.Sim.step_ret_callbackRetS {small : (Nat → F64) → SSrv → F.S → Arg → Prop}
    (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hF : FfiSim F FR okCall okBack) (hB : FfiBackSimS F FR okBack' small) (hL : FfiLawful F) {v : Val}
    {name rt : Name} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .k (.native (.ffi .callbackRet) [.str name, .str rt]) :: fs) (hn : s.next < Sim.bound)
    (hbuf : ArgBufOK F K W s S.tab.length v) (hbool : BoolOK K rt v)
    (hok : BackOKS F K okBack' (small ν) { s with stack := fs } S rt v)
    (hcbr : ∀ f, cbBase ≤ f → Present s (f - cbBase) → M.region f = cbBase + M.a (f - cbBase)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨hts, h1⟩ := h.pop hs
  have htc : t.ctl = .ret (M.val v) := by rw [h.ctl, hc]; rfl
  have hv : Supp.val (Present s) S.tab.length v := by have := h.ctlSupp; rw [hc] at this; exact this
  have e1 : step F s = retStep F { s with stack := fs } (.k (.native (.ffi .callbackRet) [.str name, .str rt])) v := by
    simp only [step, hc, stepRet, hs]
  have e2 : step F t = retStep F { t with stack := fs.map M.frame ++ stk }
      (M.frame (.k (.native (.ffi .callbackRet) [.str name, .str rt]))) (M.val v) := by
    simp only [step, htc, stepRet, hts]
  rw [e1, e2]
  show MSim _ S C (nativeRet F { s with stack := fs } (.ffi .callbackRet) [.str name, .str rt] v)
    (nativeRet F { t with stack := fs.map M.frame ++ stk } (.ffi .callbackRet) [.str name, .str rt] (M.val v))
  simp only [nativeRet]
  refine MSim.condH _ (fun hvd => ?_) (fun hvd => ?_)
  · obtain ⟨hob, hsm, hres⟩ := hok.1 hvd
    exact back_simS (a := .null) h1 hFR hB hL hn trivial hob hsm hres hcbr
  · refine MSim.bind (MSim.withRun (decodeArg_sim h1 hF rt v hv hbuf hbool) (decodeArg_lawful _ _ _ _)
      (decodeArg_lawful _ _ _ _)) ?_
    rintro M1 S1 C1 r r' ⟨⟨rfl, g1, hs1⟩, hrun⟩
    cases r with
    | none => exact MSim.fail _ _
    | some a =>
      obtain ⟨hob, hsm, hres⟩ := hok.2 hvd a S1 hrun
      have h1' := h1.grow hFR g1
      simp only [Option.map_some]
      exact StepPost.after g1 (back_simS h1' hFR hB hL hn (hs1 a rfl) hob hsm hres
        (by rw [g1.ext.region, g1.ext.a]; exact hcbr))

/-- The continuation `F.back` on the decoded result, then the call's completion (`back_simS` without a
smallness premise). -/
theorem back_sim (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) (hB : FfiBackSim F FR okBack')
    (hL : FfiLawful F) (hn : s.next < Sim.bound) {name : Name} {a : Arg}
    (ha : Supp.arg (Present s) S.tab.length a) (hok : okBack' s.ffi a = true)
    (hres : ∀ r S2, interpS (F.back s.ffi a).run S = some (r, S2) → ResOK F K s S2.tab.length r)
    (hcbr : ∀ f, cbBase ≤ f → Present s (f - cbBase) → M.region f = cbBase + M.a (f - cbBase)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (Host.Ts.M.bind (F.back s.ffi a) (ffiDone F s name [a]))
      (Host.Ts.M.bind (F.back t.ffi (M.arg a)) (ffiDone F t name [M.arg a])) :=
  back_simS (small := fun _ _ _ _ => True) h hFR hB.toS hL hn ha hok trivial hres hcbr

/-- **A `JSCallback` returned** `v` to the native call `name` waiting with result type `rt`
(`step_ret_callbackRetS` without a smallness premise). -/
theorem _root_.Host.Ts.Sim.step_ret_callbackRet (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hF : FfiSim F FR okCall okBack) (hB : FfiBackSim F FR okBack') (hL : FfiLawful F) {v : Val}
    {name rt : Name} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .k (.native (.ffi .callbackRet) [.str name, .str rt]) :: fs) (hn : s.next < Sim.bound)
    (hbuf : ArgBufOK F K W s S.tab.length v) (hbool : BoolOK K rt v)
    (hok : BackOK F K okBack' { s with stack := fs } S rt v)
    (hcbr : ∀ f, cbBase ≤ f → Present s (f - cbBase) → M.region f = cbBase + M.a (f - cbBase)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) :=
  step_ret_callbackRetS (small := fun _ _ _ _ => True) h hFR hF hB.toS hL hc hs hn hbuf hbool hok.toS hcbr

end
end BufSim
end Host.Ts.Sim
