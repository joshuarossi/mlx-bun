import host.sim.template.a4pre_first_tail_x15_r0.Site1
import host.sim.template.a4pre_first_tail_x15_r0.SiteF1
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 1 of chain `PRE_first_tail_x15_r0`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0.s18`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0.srvO1 : PRE_first_tail_x15_r0.st1.S0.oracle = PRE_first_tail_x15_r0.st1.O
kernel_rfl PRE_first_tail_x15_r0.wr0B1 : PRE_first_tail_x15_r0.st1.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0.st1.s0.next || (PRE_first_tail_x15_r0.st1.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0.stFoot1 : Conv.StageFoot PRE_first_tail_x15_r0.st1.wr PRE_first_tail_x15_r0.st1.s0 PRE_first_tail_x15_r0.st1.s2 :=
  stageFoot_of PRE_first_tail_x15_r0.st1.heapFoot PRE_first_tail_x15_r0.wrNodup1 PRE_first_tail_x15_r0.wrBound1 PRE_first_tail_x15_r0.wr0B1 PRE_first_tail_x15_r0.st1.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0.merged1 {FR : Map → Nat → PRE_first_tail_x15_r0.st1.F.S → PRE_first_tail_x15_r0.st1.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0.st1.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0.st1.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0.rs1 PRE_first_tail_x15_r0.st1.wr PRE_first_tail_x15_r0.s17 PRE_first_tail_x15_r0.st1.s2 PRE_first_tail_x15_r0.st1.s0
      PRE_first_tail_x15_r0.st1.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0.st1.F FR W stk M ν K PRE_first_tail_x15_r0.s18 S t C :=
  merged_relB PRE_first_tail_x15_r0.iso1 PRE_first_tail_x15_r0.stFoot1 PRE_first_tail_x15_r0.wrNodup1 PRE_first_tail_x15_r0.wrBound1 PRE_first_tail_x15_r0.trace1 PRE_first_tail_x15_r0.mheap1
    PRE_first_tail_x15_r0.mnext1 PRE_first_tail_x15_r0.mctl1 PRE_first_tail_x15_r0.mstack1 PRE_first_tail_x15_r0.mjobs1 PRE_first_tail_x15_r0.mffi1 PRE_first_tail_x15_r0.mtrace1 PRE_first_tail_x15_r0.mstores1 h

def PRE_first_tail_x15_r0.arrEl1_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0.arrE1_2665 : arrOf PRE_first_tail_x15_r0.s18 2665 = arrOf PRE_first_tail_x15_r0.s0 2665 ++ PRE_first_tail_x15_r0.arrEl1_2665
kernel_rfl PRE_first_tail_x15_r0.arrA1_2665 : isArrB PRE_first_tail_x15_r0.s18 2665 = true
theorem PRE_first_tail_x15_r0.arr1_2665 : ∃ o, PRE_first_tail_x15_r0.s18.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0.s0 2665 ++ PRE_first_tail_x15_r0.arrEl1_2665) :=
  arrExt_of PRE_first_tail_x15_r0.arrE1_2665 PRE_first_tail_x15_r0.arrA1_2665
kernel_rfl PRE_first_tail_x15_r0.arrN1_2665 : numRefsB PRE_first_tail_x15_r0.S0.tab.length PRE_first_tail_x15_r0.arrEl1_2665 = true
theorem PRE_first_tail_x15_r0.arrR1_2665 : Prefill.NumRefs PRE_first_tail_x15_r0.S0.tab.length PRE_first_tail_x15_r0.arrEl1_2665 := numRefs_of PRE_first_tail_x15_r0.arrN1_2665

kernel_rfl PRE_first_tail_x15_r0.w4910k1 : isArrB PRE_first_tail_x15_r0.s18 4910 = false
theorem PRE_first_tail_x15_r0.keep1 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0.s0 q) PRE_first_tail_x15_r0.s18 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0.w4910k1 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0.arr1_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0.arrEl1_2665]

end Host.Load.Run.Tpl
