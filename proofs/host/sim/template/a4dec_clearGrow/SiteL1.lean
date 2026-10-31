import host.sim.template.a4dec_clearGrow.Site1
import host.sim.template.a4dec_clearGrow.SiteF1
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 1 of chain `DEC_clearGrow`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `DEC_clearGrow.s5`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl DEC_clearGrow.srvO1 : DEC_clearGrow.st1.S0.oracle = DEC_clearGrow.st1.O
theorem DEC_clearGrow.wr0B1 : DEC_clearGrow.st1.wr.all (fun b => !Nat.blt b DEC_clearGrow.st1.s0.next || (DEC_clearGrow.st1.s0.heap.get b).isSome) = true :=
  footW_lowAll (Nat.ble_eq.mpr (Nat.le_refl _)) DEC_clearGrow.st1.wr0Old
theorem DEC_clearGrow.stFoot1 : Conv.StageFoot DEC_clearGrow.st1.wr DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s153 := DEC_clearGrow.st1.stFoot

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem DEC_clearGrow.merged1 {FR : Map → Nat → DEC_clearGrow.st1.F.S → DEC_clearGrow.st1.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St DEC_clearGrow.st1.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB DEC_clearGrow.st1.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) DEC_clearGrow.rs1 DEC_clearGrow.st1.wr DEC_clearGrow.s4 DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0
      DEC_clearGrow.st1.s153.ffi) S t C) : RelB DEC_clearGrow.st1.F FR W stk M ν K DEC_clearGrow.s5 S t C :=
  merged_relB DEC_clearGrow.iso1 DEC_clearGrow.stFoot1 DEC_clearGrow.wrNodup1 DEC_clearGrow.wrBound1 DEC_clearGrow.trace1 DEC_clearGrow.mheap1
    DEC_clearGrow.mnext1 DEC_clearGrow.mctl1 DEC_clearGrow.mstack1 DEC_clearGrow.mjobs1 DEC_clearGrow.mffi1 DEC_clearGrow.mtrace1 DEC_clearGrow.mstores1 h

def DEC_clearGrow.arrEl1_2673448 : List Val := [(Val.num (NumV.ref 79))]
kernel_rfl DEC_clearGrow.arrE1_2673448 : arrOf DEC_clearGrow.s5 2673448 = arrOf DEC_clearGrow.s0 2673448 ++ DEC_clearGrow.arrEl1_2673448
kernel_rfl DEC_clearGrow.arrA1_2673448 : isArrB DEC_clearGrow.s5 2673448 = true
theorem DEC_clearGrow.arr1_2673448 : ∃ o, DEC_clearGrow.s5.heap.get 2673448 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearGrow.s0 2673448 ++ DEC_clearGrow.arrEl1_2673448) :=
  arrExt_of DEC_clearGrow.arrE1_2673448 DEC_clearGrow.arrA1_2673448
kernel_rfl DEC_clearGrow.arrN1_2673448 : numRefsB DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl1_2673448 = true
theorem DEC_clearGrow.arrR1_2673448 : Prefill.NumRefs DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl1_2673448 := numRefs_of DEC_clearGrow.arrN1_2673448

def DEC_clearGrow.arrEl1_12504 : List Val := [(Val.num (NumV.ref 79))]
kernel_rfl DEC_clearGrow.arrE1_12504 : arrOf DEC_clearGrow.s5 12504 = arrOf DEC_clearGrow.s0 12504 ++ DEC_clearGrow.arrEl1_12504
kernel_rfl DEC_clearGrow.arrA1_12504 : isArrB DEC_clearGrow.s5 12504 = true
theorem DEC_clearGrow.arr1_12504 : ∃ o, DEC_clearGrow.s5.heap.get 12504 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearGrow.s0 12504 ++ DEC_clearGrow.arrEl1_12504) :=
  arrExt_of DEC_clearGrow.arrE1_12504 DEC_clearGrow.arrA1_12504
kernel_rfl DEC_clearGrow.arrN1_12504 : numRefsB DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl1_12504 = true
theorem DEC_clearGrow.arrR1_12504 : Prefill.NumRefs DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl1_12504 := numRefs_of DEC_clearGrow.arrN1_12504

def DEC_clearGrow.arrEl1_2665 : List Val := []
kernel_rfl DEC_clearGrow.arrE1_2665 : arrOf DEC_clearGrow.s5 2665 = arrOf DEC_clearGrow.s0 2665 ++ DEC_clearGrow.arrEl1_2665
kernel_rfl DEC_clearGrow.arrA1_2665 : isArrB DEC_clearGrow.s5 2665 = true
theorem DEC_clearGrow.arr1_2665 : ∃ o, DEC_clearGrow.s5.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearGrow.s0 2665 ++ DEC_clearGrow.arrEl1_2665) :=
  arrExt_of DEC_clearGrow.arrE1_2665 DEC_clearGrow.arrA1_2665
kernel_rfl DEC_clearGrow.arrN1_2665 : numRefsB DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl1_2665 = true
theorem DEC_clearGrow.arrR1_2665 : Prefill.NumRefs DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl1_2665 := numRefs_of DEC_clearGrow.arrN1_2665

kernel_rfl DEC_clearGrow.w4910k1 : isArrB DEC_clearGrow.s5 4910 = false
theorem DEC_clearGrow.keep1 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP DEC_clearGrow.s0 q) DEC_clearGrow.s5 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of DEC_clearGrow.w4910k1 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := DEC_clearGrow.arr1_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [DEC_clearGrow.arrEl1_2665]

end Host.Load.Run.Tpl
