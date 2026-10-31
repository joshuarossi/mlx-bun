import host.sim.template.a4pre_first_tail_x15_r0_body.H43
import host.sim.template.a4pre_first_tail_x15_r0_body.st143.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 143 of chain `PRE_first_tail_x15_r0_body`: `plan__g143__g144` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1379`, the merged state `PRE_first_tail_x15_r0_body.s1380`,
the site template `PRE_first_tail_x15_r0_body.st143` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1381`: the merge.
The footprint's facts are in `SiteF143`, the compaction's in `SiteC143`, `SiteK143`, `SiteNa143`, `SiteNb143`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso143 : PRE_first_tail_x15_r0_body.st143.s0 = { PRE_first_tail_x15_r0_body.s1379 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs143 : List Frame := PRE_first_tail_x15_r0_body.s1379.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_143 : PRE_first_tail_x15_r0_body.S1379.tab.length = 6166
kernel_rfl PRE_first_tail_x15_r0_body.tab0_143 : PRE_first_tail_x15_r0_body.st143.S0.tab = PRE_first_tail_x15_r0_body.S1379.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws143 : List Nat := [3391, 3392, 3393, 3394, 3395, 3396, 3397, 3398, 3399]
kernel_rfl PRE_first_tail_x15_r0_body.fresh143 : (PRE_first_tail_x15_r0_body.S1379.tab.all fun e => PRE_first_tail_x15_r0_body.ws143.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1379.oracle.all fun q => PRE_first_tail_x15_r0_body.ws143.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab143 : PRE_first_tail_x15_r0_body.S1380.tab = PRE_first_tail_x15_r0_body.S1379.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws143
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen143 : PRE_first_tail_x15_r0_body.st143.S2.tab.length - PRE_first_tail_x15_r0_body.st143.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged143`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap143 : PRE_first_tail_x15_r0_body.s1380.heap = PRE_first_tail_x15_r0_body.st143.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext143 : PRE_first_tail_x15_r0_body.s1380.next = PRE_first_tail_x15_r0_body.st143.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl143 : PRE_first_tail_x15_r0_body.s1380.ctl = PRE_first_tail_x15_r0_body.st143.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack143 : PRE_first_tail_x15_r0_body.s1380.stack = PRE_first_tail_x15_r0_body.st143.s2.stack ++ PRE_first_tail_x15_r0_body.s1379.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs143 : PRE_first_tail_x15_r0_body.s1380.jobs = PRE_first_tail_x15_r0_body.st143.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi143 : PRE_first_tail_x15_r0_body.s1380.ffi = PRE_first_tail_x15_r0_body.st143.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace143 : PRE_first_tail_x15_r0_body.s1380.trace = PRE_first_tail_x15_r0_body.st143.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores143 : PRE_first_tail_x15_r0_body.s1380.stores = PRE_first_tail_x15_r0_body.st143.s2.stores

end Host.Load.Run.Tpl
