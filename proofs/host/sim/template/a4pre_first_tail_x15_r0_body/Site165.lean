import host.sim.template.a4pre_first_tail_x15_r0_body.H45
import host.sim.template.a4pre_first_tail_x15_r0_body.st165.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 165 of chain `PRE_first_tail_x15_r0_body`: `kvW__g165__g166` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s1457`, the merged state `PRE_first_tail_x15_r0_body.s1458`,
the site template `PRE_first_tail_x15_r0_body.st165` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1459`: the merge.
The footprint's facts are in `SiteF165`, the compaction's in `SiteC165`, `SiteK165`, `SiteNa165`, `SiteNb165`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso165 : PRE_first_tail_x15_r0_body.st165.s0 = { PRE_first_tail_x15_r0_body.s1457 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs165 : List Frame := PRE_first_tail_x15_r0_body.s1457.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_165 : PRE_first_tail_x15_r0_body.S1457.tab.length = 7143
kernel_rfl PRE_first_tail_x15_r0_body.tab0_165 : PRE_first_tail_x15_r0_body.st165.S0.tab = PRE_first_tail_x15_r0_body.S1457.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws165 : List Nat := [3773, 3774, 3775, 3776, 3777, 3778, 3779, 3780, 3781, 3782, 3783, 3784, 3785, 3786, 3787, 3788, 3789]
kernel_rfl PRE_first_tail_x15_r0_body.fresh165 : (PRE_first_tail_x15_r0_body.S1457.tab.all fun e => PRE_first_tail_x15_r0_body.ws165.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1457.oracle.all fun q => PRE_first_tail_x15_r0_body.ws165.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab165 : PRE_first_tail_x15_r0_body.S1458.tab = PRE_first_tail_x15_r0_body.S1457.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws165
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen165 : PRE_first_tail_x15_r0_body.st165.S2.tab.length - PRE_first_tail_x15_r0_body.st165.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged165`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap165 : PRE_first_tail_x15_r0_body.s1458.heap = PRE_first_tail_x15_r0_body.st165.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext165 : PRE_first_tail_x15_r0_body.s1458.next = PRE_first_tail_x15_r0_body.st165.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl165 : PRE_first_tail_x15_r0_body.s1458.ctl = PRE_first_tail_x15_r0_body.st165.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack165 : PRE_first_tail_x15_r0_body.s1458.stack = PRE_first_tail_x15_r0_body.st165.s2.stack ++ PRE_first_tail_x15_r0_body.s1457.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs165 : PRE_first_tail_x15_r0_body.s1458.jobs = PRE_first_tail_x15_r0_body.st165.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi165 : PRE_first_tail_x15_r0_body.s1458.ffi = PRE_first_tail_x15_r0_body.st165.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace165 : PRE_first_tail_x15_r0_body.s1458.trace = PRE_first_tail_x15_r0_body.st165.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores165 : PRE_first_tail_x15_r0_body.s1458.stores = PRE_first_tail_x15_r0_body.st165.s2.stores

end Host.Load.Run.Tpl
