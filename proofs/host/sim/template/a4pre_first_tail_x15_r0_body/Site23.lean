import host.sim.template.a4pre_first_tail_x15_r0_body.H7
import host.sim.template.a4pre_first_tail_x15_r0_body.st23.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 23 of chain `PRE_first_tail_x15_r0_body`: `plan__g23__g24` (`plan`), the call state `PRE_first_tail_x15_r0_body.s229`, the merged state `PRE_first_tail_x15_r0_body.s230`,
the site template `PRE_first_tail_x15_r0_body.st23` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s231`: the merge.
The footprint's facts are in `SiteF23`, the compaction's in `SiteC23`, `SiteK23`, `SiteNa23`, `SiteNb23`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso23 : PRE_first_tail_x15_r0_body.st23.s0 = { PRE_first_tail_x15_r0_body.s229 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs23 : List Frame := PRE_first_tail_x15_r0_body.s229.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_23 : PRE_first_tail_x15_r0_body.S229.tab.length = 1036
kernel_rfl PRE_first_tail_x15_r0_body.tab0_23 : PRE_first_tail_x15_r0_body.st23.S0.tab = PRE_first_tail_x15_r0_body.S229.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws23 : List Nat := [1389, 1390, 1391]
kernel_rfl PRE_first_tail_x15_r0_body.fresh23 : (PRE_first_tail_x15_r0_body.S229.tab.all fun e => PRE_first_tail_x15_r0_body.ws23.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S229.oracle.all fun q => PRE_first_tail_x15_r0_body.ws23.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab23 : PRE_first_tail_x15_r0_body.S230.tab = PRE_first_tail_x15_r0_body.S229.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws23
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen23 : PRE_first_tail_x15_r0_body.st23.S2.tab.length - PRE_first_tail_x15_r0_body.st23.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged23`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap23 : PRE_first_tail_x15_r0_body.s230.heap = PRE_first_tail_x15_r0_body.st23.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext23 : PRE_first_tail_x15_r0_body.s230.next = PRE_first_tail_x15_r0_body.st23.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl23 : PRE_first_tail_x15_r0_body.s230.ctl = PRE_first_tail_x15_r0_body.st23.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack23 : PRE_first_tail_x15_r0_body.s230.stack = PRE_first_tail_x15_r0_body.st23.s2.stack ++ PRE_first_tail_x15_r0_body.s229.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs23 : PRE_first_tail_x15_r0_body.s230.jobs = PRE_first_tail_x15_r0_body.st23.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi23 : PRE_first_tail_x15_r0_body.s230.ffi = PRE_first_tail_x15_r0_body.st23.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace23 : PRE_first_tail_x15_r0_body.s230.trace = PRE_first_tail_x15_r0_body.st23.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores23 : PRE_first_tail_x15_r0_body.s230.stores = PRE_first_tail_x15_r0_body.st23.s2.stores

end Host.Load.Run.Tpl
