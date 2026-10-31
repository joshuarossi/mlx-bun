import host.sim.template.a4pre_first_tail_x15_r0_body.H52
import host.sim.template.a4pre_first_tail_x15_r0_body.st174.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 174 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g174__g175` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1684`, the merged state `PRE_first_tail_x15_r0_body.s1685`,
the site template `PRE_first_tail_x15_r0_body.st174` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1686`: the merge.
The footprint's facts are in `SiteF174`, the compaction's in `SiteC174`, `SiteK174`, `SiteNa174`, `SiteNb174`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso174 : PRE_first_tail_x15_r0_body.st174.s0 = { PRE_first_tail_x15_r0_body.s1684 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs174 : List Frame := PRE_first_tail_x15_r0_body.s1684.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_174 : PRE_first_tail_x15_r0_body.S1684.tab.length = 7523
kernel_rfl PRE_first_tail_x15_r0_body.tab0_174 : PRE_first_tail_x15_r0_body.st174.S0.tab = PRE_first_tail_x15_r0_body.S1684.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws174 : List Nat := [3930, 3931, 3932, 3933, 3934, 3935, 3936, 3937, 3938, 3939, 3940, 3941, 3942, 3943, 3944, 3945, 3946, 3947, 3948, 3949, 3950, 3951, 3952, 3953, 3954, 3955, 3956, 3957, 3958, 3959, 3960]
kernel_rfl PRE_first_tail_x15_r0_body.fresh174 : (PRE_first_tail_x15_r0_body.S1684.tab.all fun e => PRE_first_tail_x15_r0_body.ws174.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1684.oracle.all fun q => PRE_first_tail_x15_r0_body.ws174.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab174 : PRE_first_tail_x15_r0_body.S1685.tab = PRE_first_tail_x15_r0_body.S1684.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws174
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen174 : PRE_first_tail_x15_r0_body.st174.S5.tab.length - PRE_first_tail_x15_r0_body.st174.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged174`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap174 : PRE_first_tail_x15_r0_body.s1685.heap = PRE_first_tail_x15_r0_body.st174.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext174 : PRE_first_tail_x15_r0_body.s1685.next = PRE_first_tail_x15_r0_body.st174.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl174 : PRE_first_tail_x15_r0_body.s1685.ctl = PRE_first_tail_x15_r0_body.st174.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack174 : PRE_first_tail_x15_r0_body.s1685.stack = PRE_first_tail_x15_r0_body.st174.s5.stack ++ PRE_first_tail_x15_r0_body.s1684.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs174 : PRE_first_tail_x15_r0_body.s1685.jobs = PRE_first_tail_x15_r0_body.st174.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi174 : PRE_first_tail_x15_r0_body.s1685.ffi = PRE_first_tail_x15_r0_body.st174.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace174 : PRE_first_tail_x15_r0_body.s1685.trace = PRE_first_tail_x15_r0_body.st174.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores174 : PRE_first_tail_x15_r0_body.s1685.stores = PRE_first_tail_x15_r0_body.st174.s5.stores

end Host.Load.Run.Tpl
