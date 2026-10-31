import host.sim.template.a4dec_fill.Site2
import host.sim.template.a4dec_fill.SiteF2
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 2 of chain `DEC_fill`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `DEC_fill.s9`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl DEC_fill.srvO2 : DEC_fill.st2.S0.oracle = DEC_fill.st2.O
kernel_rfl DEC_fill.wr0B2 : DEC_fill.st2.wr.all (fun b => !Nat.blt b DEC_fill.st2.s0.next || (DEC_fill.st2.s0.heap.get b).isSome) = true
theorem DEC_fill.stFoot2 : Conv.StageFoot DEC_fill.st2.wr DEC_fill.st2.s0 DEC_fill.st2.s2 :=
  stageFoot_of DEC_fill.st2.heapFoot DEC_fill.wrNodup2 DEC_fill.wrBound2 DEC_fill.wr0B2 DEC_fill.st2.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem DEC_fill.merged2 {FR : Map → Nat → DEC_fill.st2.F.S → DEC_fill.st2.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St DEC_fill.st2.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB DEC_fill.st2.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) DEC_fill.rs2 DEC_fill.st2.wr DEC_fill.s8 DEC_fill.st2.s2 DEC_fill.st2.s0
      DEC_fill.st2.s2.ffi) S t C) : RelB DEC_fill.st2.F FR W stk M ν K DEC_fill.s9 S t C :=
  merged_relB DEC_fill.iso2 DEC_fill.stFoot2 DEC_fill.wrNodup2 DEC_fill.wrBound2 DEC_fill.trace2 DEC_fill.mheap2
    DEC_fill.mnext2 DEC_fill.mctl2 DEC_fill.mstack2 DEC_fill.mjobs2 DEC_fill.mffi2 DEC_fill.mtrace2 DEC_fill.mstores2 h

def DEC_fill.arrEl2_2673448 : List Val := []
kernel_rfl DEC_fill.arrE2_2673448 : arrOf DEC_fill.s9 2673448 = arrOf DEC_fill.s0 2673448 ++ DEC_fill.arrEl2_2673448
kernel_rfl DEC_fill.arrA2_2673448 : isArrB DEC_fill.s9 2673448 = true
theorem DEC_fill.arr2_2673448 : ∃ o, DEC_fill.s9.heap.get 2673448 = some (.obj o) ∧ o.kind = .array (arrOf DEC_fill.s0 2673448 ++ DEC_fill.arrEl2_2673448) :=
  arrExt_of DEC_fill.arrE2_2673448 DEC_fill.arrA2_2673448
kernel_rfl DEC_fill.arrN2_2673448 : numRefsB DEC_fill.S0.tab.length DEC_fill.arrEl2_2673448 = true
theorem DEC_fill.arrR2_2673448 : Prefill.NumRefs DEC_fill.S0.tab.length DEC_fill.arrEl2_2673448 := numRefs_of DEC_fill.arrN2_2673448

def DEC_fill.arrEl2_12504 : List Val := []
kernel_rfl DEC_fill.arrE2_12504 : arrOf DEC_fill.s9 12504 = arrOf DEC_fill.s0 12504 ++ DEC_fill.arrEl2_12504
kernel_rfl DEC_fill.arrA2_12504 : isArrB DEC_fill.s9 12504 = true
theorem DEC_fill.arr2_12504 : ∃ o, DEC_fill.s9.heap.get 12504 = some (.obj o) ∧ o.kind = .array (arrOf DEC_fill.s0 12504 ++ DEC_fill.arrEl2_12504) :=
  arrExt_of DEC_fill.arrE2_12504 DEC_fill.arrA2_12504
kernel_rfl DEC_fill.arrN2_12504 : numRefsB DEC_fill.S0.tab.length DEC_fill.arrEl2_12504 = true
theorem DEC_fill.arrR2_12504 : Prefill.NumRefs DEC_fill.S0.tab.length DEC_fill.arrEl2_12504 := numRefs_of DEC_fill.arrN2_12504

def DEC_fill.arrEl2_2665 : List Val := []
kernel_rfl DEC_fill.arrE2_2665 : arrOf DEC_fill.s9 2665 = arrOf DEC_fill.s0 2665 ++ DEC_fill.arrEl2_2665
kernel_rfl DEC_fill.arrA2_2665 : isArrB DEC_fill.s9 2665 = true
theorem DEC_fill.arr2_2665 : ∃ o, DEC_fill.s9.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf DEC_fill.s0 2665 ++ DEC_fill.arrEl2_2665) :=
  arrExt_of DEC_fill.arrE2_2665 DEC_fill.arrA2_2665
kernel_rfl DEC_fill.arrN2_2665 : numRefsB DEC_fill.S0.tab.length DEC_fill.arrEl2_2665 = true
theorem DEC_fill.arrR2_2665 : Prefill.NumRefs DEC_fill.S0.tab.length DEC_fill.arrEl2_2665 := numRefs_of DEC_fill.arrN2_2665

kernel_rfl DEC_fill.w4910k2 : isArrB DEC_fill.s9 4910 = false
theorem DEC_fill.keep2 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP DEC_fill.s0 q) DEC_fill.s9 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of DEC_fill.w4910k2 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := DEC_fill.arr2_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [DEC_fill.arrEl2_2665]

end Host.Load.Run.Tpl
