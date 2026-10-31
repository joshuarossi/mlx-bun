import host.sim.footprint.HeapNative
import host.sim.dispatch.OkBack

namespace Host.Ts.Sim.HeapFoot
open Host.Ts Host.Ts.Sim Conv BufSim Disp

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
  {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx} {s t s1 t1 : St F.S}
  {S S1 : SSrv} {C C1 : CSrv} {P : JSP F}
  {okCall0 : F.S → Name → List Arg → Bool} {okBack0 okBack : F.S → Arg → Bool}

/-- Every actually accepted callback return has the JS heap footprint. -/
theorem cbRetB_foot {smallBack : (Nat → F64) → SSrv → F.S → Arg → Prop}
    (hF : FfiSim F FR okCall0 okBack0) (hB : FfiBackSimS F FR okBack smallBack)
    (hsmB : ∀ S x a, P.smallBackB S x a = true → smallBack ν S x a)
    (hFR : FRLaws FR) (hL : FfiLawful F) (hN : NativeFacts F FR P)
    (hK : Kp P K) (hW : Wp P W) (h : RelXB F FR W stk M ν K s S t C)
    (hok : cbRetB P okBack s S = true)
    (hsrun : interpS (step F s).run S = some (s1, S1))
    (htrun : interpC (step F t).run C = some (t1, C1)) : HeapStepFoot M s t s1 t1 := by
  obtain ⟨v, name, rt, fs, hc, hs, hn, h1, h2, h3⟩ := cbRetB_spec hok
  have hr : RelB F FR W stk M ν K s S t C := by
    rcases h with h | ⟨_, _, _, _, _, _, _, he, _⟩
    · exact h
    · rw [hs] at he; cases he
  have hbool : BoolOK K rt v := by
    intro hb
    simp only [hb, Bool.not_true, Bool.false_or] at h2
    exact hK.bfBig h2
  have hn' : s.next < Sim.bound := by have := next_ok hn; omega
  exact Post.foot (step_ret_callbackRet_foot hr hFR hF hB hL hc hs hn' (hK.argBuf hW h1) hbool
    ((hK.backS h3).mono hsmB) (fun f hf _ => hN.cb M _ _ _ hr.ffi f hf)) hsrun htrun

/-- A symbol call accepted by the dispatcher's existing positional argument checks. -/
theorem symCallB_foot {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop}
    (hF : FfiSim F FR okCall0 okBack0) (hC : FfiCallSim F FR P.okCall small)
    (hsm : ∀ S x name args, P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : FfiLawful F) (hN : NativeFacts F FR P)
    (hK : Kp P K) (hW : Wp P W) (h : RelXB F FR W stk M ν K s S t C)
    {a : Nat} {this : Val} {args data : List Val} {o : Obj}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ffi .symbol) data)) (hn : s.next < Sim.bound)
    (hok : symCallB P s S S.tab.length data args = true)
    (hsrun : interpS (step F s).run S = some (s1, S1))
    (htrun : interpC (step F t).run C = some (t1, C1)) : HeapStepFoot M s t s1 t1 := by
  have h := RelXB.rel h (by intro v he; rw [hc] at he; cases he)
  obtain ⟨name, rt, ta, oa, tys, rfl, hoa, htys, h1, h2, h3, h4⟩ := symCallB_spec hok
  exact Post.foot (step_ffi_symbol_foot h hFR hF hC hL hc ho hk hoa htys hn (hK.fr_none h1)
    (fun v hv => hK.argBuf hW (allB_sound h2 v hv)) (hK.boolsP h3) (symOKB_sound hK h4)
    (fun args' S' hr => hsm _ _ _ _ (symOKB_small h4 args' S' hr))
    (fun f hf _ => hN.cb M _ _ _ h.ffi f hf)) hsrun htrun

end
end Host.Ts.Sim.HeapFoot
