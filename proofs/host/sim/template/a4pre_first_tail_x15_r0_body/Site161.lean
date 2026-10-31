import host.sim.template.a4pre_first_tail_x15_r0_body.H48
import host.sim.template.a4pre_first_tail_x15_r0_body.st161.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 161 of chain `PRE_first_tail_x15_r0_body`: `plan__g161__g162` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1552`, the merged state `PRE_first_tail_x15_r0_body.s1553`,
the site template `PRE_first_tail_x15_r0_body.st161` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1554`: the merge.
The footprint's facts are in `SiteF161`, the compaction's in `SiteC161`, `SiteK161`, `SiteNa161`, `SiteNb161`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso161 : PRE_first_tail_x15_r0_body.st161.s0 = { PRE_first_tail_x15_r0_body.s1552 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs161 : List Frame := PRE_first_tail_x15_r0_body.s1552.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_161 : PRE_first_tail_x15_r0_body.S1552.tab.length = 6937
kernel_rfl PRE_first_tail_x15_r0_body.tab0_161 : PRE_first_tail_x15_r0_body.st161.S0.tab = PRE_first_tail_x15_r0_body.S1552.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws161 : List Nat := [3710, 3711, 3712]
kernel_rfl PRE_first_tail_x15_r0_body.fresh161 : (PRE_first_tail_x15_r0_body.S1552.tab.all fun e => PRE_first_tail_x15_r0_body.ws161.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1552.oracle.all fun q => PRE_first_tail_x15_r0_body.ws161.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab161 : PRE_first_tail_x15_r0_body.S1553.tab = PRE_first_tail_x15_r0_body.S1552.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws161
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen161 : PRE_first_tail_x15_r0_body.st161.S2.tab.length - PRE_first_tail_x15_r0_body.st161.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged161`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap161 : PRE_first_tail_x15_r0_body.s1553.heap = PRE_first_tail_x15_r0_body.st161.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext161 : PRE_first_tail_x15_r0_body.s1553.next = PRE_first_tail_x15_r0_body.st161.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl161 : PRE_first_tail_x15_r0_body.s1553.ctl = PRE_first_tail_x15_r0_body.st161.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack161 : PRE_first_tail_x15_r0_body.s1553.stack = PRE_first_tail_x15_r0_body.st161.s2.stack ++ PRE_first_tail_x15_r0_body.s1552.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs161 : PRE_first_tail_x15_r0_body.s1553.jobs = PRE_first_tail_x15_r0_body.st161.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi161 : PRE_first_tail_x15_r0_body.s1553.ffi = PRE_first_tail_x15_r0_body.st161.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace161 : PRE_first_tail_x15_r0_body.s1553.trace = PRE_first_tail_x15_r0_body.st161.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores161 : PRE_first_tail_x15_r0_body.s1553.stores = PRE_first_tail_x15_r0_body.st161.s2.stores

end Host.Load.Run.Tpl
