import host.sim.template.a4dec_clearFill.Site2
import host.sim.template.a4dec_clearFill.SiteF2
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 2 of chain `DEC_clearFill`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `DEC_clearFill.s9`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl DEC_clearFill.srvO2 : DEC_clearFill.st2.S0.oracle = DEC_clearFill.st2.O
kernel_rfl DEC_clearFill.wr0B2 : DEC_clearFill.st2.wr.all (fun b => !Nat.blt b DEC_clearFill.st2.s0.next || (DEC_clearFill.st2.s0.heap.get b).isSome) = true
theorem DEC_clearFill.stFoot2 : Conv.StageFoot DEC_clearFill.st2.wr DEC_clearFill.st2.s0 DEC_clearFill.st2.s2 :=
  stageFoot_of DEC_clearFill.st2.heapFoot DEC_clearFill.wrNodup2 DEC_clearFill.wrBound2 DEC_clearFill.wr0B2 DEC_clearFill.st2.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem DEC_clearFill.merged2 {FR : Map → Nat → DEC_clearFill.st2.F.S → DEC_clearFill.st2.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St DEC_clearFill.st2.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB DEC_clearFill.st2.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) DEC_clearFill.rs2 DEC_clearFill.st2.wr DEC_clearFill.s8 DEC_clearFill.st2.s2 DEC_clearFill.st2.s0
      DEC_clearFill.st2.s2.ffi) S t C) : RelB DEC_clearFill.st2.F FR W stk M ν K DEC_clearFill.s9 S t C :=
  merged_relB DEC_clearFill.iso2 DEC_clearFill.stFoot2 DEC_clearFill.wrNodup2 DEC_clearFill.wrBound2 DEC_clearFill.trace2 DEC_clearFill.mheap2
    DEC_clearFill.mnext2 DEC_clearFill.mctl2 DEC_clearFill.mstack2 DEC_clearFill.mjobs2 DEC_clearFill.mffi2 DEC_clearFill.mtrace2 DEC_clearFill.mstores2 h

def DEC_clearFill.arrEl2_2673448 : List Val := []
kernel_rfl DEC_clearFill.arrE2_2673448 : arrOf DEC_clearFill.s9 2673448 = arrOf DEC_clearFill.s0 2673448 ++ DEC_clearFill.arrEl2_2673448
kernel_rfl DEC_clearFill.arrA2_2673448 : isArrB DEC_clearFill.s9 2673448 = true
theorem DEC_clearFill.arr2_2673448 : ∃ o, DEC_clearFill.s9.heap.get 2673448 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearFill.s0 2673448 ++ DEC_clearFill.arrEl2_2673448) :=
  arrExt_of DEC_clearFill.arrE2_2673448 DEC_clearFill.arrA2_2673448
kernel_rfl DEC_clearFill.arrN2_2673448 : numRefsB DEC_clearFill.S0.tab.length DEC_clearFill.arrEl2_2673448 = true
theorem DEC_clearFill.arrR2_2673448 : Prefill.NumRefs DEC_clearFill.S0.tab.length DEC_clearFill.arrEl2_2673448 := numRefs_of DEC_clearFill.arrN2_2673448

def DEC_clearFill.arrEl2_12504 : List Val := []
kernel_rfl DEC_clearFill.arrE2_12504 : arrOf DEC_clearFill.s9 12504 = arrOf DEC_clearFill.s0 12504 ++ DEC_clearFill.arrEl2_12504
kernel_rfl DEC_clearFill.arrA2_12504 : isArrB DEC_clearFill.s9 12504 = true
theorem DEC_clearFill.arr2_12504 : ∃ o, DEC_clearFill.s9.heap.get 12504 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearFill.s0 12504 ++ DEC_clearFill.arrEl2_12504) :=
  arrExt_of DEC_clearFill.arrE2_12504 DEC_clearFill.arrA2_12504
kernel_rfl DEC_clearFill.arrN2_12504 : numRefsB DEC_clearFill.S0.tab.length DEC_clearFill.arrEl2_12504 = true
theorem DEC_clearFill.arrR2_12504 : Prefill.NumRefs DEC_clearFill.S0.tab.length DEC_clearFill.arrEl2_12504 := numRefs_of DEC_clearFill.arrN2_12504

def DEC_clearFill.arrEl2_2665 : List Val := []
kernel_rfl DEC_clearFill.arrE2_2665 : arrOf DEC_clearFill.s9 2665 = arrOf DEC_clearFill.s0 2665 ++ DEC_clearFill.arrEl2_2665
kernel_rfl DEC_clearFill.arrA2_2665 : isArrB DEC_clearFill.s9 2665 = true
theorem DEC_clearFill.arr2_2665 : ∃ o, DEC_clearFill.s9.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearFill.s0 2665 ++ DEC_clearFill.arrEl2_2665) :=
  arrExt_of DEC_clearFill.arrE2_2665 DEC_clearFill.arrA2_2665
kernel_rfl DEC_clearFill.arrN2_2665 : numRefsB DEC_clearFill.S0.tab.length DEC_clearFill.arrEl2_2665 = true
theorem DEC_clearFill.arrR2_2665 : Prefill.NumRefs DEC_clearFill.S0.tab.length DEC_clearFill.arrEl2_2665 := numRefs_of DEC_clearFill.arrN2_2665

kernel_rfl DEC_clearFill.w4910k2 : isArrB DEC_clearFill.s9 4910 = false
theorem DEC_clearFill.keep2 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP DEC_clearFill.s0 q) DEC_clearFill.s9 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of DEC_clearFill.w4910k2 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := DEC_clearFill.arr2_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [DEC_clearFill.arrEl2_2665]

end Host.Load.Run.Tpl
