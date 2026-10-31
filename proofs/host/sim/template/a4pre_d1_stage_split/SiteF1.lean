import host.sim.template.a4pre_d1_stage_split.st1.Foot
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 1 of chain `D1StageSplit`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl D1StageSplit.wrNodupB1 : nodupT D1StageSplit.st1.wr PTrie.nil = true
theorem D1StageSplit.wrNodup1 : D1StageSplit.st1.wr.Nodup := (nodupT_sound D1StageSplit.wrNodupB1).2
kernel_rfl D1StageSplit.wrBoundB1 : D1StageSplit.st1.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem D1StageSplit.wrBound1 : ∀ b ∈ D1StageSplit.st1.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp D1StageSplit.wrBoundB1 b hb)
noncomputable def D1StageSplit.trFr1 := D1StageSplit.st1.s2.trace.take 0
kernel_rfl D1StageSplit.traceEq1 : D1StageSplit.st1.s2.trace = D1StageSplit.trFr1 ++ D1StageSplit.st1.s0.trace
theorem D1StageSplit.trace1 : ∃ fr, D1StageSplit.st1.s2.trace = fr ++ D1StageSplit.st1.s0.trace := ⟨_, D1StageSplit.traceEq1⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def D1StageSplit.wide1 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl D1StageSplit.wfixB1 : (D1StageSplit.wide1.all fun p => wfixB Map.id (presentB D1StageSplit.st1.s0) p.2) = true
theorem D1StageSplit.wfix1 : ∀ p ∈ D1StageSplit.wide1, WFix Map.id (Present D1StageSplit.st1.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp D1StageSplit.wfixB1 p hp)

end Host.Load.Run.Tpl
