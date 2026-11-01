import host.sim.State
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim

/-! # Padding a table

Fresh entries at the images of their values: the relation is unchanged, the map only grows. -/

theorem relB_pad {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {ν : Nat → F64}
    {K : Ctx} {s t : St F.S} {C : CSrv}
    (hstable : ∀ M M' n x y, FR M n x y → Ext M M' n → FR M' n x y)
    (hmono : ∀ M n n' x y, FR M n x y → n ≤ n' → FR M n' x y) :
    ∀ (pad : List SymE) {M : Map} {S : SSrv}, RelB F FR W stk M ν K s S t C →
      ∃ M', Ext M M' S.tab.length ∧ RelB F FR W stk M' ν K s { S with tab := S.tab ++ pad } t C
  | [], M, S, h => by
    refine ⟨M, Ext.refl _ _, ?_⟩
    simpa using h
  | e :: rest, M, S, h => by
    have hext := M.setNum_ext S.tab.length (.lit (e.eval ν))
    have hsrv : Srv (M.setNum S.tab.length (.lit (e.eval ν))) ν { S with tab := S.tab ++ [e] } C := by
      refine ⟨?_, h.srv.good⟩
      intro i e' hi
      rcases nth?_append_eq S.tab e i e' hi with ⟨hlt, hi'⟩ | ⟨rfl, rfl⟩
      · rw [hext.num i hlt]
        exact h.srv.num i e' hi'
      · rw [M.setNum_self]
        rfl
    have h1 : RelB F FR W stk (M.setNum S.tab.length (.lit (e.eval ν))) ν K s { S with tab := S.tab ++ [e] } t C :=
      h.extend hext hsrv (by simp) hstable hmono
    obtain ⟨M2, he, h2⟩ := relB_pad hstable hmono rest h1
    refine ⟨M2, hext.trans he (by simp), ?_⟩
    simpa [List.append_assoc] using h2

end Host.Ts.Sim.Compose
