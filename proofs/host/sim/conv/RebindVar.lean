import host.sim.conv.Decanon
import host.sim.Upd

namespace Host.Ts.Sim
open Host.Ts

/-- Move a variable to a fresh name and bind that name to the old value. Expressions that
did not use the fresh name retain their values. -/
theorem _root_.Host.Ts.SymE.eval_rebindVar (ν : Nat → F64) {old fresh : Nat}
    (hne : old ≠ fresh) (e : SymE) (hfresh : e.noVar fresh = true) :
    (e.subst (fun v => if v = old then .var fresh else .var v)).eval
      (upd ν fresh (ν old)) = e.eval ν := by
  rw [SymE.eval_subst]
  have hv : (fun v => ((if v = old then SymE.var fresh else .var v).eval
      (upd ν fresh (ν old)))) = upd ν fresh (ν old) := by
    funext v
    by_cases he : v = old
    · subst v
      simp [SymE.eval, upd_self, upd_other ν (ν old) hne]
    · simp [he, SymE.eval]
  rw [hv, SymE.eval_upd ν fresh (ν old) e hfresh]

/-- Rebind a table variable without changing number references or their concrete images.
The new oracle may be any oracle checked at the rebound valuation. -/
theorem Srv.rebindVar {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv}
    (h : Srv M ν S C) {old fresh : Nat} (hne : old ≠ fresh)
    (htab : ∀ e ∈ S.tab, e.noVar fresh = true) {newOracle : List Ans}
    (hgood : Good (upd ν fresh (ν old)) newOracle) :
    Srv M (upd ν fresh (ν old))
      ⟨S.tab.map (fun e => e.subst (fun v => if v = old then .var fresh else .var v)), newOracle⟩ C := by
  refine ⟨fun i e he => ?_, hgood⟩
  rw [nth?_map] at he
  cases hi : nth? S.tab i with
  | none => rw [hi] at he; cases he
  | some e0 =>
    rw [hi] at he
    obtain rfl : e0.subst (fun v => if v = old then .var fresh else .var v) = e := Option.some.inj he
    rw [h.num i e0 hi, SymE.eval_rebindVar ν hne e0 (htab e0 (nth?_mem_some hi))]

/-- Rebind a source table variable in zero steps. Both states, the map, context, frames and
native relation stay the same. -/
theorem RelB.rebindVar {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t : St F.S} {S : SSrv} {C : CSrv} (h : RelB F FR W stk M ν K s S t C)
    {old fresh : Nat} (hne : old ≠ fresh) (htab : ∀ e ∈ S.tab, e.noVar fresh = true)
    {newOracle : List Ans} (hgood : Good (upd ν fresh (ν old)) newOracle) :
    RelB F FR W stk M (upd ν fresh (ν old)) K s
      ⟨S.tab.map (fun e => e.subst (fun v => if v = old then .var fresh else .var v)), newOracle⟩ t C :=
  h.withTab (by simp) (h.srv.rebindVar hne htab hgood)

end Host.Ts.Sim
