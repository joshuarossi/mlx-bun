import host.sim.template.a4pre_first_tail_x15_r0_body.H32
import host.sim.template.a4pre_first_tail_x15_r0_body.st105.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 105 of chain `PRE_first_tail_x15_r0_body`: `kvW__g105__g106` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s1022`, the merged state `PRE_first_tail_x15_r0_body.s1023`,
the site template `PRE_first_tail_x15_r0_body.st105` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1024`: the merge.
The footprint's facts are in `SiteF105`, the compaction's in `SiteC105`, `SiteK105`, `SiteNa105`, `SiteNb105`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso105 : PRE_first_tail_x15_r0_body.st105.s0 = { PRE_first_tail_x15_r0_body.s1022 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs105 : List Frame := PRE_first_tail_x15_r0_body.s1022.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_105 : PRE_first_tail_x15_r0_body.S1022.tab.length = 4578
kernel_rfl PRE_first_tail_x15_r0_body.tab0_105 : PRE_first_tail_x15_r0_body.st105.S0.tab = PRE_first_tail_x15_r0_body.S1022.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws105 : List Nat := [2772, 2773, 2774, 2775, 2776, 2777, 2778, 2779, 2780, 2781, 2782, 2783, 2784, 2785, 2786, 2787, 2788]
kernel_rfl PRE_first_tail_x15_r0_body.fresh105 : (PRE_first_tail_x15_r0_body.S1022.tab.all fun e => PRE_first_tail_x15_r0_body.ws105.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1022.oracle.all fun q => PRE_first_tail_x15_r0_body.ws105.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab105 : PRE_first_tail_x15_r0_body.S1023.tab = PRE_first_tail_x15_r0_body.S1022.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws105
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen105 : PRE_first_tail_x15_r0_body.st105.S3.tab.length - PRE_first_tail_x15_r0_body.st105.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged105`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap105 : PRE_first_tail_x15_r0_body.s1023.heap = PRE_first_tail_x15_r0_body.st105.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext105 : PRE_first_tail_x15_r0_body.s1023.next = PRE_first_tail_x15_r0_body.st105.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl105 : PRE_first_tail_x15_r0_body.s1023.ctl = PRE_first_tail_x15_r0_body.st105.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack105 : PRE_first_tail_x15_r0_body.s1023.stack = PRE_first_tail_x15_r0_body.st105.s3.stack ++ PRE_first_tail_x15_r0_body.s1022.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs105 : PRE_first_tail_x15_r0_body.s1023.jobs = PRE_first_tail_x15_r0_body.st105.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi105 : PRE_first_tail_x15_r0_body.s1023.ffi = PRE_first_tail_x15_r0_body.st105.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace105 : PRE_first_tail_x15_r0_body.s1023.trace = PRE_first_tail_x15_r0_body.st105.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores105 : PRE_first_tail_x15_r0_body.s1023.stores = PRE_first_tail_x15_r0_body.st105.s3.stores

end Host.Load.Run.Tpl
