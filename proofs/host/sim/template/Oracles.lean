import host.sim.template.ordinary.H0
import host.sim.template.clear.H0
import host.sim.template.growth.H0
import host.sim.template.fill.H0
import host.sim.Cases
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-! Each case's oracle consists of its distinct answers (`Host.Ts.Sim.ordD`, …;
kernel checks), so it is correct at every iteration the case covers
(`Host.Ts.Sim.good_*_at`). -/

kernel_rfl ORDINARY.cover : ORDINARY.S0.oracle.all (fun q => ordD.contains q) = true
kernel_rfl CLEAR.cover : CLEAR.S0.oracle.all (fun q => clearD.contains q) = true
kernel_rfl GROWTH.cover : GROWTH.S0.oracle.all (fun q => growD.contains q) = true
kernel_rfl FILL.cover : FILL.S0.oracle.all (fun q => fillD.contains q) = true

section
variable {rest : Nat → F64} {T i tok ptok next : Nat}

theorem ORDINARY.good (hi1 : 1 ≤ i) (hT : i + 2 < T) (hrem : i % 256 ≠ 0) (h253 : i % 256 ≠ 253)
    (h254 : i % 256 ≠ 254) (htok : tok ≠ 248044) (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) ORDINARY.S0.oracle :=
  good_of_mem (good_ord_at hi1 hT hrem h253 h254 htok hTb ht) ORDINARY.cover

theorem CLEAR.good (hi1 : 1 ≤ i) (hT : i + 2 < T) (hrem : i % 256 = 0) (htok : tok ≠ 248044)
    (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) CLEAR.S0.oracle :=
  good_of_mem (good_clear_at hi1 hT hrem htok hTb ht) CLEAR.cover

theorem GROWTH.good (hi1 : 1 ≤ i) (hT : i + 2 < T) (h254 : i % 256 = 254) (htok : tok ≠ 248044)
    (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) GROWTH.S0.oracle :=
  good_of_mem (good_grow_at hi1 hT h254 htok hTb ht) GROWTH.cover

theorem FILL.good (hi1 : 1 ≤ i) (hT : i + 2 < T) (h253 : i % 256 = 253) (htok : tok ≠ 248044)
    (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) FILL.S0.oracle :=
  good_of_mem (good_fill_at hi1 hT h253 htok hTb ht) FILL.cover

end
end Host.Load.Run.Tpl
