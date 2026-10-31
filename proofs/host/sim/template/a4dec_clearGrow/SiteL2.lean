import host.sim.template.a4dec_clearGrow.Site2
import host.sim.template.a4dec_clearGrow.SiteF2
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 2 of chain `DEC_clearGrow`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `DEC_clearGrow.s9`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl DEC_clearGrow.srvO2 : DEC_clearGrow.st2.S0.oracle = DEC_clearGrow.st2.O
kernel_rfl DEC_clearGrow.wr0B2 : DEC_clearGrow.st2.wr.all (fun b => !Nat.blt b DEC_clearGrow.st2.s0.next || (DEC_clearGrow.st2.s0.heap.get b).isSome) = true
theorem DEC_clearGrow.stFoot2 : Conv.StageFoot DEC_clearGrow.st2.wr DEC_clearGrow.st2.s0 DEC_clearGrow.st2.s2 :=
  stageFoot_of DEC_clearGrow.st2.heapFoot DEC_clearGrow.wrNodup2 DEC_clearGrow.wrBound2 DEC_clearGrow.wr0B2 DEC_clearGrow.st2.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem DEC_clearGrow.merged2 {FR : Map → Nat → DEC_clearGrow.st2.F.S → DEC_clearGrow.st2.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St DEC_clearGrow.st2.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB DEC_clearGrow.st2.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) DEC_clearGrow.rs2 DEC_clearGrow.st2.wr DEC_clearGrow.s8 DEC_clearGrow.st2.s2 DEC_clearGrow.st2.s0
      DEC_clearGrow.st2.s2.ffi) S t C) : RelB DEC_clearGrow.st2.F FR W stk M ν K DEC_clearGrow.s9 S t C :=
  merged_relB DEC_clearGrow.iso2 DEC_clearGrow.stFoot2 DEC_clearGrow.wrNodup2 DEC_clearGrow.wrBound2 DEC_clearGrow.trace2 DEC_clearGrow.mheap2
    DEC_clearGrow.mnext2 DEC_clearGrow.mctl2 DEC_clearGrow.mstack2 DEC_clearGrow.mjobs2 DEC_clearGrow.mffi2 DEC_clearGrow.mtrace2 DEC_clearGrow.mstores2 h

def DEC_clearGrow.arrEl2_2673448 : List Val := []
kernel_rfl DEC_clearGrow.arrE2_2673448 : arrOf DEC_clearGrow.s9 2673448 = arrOf DEC_clearGrow.s0 2673448 ++ DEC_clearGrow.arrEl2_2673448
kernel_rfl DEC_clearGrow.arrA2_2673448 : isArrB DEC_clearGrow.s9 2673448 = true
theorem DEC_clearGrow.arr2_2673448 : ∃ o, DEC_clearGrow.s9.heap.get 2673448 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearGrow.s0 2673448 ++ DEC_clearGrow.arrEl2_2673448) :=
  arrExt_of DEC_clearGrow.arrE2_2673448 DEC_clearGrow.arrA2_2673448
kernel_rfl DEC_clearGrow.arrN2_2673448 : numRefsB DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl2_2673448 = true
theorem DEC_clearGrow.arrR2_2673448 : Prefill.NumRefs DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl2_2673448 := numRefs_of DEC_clearGrow.arrN2_2673448

def DEC_clearGrow.arrEl2_12504 : List Val := []
kernel_rfl DEC_clearGrow.arrE2_12504 : arrOf DEC_clearGrow.s9 12504 = arrOf DEC_clearGrow.s0 12504 ++ DEC_clearGrow.arrEl2_12504
kernel_rfl DEC_clearGrow.arrA2_12504 : isArrB DEC_clearGrow.s9 12504 = true
theorem DEC_clearGrow.arr2_12504 : ∃ o, DEC_clearGrow.s9.heap.get 12504 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearGrow.s0 12504 ++ DEC_clearGrow.arrEl2_12504) :=
  arrExt_of DEC_clearGrow.arrE2_12504 DEC_clearGrow.arrA2_12504
kernel_rfl DEC_clearGrow.arrN2_12504 : numRefsB DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl2_12504 = true
theorem DEC_clearGrow.arrR2_12504 : Prefill.NumRefs DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl2_12504 := numRefs_of DEC_clearGrow.arrN2_12504

def DEC_clearGrow.arrEl2_2665 : List Val := []
kernel_rfl DEC_clearGrow.arrE2_2665 : arrOf DEC_clearGrow.s9 2665 = arrOf DEC_clearGrow.s0 2665 ++ DEC_clearGrow.arrEl2_2665
kernel_rfl DEC_clearGrow.arrA2_2665 : isArrB DEC_clearGrow.s9 2665 = true
theorem DEC_clearGrow.arr2_2665 : ∃ o, DEC_clearGrow.s9.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearGrow.s0 2665 ++ DEC_clearGrow.arrEl2_2665) :=
  arrExt_of DEC_clearGrow.arrE2_2665 DEC_clearGrow.arrA2_2665
kernel_rfl DEC_clearGrow.arrN2_2665 : numRefsB DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl2_2665 = true
theorem DEC_clearGrow.arrR2_2665 : Prefill.NumRefs DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl2_2665 := numRefs_of DEC_clearGrow.arrN2_2665

kernel_rfl DEC_clearGrow.w4910k2 : isArrB DEC_clearGrow.s9 4910 = false
theorem DEC_clearGrow.keep2 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP DEC_clearGrow.s0 q) DEC_clearGrow.s9 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of DEC_clearGrow.w4910k2 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := DEC_clearGrow.arr2_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [DEC_clearGrow.arrEl2_2665]

end Host.Load.Run.Tpl
