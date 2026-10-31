import host.sim.template.a4pre_first_tail_x15_r0_body.H27
import host.sim.template.a4pre_first_tail_x15_r0_body.st99.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 99 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g99__g100` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s881`, the merged state `PRE_first_tail_x15_r0_body.s882`,
the site template `PRE_first_tail_x15_r0_body.st99` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s883`: the merge.
The footprint's facts are in `SiteF99`, the compaction's in `SiteC99`, `SiteK99`, `SiteNa99`, `SiteNb99`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso99 : PRE_first_tail_x15_r0_body.st99.s0 = { PRE_first_tail_x15_r0_body.s881 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs99 : List Frame := PRE_first_tail_x15_r0_body.s881.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_99 : PRE_first_tail_x15_r0_body.S881.tab.length = 4316
kernel_rfl PRE_first_tail_x15_r0_body.tab0_99 : PRE_first_tail_x15_r0_body.st99.S0.tab = PRE_first_tail_x15_r0_body.S881.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws99 : List Nat := [2658, 2659, 2660, 2661, 2662, 2663, 2664, 2665, 2666, 2667, 2668, 2669, 2670, 2671, 2672, 2673, 2674, 2675, 2676, 2677, 2678, 2679, 2680, 2681, 2682, 2683, 2684, 2685, 2686, 2687, 2688]
kernel_rfl PRE_first_tail_x15_r0_body.fresh99 : (PRE_first_tail_x15_r0_body.S881.tab.all fun e => PRE_first_tail_x15_r0_body.ws99.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S881.oracle.all fun q => PRE_first_tail_x15_r0_body.ws99.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab99 : PRE_first_tail_x15_r0_body.S882.tab = PRE_first_tail_x15_r0_body.S881.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws99
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen99 : PRE_first_tail_x15_r0_body.st99.S3.tab.length - PRE_first_tail_x15_r0_body.st99.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged99`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap99 : PRE_first_tail_x15_r0_body.s882.heap = PRE_first_tail_x15_r0_body.st99.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext99 : PRE_first_tail_x15_r0_body.s882.next = PRE_first_tail_x15_r0_body.st99.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl99 : PRE_first_tail_x15_r0_body.s882.ctl = PRE_first_tail_x15_r0_body.st99.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack99 : PRE_first_tail_x15_r0_body.s882.stack = PRE_first_tail_x15_r0_body.st99.s3.stack ++ PRE_first_tail_x15_r0_body.s881.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs99 : PRE_first_tail_x15_r0_body.s882.jobs = PRE_first_tail_x15_r0_body.st99.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi99 : PRE_first_tail_x15_r0_body.s882.ffi = PRE_first_tail_x15_r0_body.st99.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace99 : PRE_first_tail_x15_r0_body.s882.trace = PRE_first_tail_x15_r0_body.st99.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores99 : PRE_first_tail_x15_r0_body.s882.stores = PRE_first_tail_x15_r0_body.st99.s3.stores

end Host.Load.Run.Tpl
