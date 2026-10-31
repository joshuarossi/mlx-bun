import host.sim.template.a4dec_ord.Site2
import host.sim.template.a4dec_ord.SiteF2
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 2 of chain `DEC_ord`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `DEC_ord.s9`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl DEC_ord.srvO2 : DEC_ord.st2.S0.oracle = DEC_ord.st2.O
kernel_rfl DEC_ord.wr0B2 : DEC_ord.st2.wr.all (fun b => !Nat.blt b DEC_ord.st2.s0.next || (DEC_ord.st2.s0.heap.get b).isSome) = true
theorem DEC_ord.stFoot2 : Conv.StageFoot DEC_ord.st2.wr DEC_ord.st2.s0 DEC_ord.st2.s2 :=
  stageFoot_of DEC_ord.st2.heapFoot DEC_ord.wrNodup2 DEC_ord.wrBound2 DEC_ord.wr0B2 DEC_ord.st2.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem DEC_ord.merged2 {FR : Map → Nat → DEC_ord.st2.F.S → DEC_ord.st2.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St DEC_ord.st2.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB DEC_ord.st2.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) DEC_ord.rs2 DEC_ord.st2.wr DEC_ord.s8 DEC_ord.st2.s2 DEC_ord.st2.s0
      DEC_ord.st2.s2.ffi) S t C) : RelB DEC_ord.st2.F FR W stk M ν K DEC_ord.s9 S t C :=
  merged_relB DEC_ord.iso2 DEC_ord.stFoot2 DEC_ord.wrNodup2 DEC_ord.wrBound2 DEC_ord.trace2 DEC_ord.mheap2
    DEC_ord.mnext2 DEC_ord.mctl2 DEC_ord.mstack2 DEC_ord.mjobs2 DEC_ord.mffi2 DEC_ord.mtrace2 DEC_ord.mstores2 h

def DEC_ord.arrEl2_2673448 : List Val := []
kernel_rfl DEC_ord.arrE2_2673448 : arrOf DEC_ord.s9 2673448 = arrOf DEC_ord.s0 2673448 ++ DEC_ord.arrEl2_2673448
kernel_rfl DEC_ord.arrA2_2673448 : isArrB DEC_ord.s9 2673448 = true
theorem DEC_ord.arr2_2673448 : ∃ o, DEC_ord.s9.heap.get 2673448 = some (.obj o) ∧ o.kind = .array (arrOf DEC_ord.s0 2673448 ++ DEC_ord.arrEl2_2673448) :=
  arrExt_of DEC_ord.arrE2_2673448 DEC_ord.arrA2_2673448
kernel_rfl DEC_ord.arrN2_2673448 : numRefsB DEC_ord.S0.tab.length DEC_ord.arrEl2_2673448 = true
theorem DEC_ord.arrR2_2673448 : Prefill.NumRefs DEC_ord.S0.tab.length DEC_ord.arrEl2_2673448 := numRefs_of DEC_ord.arrN2_2673448

def DEC_ord.arrEl2_12504 : List Val := []
kernel_rfl DEC_ord.arrE2_12504 : arrOf DEC_ord.s9 12504 = arrOf DEC_ord.s0 12504 ++ DEC_ord.arrEl2_12504
kernel_rfl DEC_ord.arrA2_12504 : isArrB DEC_ord.s9 12504 = true
theorem DEC_ord.arr2_12504 : ∃ o, DEC_ord.s9.heap.get 12504 = some (.obj o) ∧ o.kind = .array (arrOf DEC_ord.s0 12504 ++ DEC_ord.arrEl2_12504) :=
  arrExt_of DEC_ord.arrE2_12504 DEC_ord.arrA2_12504
kernel_rfl DEC_ord.arrN2_12504 : numRefsB DEC_ord.S0.tab.length DEC_ord.arrEl2_12504 = true
theorem DEC_ord.arrR2_12504 : Prefill.NumRefs DEC_ord.S0.tab.length DEC_ord.arrEl2_12504 := numRefs_of DEC_ord.arrN2_12504

def DEC_ord.arrEl2_2665 : List Val := []
kernel_rfl DEC_ord.arrE2_2665 : arrOf DEC_ord.s9 2665 = arrOf DEC_ord.s0 2665 ++ DEC_ord.arrEl2_2665
kernel_rfl DEC_ord.arrA2_2665 : isArrB DEC_ord.s9 2665 = true
theorem DEC_ord.arr2_2665 : ∃ o, DEC_ord.s9.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf DEC_ord.s0 2665 ++ DEC_ord.arrEl2_2665) :=
  arrExt_of DEC_ord.arrE2_2665 DEC_ord.arrA2_2665
kernel_rfl DEC_ord.arrN2_2665 : numRefsB DEC_ord.S0.tab.length DEC_ord.arrEl2_2665 = true
theorem DEC_ord.arrR2_2665 : Prefill.NumRefs DEC_ord.S0.tab.length DEC_ord.arrEl2_2665 := numRefs_of DEC_ord.arrN2_2665

kernel_rfl DEC_ord.w4910k2 : isArrB DEC_ord.s9 4910 = false
theorem DEC_ord.keep2 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP DEC_ord.s0 q) DEC_ord.s9 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of DEC_ord.w4910k2 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := DEC_ord.arr2_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [DEC_ord.arrEl2_2665]

end Host.Load.Run.Tpl
