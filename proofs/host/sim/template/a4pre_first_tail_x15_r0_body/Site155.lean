import host.sim.template.a4pre_first_tail_x15_r0_body.H42
import host.sim.template.a4pre_first_tail_x15_r0_body.st155.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 155 of chain `PRE_first_tail_x15_r0_body`: `plan__g155__g156` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1363`, the merged state `PRE_first_tail_x15_r0_body.s1364`,
the site template `PRE_first_tail_x15_r0_body.st155` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1365`: the merge.
The footprint's facts are in `SiteF155`, the compaction's in `SiteC155`, `SiteK155`, `SiteNa155`, `SiteNb155`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso155 : PRE_first_tail_x15_r0_body.st155.s0 = { PRE_first_tail_x15_r0_body.s1363 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs155 : List Frame := PRE_first_tail_x15_r0_body.s1363.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_155 : PRE_first_tail_x15_r0_body.S1363.tab.length = 6679
kernel_rfl PRE_first_tail_x15_r0_body.tab0_155 : PRE_first_tail_x15_r0_body.st155.S0.tab = PRE_first_tail_x15_r0_body.S1363.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws155 : List Nat := [3602, 3603, 3604]
kernel_rfl PRE_first_tail_x15_r0_body.fresh155 : (PRE_first_tail_x15_r0_body.S1363.tab.all fun e => PRE_first_tail_x15_r0_body.ws155.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1363.oracle.all fun q => PRE_first_tail_x15_r0_body.ws155.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab155 : PRE_first_tail_x15_r0_body.S1364.tab = PRE_first_tail_x15_r0_body.S1363.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws155
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen155 : PRE_first_tail_x15_r0_body.st155.S2.tab.length - PRE_first_tail_x15_r0_body.st155.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged155`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap155 : PRE_first_tail_x15_r0_body.s1364.heap = PRE_first_tail_x15_r0_body.st155.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext155 : PRE_first_tail_x15_r0_body.s1364.next = PRE_first_tail_x15_r0_body.st155.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl155 : PRE_first_tail_x15_r0_body.s1364.ctl = PRE_first_tail_x15_r0_body.st155.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack155 : PRE_first_tail_x15_r0_body.s1364.stack = PRE_first_tail_x15_r0_body.st155.s2.stack ++ PRE_first_tail_x15_r0_body.s1363.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs155 : PRE_first_tail_x15_r0_body.s1364.jobs = PRE_first_tail_x15_r0_body.st155.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi155 : PRE_first_tail_x15_r0_body.s1364.ffi = PRE_first_tail_x15_r0_body.st155.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace155 : PRE_first_tail_x15_r0_body.s1364.trace = PRE_first_tail_x15_r0_body.st155.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores155 : PRE_first_tail_x15_r0_body.s1364.stores = PRE_first_tail_x15_r0_body.st155.s2.stores

end Host.Load.Run.Tpl
