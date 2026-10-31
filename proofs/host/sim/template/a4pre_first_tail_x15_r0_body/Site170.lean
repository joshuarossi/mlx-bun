import host.sim.template.a4pre_first_tail_x15_r0_body.H46
import host.sim.template.a4pre_first_tail_x15_r0_body.st170.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 170 of chain `PRE_first_tail_x15_r0_body`: `plan__g170__g171` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1495`, the merged state `PRE_first_tail_x15_r0_body.s1496`,
the site template `PRE_first_tail_x15_r0_body.st170` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1497`: the merge.
The footprint's facts are in `SiteF170`, the compaction's in `SiteC170`, `SiteK170`, `SiteNa170`, `SiteNb170`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso170 : PRE_first_tail_x15_r0_body.st170.s0 = { PRE_first_tail_x15_r0_body.s1495 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs170 : List Frame := PRE_first_tail_x15_r0_body.s1495.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_170 : PRE_first_tail_x15_r0_body.S1495.tab.length = 7321
kernel_rfl PRE_first_tail_x15_r0_body.tab0_170 : PRE_first_tail_x15_r0_body.st170.S0.tab = PRE_first_tail_x15_r0_body.S1495.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws170 : List Nat := [3861, 3862, 3863, 3864, 3865, 3866, 3867, 3868, 3869]
kernel_rfl PRE_first_tail_x15_r0_body.fresh170 : (PRE_first_tail_x15_r0_body.S1495.tab.all fun e => PRE_first_tail_x15_r0_body.ws170.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1495.oracle.all fun q => PRE_first_tail_x15_r0_body.ws170.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab170 : PRE_first_tail_x15_r0_body.S1496.tab = PRE_first_tail_x15_r0_body.S1495.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws170
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen170 : PRE_first_tail_x15_r0_body.st170.S2.tab.length - PRE_first_tail_x15_r0_body.st170.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged170`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap170 : PRE_first_tail_x15_r0_body.s1496.heap = PRE_first_tail_x15_r0_body.st170.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext170 : PRE_first_tail_x15_r0_body.s1496.next = PRE_first_tail_x15_r0_body.st170.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl170 : PRE_first_tail_x15_r0_body.s1496.ctl = PRE_first_tail_x15_r0_body.st170.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack170 : PRE_first_tail_x15_r0_body.s1496.stack = PRE_first_tail_x15_r0_body.st170.s2.stack ++ PRE_first_tail_x15_r0_body.s1495.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs170 : PRE_first_tail_x15_r0_body.s1496.jobs = PRE_first_tail_x15_r0_body.st170.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi170 : PRE_first_tail_x15_r0_body.s1496.ffi = PRE_first_tail_x15_r0_body.st170.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace170 : PRE_first_tail_x15_r0_body.s1496.trace = PRE_first_tail_x15_r0_body.st170.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores170 : PRE_first_tail_x15_r0_body.s1496.stores = PRE_first_tail_x15_r0_body.st170.s2.stores

end Host.Load.Run.Tpl
