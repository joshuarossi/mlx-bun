import host.sim.footprint.HeapFfi
import host.sim.dispatch.FfiAdapt

namespace Host.Ts.Sim.HeapFoot
open Host.Ts Host.Ts.Sim Conv BufSim Disp

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
  {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}
  {okCall okCall' : F.S → Name → List Arg → Bool} {okBack okBack' : F.S → Arg → Bool}

/-- A dispatched FFI symbol call, under exactly `step_ffi_symbolP`'s operational premises. -/
theorem step_ffi_symbol_foot
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop}
    (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hF : FfiSim F FR okCall' okBack) (hC : FfiCallSim F FR okCall small) (hL : FfiLawful F)
    {a : Nat} {this : Val} {args : List Val}
    {o : Obj} {name rt : Name} {ta : Nat} {oa : Obj} {tys : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ffi .symbol) [.str name, .obj ta, .str rt]))
    (hta : s.obj? ta = some oa) (htk : oa.kind = .array tys) (hn : s.next < Sim.bound)
    (hfr : K.fr ta = none) (hbuf : ∀ v ∈ args, ArgBufOK F K W s S.tab.length v)
    (hbool : BoolsP K tys args)
    (hok : SymOK F K okCall s S name tys args)
    (hsmall : ∀ args' S1, interpS (decodeArgs F s tys args).run S = some (some args', S1) →
      small ν S1 s.ffi name args')
    (hcbr : ∀ f, cbBase ≤ f → Present s (f - cbBase) → M.region f = cbBase + M.a (f - cbBase)) :
    MSim (Post F FR W stk M ν K S C s t) S C (step F s) (step F t) := by
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  have htt : t.obj? (M.a ta) = some (M.obj oa) := h.obj? hta hfr
  have hso : Supp.vals (Present s) S.tab.length tys := by
    have := (h.obj?_supp hta).1
    rw [htk] at this
    exact this
  obtain ⟨kd, pr, ps, pv, e⟩ := oa
  simp only at htk
  subst htk
  show MSim _ S C (ffiN F s this args [.str name, .obj ta, .str rt] .symbol)
    (ffiN F t (M.val this) (M.vals args) (M.vals [.str name, .obj ta, .str rt]) .symbol)
  simp only [ffiN, Map.vals, List.map, Map.val, elemsOf, hta, htt, Map.obj, Map.kind]
  show MSim _ S C (Host.Ts.M.bind (decodeArgs F s tys args) _)
    (Host.Ts.M.bind (decodeArgs F t (M.vals tys) (M.vals args)) _)
  refine MSim.bind (MSim.withRun (decodeArgs_simP hFR hF tys args h hso (call_supp h hc).2 hbuf hbool)
    (decodeArgs_lawful _ _ _ _) (decodeArgs_lawful _ _ _ _)) ?_
  rintro M1 S1 C1 r r' ⟨⟨rfl, g1, hs1⟩, hrun⟩
  cases r with
  | none => exact MSim.fail _ _
  | some args' =>
    obtain ⟨hokc, hres⟩ := hok args' S1 hrun
    have h1 := h.grow hFR g1
    have hcall := hC.call M1 ν S1 C1 s.ffi t.ffi name args' h1.srv h1.ffi hokc
      (fun x hx => Supp.arg_mono (fun _ _ => trivial) (Nat.le_refl _) (hs1 args' rfl x hx))
      (hsmall args' S1 hrun)
    simp only [Option.map_some]
    refine MSim.bind (MSim.withRun hcall (hL.call _ _ _) (hL.call _ _ _)) ?_
    rintro M2 S2 C2 cr cr' ⟨⟨g2, hcr⟩, hrun2⟩
    have h2 := h1.grow hFR g2
    have has2 : ∀ x ∈ args', Supp.arg (Present s) S2.tab.length x :=
      fun x hx => Supp.arg_mono (fun _ hp => hp) g2.len (hs1 args' rfl x hx)
    have hmap : args'.map M1.arg = args'.map M2.arg :=
      List.map_congr_left fun x hx => Map.arg_agree (g2.ext.agree (A := Present s)) (hs1 args' rfl x hx)
    rw [hmap]
    have g := g1.trans g2
    exact Post.after g (ffiDone_foot h2 hn has2 (by rw [g.ext.region, g.ext.a]; exact hcbr) hcr
      (hres cr S2 hrun2))

/-- A native continuation followed by the actual JS buffer writes and return/callback. -/
theorem back_foot {small : (Nat → F64) → SSrv → F.S → Arg → Prop}
    (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hB : FfiBackSimS F FR okBack' small) (hL : FfiLawful F) (hn : s.next < Sim.bound)
    {name : Name} {a : Arg} (ha : Supp.arg (Present s) S.tab.length a)
    (hok : okBack' s.ffi a = true) (hsm : small ν S s.ffi a)
    (hres : ∀ r S2, interpS (F.back s.ffi a).run S = some (r, S2) → ResOK F K s S2.tab.length r)
    (hcbr : ∀ f, cbBase ≤ f → Present s (f - cbBase) → M.region f = cbBase + M.a (f - cbBase)) :
    MSim (Post F FR W stk M ν K S C s t) S C
      (Host.Ts.M.bind (F.back s.ffi a) (ffiDone F s name [a]))
      (Host.Ts.M.bind (F.back t.ffi (M.arg a)) (ffiDone F t name [M.arg a])) := by
  have hb := hB.back M ν S C s.ffi t.ffi a h.srv h.ffi hok
    (Supp.arg_mono (fun _ _ => trivial) (Nat.le_refl _) ha) hsm
  refine MSim.bind (MSim.withRun hb (hL.back _ _) (hL.back _ _)) ?_
  rintro M2 S2 C2 cr cr' ⟨⟨g2, hcr⟩, hrun2⟩
  have h2 := h.grow hFR g2
  have ha2 : Supp.arg (Present s) S2.tab.length a := Supp.arg_mono (fun _ hp => hp) g2.len ha
  have hmap : M.arg a = M2.arg a := Map.arg_agree (g2.ext.agree (A := Present s)) ha
  rw [hmap]
  exact Post.after g2 (ffiDone_foot (args := [a]) h2 hn (fun x hx => by
    rcases List.mem_singleton.1 hx with rfl; exact ha2)
    (by rw [g2.ext.region, g2.ext.a]; exact hcbr) hcr (hres cr S2 hrun2))

/-- A dispatched callback return, with the unchanged `step_ret_callbackRetS` premises. -/
theorem step_ret_callbackRet_foot {small : (Nat → F64) → SSrv → F.S → Arg → Prop}
    (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hF : FfiSim F FR okCall okBack) (hB : FfiBackSimS F FR okBack' small) (hL : FfiLawful F)
    {v : Val} {name rt : Name} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .k (.native (.ffi .callbackRet) [.str name, .str rt]) :: fs)
    (hn : s.next < Sim.bound) (hbuf : ArgBufOK F K W s S.tab.length v) (hbool : BoolOK K rt v)
    (hok : BackOKS F K okBack' (small ν) { s with stack := fs } S rt v)
    (hcbr : ∀ f, cbBase ≤ f → Present s (f - cbBase) → M.region f = cbBase + M.a (f - cbBase)) :
    MSim (Post F FR W stk M ν K S C s t) S C (step F s) (step F t) := by
  obtain ⟨hts, h1⟩ := h.pop hs
  have htc : t.ctl = .ret (M.val v) := by rw [h.ctl, hc]; rfl
  have hv : Supp.val (Present s) S.tab.length v := by have := h.ctlSupp; rw [hc] at this; exact this
  have e1 : step F s = nativeRet F { s with stack := fs } (.ffi .callbackRet) [.str name, .str rt] v := by
    simp only [step, hc, stepRet, hs, retStep, retK]
  have e2 : step F t = nativeRet F { t with stack := fs.map M.frame ++ stk }
      (.ffi .callbackRet) [.str name, .str rt] (M.val v) := by
    simp only [step, htc, stepRet, hts, retStep, retK, Map.frame, Map.fnF, Map.vals, List.map, Map.val]
  rw [e1, e2]
  apply Post.start (s0 := s) (t0 := t)
    (s := { s with stack := fs }) (t := { t with stack := fs.map M.frame ++ stk })
    (hs := ⟨rfl, rfl⟩) (ht := ⟨rfl, rfl⟩)
  simp only [nativeRet]
  refine MSim.condH _ (fun hvd => ?_) (fun hvd => ?_)
  · obtain ⟨hob, hsm, hres⟩ := hok.1 hvd
    exact back_foot (a := .null) h1 hFR hB hL hn trivial hob hsm hres hcbr
  · refine MSim.bind (MSim.withRun (decodeArg_sim h1 hF rt v hv hbuf hbool)
      (decodeArg_lawful _ _ _ _) (decodeArg_lawful _ _ _ _)) ?_
    rintro M1 S1 C1 r r' ⟨⟨rfl, g1, hs1⟩, hrun⟩
    cases r with
    | none => exact MSim.fail _ _
    | some a =>
      obtain ⟨hob, hsm, hres⟩ := hok.2 hvd a S1 hrun
      have h1' := h1.grow hFR g1
      simp only [Option.map_some]
      exact Post.after g1 (back_foot h1' hFR hB hL hn (hs1 a rfl) hob hsm hres
        (by rw [g1.ext.region, g1.ext.a]; exact hcbr))

end
end Host.Ts.Sim.HeapFoot
