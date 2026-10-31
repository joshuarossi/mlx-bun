import host.sim.template.a4pre_first_tail_x15_r0_body.H26
import host.sim.template.a4pre_first_tail_x15_r0_body.st96.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 96 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g96__g97` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s854`, the merged state `PRE_first_tail_x15_r0_body.s855`,
the site template `PRE_first_tail_x15_r0_body.st96` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s856`: the merge.
The footprint's facts are in `SiteF96`, the compaction's in `SiteC96`, `SiteK96`, `SiteNa96`, `SiteNb96`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso96 : PRE_first_tail_x15_r0_body.st96.s0 = { PRE_first_tail_x15_r0_body.s854 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs96 : List Frame := PRE_first_tail_x15_r0_body.s854.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_96 : PRE_first_tail_x15_r0_body.S854.tab.length = 4187
kernel_rfl PRE_first_tail_x15_r0_body.tab0_96 : PRE_first_tail_x15_r0_body.st96.S0.tab = PRE_first_tail_x15_r0_body.S854.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws96 : List Nat := [2598, 2599, 2600, 2601, 2602, 2603, 2604, 2605, 2606, 2607, 2608, 2609, 2610, 2611, 2612, 2613, 2614, 2615, 2616, 2617, 2618, 2619, 2620, 2621, 2622, 2623, 2624, 2625, 2626, 2627, 2628]
kernel_rfl PRE_first_tail_x15_r0_body.fresh96 : (PRE_first_tail_x15_r0_body.S854.tab.all fun e => PRE_first_tail_x15_r0_body.ws96.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S854.oracle.all fun q => PRE_first_tail_x15_r0_body.ws96.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab96 : PRE_first_tail_x15_r0_body.S855.tab = PRE_first_tail_x15_r0_body.S854.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws96
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen96 : PRE_first_tail_x15_r0_body.st96.S3.tab.length - PRE_first_tail_x15_r0_body.st96.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged96`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap96 : PRE_first_tail_x15_r0_body.s855.heap = PRE_first_tail_x15_r0_body.st96.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext96 : PRE_first_tail_x15_r0_body.s855.next = PRE_first_tail_x15_r0_body.st96.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl96 : PRE_first_tail_x15_r0_body.s855.ctl = PRE_first_tail_x15_r0_body.st96.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack96 : PRE_first_tail_x15_r0_body.s855.stack = PRE_first_tail_x15_r0_body.st96.s3.stack ++ PRE_first_tail_x15_r0_body.s854.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs96 : PRE_first_tail_x15_r0_body.s855.jobs = PRE_first_tail_x15_r0_body.st96.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi96 : PRE_first_tail_x15_r0_body.s855.ffi = PRE_first_tail_x15_r0_body.st96.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace96 : PRE_first_tail_x15_r0_body.s855.trace = PRE_first_tail_x15_r0_body.st96.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores96 : PRE_first_tail_x15_r0_body.s855.stores = PRE_first_tail_x15_r0_body.st96.s3.stores

end Host.Load.Run.Tpl
