import host.sim.template.eosx.H0
import host.sim.template.finale.H0
import host.sim.template.finalec0.H0
import host.sim.CasesEos
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-! Each EOS case's oracle consists of its distinct answers (`Host.Ts.Sim.eosD`,
`Host.Ts.Sim.finalEDG`; kernel checks), so it is correct at every iteration the case covers
(`Host.Ts.Sim.good_eos_at`, `Host.Ts.Sim.good_finalE_at`). -/

kernel_rfl EOSX.cover : EOSX.S0.oracle.all (fun q => eosD.contains q) = true
kernel_rfl FINALE.cover : FINALE.S0.oracle.all (fun q => (finalEDG false).contains q) = true
kernel_rfl FINALEC0.cover : FINALEC0.S0.oracle.all (fun q => (finalEDG true).contains q) = true

section
variable {rest : Nat → F64} {T i tok ptok next : Nat}

theorem EOSX.good (hi1 : 1 ≤ i) (htok : tok = 248044) (hib : i < 2 ^ 30) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) EOSX.S0.oracle :=
  good_of_mem (good_eos_at hi1 htok hib) EOSX.cover

theorem FINALE.good (hi1 : 1 ≤ i) (hT : T = i + 2) (hrem : i % 256 ≠ 0) (htok : tok ≠ 248044)
    (hnext : next = 248044) (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) FINALE.S0.oracle := by
  have h := good_finalE_at (rest := rest) (ptok := ptok) hi1 hT htok hnext hTb ht
  rw [show decide (i % 256 = 0) = false from decide_eq_false hrem] at h
  exact good_of_mem h FINALE.cover

theorem FINALEC0.good (hi1 : 1 ≤ i) (hT : T = i + 2) (hrem : i % 256 = 0) (htok : tok ≠ 248044)
    (hnext : next = 248044) (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) FINALEC0.S0.oracle := by
  have h := good_finalE_at (rest := rest) (ptok := ptok) hi1 hT htok hnext hTb ht
  rw [show decide (i % 256 = 0) = true from decide_eq_true hrem] at h
  exact good_of_mem h FINALEC0.cover

end
end Host.Load.Run.Tpl
