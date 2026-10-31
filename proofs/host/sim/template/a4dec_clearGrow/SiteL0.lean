import host.sim.template.a4dec_clearGrow.Site0
import host.sim.template.a4dec_clearGrow.SiteF0
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 0 of chain `DEC_clearGrow`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `DEC_clearGrow.s1`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl DEC_clearGrow.srvO0 : DEC_clearGrow.st0.S0.oracle = DEC_clearGrow.st0.O
kernel_rfl DEC_clearGrow.wr0B0 : DEC_clearGrow.st0.wr.all (fun b => !Nat.blt b DEC_clearGrow.st0.s0.next || (DEC_clearGrow.st0.s0.heap.get b).isSome) = true
theorem DEC_clearGrow.stFoot0 : Conv.StageFoot DEC_clearGrow.st0.wr DEC_clearGrow.st0.s0 DEC_clearGrow.st0.s2 :=
  stageFoot_of DEC_clearGrow.st0.heapFoot DEC_clearGrow.wrNodup0 DEC_clearGrow.wrBound0 DEC_clearGrow.wr0B0 DEC_clearGrow.st0.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem DEC_clearGrow.merged0 {FR : Map → Nat → DEC_clearGrow.st0.F.S → DEC_clearGrow.st0.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St DEC_clearGrow.st0.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB DEC_clearGrow.st0.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) DEC_clearGrow.rs0 DEC_clearGrow.st0.wr DEC_clearGrow.s0 DEC_clearGrow.st0.s2 DEC_clearGrow.st0.s0
      DEC_clearGrow.st0.s2.ffi) S t C) : RelB DEC_clearGrow.st0.F FR W stk M ν K DEC_clearGrow.s1 S t C :=
  merged_relB DEC_clearGrow.iso0 DEC_clearGrow.stFoot0 DEC_clearGrow.wrNodup0 DEC_clearGrow.wrBound0 DEC_clearGrow.trace0 DEC_clearGrow.mheap0
    DEC_clearGrow.mnext0 DEC_clearGrow.mctl0 DEC_clearGrow.mstack0 DEC_clearGrow.mjobs0 DEC_clearGrow.mffi0 DEC_clearGrow.mtrace0 DEC_clearGrow.mstores0 h

def DEC_clearGrow.arrEl0_2673448 : List Val := []
kernel_rfl DEC_clearGrow.arrE0_2673448 : arrOf DEC_clearGrow.s1 2673448 = arrOf DEC_clearGrow.s0 2673448 ++ DEC_clearGrow.arrEl0_2673448
kernel_rfl DEC_clearGrow.arrA0_2673448 : isArrB DEC_clearGrow.s1 2673448 = true
theorem DEC_clearGrow.arr0_2673448 : ∃ o, DEC_clearGrow.s1.heap.get 2673448 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearGrow.s0 2673448 ++ DEC_clearGrow.arrEl0_2673448) :=
  arrExt_of DEC_clearGrow.arrE0_2673448 DEC_clearGrow.arrA0_2673448
kernel_rfl DEC_clearGrow.arrN0_2673448 : numRefsB DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl0_2673448 = true
theorem DEC_clearGrow.arrR0_2673448 : Prefill.NumRefs DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl0_2673448 := numRefs_of DEC_clearGrow.arrN0_2673448

def DEC_clearGrow.arrEl0_12504 : List Val := []
kernel_rfl DEC_clearGrow.arrE0_12504 : arrOf DEC_clearGrow.s1 12504 = arrOf DEC_clearGrow.s0 12504 ++ DEC_clearGrow.arrEl0_12504
kernel_rfl DEC_clearGrow.arrA0_12504 : isArrB DEC_clearGrow.s1 12504 = true
theorem DEC_clearGrow.arr0_12504 : ∃ o, DEC_clearGrow.s1.heap.get 12504 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearGrow.s0 12504 ++ DEC_clearGrow.arrEl0_12504) :=
  arrExt_of DEC_clearGrow.arrE0_12504 DEC_clearGrow.arrA0_12504
kernel_rfl DEC_clearGrow.arrN0_12504 : numRefsB DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl0_12504 = true
theorem DEC_clearGrow.arrR0_12504 : Prefill.NumRefs DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl0_12504 := numRefs_of DEC_clearGrow.arrN0_12504

def DEC_clearGrow.arrEl0_2665 : List Val := []
kernel_rfl DEC_clearGrow.arrE0_2665 : arrOf DEC_clearGrow.s1 2665 = arrOf DEC_clearGrow.s0 2665 ++ DEC_clearGrow.arrEl0_2665
kernel_rfl DEC_clearGrow.arrA0_2665 : isArrB DEC_clearGrow.s1 2665 = true
theorem DEC_clearGrow.arr0_2665 : ∃ o, DEC_clearGrow.s1.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearGrow.s0 2665 ++ DEC_clearGrow.arrEl0_2665) :=
  arrExt_of DEC_clearGrow.arrE0_2665 DEC_clearGrow.arrA0_2665
kernel_rfl DEC_clearGrow.arrN0_2665 : numRefsB DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl0_2665 = true
theorem DEC_clearGrow.arrR0_2665 : Prefill.NumRefs DEC_clearGrow.S0.tab.length DEC_clearGrow.arrEl0_2665 := numRefs_of DEC_clearGrow.arrN0_2665

kernel_rfl DEC_clearGrow.w4910k0 : isArrB DEC_clearGrow.s1 4910 = false
theorem DEC_clearGrow.keep0 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP DEC_clearGrow.s0 q) DEC_clearGrow.s1 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of DEC_clearGrow.w4910k0 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := DEC_clearGrow.arr0_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [DEC_clearGrow.arrEl0_2665]

end Host.Load.Run.Tpl
