import host.sim.footprint.HeapBasic

namespace Host.Ts.Sim.HeapFoot
open Host.Ts Host.Ts.Sim Conv
open Host.Mlx.Ffi.FullKeep (AllX)

/-- Returning to a statement list changes only control and stack. -/
theorem step_block_same (F : Ffi) {s : St F.S} {v : Val} {rest : List Stmt} {env : Env}
    {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .s (.block rest env) :: fs) :
    AllX (Same s) (step F s) := by
  have e : step F s = retSt F { s with stack := fs } (.block rest env) v := by
    simp only [step, hc, stepRet, hs, retStep]
  rw [e]
  cases rest <;> exact AllX.pure ⟨rfl, rfl⟩

/-- Statement-list returns have the footprint even when their discarded values differ. -/
theorem step_ret_block_foot {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t s1 t1 : St F.S} {S S1 : SSrv} {C C1 : CSrv}
    (h : RelXB F FR W stk M ν K s S t C) {v : Val} {rest : List Stmt} {env : Env} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .s (.block rest env) :: fs)
    (hsrun : interpS (step F s).run S = some (s1, S1))
    (htrun : interpC (step F t).run C = some (t1, C1)) : HeapStepFoot M s t s1 t1 := by
  have ht : ∃ v' rest' env' fs', t.ctl = .ret v' ∧ t.stack = .s (.block rest' env') :: fs' := by
    rcases h with h | ⟨v0, v', rest', env', fs', _, htc, hss, hr⟩
    · refine ⟨M.val v, rest, M.env env, fs.map M.frame ++ stk, ?_, ?_⟩
      · rw [h.ctl, hc]; rfl
      · rw [h.stack, hs]; rfl
    · refine ⟨v', rest', M.env env', fs'.map M.frame ++ stk, htc, ?_⟩
      rw [hr.stack, hss]
      rfl
  obtain ⟨v', rest', env', fs', htc, hts⟩ := ht
  exact same_foot ((step_block_same F hc hs).1 S s1 S1 hsrun)
    ((step_block_same F htc hts).2 C t1 C1 htrun)

/-- The dispatcher's delayed-value branch needs no heap or native premises. -/
theorem delayed_foot {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t s1 t1 : St F.S} {S S1 : SSrv} {C C1 : CSrv}
    (h : RelDB F FR W stk M ν K s S t C)
    (hsrun : interpS (step F s).run S = some (s1, S1))
    (htrun : interpC (step F t).run C = some (t1, C1)) : HeapStepFoot M s t s1 t1 := by
  have h0 := h
  obtain ⟨v, _, rest, env, fs, hc, _, hs, _⟩ := h0
  exact step_ret_block_foot (.inr h) hc hs hsrun htrun

end Host.Ts.Sim.HeapFoot
