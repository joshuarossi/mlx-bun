import host.sim.template.a4pre_d1_stage_split.Site0
import host.sim.template.a4pre_d1_stage_split.SiteF0
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 0 of chain `D1StageSplit`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `D1StageSplit.s1`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl D1StageSplit.srvO0 : D1StageSplit.st0.S0.oracle = D1StageSplit.st0.O
kernel_rfl D1StageSplit.wr0B0 : D1StageSplit.st0.wr.all (fun b => !Nat.blt b D1StageSplit.st0.s0.next || (D1StageSplit.st0.s0.heap.get b).isSome) = true
theorem D1StageSplit.stFoot0 : Conv.StageFoot D1StageSplit.st0.wr D1StageSplit.st0.s0 D1StageSplit.st0.s2 :=
  stageFoot_of D1StageSplit.st0.heapFoot D1StageSplit.wrNodup0 D1StageSplit.wrBound0 D1StageSplit.wr0B0 D1StageSplit.st0.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem D1StageSplit.merged0 {FR : Map → Nat → D1StageSplit.st0.F.S → D1StageSplit.st0.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St D1StageSplit.st0.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB D1StageSplit.st0.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) D1StageSplit.rs0 D1StageSplit.st0.wr D1StageSplit.s0 D1StageSplit.st0.s2 D1StageSplit.st0.s0
      D1StageSplit.st0.s2.ffi) S t C) : RelB D1StageSplit.st0.F FR W stk M ν K D1StageSplit.s1 S t C :=
  merged_relB D1StageSplit.iso0 D1StageSplit.stFoot0 D1StageSplit.wrNodup0 D1StageSplit.wrBound0 D1StageSplit.trace0 D1StageSplit.mheap0
    D1StageSplit.mnext0 D1StageSplit.mctl0 D1StageSplit.mstack0 D1StageSplit.mjobs0 D1StageSplit.mffi0 D1StageSplit.mtrace0 D1StageSplit.mstores0 h

def D1StageSplit.arrEl0_2665 : List Val := []
kernel_rfl D1StageSplit.arrE0_2665 : arrOf D1StageSplit.s1 2665 = arrOf D1StageSplit.s0 2665 ++ D1StageSplit.arrEl0_2665
kernel_rfl D1StageSplit.arrA0_2665 : isArrB D1StageSplit.s1 2665 = true
theorem D1StageSplit.arr0_2665 : ∃ o, D1StageSplit.s1.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf D1StageSplit.s0 2665 ++ D1StageSplit.arrEl0_2665) :=
  arrExt_of D1StageSplit.arrE0_2665 D1StageSplit.arrA0_2665
kernel_rfl D1StageSplit.arrN0_2665 : numRefsB D1StageSplit.S0.tab.length D1StageSplit.arrEl0_2665 = true
theorem D1StageSplit.arrR0_2665 : Prefill.NumRefs D1StageSplit.S0.tab.length D1StageSplit.arrEl0_2665 := numRefs_of D1StageSplit.arrN0_2665

kernel_rfl D1StageSplit.w4910k0 : isArrB D1StageSplit.s1 4910 = false
theorem D1StageSplit.keep0 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP D1StageSplit.s0 q) D1StageSplit.s1 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of D1StageSplit.w4910k0 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := D1StageSplit.arr0_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [D1StageSplit.arrEl0_2665]

end Host.Load.Run.Tpl
