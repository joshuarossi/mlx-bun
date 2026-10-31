import host.sim.template.a4pre_setup_early_r0.Site0
import host.sim.template.a4pre_setup_early_r0.SiteF0
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 0 of chain `PRE_setup_early_r0`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_setup_early_r0.s5`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_setup_early_r0.srvO0 : PRE_setup_early_r0.st0.S0.oracle = PRE_setup_early_r0.st0.O
kernel_rfl PRE_setup_early_r0.wr0B0 : PRE_setup_early_r0.st0.wr.all (fun b => !Nat.blt b PRE_setup_early_r0.st0.s0.next || (PRE_setup_early_r0.st0.s0.heap.get b).isSome) = true
theorem PRE_setup_early_r0.stFoot0 : Conv.StageFoot PRE_setup_early_r0.st0.wr PRE_setup_early_r0.st0.s0 PRE_setup_early_r0.st0.s2 :=
  stageFoot_of PRE_setup_early_r0.st0.heapFoot PRE_setup_early_r0.wrNodup0 PRE_setup_early_r0.wrBound0 PRE_setup_early_r0.wr0B0 PRE_setup_early_r0.st0.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_setup_early_r0.merged0 {FR : Map → Nat → PRE_setup_early_r0.st0.F.S → PRE_setup_early_r0.st0.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_setup_early_r0.st0.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_setup_early_r0.st0.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_setup_early_r0.rs0 PRE_setup_early_r0.st0.wr PRE_setup_early_r0.s4 PRE_setup_early_r0.st0.s2 PRE_setup_early_r0.st0.s0
      PRE_setup_early_r0.st0.s2.ffi) S t C) : RelB PRE_setup_early_r0.st0.F FR W stk M ν K PRE_setup_early_r0.s5 S t C :=
  merged_relB PRE_setup_early_r0.iso0 PRE_setup_early_r0.stFoot0 PRE_setup_early_r0.wrNodup0 PRE_setup_early_r0.wrBound0 PRE_setup_early_r0.trace0 PRE_setup_early_r0.mheap0
    PRE_setup_early_r0.mnext0 PRE_setup_early_r0.mctl0 PRE_setup_early_r0.mstack0 PRE_setup_early_r0.mjobs0 PRE_setup_early_r0.mffi0 PRE_setup_early_r0.mtrace0 PRE_setup_early_r0.mstores0 h

def PRE_setup_early_r0.arrEl0_2665 : List Val := []
kernel_rfl PRE_setup_early_r0.arrE0_2665 : arrOf PRE_setup_early_r0.s5 2665 = arrOf PRE_setup_early_r0.s0 2665 ++ PRE_setup_early_r0.arrEl0_2665
kernel_rfl PRE_setup_early_r0.arrA0_2665 : isArrB PRE_setup_early_r0.s5 2665 = true
theorem PRE_setup_early_r0.arr0_2665 : ∃ o, PRE_setup_early_r0.s5.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_setup_early_r0.s0 2665 ++ PRE_setup_early_r0.arrEl0_2665) :=
  arrExt_of PRE_setup_early_r0.arrE0_2665 PRE_setup_early_r0.arrA0_2665
kernel_rfl PRE_setup_early_r0.arrN0_2665 : numRefsB PRE_setup_early_r0.S0.tab.length PRE_setup_early_r0.arrEl0_2665 = true
theorem PRE_setup_early_r0.arrR0_2665 : Prefill.NumRefs PRE_setup_early_r0.S0.tab.length PRE_setup_early_r0.arrEl0_2665 := numRefs_of PRE_setup_early_r0.arrN0_2665

kernel_rfl PRE_setup_early_r0.w4910k0 : isArrB PRE_setup_early_r0.s5 4910 = false
theorem PRE_setup_early_r0.keep0 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_setup_early_r0.s0 q) PRE_setup_early_r0.s5 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_setup_early_r0.w4910k0 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_setup_early_r0.arr0_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_setup_early_r0.arrEl0_2665]

end Host.Load.Run.Tpl
