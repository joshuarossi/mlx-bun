import host.sim.template.a4pre_first_tail_x15_r0_body.H30
import host.sim.template.a4pre_first_tail_x15_r0_body.st108.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 108 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g108__g109` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s959`, the merged state `PRE_first_tail_x15_r0_body.s960`,
the site template `PRE_first_tail_x15_r0_body.st108` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s961`: the merge.
The footprint's facts are in `SiteF108`, the compaction's in `SiteC108`, `SiteK108`, `SiteNa108`, `SiteNb108`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso108 : PRE_first_tail_x15_r0_body.st108.s0 = { PRE_first_tail_x15_r0_body.s959 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs108 : List Frame := PRE_first_tail_x15_r0_body.s959.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_108 : PRE_first_tail_x15_r0_body.S959.tab.length = 4700
kernel_rfl PRE_first_tail_x15_r0_body.tab0_108 : PRE_first_tail_x15_r0_body.st108.S0.tab = PRE_first_tail_x15_r0_body.S959.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws108 : List Nat := [2803, 2804, 2805, 2806, 2807, 2808, 2809, 2810, 2811, 2812, 2813, 2814, 2815, 2816, 2817, 2818, 2819, 2820, 2821, 2822, 2823, 2824, 2825, 2826, 2827, 2828, 2829, 2830, 2831, 2832, 2833]
kernel_rfl PRE_first_tail_x15_r0_body.fresh108 : (PRE_first_tail_x15_r0_body.S959.tab.all fun e => PRE_first_tail_x15_r0_body.ws108.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S959.oracle.all fun q => PRE_first_tail_x15_r0_body.ws108.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab108 : PRE_first_tail_x15_r0_body.S960.tab = PRE_first_tail_x15_r0_body.S959.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws108
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen108 : PRE_first_tail_x15_r0_body.st108.S3.tab.length - PRE_first_tail_x15_r0_body.st108.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged108`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap108 : PRE_first_tail_x15_r0_body.s960.heap = PRE_first_tail_x15_r0_body.st108.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext108 : PRE_first_tail_x15_r0_body.s960.next = PRE_first_tail_x15_r0_body.st108.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl108 : PRE_first_tail_x15_r0_body.s960.ctl = PRE_first_tail_x15_r0_body.st108.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack108 : PRE_first_tail_x15_r0_body.s960.stack = PRE_first_tail_x15_r0_body.st108.s3.stack ++ PRE_first_tail_x15_r0_body.s959.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs108 : PRE_first_tail_x15_r0_body.s960.jobs = PRE_first_tail_x15_r0_body.st108.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi108 : PRE_first_tail_x15_r0_body.s960.ffi = PRE_first_tail_x15_r0_body.st108.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace108 : PRE_first_tail_x15_r0_body.s960.trace = PRE_first_tail_x15_r0_body.st108.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores108 : PRE_first_tail_x15_r0_body.s960.stores = PRE_first_tail_x15_r0_body.st108.s3.stores

end Host.Load.Run.Tpl
