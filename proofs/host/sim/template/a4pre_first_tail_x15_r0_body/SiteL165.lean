import host.sim.template.a4pre_first_tail_x15_r0_body.Site165
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF165
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 165 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1458`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO165 : PRE_first_tail_x15_r0_body.st165.S0.oracle = PRE_first_tail_x15_r0_body.st165.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B165 : PRE_first_tail_x15_r0_body.st165.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st165.s0.next || (PRE_first_tail_x15_r0_body.st165.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot165 : Conv.StageFoot PRE_first_tail_x15_r0_body.st165.wr PRE_first_tail_x15_r0_body.st165.s0 PRE_first_tail_x15_r0_body.st165.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st165.heapFoot PRE_first_tail_x15_r0_body.wrNodup165 PRE_first_tail_x15_r0_body.wrBound165 PRE_first_tail_x15_r0_body.wr0B165 PRE_first_tail_x15_r0_body.st165.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged165 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st165.F.S → PRE_first_tail_x15_r0_body.st165.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st165.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st165.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs165 PRE_first_tail_x15_r0_body.st165.wr PRE_first_tail_x15_r0_body.s1457 PRE_first_tail_x15_r0_body.st165.s2 PRE_first_tail_x15_r0_body.st165.s0
      PRE_first_tail_x15_r0_body.st165.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st165.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1458 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso165 PRE_first_tail_x15_r0_body.stFoot165 PRE_first_tail_x15_r0_body.wrNodup165 PRE_first_tail_x15_r0_body.wrBound165 PRE_first_tail_x15_r0_body.trace165 PRE_first_tail_x15_r0_body.mheap165
    PRE_first_tail_x15_r0_body.mnext165 PRE_first_tail_x15_r0_body.mctl165 PRE_first_tail_x15_r0_body.mstack165 PRE_first_tail_x15_r0_body.mjobs165 PRE_first_tail_x15_r0_body.mffi165 PRE_first_tail_x15_r0_body.mtrace165 PRE_first_tail_x15_r0_body.mstores165 h

def PRE_first_tail_x15_r0_body.arrEl165_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE165_2665 : arrOf PRE_first_tail_x15_r0_body.s1458 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl165_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA165_2665 : isArrB PRE_first_tail_x15_r0_body.s1458 2665 = true
theorem PRE_first_tail_x15_r0_body.arr165_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1458.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl165_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE165_2665 PRE_first_tail_x15_r0_body.arrA165_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN165_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl165_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR165_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl165_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN165_2665

def PRE_first_tail_x15_r0_body.arrEl165_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE165_2673467 : arrOf PRE_first_tail_x15_r0_body.s1458 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl165_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA165_2673467 : isArrB PRE_first_tail_x15_r0_body.s1458 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr165_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1458.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl165_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE165_2673467 PRE_first_tail_x15_r0_body.arrA165_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN165_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl165_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR165_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl165_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN165_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k165 : isArrB PRE_first_tail_x15_r0_body.s1458 4910 = false
theorem PRE_first_tail_x15_r0_body.keep165 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1458 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k165 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr165_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl165_2665]

end Host.Load.Run.Tpl
