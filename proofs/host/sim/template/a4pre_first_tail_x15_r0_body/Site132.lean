import host.sim.template.a4pre_first_tail_x15_r0_body.H40
import host.sim.template.a4pre_first_tail_x15_r0_body.st132.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 132 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g132__g133` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1281`, the merged state `PRE_first_tail_x15_r0_body.s1282`,
the site template `PRE_first_tail_x15_r0_body.st132` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1283`: the merge.
The footprint's facts are in `SiteF132`, the compaction's in `SiteC132`, `SiteK132`, `SiteNa132`, `SiteNb132`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso132 : PRE_first_tail_x15_r0_body.st132.s0 = { PRE_first_tail_x15_r0_body.s1281 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs132 : List Frame := PRE_first_tail_x15_r0_body.s1281.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_132 : PRE_first_tail_x15_r0_body.S1281.tab.length = 5726
kernel_rfl PRE_first_tail_x15_r0_body.tab0_132 : PRE_first_tail_x15_r0_body.st132.S0.tab = PRE_first_tail_x15_r0_body.S1281.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws132 : List Nat := [3189, 3190, 3191, 3192, 3193, 3194, 3195, 3196, 3197, 3198, 3199, 3200, 3201, 3202, 3203, 3204, 3205, 3206, 3207, 3208, 3209, 3210, 3211, 3212, 3213, 3214, 3215, 3216, 3217, 3218, 3219]
kernel_rfl PRE_first_tail_x15_r0_body.fresh132 : (PRE_first_tail_x15_r0_body.S1281.tab.all fun e => PRE_first_tail_x15_r0_body.ws132.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1281.oracle.all fun q => PRE_first_tail_x15_r0_body.ws132.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab132 : PRE_first_tail_x15_r0_body.S1282.tab = PRE_first_tail_x15_r0_body.S1281.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws132
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen132 : PRE_first_tail_x15_r0_body.st132.S5.tab.length - PRE_first_tail_x15_r0_body.st132.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged132`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap132 : PRE_first_tail_x15_r0_body.s1282.heap = PRE_first_tail_x15_r0_body.st132.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext132 : PRE_first_tail_x15_r0_body.s1282.next = PRE_first_tail_x15_r0_body.st132.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl132 : PRE_first_tail_x15_r0_body.s1282.ctl = PRE_first_tail_x15_r0_body.st132.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack132 : PRE_first_tail_x15_r0_body.s1282.stack = PRE_first_tail_x15_r0_body.st132.s5.stack ++ PRE_first_tail_x15_r0_body.s1281.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs132 : PRE_first_tail_x15_r0_body.s1282.jobs = PRE_first_tail_x15_r0_body.st132.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi132 : PRE_first_tail_x15_r0_body.s1282.ffi = PRE_first_tail_x15_r0_body.st132.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace132 : PRE_first_tail_x15_r0_body.s1282.trace = PRE_first_tail_x15_r0_body.st132.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores132 : PRE_first_tail_x15_r0_body.s1282.stores = PRE_first_tail_x15_r0_body.st132.s5.stores

end Host.Load.Run.Tpl
