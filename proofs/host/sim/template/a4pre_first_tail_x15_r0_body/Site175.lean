import host.sim.template.a4pre_first_tail_x15_r0_body.H48
import host.sim.template.a4pre_first_tail_x15_r0_body.st175.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 175 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g175__g176` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1545`, the merged state `PRE_first_tail_x15_r0_body.s1546`,
the site template `PRE_first_tail_x15_r0_body.st175` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1547`: the merge.
The footprint's facts are in `SiteF175`, the compaction's in `SiteC175`, `SiteK175`, `SiteNa175`, `SiteNb175`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso175 : PRE_first_tail_x15_r0_body.st175.s0 = { PRE_first_tail_x15_r0_body.s1545 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs175 : List Frame := PRE_first_tail_x15_r0_body.s1545.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_175 : PRE_first_tail_x15_r0_body.S1545.tab.length = 7562
kernel_rfl PRE_first_tail_x15_r0_body.tab0_175 : PRE_first_tail_x15_r0_body.st175.S0.tab = PRE_first_tail_x15_r0_body.S1545.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws175 : List Nat := [3979, 3980]
kernel_rfl PRE_first_tail_x15_r0_body.fresh175 : (PRE_first_tail_x15_r0_body.S1545.tab.all fun e => PRE_first_tail_x15_r0_body.ws175.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1545.oracle.all fun q => PRE_first_tail_x15_r0_body.ws175.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab175 : PRE_first_tail_x15_r0_body.S1546.tab = PRE_first_tail_x15_r0_body.S1545.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws175
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen175 : PRE_first_tail_x15_r0_body.st175.S2.tab.length - PRE_first_tail_x15_r0_body.st175.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged175`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap175 : PRE_first_tail_x15_r0_body.s1546.heap = PRE_first_tail_x15_r0_body.st175.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext175 : PRE_first_tail_x15_r0_body.s1546.next = PRE_first_tail_x15_r0_body.st175.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl175 : PRE_first_tail_x15_r0_body.s1546.ctl = PRE_first_tail_x15_r0_body.st175.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack175 : PRE_first_tail_x15_r0_body.s1546.stack = PRE_first_tail_x15_r0_body.st175.s2.stack ++ PRE_first_tail_x15_r0_body.s1545.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs175 : PRE_first_tail_x15_r0_body.s1546.jobs = PRE_first_tail_x15_r0_body.st175.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi175 : PRE_first_tail_x15_r0_body.s1546.ffi = PRE_first_tail_x15_r0_body.st175.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace175 : PRE_first_tail_x15_r0_body.s1546.trace = PRE_first_tail_x15_r0_body.st175.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores175 : PRE_first_tail_x15_r0_body.s1546.stores = PRE_first_tail_x15_r0_body.st175.s2.stores

end Host.Load.Run.Tpl
