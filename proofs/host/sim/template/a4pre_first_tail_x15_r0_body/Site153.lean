import host.sim.template.a4pre_first_tail_x15_r0_body.H46
import host.sim.template.a4pre_first_tail_x15_r0_body.st153.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 153 of chain `PRE_first_tail_x15_r0_body`: `kvW__g153__g154` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s1482`, the merged state `PRE_first_tail_x15_r0_body.s1483`,
the site template `PRE_first_tail_x15_r0_body.st153` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1484`: the merge.
The footprint's facts are in `SiteF153`, the compaction's in `SiteC153`, `SiteK153`, `SiteNa153`, `SiteNb153`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso153 : PRE_first_tail_x15_r0_body.st153.s0 = { PRE_first_tail_x15_r0_body.s1482 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs153 : List Frame := PRE_first_tail_x15_r0_body.s1482.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_153 : PRE_first_tail_x15_r0_body.S1482.tab.length = 6630
kernel_rfl PRE_first_tail_x15_r0_body.tab0_153 : PRE_first_tail_x15_r0_body.st153.S0.tab = PRE_first_tail_x15_r0_body.S1482.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws153 : List Nat := [3574, 3575, 3576, 3577, 3578, 3579, 3580, 3581, 3582, 3583, 3584, 3585, 3586, 3587, 3588, 3589, 3590]
kernel_rfl PRE_first_tail_x15_r0_body.fresh153 : (PRE_first_tail_x15_r0_body.S1482.tab.all fun e => PRE_first_tail_x15_r0_body.ws153.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1482.oracle.all fun q => PRE_first_tail_x15_r0_body.ws153.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab153 : PRE_first_tail_x15_r0_body.S1483.tab = PRE_first_tail_x15_r0_body.S1482.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws153
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen153 : PRE_first_tail_x15_r0_body.st153.S3.tab.length - PRE_first_tail_x15_r0_body.st153.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged153`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap153 : PRE_first_tail_x15_r0_body.s1483.heap = PRE_first_tail_x15_r0_body.st153.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext153 : PRE_first_tail_x15_r0_body.s1483.next = PRE_first_tail_x15_r0_body.st153.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl153 : PRE_first_tail_x15_r0_body.s1483.ctl = PRE_first_tail_x15_r0_body.st153.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack153 : PRE_first_tail_x15_r0_body.s1483.stack = PRE_first_tail_x15_r0_body.st153.s3.stack ++ PRE_first_tail_x15_r0_body.s1482.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs153 : PRE_first_tail_x15_r0_body.s1483.jobs = PRE_first_tail_x15_r0_body.st153.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi153 : PRE_first_tail_x15_r0_body.s1483.ffi = PRE_first_tail_x15_r0_body.st153.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace153 : PRE_first_tail_x15_r0_body.s1483.trace = PRE_first_tail_x15_r0_body.st153.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores153 : PRE_first_tail_x15_r0_body.s1483.stores = PRE_first_tail_x15_r0_body.st153.s3.stores

end Host.Load.Run.Tpl
