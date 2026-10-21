import host.sim.template.final.H0
import host.sim.template.finalc0.H0
import host.sim.template.finalc1.H0
import host.sim.Cases
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-! Each final case's oracle consists of its distinct answers (`Host.Ts.Sim.finalDG`;
kernel checks), so it is correct at every iteration the case covers
(`Host.Ts.Sim.good_*_at`). -/

kernel_rfl FINAL.cover : FINAL.S0.oracle.all (fun q => finalD.contains q) = true
kernel_rfl FINALC0.cover : FINALC0.S0.oracle.all (fun q => (finalDG true false).contains q) = true
kernel_rfl FINALC1.cover : FINALC1.S0.oracle.all (fun q => (finalDG false true).contains q) = true

section
variable {rest : Nat → F64} {T i tok ptok next : Nat}

theorem FINAL.good (hi1 : 1 ≤ i) (hT : T = i + 2) (hrem : i % 256 ≠ 0) (hrem1 : (i + 1) % 256 ≠ 0)
    (htok : tok ≠ 248044) (hnext : next ≠ 248044) (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) (hn : next < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) FINAL.S0.oracle :=
  good_of_mem (good_final_at hi1 hT hrem hrem1 htok hnext hTb ht hn) FINAL.cover

theorem FINALC0.good (hi1 : 1 ≤ i) (hT : T = i + 2) (hrem : i % 256 = 0)
    (htok : tok ≠ 248044) (hnext : next ≠ 248044) (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) (hn : next < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) FINALC0.S0.oracle := by
  have h := good_finalG_at (rest := rest) (ptok := ptok) hi1 hT htok hnext hTb ht hn
  rw [show decide (i % 256 = 0) = true from decide_eq_true hrem,
    show decide ((i + 1) % 256 = 0) = false from decide_eq_false (by omega)] at h
  exact good_of_mem h FINALC0.cover

theorem FINALC1.good (hi1 : 1 ≤ i) (hT : T = i + 2) (hrem1 : (i + 1) % 256 = 0)
    (htok : tok ≠ 248044) (hnext : next ≠ 248044) (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) (hn : next < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) FINALC1.S0.oracle := by
  have h := good_finalG_at (rest := rest) (ptok := ptok) hi1 hT htok hnext hTb ht hn
  rw [show decide (i % 256 = 0) = false from decide_eq_false (by omega),
    show decide ((i + 1) % 256 = 0) = true from decide_eq_true hrem1] at h
  exact good_of_mem h FINALC1.cover

end
end Host.Load.Run.Tpl
