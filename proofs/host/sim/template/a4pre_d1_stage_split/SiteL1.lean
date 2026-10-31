import host.sim.template.a4pre_d1_stage_split.Site1
import host.sim.template.a4pre_d1_stage_split.SiteF1
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 1 of chain `D1StageSplit`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `D1StageSplit.s21`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl D1StageSplit.srvO1 : D1StageSplit.st1.S0.oracle = D1StageSplit.st1.O
kernel_rfl D1StageSplit.wr0B1 : D1StageSplit.st1.wr.all (fun b => !Nat.blt b D1StageSplit.st1.s0.next || (D1StageSplit.st1.s0.heap.get b).isSome) = true
theorem D1StageSplit.stFoot1 : Conv.StageFoot D1StageSplit.st1.wr D1StageSplit.st1.s0 D1StageSplit.st1.s2 :=
  stageFoot_of D1StageSplit.st1.heapFoot D1StageSplit.wrNodup1 D1StageSplit.wrBound1 D1StageSplit.wr0B1 D1StageSplit.st1.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem D1StageSplit.merged1 {FR : Map → Nat → D1StageSplit.st1.F.S → D1StageSplit.st1.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St D1StageSplit.st1.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB D1StageSplit.st1.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) D1StageSplit.rs1 D1StageSplit.st1.wr D1StageSplit.s20 D1StageSplit.st1.s2 D1StageSplit.st1.s0
      D1StageSplit.st1.s2.ffi) S t C) : RelB D1StageSplit.st1.F FR W stk M ν K D1StageSplit.s21 S t C :=
  merged_relB D1StageSplit.iso1 D1StageSplit.stFoot1 D1StageSplit.wrNodup1 D1StageSplit.wrBound1 D1StageSplit.trace1 D1StageSplit.mheap1
    D1StageSplit.mnext1 D1StageSplit.mctl1 D1StageSplit.mstack1 D1StageSplit.mjobs1 D1StageSplit.mffi1 D1StageSplit.mtrace1 D1StageSplit.mstores1 h

def D1StageSplit.arrEl1_2665 : List Val := []
kernel_rfl D1StageSplit.arrE1_2665 : arrOf D1StageSplit.s21 2665 = arrOf D1StageSplit.s0 2665 ++ D1StageSplit.arrEl1_2665
kernel_rfl D1StageSplit.arrA1_2665 : isArrB D1StageSplit.s21 2665 = true
theorem D1StageSplit.arr1_2665 : ∃ o, D1StageSplit.s21.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf D1StageSplit.s0 2665 ++ D1StageSplit.arrEl1_2665) :=
  arrExt_of D1StageSplit.arrE1_2665 D1StageSplit.arrA1_2665
kernel_rfl D1StageSplit.arrN1_2665 : numRefsB D1StageSplit.S0.tab.length D1StageSplit.arrEl1_2665 = true
theorem D1StageSplit.arrR1_2665 : Prefill.NumRefs D1StageSplit.S0.tab.length D1StageSplit.arrEl1_2665 := numRefs_of D1StageSplit.arrN1_2665

def D1StageSplit.arrEl1_2673479 : List Val := []
kernel_rfl D1StageSplit.arrE1_2673479 : arrOf D1StageSplit.s21 2673479 = arrOf D1StageSplit.s0 2673479 ++ D1StageSplit.arrEl1_2673479
kernel_rfl D1StageSplit.arrA1_2673479 : isArrB D1StageSplit.s21 2673479 = true
theorem D1StageSplit.arr1_2673479 : ∃ o, D1StageSplit.s21.heap.get 2673479 = some (.obj o) ∧ o.kind = .array (arrOf D1StageSplit.s0 2673479 ++ D1StageSplit.arrEl1_2673479) :=
  arrExt_of D1StageSplit.arrE1_2673479 D1StageSplit.arrA1_2673479
kernel_rfl D1StageSplit.arrN1_2673479 : numRefsB D1StageSplit.S0.tab.length D1StageSplit.arrEl1_2673479 = true
theorem D1StageSplit.arrR1_2673479 : Prefill.NumRefs D1StageSplit.S0.tab.length D1StageSplit.arrEl1_2673479 := numRefs_of D1StageSplit.arrN1_2673479

kernel_rfl D1StageSplit.w4910k1 : isArrB D1StageSplit.s21 4910 = false
theorem D1StageSplit.keep1 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP D1StageSplit.s0 q) D1StageSplit.s21 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of D1StageSplit.w4910k1 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := D1StageSplit.arr1_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [D1StageSplit.arrEl1_2665]

end Host.Load.Run.Tpl
