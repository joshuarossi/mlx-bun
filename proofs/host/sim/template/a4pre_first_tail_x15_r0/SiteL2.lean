import host.sim.template.a4pre_first_tail_x15_r0.Site2
import host.sim.template.a4pre_first_tail_x15_r0.SiteF2
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 2 of chain `PRE_first_tail_x15_r0`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0.s39`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0.srvO2 : PRE_first_tail_x15_r0.st2.S0.oracle = PRE_first_tail_x15_r0.st2.O
kernel_rfl PRE_first_tail_x15_r0.wr0B2 : PRE_first_tail_x15_r0.st2.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0.st2.s0.next || (PRE_first_tail_x15_r0.st2.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0.stFoot2 : Conv.StageFoot PRE_first_tail_x15_r0.st2.wr PRE_first_tail_x15_r0.st2.s0 PRE_first_tail_x15_r0.st2.s2 :=
  stageFoot_of PRE_first_tail_x15_r0.st2.heapFoot PRE_first_tail_x15_r0.wrNodup2 PRE_first_tail_x15_r0.wrBound2 PRE_first_tail_x15_r0.wr0B2 PRE_first_tail_x15_r0.st2.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0.merged2 {FR : Map → Nat → PRE_first_tail_x15_r0.st2.F.S → PRE_first_tail_x15_r0.st2.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0.st2.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0.st2.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0.rs2 PRE_first_tail_x15_r0.st2.wr PRE_first_tail_x15_r0.s38 PRE_first_tail_x15_r0.st2.s2 PRE_first_tail_x15_r0.st2.s0
      PRE_first_tail_x15_r0.st2.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0.st2.F FR W stk M ν K PRE_first_tail_x15_r0.s39 S t C :=
  merged_relB PRE_first_tail_x15_r0.iso2 PRE_first_tail_x15_r0.stFoot2 PRE_first_tail_x15_r0.wrNodup2 PRE_first_tail_x15_r0.wrBound2 PRE_first_tail_x15_r0.trace2 PRE_first_tail_x15_r0.mheap2
    PRE_first_tail_x15_r0.mnext2 PRE_first_tail_x15_r0.mctl2 PRE_first_tail_x15_r0.mstack2 PRE_first_tail_x15_r0.mjobs2 PRE_first_tail_x15_r0.mffi2 PRE_first_tail_x15_r0.mtrace2 PRE_first_tail_x15_r0.mstores2 h

def PRE_first_tail_x15_r0.arrEl2_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0.arrE2_2665 : arrOf PRE_first_tail_x15_r0.s39 2665 = arrOf PRE_first_tail_x15_r0.s0 2665 ++ PRE_first_tail_x15_r0.arrEl2_2665
kernel_rfl PRE_first_tail_x15_r0.arrA2_2665 : isArrB PRE_first_tail_x15_r0.s39 2665 = true
theorem PRE_first_tail_x15_r0.arr2_2665 : ∃ o, PRE_first_tail_x15_r0.s39.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0.s0 2665 ++ PRE_first_tail_x15_r0.arrEl2_2665) :=
  arrExt_of PRE_first_tail_x15_r0.arrE2_2665 PRE_first_tail_x15_r0.arrA2_2665
kernel_rfl PRE_first_tail_x15_r0.arrN2_2665 : numRefsB PRE_first_tail_x15_r0.S0.tab.length PRE_first_tail_x15_r0.arrEl2_2665 = true
theorem PRE_first_tail_x15_r0.arrR2_2665 : Prefill.NumRefs PRE_first_tail_x15_r0.S0.tab.length PRE_first_tail_x15_r0.arrEl2_2665 := numRefs_of PRE_first_tail_x15_r0.arrN2_2665

def PRE_first_tail_x15_r0.arrEl2_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0.arrE2_2673467 : arrOf PRE_first_tail_x15_r0.s39 2673467 = arrOf PRE_first_tail_x15_r0.s0 2673467 ++ PRE_first_tail_x15_r0.arrEl2_2673467
kernel_rfl PRE_first_tail_x15_r0.arrA2_2673467 : isArrB PRE_first_tail_x15_r0.s39 2673467 = true
theorem PRE_first_tail_x15_r0.arr2_2673467 : ∃ o, PRE_first_tail_x15_r0.s39.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0.s0 2673467 ++ PRE_first_tail_x15_r0.arrEl2_2673467) :=
  arrExt_of PRE_first_tail_x15_r0.arrE2_2673467 PRE_first_tail_x15_r0.arrA2_2673467
kernel_rfl PRE_first_tail_x15_r0.arrN2_2673467 : numRefsB PRE_first_tail_x15_r0.S0.tab.length PRE_first_tail_x15_r0.arrEl2_2673467 = true
theorem PRE_first_tail_x15_r0.arrR2_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0.S0.tab.length PRE_first_tail_x15_r0.arrEl2_2673467 := numRefs_of PRE_first_tail_x15_r0.arrN2_2673467

kernel_rfl PRE_first_tail_x15_r0.w4910k2 : isArrB PRE_first_tail_x15_r0.s39 4910 = false
theorem PRE_first_tail_x15_r0.keep2 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0.s0 q) PRE_first_tail_x15_r0.s39 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0.w4910k2 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0.arr2_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0.arrEl2_2665]

end Host.Load.Run.Tpl
