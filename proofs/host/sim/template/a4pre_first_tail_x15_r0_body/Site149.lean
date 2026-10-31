import host.sim.template.a4pre_first_tail_x15_r0_body.H41
import host.sim.template.a4pre_first_tail_x15_r0_body.st149.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 149 of chain `PRE_first_tail_x15_r0_body`: `plan__g149__g150` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1312`, the merged state `PRE_first_tail_x15_r0_body.s1313`,
the site template `PRE_first_tail_x15_r0_body.st149` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1314`: the merge.
The footprint's facts are in `SiteF149`, the compaction's in `SiteC149`, `SiteK149`, `SiteNa149`, `SiteNb149`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso149 : PRE_first_tail_x15_r0_body.st149.s0 = { PRE_first_tail_x15_r0_body.s1312 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs149 : List Frame := PRE_first_tail_x15_r0_body.s1312.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_149 : PRE_first_tail_x15_r0_body.S1312.tab.length = 6424
kernel_rfl PRE_first_tail_x15_r0_body.tab0_149 : PRE_first_tail_x15_r0_body.st149.S0.tab = PRE_first_tail_x15_r0_body.S1312.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws149 : List Nat := [3511, 3512, 3513, 3514, 3515, 3516, 3517, 3518, 3519]
kernel_rfl PRE_first_tail_x15_r0_body.fresh149 : (PRE_first_tail_x15_r0_body.S1312.tab.all fun e => PRE_first_tail_x15_r0_body.ws149.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1312.oracle.all fun q => PRE_first_tail_x15_r0_body.ws149.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab149 : PRE_first_tail_x15_r0_body.S1313.tab = PRE_first_tail_x15_r0_body.S1312.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws149
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen149 : PRE_first_tail_x15_r0_body.st149.S2.tab.length - PRE_first_tail_x15_r0_body.st149.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged149`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap149 : PRE_first_tail_x15_r0_body.s1313.heap = PRE_first_tail_x15_r0_body.st149.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext149 : PRE_first_tail_x15_r0_body.s1313.next = PRE_first_tail_x15_r0_body.st149.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl149 : PRE_first_tail_x15_r0_body.s1313.ctl = PRE_first_tail_x15_r0_body.st149.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack149 : PRE_first_tail_x15_r0_body.s1313.stack = PRE_first_tail_x15_r0_body.st149.s2.stack ++ PRE_first_tail_x15_r0_body.s1312.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs149 : PRE_first_tail_x15_r0_body.s1313.jobs = PRE_first_tail_x15_r0_body.st149.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi149 : PRE_first_tail_x15_r0_body.s1313.ffi = PRE_first_tail_x15_r0_body.st149.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace149 : PRE_first_tail_x15_r0_body.s1313.trace = PRE_first_tail_x15_r0_body.st149.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores149 : PRE_first_tail_x15_r0_body.s1313.stores = PRE_first_tail_x15_r0_body.st149.s2.stores

end Host.Load.Run.Tpl
