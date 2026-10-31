import host.sim.full.BridgeJs

namespace Host.Ts.Sim
open Host.Ts

/-- Append one symbolic entry and its concrete image without running either machine. -/
theorem Srv.appendNum {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {v : NumV} {e : SymE}
    (h : Srv M ν S C) (hv : C.val v = some (e.eval ν)) :
    Srv (M.setNum S.tab.length v) ν ⟨S.tab ++ [e], S.oracle⟩ C := by
  refine ⟨fun i q hq => ?_, h.good⟩
  rcases nth?_append_eq S.tab e i q hq with ⟨hi, hq⟩ | ⟨rfl, rfl⟩
  · rw [(Map.setNum_ext M S.tab.length v).num i hi]
    exact h.num i q hq
  · rw [Map.setNum_self]
    exact hv

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame}
  {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} {v : NumV}

/-- Abstract a numeric return by one fresh table reference. The target state is unchanged. -/
theorem RelB.abstractRetNum (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .ret (.num v)) {e : SymE} (hv : C.val (M.nv v) = some (e.eval ν)) :
    RelB F FR W stk (M.setNum S.tab.length (M.nv v)) ν K
      (s.ret (.num (.ref S.tab.length))) ⟨S.tab ++ [e], S.oracle⟩ t C := by
  have h' := h.extend (Map.setNum_ext M S.tab.length (M.nv v)) (h.srv.appendNum hv)
    (by simp) hFR.stable hFR.mono
  refine { h' with ctl := ?_, ctlSupp := ?_ }
  · change t.ctl = .ret (.num ((M.setNum S.tab.length (M.nv v)).num S.tab.length))
    rw [Map.setNum_self, h.ctl, hc]
    rfl
  · change S.tab.length < (S.tab ++ [e]).length
    simp

/-- Abstract a numeric return into a fresh variable, binding only that variable's valuation. -/
theorem RelB.abstractRetVar (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .ret (.num v)) {j : Nat} {x : F64}
    (htab : ∀ e ∈ S.tab, e.noVar j = true) (hor : ∀ q ∈ S.oracle, q.noVar j = true)
    (hv : C.val (M.nv v) = some x) :
    RelB F FR W stk (M.setNum S.tab.length (M.nv v)) (upd ν j x) K
      (s.ret (.num (.ref S.tab.length))) ⟨S.tab ++ [.var j], S.oracle⟩ t C := by
  have hν : Srv M (upd ν j x) S C := by
    refine ⟨fun i e he => ?_, good_upd h.srv.good hor⟩
    rw [h.srv.num i e he, SymE.eval_upd ν j x e (htab e (nth?_mem_some he))]
  have h' : RelB F FR W stk M (upd ν j x) K s S t C := { h with srv := hν }
  exact h'.abstractRetNum hFR hc (by simpa only [SymE.eval, upd_self] using hv)

/-- The literal-return case needs only freshness of the new variable. -/
theorem RelB.abstractRetLit (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    {x : F64} (hc : s.ctl = .ret (.num (.lit x))) {j : Nat}
    (htab : ∀ e ∈ S.tab, e.noVar j = true) (hor : ∀ q ∈ S.oracle, q.noVar j = true) :
    RelB F FR W stk (M.setNum S.tab.length (.lit x)) (upd ν j x) K
      (s.ret (.num (.ref S.tab.length))) ⟨S.tab ++ [.var j], S.oracle⟩ t C :=
  h.abstractRetVar hFR hc htab hor rfl

/-- Numeric return abstraction preserves the JavaScript pointer law. -/
theorem RelB.abstractRetVarJ (h : RelB F (Disp.FRJ FR) W stk M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .ret (.num v)) {j : Nat} {x : F64}
    (htab : ∀ e ∈ S.tab, e.noVar j = true) (hor : ∀ q ∈ S.oracle, q.noVar j = true)
    (hv : C.val (M.nv v) = some x) :
    RelB F (Disp.FRJ FR) W stk (M.setNum S.tab.length (M.nv v)) (upd ν j x) K
      (s.ret (.num (.ref S.tab.length))) ⟨S.tab ++ [.var j], S.oracle⟩ t C :=
  (h.ofJ.abstractRetVar hFR hc htab hor hv).toJ (h.ffi.2.ext (Map.setNum_ext M S.tab.length (M.nv v)))

/-- A literal return becomes a variable reference under `FRJ` in zero target steps. -/
theorem RelB.abstractRetLitJ (h : RelB F (Disp.FRJ FR) W stk M ν K s S t C) (hFR : FRLaws FR)
    {x : F64} (hc : s.ctl = .ret (.num (.lit x))) {j : Nat}
    (htab : ∀ e ∈ S.tab, e.noVar j = true) (hor : ∀ q ∈ S.oracle, q.noVar j = true) :
    RelB F (Disp.FRJ FR) W stk (M.setNum S.tab.length (.lit x)) (upd ν j x) K
      (s.ret (.num (.ref S.tab.length))) ⟨S.tab ++ [.var j], S.oracle⟩ t C :=
  h.abstractRetVarJ hFR hc htab hor rfl

end
end Host.Ts.Sim
