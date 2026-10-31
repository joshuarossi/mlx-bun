import host.sim.template.a4dec_clear.Site0
import host.sim.template.a4dec_clear.SiteF0
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 0 of chain `DEC_clear`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `DEC_clear.s1`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl DEC_clear.srvO0 : DEC_clear.st0.S0.oracle = DEC_clear.st0.O
kernel_rfl DEC_clear.wr0B0 : DEC_clear.st0.wr.all (fun b => !Nat.blt b DEC_clear.st0.s0.next || (DEC_clear.st0.s0.heap.get b).isSome) = true
theorem DEC_clear.stFoot0 : Conv.StageFoot DEC_clear.st0.wr DEC_clear.st0.s0 DEC_clear.st0.s2 :=
  stageFoot_of DEC_clear.st0.heapFoot DEC_clear.wrNodup0 DEC_clear.wrBound0 DEC_clear.wr0B0 DEC_clear.st0.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem DEC_clear.merged0 {FR : Map → Nat → DEC_clear.st0.F.S → DEC_clear.st0.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St DEC_clear.st0.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB DEC_clear.st0.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) DEC_clear.rs0 DEC_clear.st0.wr DEC_clear.s0 DEC_clear.st0.s2 DEC_clear.st0.s0
      DEC_clear.st0.s2.ffi) S t C) : RelB DEC_clear.st0.F FR W stk M ν K DEC_clear.s1 S t C :=
  merged_relB DEC_clear.iso0 DEC_clear.stFoot0 DEC_clear.wrNodup0 DEC_clear.wrBound0 DEC_clear.trace0 DEC_clear.mheap0
    DEC_clear.mnext0 DEC_clear.mctl0 DEC_clear.mstack0 DEC_clear.mjobs0 DEC_clear.mffi0 DEC_clear.mtrace0 DEC_clear.mstores0 h

def DEC_clear.arrEl0_2673448 : List Val := []
kernel_rfl DEC_clear.arrE0_2673448 : arrOf DEC_clear.s1 2673448 = arrOf DEC_clear.s0 2673448 ++ DEC_clear.arrEl0_2673448
kernel_rfl DEC_clear.arrA0_2673448 : isArrB DEC_clear.s1 2673448 = true
theorem DEC_clear.arr0_2673448 : ∃ o, DEC_clear.s1.heap.get 2673448 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clear.s0 2673448 ++ DEC_clear.arrEl0_2673448) :=
  arrExt_of DEC_clear.arrE0_2673448 DEC_clear.arrA0_2673448
kernel_rfl DEC_clear.arrN0_2673448 : numRefsB DEC_clear.S0.tab.length DEC_clear.arrEl0_2673448 = true
theorem DEC_clear.arrR0_2673448 : Prefill.NumRefs DEC_clear.S0.tab.length DEC_clear.arrEl0_2673448 := numRefs_of DEC_clear.arrN0_2673448

def DEC_clear.arrEl0_12504 : List Val := []
kernel_rfl DEC_clear.arrE0_12504 : arrOf DEC_clear.s1 12504 = arrOf DEC_clear.s0 12504 ++ DEC_clear.arrEl0_12504
kernel_rfl DEC_clear.arrA0_12504 : isArrB DEC_clear.s1 12504 = true
theorem DEC_clear.arr0_12504 : ∃ o, DEC_clear.s1.heap.get 12504 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clear.s0 12504 ++ DEC_clear.arrEl0_12504) :=
  arrExt_of DEC_clear.arrE0_12504 DEC_clear.arrA0_12504
kernel_rfl DEC_clear.arrN0_12504 : numRefsB DEC_clear.S0.tab.length DEC_clear.arrEl0_12504 = true
theorem DEC_clear.arrR0_12504 : Prefill.NumRefs DEC_clear.S0.tab.length DEC_clear.arrEl0_12504 := numRefs_of DEC_clear.arrN0_12504

def DEC_clear.arrEl0_2665 : List Val := []
kernel_rfl DEC_clear.arrE0_2665 : arrOf DEC_clear.s1 2665 = arrOf DEC_clear.s0 2665 ++ DEC_clear.arrEl0_2665
kernel_rfl DEC_clear.arrA0_2665 : isArrB DEC_clear.s1 2665 = true
theorem DEC_clear.arr0_2665 : ∃ o, DEC_clear.s1.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clear.s0 2665 ++ DEC_clear.arrEl0_2665) :=
  arrExt_of DEC_clear.arrE0_2665 DEC_clear.arrA0_2665
kernel_rfl DEC_clear.arrN0_2665 : numRefsB DEC_clear.S0.tab.length DEC_clear.arrEl0_2665 = true
theorem DEC_clear.arrR0_2665 : Prefill.NumRefs DEC_clear.S0.tab.length DEC_clear.arrEl0_2665 := numRefs_of DEC_clear.arrN0_2665

kernel_rfl DEC_clear.w4910k0 : isArrB DEC_clear.s1 4910 = false
theorem DEC_clear.keep0 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP DEC_clear.s0 q) DEC_clear.s1 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of DEC_clear.w4910k0 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := DEC_clear.arr0_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [DEC_clear.arrEl0_2665]

end Host.Load.Run.Tpl
