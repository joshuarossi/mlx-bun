import host.sim.template.a4dec_ord.Site1
import host.sim.template.a4dec_ord.SiteF1
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 1 of chain `DEC_ord`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `DEC_ord.s5`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl DEC_ord.srvO1 : DEC_ord.st1.S0.oracle = DEC_ord.st1.O
theorem DEC_ord.wr0B1 : DEC_ord.st1.wr.all (fun b => !Nat.blt b DEC_ord.st1.s0.next || (DEC_ord.st1.s0.heap.get b).isSome) = true :=
  footW_lowAll (Nat.ble_eq.mpr (Nat.le_refl _)) DEC_ord.st1.wr0Old
theorem DEC_ord.stFoot1 : Conv.StageFoot DEC_ord.st1.wr DEC_ord.st1.s0 DEC_ord.st1.s150 := DEC_ord.st1.stFoot

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem DEC_ord.merged1 {FR : Map → Nat → DEC_ord.st1.F.S → DEC_ord.st1.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St DEC_ord.st1.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB DEC_ord.st1.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) DEC_ord.rs1 DEC_ord.st1.wr DEC_ord.s4 DEC_ord.st1.s150 DEC_ord.st1.s0
      DEC_ord.st1.s150.ffi) S t C) : RelB DEC_ord.st1.F FR W stk M ν K DEC_ord.s5 S t C :=
  merged_relB DEC_ord.iso1 DEC_ord.stFoot1 DEC_ord.wrNodup1 DEC_ord.wrBound1 DEC_ord.trace1 DEC_ord.mheap1
    DEC_ord.mnext1 DEC_ord.mctl1 DEC_ord.mstack1 DEC_ord.mjobs1 DEC_ord.mffi1 DEC_ord.mtrace1 DEC_ord.mstores1 h

def DEC_ord.arrEl1_2673448 : List Val := [(Val.num (NumV.ref 79))]
kernel_rfl DEC_ord.arrE1_2673448 : arrOf DEC_ord.s5 2673448 = arrOf DEC_ord.s0 2673448 ++ DEC_ord.arrEl1_2673448
kernel_rfl DEC_ord.arrA1_2673448 : isArrB DEC_ord.s5 2673448 = true
theorem DEC_ord.arr1_2673448 : ∃ o, DEC_ord.s5.heap.get 2673448 = some (.obj o) ∧ o.kind = .array (arrOf DEC_ord.s0 2673448 ++ DEC_ord.arrEl1_2673448) :=
  arrExt_of DEC_ord.arrE1_2673448 DEC_ord.arrA1_2673448
kernel_rfl DEC_ord.arrN1_2673448 : numRefsB DEC_ord.S0.tab.length DEC_ord.arrEl1_2673448 = true
theorem DEC_ord.arrR1_2673448 : Prefill.NumRefs DEC_ord.S0.tab.length DEC_ord.arrEl1_2673448 := numRefs_of DEC_ord.arrN1_2673448

def DEC_ord.arrEl1_12504 : List Val := [(Val.num (NumV.ref 79))]
kernel_rfl DEC_ord.arrE1_12504 : arrOf DEC_ord.s5 12504 = arrOf DEC_ord.s0 12504 ++ DEC_ord.arrEl1_12504
kernel_rfl DEC_ord.arrA1_12504 : isArrB DEC_ord.s5 12504 = true
theorem DEC_ord.arr1_12504 : ∃ o, DEC_ord.s5.heap.get 12504 = some (.obj o) ∧ o.kind = .array (arrOf DEC_ord.s0 12504 ++ DEC_ord.arrEl1_12504) :=
  arrExt_of DEC_ord.arrE1_12504 DEC_ord.arrA1_12504
kernel_rfl DEC_ord.arrN1_12504 : numRefsB DEC_ord.S0.tab.length DEC_ord.arrEl1_12504 = true
theorem DEC_ord.arrR1_12504 : Prefill.NumRefs DEC_ord.S0.tab.length DEC_ord.arrEl1_12504 := numRefs_of DEC_ord.arrN1_12504

def DEC_ord.arrEl1_2665 : List Val := []
kernel_rfl DEC_ord.arrE1_2665 : arrOf DEC_ord.s5 2665 = arrOf DEC_ord.s0 2665 ++ DEC_ord.arrEl1_2665
kernel_rfl DEC_ord.arrA1_2665 : isArrB DEC_ord.s5 2665 = true
theorem DEC_ord.arr1_2665 : ∃ o, DEC_ord.s5.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf DEC_ord.s0 2665 ++ DEC_ord.arrEl1_2665) :=
  arrExt_of DEC_ord.arrE1_2665 DEC_ord.arrA1_2665
kernel_rfl DEC_ord.arrN1_2665 : numRefsB DEC_ord.S0.tab.length DEC_ord.arrEl1_2665 = true
theorem DEC_ord.arrR1_2665 : Prefill.NumRefs DEC_ord.S0.tab.length DEC_ord.arrEl1_2665 := numRefs_of DEC_ord.arrN1_2665

kernel_rfl DEC_ord.w4910k1 : isArrB DEC_ord.s5 4910 = false
theorem DEC_ord.keep1 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP DEC_ord.s0 q) DEC_ord.s5 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of DEC_ord.w4910k1 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := DEC_ord.arr1_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [DEC_ord.arrEl1_2665]

end Host.Load.Run.Tpl
