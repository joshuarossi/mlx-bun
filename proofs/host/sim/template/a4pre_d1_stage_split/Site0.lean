import host.sim.template.a4pre_d1_stage_split.H0
import host.sim.template.a4pre_d1_stage_split.st0.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `D1StageSplit`: `nps_FIN_first__start__g1_FIN_first` (`nextPrefillStep`), the call state `D1StageSplit.s0`, the merged state `D1StageSplit.s1`,
the site template `D1StageSplit.st0` (σ = `Map.id`, θ the identity at its own site): the merge.
The footprint's facts are in `SiteF0`. -/

kernel_rfl D1StageSplit.iso0 : D1StageSplit.st0.s0 = { D1StageSplit.s0 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def D1StageSplit.rs0 : List Frame := D1StageSplit.s0.stack
kernel_rfl D1StageSplit.n0_0 : D1StageSplit.S0.tab.length = 14
kernel_rfl D1StageSplit.tab0_0 : D1StageSplit.st0.S0.tab = D1StageSplit.S0.tab

/-- The fresh variables of the stage's results. -/
def D1StageSplit.ws0 : List Nat := [1000, 1001, 1002]
kernel_rfl D1StageSplit.fresh0 : (D1StageSplit.S0.tab.all fun e => D1StageSplit.ws0.all fun v => e.noVar v) &&
    (D1StageSplit.S0.oracle.all fun q => D1StageSplit.ws0.all fun v => q.noVar v) = true
kernel_rfl D1StageSplit.mergeTab0 : D1StageSplit.S1.tab = D1StageSplit.S0.tab ++ Conv.resTab D1StageSplit.ws0
kernel_rfl D1StageSplit.mergeLen0 : D1StageSplit.st0.S2.tab.length - D1StageSplit.st0.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`D1StageSplit.merged0`, `merged_relB`).
kernel_rfl D1StageSplit.mheap0 : D1StageSplit.s1.heap = D1StageSplit.st0.s2.heap
kernel_rfl D1StageSplit.mnext0 : D1StageSplit.s1.next = D1StageSplit.st0.s2.next
kernel_rfl D1StageSplit.mctl0 : D1StageSplit.s1.ctl = D1StageSplit.st0.s2.ctl
kernel_rfl D1StageSplit.mstack0 : D1StageSplit.s1.stack = D1StageSplit.st0.s2.stack ++ D1StageSplit.s0.stack
kernel_rfl D1StageSplit.mjobs0 : D1StageSplit.s1.jobs = D1StageSplit.st0.s2.jobs
kernel_rfl D1StageSplit.mffi0 : D1StageSplit.s1.ffi = D1StageSplit.st0.s2.ffi
kernel_rfl D1StageSplit.mtrace0 : D1StageSplit.s1.trace = D1StageSplit.st0.s2.trace
kernel_rfl D1StageSplit.mstores0 : D1StageSplit.s1.stores = D1StageSplit.st0.s2.stores

end Host.Load.Run.Tpl
