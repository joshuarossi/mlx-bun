import host.sim.dispatch.Ev
import host.sim.dispatch.Ex
import host.sim.dispatch.Ret
import host.sim.dispatch.Abr
import host.sim.dispatch.Bind
import host.sim.dispatch.Call
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # The acceptance function and the one-step theorem

`okJS P s S` decides, for a source state, which step kind it is (mirroring
`step`: the control constructor, the expression or statement, the top frame, the
callee's kind or builtin) and whether that kind has a step lemma whose source-side
side conditions hold; it also bounds the heap counter (`s.next + margin < bound`).

`stepSimXV` is the one-step obligation for `okJS P`, for valuations satisfying a
predicate `VBOk` (`StepSimXV`: `StepSimX` with `VBOk ν`), given the native
interface (`FfiSim` for buffer reads, `FfiCallSim` with smallness premise `small`
for calls, `FRLaws`, `FfiLawful`), the soundness of the smallness decider `P.smallB`
under `VBOk`, and the map facts `NativeFacts`. `runOk_simXV` is `runOk_simX` for it. -/

section
variable {F : Ffi}

def okCtl (P : JSP F) (s : St F.S) (S : SSrv) : Bool :=
  match s.ctl with
  | .ev e env => okEv P s e env
  | .ex st _ => okEx s st
  | .ret v => okRet P s S.tab.length v s.stack
  | .abr _ => okAbr P s S.tab.length s.stack
  | .call f this args => okCallB P s S S.tab.length f this args
  | .construct f args _ => okConsB P s S S.tab.length f args
  | .bind p v env mode _ => okBind P s S.tab.length p v env mode
  | .short => true
  | .halt _ => true

/-- The acceptance function of the checked runs. -/
def okJS (P : JSP F) (s : St F.S) (S : SSrv) : Bool :=
  Nat.blt s.next nextMax && okCtl P s S

variable {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F}

theorem dispatch {okCall0 : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} (hF : FfiSim F FR okCall0 okBack)
    (hC : FfiCallSim F FR P.okCall small) (hsm : ∀ S x name args, P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hK : Kp P K) (h : Rel F FR M ν K s S t C)
    (hh : isHalt s.ctl = false) (hok : okJS P s S = true) :
    MSim (PX F FR M ν K S C) S C (step F s) (step F t) := by
  simp only [okJS, Bool.and_eq_true] at hok
  have hn := next_ok hok.1
  have hk := hok.2
  unfold okCtl at hk
  cases hc : s.ctl with
  | ev e env => rw [hc] at hk; exact simEv hF hK h hc hn hk
  | ex st env => rw [hc] at hk; exact simEx h hc hn hk
  | ret v => rw [hc] at hk; exact simRet hF hFR hK hN h hc hn hk
  | abr a => rw [hc] at hk; exact simAbr hF hK h hc hn hk
  | call f this args => rw [hc] at hk; exact simCall hF hC hsm hFR hL hK hN h hc hn hk
  | construct f args nt => rw [hc] at hk; exact simCons hF hFR hK hN h hc hn hk
  | bind p v env mode kind => rw [hc] at hk; exact simBind hF hK h hc hn hk
  | short => exact MSim.toX (step_short h hc)
  | halt c => rw [hc] at hh; exact absurd hh (by simp [isHalt])

end

/-- `StepSimX` for the valuations satisfying `VBOk`. -/
def StepSimXV (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool) (Kp : Ctx → Prop)
    (VBOk : (Nat → F64) → Prop) : Prop :=
  ∀ M ν K s S t C s1 S1, Kp K → VBOk ν → RelX F FR M ν K s S t C →
    isHalt s.ctl = false → ok s S = true → interpS (step F s).run S = some (s1, S1) → ok s1 S1 = true →
    ∃ M' t1 C1, interpC (step F t).run C = some (t1, C1) ∧ Ext M M' S.tab.length ∧
      RelX F FR M' ν K s1 S1 t1 C1

/-- `runOk_simX` for `StepSimXV`. -/
theorem runOk_simXV (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool)
    (Kp : Ctx → Prop) (VBOk : (Nat → F64) → Prop) (hsim : StepSimXV F FR ok Kp VBOk) (ν : Nat → F64) (K : Ctx)
    (hK : Kp K) (hν : VBOk ν) :
    ∀ n M s S t C s' S', RelX F FR M ν K s S t C → ok s S = true → runOk F ok n s S = some (s', S') →
      ∃ M' t' C', runC F n t C = some (t', C') ∧ Ext M M' S.tab.length ∧
        RelX F FR M' ν K s' S' t' C' := by
  intro n
  induction n with
  | zero =>
    intro M s S t C s' S' hr _ h
    simp only [runOk_zero, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    exact ⟨M, t, C, rfl, Ext.refl _ _, hr⟩
  | succ n ih =>
    intro M s S t C s' S' hr hok h
    rw [runOk_succ] at h
    cases hh : isHalt s.ctl
    · simp only [hh, Bool.cond_false] at h
      cases hs : interpS (step F s).run S with
      | none => simp [hs] at h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hs] at h
        cases hk : ok s1 S1
        · simp [hk] at h
        · simp only [hk, Bool.cond_true, St.rebuild_eq] at h
          obtain ⟨M1, t1, C1, ht, he1, hr1⟩ := hsim M ν K s S t C s1 S1 hK hν hr hh hok hs hk
          obtain ⟨M', t', C', ht', he', hr'⟩ := ih M1 s1 S1 t1 C1 s' S' hr1 hk h
          refine ⟨M', t', C', ?_, he1.trans he' (interpS_len _ _ _ _ hs), hr'⟩
          simp only [runC, runWith_succ, hr.isHalt, hh, Bool.cond_false, ht, St.rebuild_eq]
          exact ht'
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      refine ⟨M, t, C, ?_, Ext.refl _ _, hr⟩
      simp only [runC, runWith_succ, hr.isHalt, hh, Bool.cond_true]

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {P : JSP F}

/-- The one-step simulation of the checked runs. -/
theorem stepSimXV {okCall0 : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) :
    StepSimXV F FR (okJS P) (Kp P) VBOk := by
  intro M ν K s S t C s1 S1 hK hν hr hh hok hs _
  rcases hr with hr | hd
  · obtain ⟨M', t1, C1, ht, hg, hr1⟩ :=
      MSim.run (dispatch hF hC (hsmall ν · · · · hν) hFR hL hN hK hr hh hok) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, hr1⟩
  · have e := RelD.step_eq hd
    obtain ⟨v, v', r, env, fs, hc, _, hstk, hr⟩ := hd
    rw [e]
    obtain ⟨M', t1, C1, ht, hg, hr1⟩ := MSim.run (step_ret_block hr hc hstk) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, .inl hr1⟩

end
end Host.Ts.Sim.Disp
