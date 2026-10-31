import host.sim.template.a4pre_first_tail_x15_r0_body.H37
import host.sim.template.a4pre_first_tail_x15_r0_body.st137.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 137 of chain `PRE_first_tail_x15_r0_body`: `plan__g137__g138` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1207`, the merged state `PRE_first_tail_x15_r0_body.s1208`,
the site template `PRE_first_tail_x15_r0_body.st137` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1209`: the merge.
The footprint's facts are in `SiteF137`, the compaction's in `SiteC137`, `SiteK137`, `SiteNa137`, `SiteNb137`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso137 : PRE_first_tail_x15_r0_body.st137.s0 = { PRE_first_tail_x15_r0_body.s1207 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs137 : List Frame := PRE_first_tail_x15_r0_body.s1207.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_137 : PRE_first_tail_x15_r0_body.S1207.tab.length = 5911
kernel_rfl PRE_first_tail_x15_r0_body.tab0_137 : PRE_first_tail_x15_r0_body.st137.S0.tab = PRE_first_tail_x15_r0_body.S1207.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws137 : List Nat := [3294, 3295, 3296, 3297, 3298, 3299, 3300, 3301, 3302]
kernel_rfl PRE_first_tail_x15_r0_body.fresh137 : (PRE_first_tail_x15_r0_body.S1207.tab.all fun e => PRE_first_tail_x15_r0_body.ws137.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1207.oracle.all fun q => PRE_first_tail_x15_r0_body.ws137.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab137 : PRE_first_tail_x15_r0_body.S1208.tab = PRE_first_tail_x15_r0_body.S1207.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws137
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen137 : PRE_first_tail_x15_r0_body.st137.S2.tab.length - PRE_first_tail_x15_r0_body.st137.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged137`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap137 : PRE_first_tail_x15_r0_body.s1208.heap = PRE_first_tail_x15_r0_body.st137.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext137 : PRE_first_tail_x15_r0_body.s1208.next = PRE_first_tail_x15_r0_body.st137.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl137 : PRE_first_tail_x15_r0_body.s1208.ctl = PRE_first_tail_x15_r0_body.st137.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack137 : PRE_first_tail_x15_r0_body.s1208.stack = PRE_first_tail_x15_r0_body.st137.s2.stack ++ PRE_first_tail_x15_r0_body.s1207.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs137 : PRE_first_tail_x15_r0_body.s1208.jobs = PRE_first_tail_x15_r0_body.st137.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi137 : PRE_first_tail_x15_r0_body.s1208.ffi = PRE_first_tail_x15_r0_body.st137.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace137 : PRE_first_tail_x15_r0_body.s1208.trace = PRE_first_tail_x15_r0_body.st137.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores137 : PRE_first_tail_x15_r0_body.s1208.stores = PRE_first_tail_x15_r0_body.st137.s2.stores

end Host.Load.Run.Tpl
