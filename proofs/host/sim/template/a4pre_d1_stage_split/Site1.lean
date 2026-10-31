import host.sim.template.a4pre_d1_stage_split.H0
import host.sim.template.a4pre_d1_stage_split.st1.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 1 of chain `D1StageSplit`: `disp_D1__g1_FIN_first__g2_fin_first` (`prompt`), the call state `D1StageSplit.s20`, the merged state `D1StageSplit.s21`,
the site template `D1StageSplit.st1` (σ = `Map.id`, θ the identity at its own site): the merge.
The footprint's facts are in `SiteF1`. -/

kernel_rfl D1StageSplit.iso1 : D1StageSplit.st1.s0 = { D1StageSplit.s20 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def D1StageSplit.rs1 : List Frame := D1StageSplit.s20.stack
kernel_rfl D1StageSplit.n0_1 : D1StageSplit.S20.tab.length = 20
kernel_rfl D1StageSplit.tab0_1 : D1StageSplit.st1.S0.tab = D1StageSplit.S20.tab

/-- The fresh variables of the stage's results. -/
def D1StageSplit.ws1 : List Nat := []
kernel_rfl D1StageSplit.fresh1 : (D1StageSplit.S20.tab.all fun e => D1StageSplit.ws1.all fun v => e.noVar v) &&
    (D1StageSplit.S20.oracle.all fun q => D1StageSplit.ws1.all fun v => q.noVar v) = true
kernel_rfl D1StageSplit.mergeTab1 : D1StageSplit.S21.tab = D1StageSplit.S20.tab ++ Conv.resTab D1StageSplit.ws1
kernel_rfl D1StageSplit.mergeLen1 : D1StageSplit.st1.S2.tab.length - D1StageSplit.st1.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`D1StageSplit.merged1`, `merged_relB`).
kernel_rfl D1StageSplit.mheap1 : D1StageSplit.s21.heap = D1StageSplit.st1.s2.heap
kernel_rfl D1StageSplit.mnext1 : D1StageSplit.s21.next = D1StageSplit.st1.s2.next
kernel_rfl D1StageSplit.mctl1 : D1StageSplit.s21.ctl = D1StageSplit.st1.s2.ctl
kernel_rfl D1StageSplit.mstack1 : D1StageSplit.s21.stack = D1StageSplit.st1.s2.stack ++ D1StageSplit.s20.stack
kernel_rfl D1StageSplit.mjobs1 : D1StageSplit.s21.jobs = D1StageSplit.st1.s2.jobs
kernel_rfl D1StageSplit.mffi1 : D1StageSplit.s21.ffi = D1StageSplit.st1.s2.ffi
kernel_rfl D1StageSplit.mtrace1 : D1StageSplit.s21.trace = D1StageSplit.st1.s2.trace
kernel_rfl D1StageSplit.mstores1 : D1StageSplit.s21.stores = D1StageSplit.st1.s2.stores

end Host.Load.Run.Tpl
