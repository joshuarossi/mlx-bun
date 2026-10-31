import host.sim.template.a4pre_first_tail_x15_r0_body.Site53
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF53
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 53 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s473`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO53 : PRE_first_tail_x15_r0_body.st53.S0.oracle = PRE_first_tail_x15_r0_body.st53.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B53 : PRE_first_tail_x15_r0_body.st53.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st53.s0.next || (PRE_first_tail_x15_r0_body.st53.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot53 : Conv.StageFoot PRE_first_tail_x15_r0_body.st53.wr PRE_first_tail_x15_r0_body.st53.s0 PRE_first_tail_x15_r0_body.st53.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st53.heapFoot PRE_first_tail_x15_r0_body.wrNodup53 PRE_first_tail_x15_r0_body.wrBound53 PRE_first_tail_x15_r0_body.wr0B53 PRE_first_tail_x15_r0_body.st53.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged53 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st53.F.S → PRE_first_tail_x15_r0_body.st53.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st53.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st53.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs53 PRE_first_tail_x15_r0_body.st53.wr PRE_first_tail_x15_r0_body.s472 PRE_first_tail_x15_r0_body.st53.s2 PRE_first_tail_x15_r0_body.st53.s0
      PRE_first_tail_x15_r0_body.st53.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st53.F FR W stk M ν K PRE_first_tail_x15_r0_body.s473 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso53 PRE_first_tail_x15_r0_body.stFoot53 PRE_first_tail_x15_r0_body.wrNodup53 PRE_first_tail_x15_r0_body.wrBound53 PRE_first_tail_x15_r0_body.trace53 PRE_first_tail_x15_r0_body.mheap53
    PRE_first_tail_x15_r0_body.mnext53 PRE_first_tail_x15_r0_body.mctl53 PRE_first_tail_x15_r0_body.mstack53 PRE_first_tail_x15_r0_body.mjobs53 PRE_first_tail_x15_r0_body.mffi53 PRE_first_tail_x15_r0_body.mtrace53 PRE_first_tail_x15_r0_body.mstores53 h

def PRE_first_tail_x15_r0_body.arrEl53_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE53_2665 : arrOf PRE_first_tail_x15_r0_body.s473 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl53_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA53_2665 : isArrB PRE_first_tail_x15_r0_body.s473 2665 = true
theorem PRE_first_tail_x15_r0_body.arr53_2665 : ∃ o, PRE_first_tail_x15_r0_body.s473.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl53_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE53_2665 PRE_first_tail_x15_r0_body.arrA53_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN53_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl53_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR53_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl53_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN53_2665

def PRE_first_tail_x15_r0_body.arrEl53_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE53_2673467 : arrOf PRE_first_tail_x15_r0_body.s473 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl53_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA53_2673467 : isArrB PRE_first_tail_x15_r0_body.s473 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr53_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s473.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl53_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE53_2673467 PRE_first_tail_x15_r0_body.arrA53_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN53_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl53_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR53_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl53_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN53_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k53 : isArrB PRE_first_tail_x15_r0_body.s473 4910 = false
theorem PRE_first_tail_x15_r0_body.keep53 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s473 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k53 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr53_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl53_2665]

end Host.Load.Run.Tpl
