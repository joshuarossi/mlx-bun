import host.sim.template.a4pre_first_tail_x15_r0_body.Site74
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF74
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 74 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s719`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO74 : PRE_first_tail_x15_r0_body.st74.S0.oracle = PRE_first_tail_x15_r0_body.st74.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B74 : PRE_first_tail_x15_r0_body.st74.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st74.s0.next || (PRE_first_tail_x15_r0_body.st74.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot74 : Conv.StageFoot PRE_first_tail_x15_r0_body.st74.wr PRE_first_tail_x15_r0_body.st74.s0 PRE_first_tail_x15_r0_body.st74.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st74.heapFoot PRE_first_tail_x15_r0_body.wrNodup74 PRE_first_tail_x15_r0_body.wrBound74 PRE_first_tail_x15_r0_body.wr0B74 PRE_first_tail_x15_r0_body.st74.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged74 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st74.F.S → PRE_first_tail_x15_r0_body.st74.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st74.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st74.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs74 PRE_first_tail_x15_r0_body.st74.wr PRE_first_tail_x15_r0_body.s718 PRE_first_tail_x15_r0_body.st74.s2 PRE_first_tail_x15_r0_body.st74.s0
      PRE_first_tail_x15_r0_body.st74.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st74.F FR W stk M ν K PRE_first_tail_x15_r0_body.s719 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso74 PRE_first_tail_x15_r0_body.stFoot74 PRE_first_tail_x15_r0_body.wrNodup74 PRE_first_tail_x15_r0_body.wrBound74 PRE_first_tail_x15_r0_body.trace74 PRE_first_tail_x15_r0_body.mheap74
    PRE_first_tail_x15_r0_body.mnext74 PRE_first_tail_x15_r0_body.mctl74 PRE_first_tail_x15_r0_body.mstack74 PRE_first_tail_x15_r0_body.mjobs74 PRE_first_tail_x15_r0_body.mffi74 PRE_first_tail_x15_r0_body.mtrace74 PRE_first_tail_x15_r0_body.mstores74 h

def PRE_first_tail_x15_r0_body.arrEl74_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE74_2665 : arrOf PRE_first_tail_x15_r0_body.s719 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl74_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA74_2665 : isArrB PRE_first_tail_x15_r0_body.s719 2665 = true
theorem PRE_first_tail_x15_r0_body.arr74_2665 : ∃ o, PRE_first_tail_x15_r0_body.s719.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl74_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE74_2665 PRE_first_tail_x15_r0_body.arrA74_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN74_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl74_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR74_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl74_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN74_2665

def PRE_first_tail_x15_r0_body.arrEl74_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE74_2673467 : arrOf PRE_first_tail_x15_r0_body.s719 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl74_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA74_2673467 : isArrB PRE_first_tail_x15_r0_body.s719 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr74_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s719.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl74_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE74_2673467 PRE_first_tail_x15_r0_body.arrA74_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN74_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl74_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR74_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl74_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN74_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k74 : isArrB PRE_first_tail_x15_r0_body.s719 4910 = false
theorem PRE_first_tail_x15_r0_body.keep74 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s719 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k74 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr74_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl74_2665]

end Host.Load.Run.Tpl
