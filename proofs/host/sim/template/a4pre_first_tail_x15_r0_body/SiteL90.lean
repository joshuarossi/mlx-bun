import host.sim.template.a4pre_first_tail_x15_r0_body.Site90
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF90
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 90 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s880`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO90 : PRE_first_tail_x15_r0_body.st90.S0.oracle = PRE_first_tail_x15_r0_body.st90.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B90 : PRE_first_tail_x15_r0_body.st90.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st90.s0.next || (PRE_first_tail_x15_r0_body.st90.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot90 : Conv.StageFoot PRE_first_tail_x15_r0_body.st90.wr PRE_first_tail_x15_r0_body.st90.s0 PRE_first_tail_x15_r0_body.st90.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st90.heapFoot PRE_first_tail_x15_r0_body.wrNodup90 PRE_first_tail_x15_r0_body.wrBound90 PRE_first_tail_x15_r0_body.wr0B90 PRE_first_tail_x15_r0_body.st90.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged90 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st90.F.S → PRE_first_tail_x15_r0_body.st90.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st90.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st90.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs90 PRE_first_tail_x15_r0_body.st90.wr PRE_first_tail_x15_r0_body.s879 PRE_first_tail_x15_r0_body.st90.s5 PRE_first_tail_x15_r0_body.st90.s0
      PRE_first_tail_x15_r0_body.st90.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st90.F FR W stk M ν K PRE_first_tail_x15_r0_body.s880 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso90 PRE_first_tail_x15_r0_body.stFoot90 PRE_first_tail_x15_r0_body.wrNodup90 PRE_first_tail_x15_r0_body.wrBound90 PRE_first_tail_x15_r0_body.trace90 PRE_first_tail_x15_r0_body.mheap90
    PRE_first_tail_x15_r0_body.mnext90 PRE_first_tail_x15_r0_body.mctl90 PRE_first_tail_x15_r0_body.mstack90 PRE_first_tail_x15_r0_body.mjobs90 PRE_first_tail_x15_r0_body.mffi90 PRE_first_tail_x15_r0_body.mtrace90 PRE_first_tail_x15_r0_body.mstores90 h

def PRE_first_tail_x15_r0_body.arrEl90_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE90_2665 : arrOf PRE_first_tail_x15_r0_body.s880 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl90_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA90_2665 : isArrB PRE_first_tail_x15_r0_body.s880 2665 = true
theorem PRE_first_tail_x15_r0_body.arr90_2665 : ∃ o, PRE_first_tail_x15_r0_body.s880.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl90_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE90_2665 PRE_first_tail_x15_r0_body.arrA90_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN90_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl90_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR90_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl90_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN90_2665

def PRE_first_tail_x15_r0_body.arrEl90_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE90_2673467 : arrOf PRE_first_tail_x15_r0_body.s880 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl90_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA90_2673467 : isArrB PRE_first_tail_x15_r0_body.s880 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr90_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s880.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl90_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE90_2673467 PRE_first_tail_x15_r0_body.arrA90_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN90_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl90_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR90_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl90_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN90_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k90 : isArrB PRE_first_tail_x15_r0_body.s880 4910 = false
theorem PRE_first_tail_x15_r0_body.keep90 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s880 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k90 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr90_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl90_2665]

end Host.Load.Run.Tpl
