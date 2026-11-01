import host.sim.Rel
import host.sim.template.EndGen
set_option autoImplicit false
namespace Host.Ts.Sim
open Host.Ts

/-! # Rewriting a server's table where its values agree

The relation reads a table entry only through its value at the valuation: `RelB.retab` replaces entries of equal value. A decode iteration's
end can so read an abstracted conv dim as its variable again, keeping the iteration's `θ` the identity there. -/

/-- **The relation at another table of the same values.** -/
theorem RelB.retab {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Ctx} {s : St F.S} {S S' : SSrv} {t : St F.S} {C : CSrv} (h : RelB F FR W stk M ν K s S t C)
    (hlen : S'.tab.length = S.tab.length) (hor : S'.oracle = S.oracle)
    (hev : ∀ i e', nth? S'.tab i = some e' → ∃ e, nth? S.tab i = some e ∧ e.eval ν = e'.eval ν) :
    RelB F FR W stk M ν K s S' t C := by
  refine { h with
    srv := ⟨fun i e' he' => ?_, by rw [hor]; exact h.srv.good⟩
    ffi := by rw [hlen]; exact h.ffi
    heapSupp := by rw [hlen]; exact h.heapSupp
    ctlSupp := by rw [hlen]; exact h.ctlSupp
    stackSupp := by rw [hlen]; exact h.stackSupp
    jobsSupp := by rw [hlen]; exact h.jobsSupp
    storesSupp := by rw [hlen]; exact h.storesSupp
    traceSupp := by rw [hlen]; exact h.traceSupp }
  obtain ⟨e, he, hv⟩ := hev i e' he'
  rw [← hv]
  exact h.srv.num i e he

kernel_rfl conv_value : F64.un .int32 (F64.bin .sub (F64.bin .add (F64.ofNat 3) (F64.ofNat 1)) (F64.ofNat 1)) = F64.ofNat 3

/-- A conv cache's length after an iteration is its variable, at the value `3`. -/
theorem conv_entry_eval {ν : Nat → F64} {j : Nat} (h : ν j = F64.ofNat 3) :
    (SymE.un .int32 (.bin .sub (.bin .add (.var j) (.lit (F64.ofNat 1))) (.lit (F64.ofNat 1)))).eval ν = (SymE.var j).eval ν := by
  simp only [SymE.eval, h]
  exact conv_value

end Host.Ts.Sim
