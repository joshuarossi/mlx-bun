import host.sim.template.a4pre_first_tail_x15_r0_body.H47
import host.sim.template.a4pre_first_tail_x15_r0_body.st171.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 171 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g171__g172` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1511`, the merged state `PRE_first_tail_x15_r0_body.s1512`,
the site template `PRE_first_tail_x15_r0_body.st171` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1513`: the merge.
The footprint's facts are in `SiteF171`, the compaction's in `SiteC171`, `SiteK171`, `SiteNa171`, `SiteNb171`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso171 : PRE_first_tail_x15_r0_body.st171.s0 = { PRE_first_tail_x15_r0_body.s1511 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs171 : List Frame := PRE_first_tail_x15_r0_body.s1511.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_171 : PRE_first_tail_x15_r0_body.S1511.tab.length = 7394
kernel_rfl PRE_first_tail_x15_r0_body.tab0_171 : PRE_first_tail_x15_r0_body.st171.S0.tab = PRE_first_tail_x15_r0_body.S1511.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws171 : List Nat := [3870, 3871, 3872, 3873, 3874, 3875, 3876, 3877, 3878, 3879, 3880, 3881, 3882, 3883, 3884, 3885, 3886, 3887, 3888, 3889, 3890, 3891, 3892, 3893, 3894, 3895, 3896, 3897, 3898, 3899, 3900]
kernel_rfl PRE_first_tail_x15_r0_body.fresh171 : (PRE_first_tail_x15_r0_body.S1511.tab.all fun e => PRE_first_tail_x15_r0_body.ws171.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1511.oracle.all fun q => PRE_first_tail_x15_r0_body.ws171.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab171 : PRE_first_tail_x15_r0_body.S1512.tab = PRE_first_tail_x15_r0_body.S1511.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws171
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen171 : PRE_first_tail_x15_r0_body.st171.S3.tab.length - PRE_first_tail_x15_r0_body.st171.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged171`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap171 : PRE_first_tail_x15_r0_body.s1512.heap = PRE_first_tail_x15_r0_body.st171.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext171 : PRE_first_tail_x15_r0_body.s1512.next = PRE_first_tail_x15_r0_body.st171.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl171 : PRE_first_tail_x15_r0_body.s1512.ctl = PRE_first_tail_x15_r0_body.st171.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack171 : PRE_first_tail_x15_r0_body.s1512.stack = PRE_first_tail_x15_r0_body.st171.s3.stack ++ PRE_first_tail_x15_r0_body.s1511.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs171 : PRE_first_tail_x15_r0_body.s1512.jobs = PRE_first_tail_x15_r0_body.st171.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi171 : PRE_first_tail_x15_r0_body.s1512.ffi = PRE_first_tail_x15_r0_body.st171.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace171 : PRE_first_tail_x15_r0_body.s1512.trace = PRE_first_tail_x15_r0_body.st171.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores171 : PRE_first_tail_x15_r0_body.s1512.stores = PRE_first_tail_x15_r0_body.st171.s3.stores

end Host.Load.Run.Tpl
